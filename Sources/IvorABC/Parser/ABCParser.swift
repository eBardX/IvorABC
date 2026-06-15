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

    private let strictness: Strictness
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

    private func _isEndDirectiveLine(_ input: Substring,
                                     _ endDirective: String) -> Bool {
        guard input.hasPrefix(endDirective)
        else { return false }

        let rest = uncomment(input.dropFirst(endDirective.count))

        return rest.isEmpty || rest.allSatisfy { $0.isABCWhitespace }
    }

    private func _joinContinuationLines(_ rawLines: [Substring]) -> [Substring] {
        var result: [Substring] = []
        var pending: String?

        for line in rawLines {
            let stripped = String(trimSuffix(uncomment(line)))

            //
            // Field lines (letter: or +:) are never folded into a pending music
            // accumulation. When a field line appears in the middle of a music
            // continuation (e.g. a w: lyric or M: meter change between two
            // backslash-continued music lines), flush the pending music first,
            // then emit the field line on its own — stripping any trailing \
            // that was acting as the continuation signal rather than field content.
            //
            let isFieldLine = (stripped.first?.isABCLetter == true || stripped.first == "+")
                              && stripped.dropFirst().first == ":"

            if isFieldLine {
                if let buf = pending {
                    result.append(Substring(buf))
                    pending = nil
                }

                let fieldText = stripped.hasSuffix("\\")
                                ? String(stripped.dropLast())
                                : String(stripped)

                result.append(Substring(fieldText))
            } else if stripped.hasSuffix("\\") {
                pending = (pending ?? "") + stripped.dropLast()
            } else if let buf = pending {
                result.append(Substring(buf + String(line)))
                pending = nil
            } else {
                result.append(line)
            }
        }

        if let buf = pending {
            result.append(Substring(buf))
        }

        return result
    }

    private func _makeTunebook(_ version: ABCVersion,
                               _ restLines: [Line],
                               _ diagnostics: inout [Diagnostic]) throws -> ABCTunebook {
        var lineReader = SequenceReader(restLines)

        let headers = _processHeaderLines(&lineReader)
        let tunes = try _makeTunes(&lineReader, &diagnostics)

        return ABCTunebook(version: version,
                           headers: headers,
                           tunes: tunes)
    }

    private func _makeTunes(_ reader: inout SequenceReader<[Line]>,
                            _ diagnostics: inout [Diagnostic]) throws -> [ABCTune] {
        var tunes: [ABCTune] = []

        while let tune = try _processTuneLines(&reader, &diagnostics) {
            tunes.append(tune)
        }

        return tunes
    }

    private func _mergeContinuation(_ tidyInput: String,
                                    _ field: ABCField) -> ABCField? {
        func joinText(_ text: ABCText) -> ABCText {
            let tmpString = normalize(Substring(tidyInput))

            var stringValue = text.stringValue

            if !stringValue.isEmpty {
                stringValue += " "
            }

            stringValue += tmpString

            return ABCText(stringValue: stringValue)!   // swiftlint:disable:this force_unwrapping
        }

        switch field {
        case let .area(text):
            return .area(joinText(text))

        case let .book(text):
            return .book(joinText(text))

        case let .composer(text):
            return .composer(joinText(text))

        case let .discography(text):
            return .discography(joinText(text))

        case let .fileURL(text):
            return .fileURL(joinText(text))

        case let .group(text):
            return .group(joinText(text))

        case let .history(text):
            return .history(joinText(text))

        case let .lyrics(text):
            return .lyrics(joinText(text))

        case let .notes(text):
            return .notes(joinText(text))

        case let .origin(text):
            return .origin(joinText(text))

        case let .remark(text):
            return .remark(joinText(text))

        case let .rhythm(text):
            return .rhythm(joinText(text))

        case let .source(text):
            return .source(joinText(text))

        case let .title(text):
            return .title(joinText(text))

        case let .transcription(text):
            return .transcription(joinText(text))

        default:
            return nil
        }
    }

    private func _parse(_ data: Data,
                        _ diagnostics: inout [Diagnostic]) throws -> ABCTunebook {
        guard let input = String(data: data,
                                 encoding: .utf8)
        else { throw Error.dataConversionFailed }

        let rawLines = input.split(separator: /\n|(?:\r\n?)/,
                                   omittingEmptySubsequences: false)
        let lines = _joinContinuationLines(rawLines)

        var context = ABCParseContext()

        let (version, bodyLines) = try _resolveFileID(lines, &diagnostics)

        var idx = bodyLines.startIndex
        var restLines: [Line] = []

        while idx < bodyLines.endIndex {
            let text = bodyLines[idx]

            idx += 1

            if let (name, beginValue) = _parseBeginDirective(text) {
                let endDirective = Self.expectedEndDirectivePrefix + name

                var contentLines: [String] = []
                var foundEnd = false

                while idx < bodyLines.endIndex {
                    let contentText = bodyLines[idx]

                    idx += 1

                    if _isEndDirectiveLine(contentText, endDirective) {
                        foundEnd = true
                        break
                    }

                    contentLines.append(String(contentText))
                }

                guard foundEnd
                else { throw Error.unmatchedBeginDirective(name) }

                restLines.append(.directive(ABCDirective(name: name,
                                                         value: beginValue,
                                                         content: contentLines)))
                continue
            }

            do {
                guard let line = try _parseLine(text, version, &context, &diagnostics)
                else { continue }

                if case let .directive(directive) = line {
                    context.update(with: directive)
                }

                restLines.append(line)
            } catch {
                if strictness == .lenient {
                    diagnostics.append(.unrecognizedLine(String(text)))
                } else {
                    throw error
                }
            }
        }

        return try _makeTunebook(version, restLines, &diagnostics)
    }

    private func _parseBeginDirective(_ input: Substring) -> (name: String, value: String)? {
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
                                                    text: nil))

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

    private func _processHeaderLine(_ line: Line) -> (header: ABCHeader?, empty: Bool) {
        switch line {
        case let .directive(directive):
            (.directive(directive), false)

        case .empty:
            (nil, true)

        case let .field(field) where field.isValidInFileHeader:
            (.field(field), false)

        default:
            (nil, false)
        }
    }

    private func _processHeaderLines(_ reader: inout SequenceReader<[Line]>) -> [ABCHeader] {
        var headers: [ABCHeader] = []

        while let line = reader.peek() {
            if case let .continuation(text) = line {
                if let lastIndex = headers.indices.last,
                   case let .field(field) = headers[lastIndex],
                   let merged = _mergeContinuation(text, field) {
                    headers[lastIndex] = .field(merged)
                }

                reader.skip()
                continue
            }

            let result = _processHeaderLine(line)

            if result.empty {
                reader.skip()
                break
            }

            guard let header = result.header
            else { break }

            headers.append(header)

            reader.skip()
        }

        return headers
    }

    private func _processTuneLine(_ line: Line,
                                  _ diagnostics: inout [Diagnostic]) throws -> (entry: ABCEntry?, empty: Bool) {
        switch line {
        case let .directive(directive):
            return (.directive(directive), false)

        case .empty:
            return (nil, true)

        case let .field(field):
            if field.isValidInTuneHeader || field.isValidInTuneBody {
                return (.field(field), false)
            } else if strictness == .lenient {
                diagnostics.append(.misplacedField(field))
                return (nil, false)
            } else {
                throw Error.misplacedField(field)
            }

        case let .symbols(symbols):
            return (.symbols(symbols), false)

        default:
            return (nil, false)
        }
    }

    private func _processTuneLines(_ reader: inout SequenceReader<[Line]>,
                                   _ diagnostics: inout [Diagnostic]) throws -> ABCTune? {
        // Skip any leading empty lines before the tune content starts (e.g., after
        // multiple blank lines or skipped prose in lenient mode).
        while let line = reader.peek(), case .empty = line {
            reader.skip()
        }

        var entries: [ABCEntry] = []

        while let line = reader.peek() {
            if case let .continuation(text) = line {
                if let lastIndex = entries.indices.last,
                   case let .field(field) = entries[lastIndex],
                   let merged = _mergeContinuation(text, field) {
                    entries[lastIndex] = .field(merged)
                }

                reader.skip()
                continue
            }

            let result = try _processTuneLine(line, &diagnostics)

            if result.empty {
                reader.skip()
                break
            }

            guard let entry = result.entry
            else { break }

            entries.append(entry)

            reader.skip()
        }

        guard !entries.isEmpty
        else { return nil }

        return ABCTune(entries: entries)
    }

    private func _resolveFileID(_ lines: [Substring],
                                _ diagnostics: inout [Diagnostic]) throws -> (ABCVersion, [Substring]) {
        var version = ABCVersion.current

        guard let firstText = lines.first,
              firstText.hasPrefix(Self.expectedFileIDPrefix)
        else {
            //
            // No "%abc" prefix on the first line.  In strict mode the file ID is
            // required; in lenient mode assume version 2.1 and include all lines
            // in the body.
            //
            if strictness == .strict {
                throw Error.missingFileID
            }

            diagnostics.append(.missingFileID)

            return (version, Array(lines))
        }

        //
        // First line starts with "%abc" — consume it regardless of validity.
        //
        do {
            if let line = try _parseFileIDLine(firstText),
               case let .fileID(fileID) = line {
                let v = fileID.version

                if !ABCVersion.supported.contains(v) {
                    if strictness == .strict {
                        throw Error.unsupportedVersion(v)
                    }

                    diagnostics.append(.unsupportedVersion(v))
                }

                version = v
            } else {
                //
                // "%abc" prefix but parsed to nil or a non-fileID line (should
                // not happen in practice but handled defensively).
                //
                if strictness == .strict {
                    throw Error.missingFileID
                }

                diagnostics.append(.missingFileID)
            }
        } catch {
            if strictness == .strict {
                throw error
            }

            diagnostics.append(.missingFileID)
        }

        return (version, Array(lines.dropFirst()))
    }
}
