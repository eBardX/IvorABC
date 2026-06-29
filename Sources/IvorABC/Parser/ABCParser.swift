// © 2026 John Gary Pusey (see LICENSE.md)

public import Foundation

private import XestiTools

/// A parser for ABC notation.
///
/// The parser derives its parse policy automatically from the declared
/// version in the input: strict when the file declares ABC 2.1 or later, loose
/// otherwise (including unversioned files). Use ``parseWithDiagnostics(_:)`` to
/// retrieve ``Diagnostic`` values emitted during loose recovery or for
/// deprecated forms accepted in all stances.
public struct ABCParser {

    // MARK: Public Initializers

    /// Creates a new ABC parser.
    public init() {
        self.tokenizer = ABCSymbolTokenizer(tracing: .silent)
    }

    // MARK: Private Instance Properties

    private let tokenizer: ABCSymbolTokenizer
}

// MARK: -

extension ABCParser {

    // MARK: Public Instance Methods

    /// Parses ABC notation data and returns the resulting tunebook.
    ///
    /// Any ``Diagnostic`` values generated during parsing are silently
    /// discarded. Use ``parseWithDiagnostics(_:)`` to retrieve them.
    ///
    /// - Parameter data: The ABC notation data to parse.
    ///
    /// - Returns:  The ``ABCTunebook`` parsed from `data`.
    ///
    /// - Throws:   ``Error`` if the data cannot be parsed.
    public func parse(_ data: Data) throws -> ABCTunebook {
        var diagnostics: [Diagnostic] = []

        return try _parse(data, &diagnostics)
    }

    /// Parses ABC notation data and returns the resulting tunebook along
    /// with any diagnostic messages produced during parsing.
    ///
    /// - Parameter data: The ABC notation data to parse.
    ///
    /// - Returns:  A tuple containing the ``ABCTunebook`` parsed from `data`
    ///             and an array of ``Diagnostic`` values describing any
    ///             recoveries or deprecated forms encountered.
    ///
    /// - Throws:   ``Error`` if the data cannot be parsed.
    public func parseWithDiagnostics(_ data: Data) throws -> (ABCTunebook, [Diagnostic]) {
        var diagnostics: [Diagnostic] = []

        let tunebook = try _parse(data, &diagnostics)

        return (tunebook, diagnostics)
    }

    // MARK: Private Type Properties

    private static let expectedBeginDirectivePrefix = "%%begin"
    private static let expectedDirectivePrefix      = "%%"
    private static let expectedEndDirectivePrefix   = "%%end"

    // MARK: Private Instance Methods

    private func _applyLine(_ line: Line,
                            inFileHeader: inout Bool,
                            context: inout Context) {
        switch line {
        case .empty:
            if inFileHeader {
                inFileHeader = false
                context.inTune = true
            } else {
                context.resetTuneScope()
            }

        case let .directive(directive):
            context.update(with: directive)

        default:
            break
        }
    }

    private func _isEndDirectiveLine(_ input: Substring,
                                     _ endDirective: String) -> Bool {
        guard input.hasPrefix(endDirective)
        else { return false }

        let rest = uncomment(input.dropFirst(endDirective.count))

        return rest.isEmpty || rest.allSatisfy { $0.isABCWhitespace }
    }

    private func _parse(_ data: Data,
                        _ diagnostics: inout [Diagnostic]) throws -> ABCTunebook {
        let (lines, version, preprocDiagnostics) = try preprocess(data)

        diagnostics.append(contentsOf: preprocDiagnostics)

        let policy = Policy(version: version)
        var context = Context()
        var inFileHeader = true

        var idx = lines.startIndex
        var restLines: [Line] = []

        while idx < lines.endIndex {
            let text = lines[idx]

            idx += 1

            if let (name, beginValue) = _parseBeginDirective(text) {
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
                else { throw Error.unmatchedBeginDirective(name.stringValue) }

                restLines.append(.directive(ABCDirective(name: name,
                                                         value: beginValue,
                                                         content: contentLines)))
                continue
            }

            //
            // If still in the file header and this line opens with a reference-
            // number field (X:), the file has no file header.  Switch to tune
            // scope before parsing so any definitions on this line land in the
            // per-tune store rather than the global one.
            //
            if inFileHeader, text.hasPrefix("X:") {
                inFileHeader = false
                context.inTune = true
            }

            do {
                guard let line = try _parseLine(text, policy, &context, &diagnostics)
                else { continue }

                _applyLine(line,
                           inFileHeader: &inFileHeader,
                           context: &context)

                restLines.append(line)
            } catch {
                if policy.mode == .loose {
                    diagnostics.append(.unrecognizedLine(String(text)))
                } else {
                    throw error
                }
            }
        }

        return try makeTunebook(version, policy, restLines, &diagnostics)
    }

