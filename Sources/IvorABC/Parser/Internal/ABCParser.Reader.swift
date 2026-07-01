// © 2026 John Gary Pusey (see LICENSE.md)

internal import Foundation

private import XestiTools

extension ABCParser {

    // MARK: Internal Nested Types

    internal struct Reader {

        // MARK: Internal Initializers

        /// Creates a new ABC parser.
        internal init(data: Data) {
            self.data = data
            self.diagnostics = []
            self.tokenizer = ABCSymbolTokenizer(tracing: .silent)
        }

        // MARK: Private Instance Properties

        private let data: Data
        private let tokenizer: ABCSymbolTokenizer

        private var diagnostics: [Diagnostic]
    }
}

// MARK: -

extension ABCParser.Reader {

    // MARK: Internal Instance Methods

    internal mutating func readTunebook() throws -> (ABCTunebook, [ABCParser.Diagnostic]) {
        let tunebook = try _readTunebook()

        return (tunebook, diagnostics)
    }

    // MARK: Private Type Properties

    private static let expectedBeginDirectivePrefix = "%%begin"
    private static let expectedDirectivePrefix      = "%%"
    private static let expectedEndDirectivePrefix   = "%%end"

    // MARK: Private Instance Methods

    private func _isEndDirectiveLine(_ input: Substring,
                                     _ endDirective: String) -> Bool {
        guard input.hasPrefix(endDirective)
        else { return false }

        let rest = uncomment(input.dropFirst(endDirective.count))

        return rest.isEmpty || rest.allSatisfy { $0.isABCWhitespace }
    }

    private func _readBeginDirective(_ input: Substring) -> (name: ABCDirective.Name, value: String)? {
        let beginPrefix = Self.expectedBeginDirectivePrefix

        guard input.hasPrefix(beginPrefix)
        else { return nil }

        let afterBegin = uncomment(input.dropFirst(beginPrefix.count))
        let nameInput = afterBegin.prefix { !$0.isABCWhitespace }

        guard let name = parseDirectiveName(nameInput)
        else { return nil }

        let value = String(trimPrefix(afterBegin.dropFirst(nameInput.count)))

        return (name, value)
    }

    private func _readDirective(_ tidyInput: Substring) throws -> ABCDirective {
        let result = tidyInput.splitBeforeFirst { $0.isABCWhitespace }

        guard let name = parseDirectiveName(result.head)
        else { throw ABCParser.Error.invalidDirective(Self.expectedDirectivePrefix + tidyInput) }

        let value = String(trimPrefix(result.tail ?? ""))

        return ABCDirective(name: name,
                            value: value)
    }

    private func _readDirectiveLine(_ input: Substring) throws -> ABCParser.Line? {
        let prefix = Self.expectedDirectivePrefix

        guard input.hasPrefix(prefix)
        else { return nil }

        let tidyInput = trimSuffix(uncomment(input.dropFirst(prefix.count)))

        let directive = try _readDirective(tidyInput)

        return .directive(directive)
    }

    private func _readEmptyLine(_ input: Substring) -> ABCParser.Line? {
        guard input.isEmpty || input.allSatisfy({ $0.isABCWhitespace })
        else { return nil }

        return .empty
    }

