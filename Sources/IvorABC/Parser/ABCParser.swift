// © 2026 John Gary Pusey (see LICENSE.md)

public import Foundation

private import XestiTools

/// A parser for ABC notation.
///
/// By default the parser operates in ``Strictness/strict`` mode, which requires
/// a valid `%abc-M.m` file identifier (where `M.m` is a known supported
/// version — currently 1.6, 2.0, or 2.1) on the first line and throws
/// ``Error`` on any deviation from the standard. Pass `strictness: .lenient`
/// to ``init(strictness:)`` for a mode that tolerates common real-world
/// deviations and emits ``Diagnostic`` values in place of errors.
public struct ABCParser {

    // MARK: Public Initializers

    /// Creates a new ABC parser with the specified strictness.
    ///
    /// - Parameter strictness: The strictness mode for this parser. Pass
    ///                         ``Strictness/strict`` (the default) to require
    ///                         full ABC 2.1 conformance, or
    ///                         ``Strictness/lenient`` to tolerate real-world
    ///                         deviations with ``Diagnostic`` recovery
    ///                         messages.
    public init(strictness: Strictness = .strict) {
        self.strictness = strictness
        self.tokenizer = ABCSymbolTokenizer(tracing: .silent)
    }

    // MARK: Private Instance Properties

    let strictness: Strictness
    private let tokenizer: ABCSymbolTokenizer
}

// MARK: -

extension ABCParser {

    // MARK: Public Instance Methods

    /// Parses ABC notation data and returns the resulting tunebook.
    ///
    /// Any ``Diagnostic`` values generated in ``Strictness/lenient`` mode
    /// are silently discarded. Use ``parseWithDiagnostics(_:)`` to retrieve
    /// them.
    ///
    /// - Parameter data: The UTF-8 encoded ABC notation data to parse.
    ///
    /// - Returns:  The ``ABCTunebook`` parsed from `data`.
    ///
    /// - Throws:   ``Error`` if the data cannot be parsed.
    public func parse(_ data: Data) throws -> ABCTunebook {
        var diagnostics: [Diagnostic] = []

        return try _parse(data, &diagnostics)
    }

    /// Parses ABC notation data and returns the resulting tunebook along
    /// with any diagnostic messages produced during lenient recovery.
    ///
    /// In ``Strictness/strict`` mode, the returned diagnostics array is always
    /// empty.
    ///
    /// - Parameter data: The UTF-8 encoded ABC notation data to parse.
    ///
    /// - Returns:  A tuple containing the ``ABCTunebook`` parsed from `data`
    ///             and an array of ``Diagnostic`` values describing any
    ///             recoveries performed.
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
    private static let expectedFileIDPrefix         = "%abc"

    // MARK: Private Instance Methods

    private func _applyLine(_ line: Line,
                            inFileHeader: inout Bool,
                            context: inout ABCParseContext) {
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
        let (lines, optVersion, preprocDiagnostics) = try preprocess(data, strictness: strictness)

        diagnostics.append(contentsOf: preprocDiagnostics)

        // Phase 1 bridge: nil → .current (removed in Phase 2)
        let version = optVersion ?? .current

        var context = ABCParseContext()
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
                guard let line = try _parseLine(text, version, &context, &diagnostics)
                else { continue }

                _applyLine(line,
                           inFileHeader: &inFileHeader,
                           context: &context)

                restLines.append(line)
            } catch {
                if strictness == .lenient {
                    diagnostics.append(.unrecognizedLine(String(text)))
                } else {
                    throw error
                }
            }
        }

        return try makeTunebook(version, restLines, &diagnostics)
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

    // swiftlint:disable:next cyclomatic_complexity
    private func _parseFieldLine(_ input: Substring,
                                 _ version: ABCVersion,
                                 _ context: inout ABCParseContext,
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

        let isVersion16 = (version == ABCVersion(major: 1,
                                                 minor: 6))

        //
        // E: (elemskip) is a 1.6-only field with no 2.x equivalent.
        // I: is free-text "information" in 1.6; in 2.x it is an instruction.
        //
        if isVersion16 {
            if letter == "E" {
                let tidyInput = trimSuffix(uncomment(input.dropFirst(2)))

                guard let elemskip = parseElemskip(tidyInput)
                else { throw Error.invalidField(false, tidyInput) }

                return .field(.elemskip(elemskip))
            }

            if letter == "I" {
                let tidyInput = trimSuffix(uncomment(input.dropFirst(2)))

                return try .field(.information(parseText(tidyInput)))
            }
        }

        if letter == "I" {
            return try _parseInstructionLine(input)
        }

        let tidyInput = trimSuffix(uncomment(input))

        do {
            let field = try parseField(tidyInput)

            context.update(with: field)

            return .field(field)
        } catch let Error.invalidTempo(vtext) where strictness == .lenient || version != ABCVersion.current {
            //
            // ABC 1.6 Q:C=rate / Q:Cn=rate form: "C" stands for the active
            // default note length (L:).  Try this before the bare-integer
            // path so Q:C=120 is not mistaken for "invalid bare integer".
            //
            if version == ABCVersion(major: 1,
                                     minor: 6) {
                if let tempo = parseLegacyBeatTempo(trim(vtext),
                                                    baseDuration: context.baseDuration) {
                    let field = ABCField.tempo(tempo)

                    context.update(with: field)

                    return .field(field)
                }
            }

            //
            // Accept the bare-integer tempo form (e.g. "Q:120").
            // It is deprecated in ABC 2.0 and later, but the spec says it
            // remains parseable. In lenient mode it is also flagged as a
            // diagnostic; in strict mode it is accepted silently for known
            // older versions.
            //
            if let rate = UInt(trim(vtext)), rate > 0 {
                let field = ABCField.tempo(ABCTempo(durations: [],
                                                    rate: rate,
                                                    text: nil).require())

                if strictness == .lenient {
                    diagnostics.append(.bareTempoRate(rate))
                }

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

    private func _parseFileID(_ tidyInput: Substring) throws -> ABCFileID {
        guard tidyInput.first == "-"
        else { throw Error.invalidFileID(Self.expectedFileIDPrefix + tidyInput) }

        let version = try _parseVersion(tidyInput.dropFirst())

        return ABCFileID(version: version)
    }

    private func _parseFileIDLine(_ input: Substring) throws -> Line? {
        let prefix = Self.expectedFileIDPrefix

        guard input.hasPrefix(prefix)
        else { return nil }

        let tidyInput = trimSuffix(uncomment(input.dropFirst(prefix.count)))

        let fileID = try _parseFileID(tidyInput)

        return .fileID(fileID)
    }

    private func _parseLine(_ input: Substring,
                            _ version: ABCVersion,
                            _ context: inout ABCParseContext,
                            _ diagnostics: inout [Diagnostic]) throws -> Line? {
        try _parseEmptyLine(input)
        ?? _parseFileIDLine(input)
        ?? _parseDirectiveLine(input)
        ?? _parseFieldLine(input, version, &context, &diagnostics)
        ?? _parseSymbolsLine(input, &context)
    }

    private func _parseSymbolsLine(_ input: Substring,
                                   _ context: inout ABCParseContext) throws -> Line? {
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

    private func _parseVersion(_ tidyInput: Substring) throws -> ABCVersion {
        let parts = tidyInput.split(separator: ".",
                                    maxSplits: 1,
                                    omittingEmptySubsequences: false)

        guard parts.count == 2,
              let major = UInt(parts[0]),
              let minor = UInt(parts[1])
        else { throw Error.invalidVersion(tidyInput) }

        return ABCVersion(major: major,
                          minor: minor)
    }
}