    private func _parseBeginDirective(_ input: Substring) -> (name: ABCDirective.Name, value: String)? {
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

    private func _parseDirective(_ tidyInput: Substring) throws -> ABCDirective {
        let result = tidyInput.splitBeforeFirst { $0.isABCWhitespace }

        guard let name = parseDirectiveName(result.head)
        else { throw Error.invalidDirective(Self.expectedDirectivePrefix + tidyInput) }

        let value = String(trimPrefix(result.tail ?? ""))

        return ABCDirective(name: name,
                            value: value)
    }

    private func _parseDirectiveLine(_ input: Substring) throws -> Line? {
        let prefix = Self.expectedDirectivePrefix

        guard input.hasPrefix(prefix)
        else { return nil }

        let tidyInput = trimSuffix(uncomment(input.dropFirst(prefix.count)))

        let directive = try _parseDirective(tidyInput)

        return .directive(directive)
    }

    private func _parseEmptyLine(_ input: Substring) -> Line? {
        guard input.isEmpty || input.allSatisfy({ $0.isABCWhitespace })
        else { return nil }

        return .empty
    }

    private func _parseFieldLine(_ input: Substring,
                                 _ policy: Policy,
                                 _ context: inout Context,
                                 _ diagnostics: inout [Diagnostic]) throws -> Line? {
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
            else { throw Error.invalidField(false, tidyInput) }

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
            return try _parseInstructionLine(input)
        }

        let tidyInput = trimSuffix(uncomment(input))

        do {
            let field = try parseField(tidyInput)

            context.update(with: field)

            return .field(field)
        } catch let Error.invalidTempo(vtext) {
            //
            // Q:C=rate / Q:Cn=rate form: "C" stands for the active default
            // note length (L:).  Try this before the bare-integer path so
            // Q:C=120 is not mistaken for an invalid bare integer.  Both
            // deprecated forms are accepted in all stances and diagnosed.
            //
            if let tempo = parseLegacyBeatTempo(trim(vtext),
                                                baseDuration: context.baseDuration) {
                let field = ABCField.tempo(tempo)

                diagnostics.append(.deprecatedTempo(tempo))
                context.update(with: field)

                return .field(field)
            }

            //
            // Bare-integer tempo (e.g. Q:120): deprecated in ABC 2.0+, but
            // accepted in all stances.  Represented identically to Q:C=rate
            // so Phase 4 normalization is uniform.
            //
            if let rate = UInt(trim(vtext)), rate > 0 {
                let tempo = ABCTempo(durations: [context.baseDuration],
                                     rate: rate,
                                     text: nil,
                                     beatMultiplier: 1).require()
                let field = ABCField.tempo(tempo)

                diagnostics.append(.deprecatedTempo(tempo))
                context.update(with: field)

                return .field(field)
            }

            throw Error.invalidTempo(vtext)
        }
    }

    private func _parseInstructionLine(_ input: Substring) throws -> Line {
        let tidyInput = trimSuffix(uncomment(input.dropFirst(2)))
        let result = tidyInput.splitBeforeFirst { $0.isABCWhitespace }

        guard let name = parseDirectiveName(result.head)
        else { throw Error.invalidDirective(input) }

        let value = String(trimPrefix(result.tail ?? ""))

        return .directive(ABCDirective(name: name, value: value))
    }

    private func _parseLine(_ input: Substring,
                            _ policy: Policy,
                            _ context: inout Context,
                            _ diagnostics: inout [Diagnostic]) throws -> Line? {
        try _parseEmptyLine(input)
        ?? _parseDirectiveLine(input)
        ?? _parseFieldLine(input, policy, &context, &diagnostics)
        ?? _parseSymbolsLine(input, &context)
    }

    private func _parseSymbolsLine(_ input: Substring,
                                   _ context: inout Context) throws -> Line? {
        let tokens: [ABCSymbolTokenizer.Token]

        do {
            tokens = try tokenizer.tokenize(String(input))
        } catch {
            throw Error.invalidSymbolLine(input)
        }

        var matcher = ABCSymbolMatcher(tokens: tokens)

        let symbols: [ABCSymbol]

        do {
            symbols = try matcher.matchSymbols(&context)
        } catch let error as Error {
            throw error
        } catch {
            throw Error.invalidSymbols(input)
        }

        guard !symbols.isEmpty
        else { return nil }

        return .symbols(symbols)
    }
}