    private mutating func _readFieldLine(_ input: Substring,
                                         _ policy: ABCParser.Policy) throws -> ABCParser.Line? {
        guard let letter = input.first,
              letter.isABCLetter || letter == "+",
              input.dropFirst().first == ":"
        else { return nil }

        if letter == "+" {
            let tidyInput = trimSuffix(uncomment(input))
            let vtext = trim(tidyInput.dropFirst(2))

            return .continuation(normalize(vtext))
        }

        //
        // E: (elemskip) is deprecated with no 2.x equivalent; accepted in
        // loose mode, flagged via deprecatedField diagnostic.
        //
        if policy.mode == .loose, letter == "E" {
            let tidyInput = trimSuffix(uncomment(input.dropFirst(2)))

            guard let elemskip = parseElemskip(tidyInput)
            else { throw ABCParser.Error.invalidField(false, tidyInput) }

            let field = ABCField.elemskip(elemskip)

            diagnostics.append(.deprecatedField(field))

            return .field(field)
        }

        //
        // I: is free-text "information" in ABC 1.6; in all other versions
        // (including unversioned files) it is a directive instruction.
        //
        if policy.iFieldIsFreeText, letter == "I" {
            let tidyInput = trimSuffix(uncomment(input.dropFirst(2)))

            return try .field(.information(parseText(tidyInput)))
        }

        if letter == "I" {
            return try _readInstructionLine(input)
        }

        let tidyInput = trimSuffix(uncomment(input))

        do {
            return try .field(parseField(tidyInput))
        } catch let ABCParser.Error.invalidTempo(vtext) {
            //
            // Q:C=rate / Q:Cn=rate form: "C" stands for the unit note length
            // (L:).  Try this before the bare-integer path so Q:C=120 is not
            // mistaken for an invalid bare integer.  Both deprecated forms are
            // accepted in all stances and diagnosed; the beat is left unresolved
            // for ``ABCNormalizer`` to resolve against the active L:.
            //
            if let tempo = parseLegacyBeatTempo(trim(vtext)) {
                diagnostics.append(.deprecatedTempo(tempo))

                return .field(.tempo(tempo))
            }

            //
            // Bare-integer tempo (e.g. Q:120): deprecated in ABC 2.0+, but
            // accepted in all stances.  Represented identically to Q:C=rate
            // so normalization is uniform.
            //
            if let rate = UInt(trim(vtext)), rate > 0 {
                let tempo = ABCTempo(lengths: [],
                                     rate: rate,
                                     text: nil,
                                     beatMultiplier: 1).require()

                diagnostics.append(.deprecatedTempo(tempo))

                return .field(.tempo(tempo))
            }

            throw ABCParser.Error.invalidTempo(vtext)
        }
    }

    private func _readInstructionLine(_ input: Substring) throws -> ABCParser.Line {
        let tidyInput = trimSuffix(uncomment(input.dropFirst(2)))
        let result = tidyInput.splitBeforeFirst { $0.isABCWhitespace }

        guard let name = parseDirectiveName(result.head)
        else { throw ABCParser.Error.invalidDirective(input) }

        let value = String(trimPrefix(result.tail ?? ""))

        return .directive(ABCDirective(name: name, value: value))
    }

    private mutating func _readLine(_ input: Substring,
                                    _ policy: ABCParser.Policy) throws -> ABCParser.Line? {
        try _readEmptyLine(input)
        ?? _readDirectiveLine(input)
        ?? _readFieldLine(input, policy)
        ?? _readSymbolsLine(input)
    }

    private func _readSymbolsLine(_ input: Substring) throws -> ABCParser.Line? {
        let tokens: [ABCSymbolTokenizer.Token]

        do {
            tokens = try tokenizer.tokenize(String(input))
        } catch {
            throw ABCParser.Error.invalidSymbolLine(input)
        }

        var matcher = ABCSymbolMatcher(tokens: tokens)

        let symbols: [ABCSymbol]

        do {
            symbols = try matcher.matchSymbols()
        } catch let error as ABCParser.Error {
            throw error
        } catch {
            throw ABCParser.Error.invalidSymbols(input)
        }

        guard !symbols.isEmpty
        else { return nil }

        return .symbols(symbols)
    }

    private mutating func _readTunebook() throws -> ABCTunebook {
        let (lines, version, ppDiagnostics) = try preprocess(data)

        diagnostics.append(contentsOf: ppDiagnostics)

        let policy = ABCParser.Policy(version: version)
        var idx = lines.startIndex
        var restLines: [ABCParser.Line] = []

        while idx < lines.endIndex {
            let text = lines[idx]

            idx += 1

            if let (name, beginValue) = _readBeginDirective(text) {
                let endDirective = Self.expectedEndDirectivePrefix + name.stringValue

                var contentLines: [String] = []
                var foundEnd = false

                while idx < lines.endIndex {
                    let contentText = lines[idx]

                    idx += 1

                    if _isEndDirectiveLine(contentText, endDirective) {
                        foundEnd = true
                        break
                    }

                    contentLines.append(String(contentText))
                }

                guard foundEnd
                else { throw ABCParser.Error.unmatchedBeginDirective(name.stringValue) }

                restLines.append(.directive(ABCDirective(name: name,
                                                         value: beginValue,
                                                         content: contentLines)))
                continue
            }

            do {
                guard let line = try _readLine(text, policy)
                else { continue }

                restLines.append(line)
            } catch {
                if policy.mode == .loose {
                    diagnostics.append(.unrecognizedLine(String(text)))
                } else {
                    throw error
                }
            }
        }

        return try makeTunebook(version, policy, restLines)
    }
}
