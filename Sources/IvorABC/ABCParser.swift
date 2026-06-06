// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

private import XestiTools

/// A parser for ABC notation.
public struct ABCParser {

    // MARK: Public Initializers

    /// Creates a new ABC parser with the specified strictness.
    ///
    /// - Parameter strictness: Controls how the parser handles deviations
    ///                         from the ABC notation standard. Defaults to
    ///                         ``Strictness/strict``, which preserves the
    ///                         existing throwing behavior.
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
    /// - Parameter data: The UTF-8 encoded ABC notation data to parse.
    ///
    /// - Returns:  The ``ABCTunebook`` parsed from `data`.
    ///
    /// - Throws:   ``ABCParseError`` if the data cannot be parsed.
    public func parse(_ data: Data) throws -> ABCTunebook {
        var diagnostics: [ABCDiagnostic] = []

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
    ///             and an array of ``ABCDiagnostic`` values describing any
    ///             recoveries performed.
    ///
    /// - Throws:   ``ABCParseError`` if the data cannot be parsed.
    public func parseWithDiagnostics(_ data: Data) throws -> (ABCTunebook, [ABCDiagnostic]) {
        var diagnostics: [ABCDiagnostic] = []
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

            if stripped.hasSuffix("\\") {
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
                               _ diagnostics: inout [ABCDiagnostic]) throws -> ABCTunebook {
        var lineReader = SequenceReader(restLines)

        let headers = _processHeaderLines(&lineReader)
        let tunes = try _makeTunes(&lineReader, &diagnostics)

        return ABCTunebook(version: version,
                           headers: headers,
                           tunes: tunes)
    }

    private func _makeTunes(_ reader: inout SequenceReader<[Line]>,
                            _ diagnostics: inout [ABCDiagnostic]) throws -> [ABCTune] {
        var tunes: [ABCTune] = []

        while let tune = try _processTuneLines(&reader, &diagnostics) {
            tunes.append(tune)
        }

        return tunes
    }

    private func _parse(_ data: Data,
                        _ diagnostics: inout [ABCDiagnostic]) throws -> ABCTunebook {
        guard let input = String(data: data,
                                 encoding: .utf8)
        else { throw ABCParseError.dataConversionFailed }

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
                else { throw ABCParseError.unmatchedBeginDirective(name) }

                restLines.append(.directive(ABCDirective(name: name,
                                                         value: beginValue,
                                                         content: contentLines)))
                continue
            }

            do {
                guard let line = try _parseLine(text, &context, &diagnostics)
                else { continue }

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
        else { throw ABCParseError.invalidDirective(Self.expectedDirectivePrefix + tidyInput) }

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
                                 _ context: inout ABCParseContext,
                                 _ diagnostics: inout [ABCDiagnostic]) throws -> Line? {
        guard let letter = input.first,
              letter.isABCLetter || letter == "+",
              input.dropFirst().first == ":"
        else { return nil }

        if letter == "I" {
            let tidyInput = trimSuffix(uncomment(input.dropFirst(2)))
            let result = tidyInput.splitBeforeFirst { $0.isABCWhitespace }

            guard let name = parseDirectiveName(result.head)
            else { throw ABCParseError.invalidDirective(input) }

            let value = String(trimPrefix(result.tail ?? ""))

            return .directive(ABCDirective(name: name, value: value))
        }

        let tidyInput = trimSuffix(uncomment(input))

        do {
            let field = try parseField(tidyInput)

            context.update(with: field)

            return .field(field)
        } catch let ABCParseError.invalidTempo(vtext) where strictness == .lenient {
            //
            // Lenient recovery for the bare-integer tempo form (e.g. "Q:120").
            // The spec notes this old style and allows parsers to accept it.
            //
            if let rate = UInt(trim(vtext)), rate > 0 {
                let field = ABCField.tempo(ABCTempo(durations: [],
                                                    rate: rate,
                                                    text: nil))

                diagnostics.append(.bareTempoRate(rate))
                context.update(with: field)

                return .field(field)
            }

            throw ABCParseError.invalidTempo(vtext)
        }
    }

    private func _parseFileID(_ tidyInput: Substring) throws -> ABCFileID {
        guard tidyInput.first == "-"
        else { throw ABCParseError.invalidFileID(Self.expectedFileIDPrefix + tidyInput) }

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
                            _ context: inout ABCParseContext,
                            _ diagnostics: inout [ABCDiagnostic]) throws -> Line? {
        try _parseEmptyLine(input)
        ?? _parseFileIDLine(input)
        ?? _parseDirectiveLine(input)
        ?? _parseFieldLine(input, &context, &diagnostics)
        ?? _parseSymbolsLine(input, &context)
    }

    private func _parseSymbolsLine(_ input: Substring,
                                   _ context: inout ABCParseContext) throws -> Line? {
        let tokens: [ABCSymbolTokenizer.Token]

        do {
            tokens = try tokenizer.tokenize(String(input))
        } catch {
            throw ABCParseError.invalidSymbolLine(input)
        }

        var matcher = ABCSymbolMatcher(tokens: tokens)

        let symbols: [ABCSymbol]

        do {
            symbols = try matcher.matchSymbols(&context)
        } catch let error as ABCParseError {
            throw error
        } catch {
            throw ABCParseError.invalidSymbols(input)
        }

        guard !symbols.isEmpty
        else { return nil }

        return .symbols(symbols)
    }

    private func _parseVersion(_ tidyInput: Substring) throws -> ABCVersion {
        let result = tidyInput.splitBeforeFirst(".")

        guard let major = UInt(result.head),
              let mtext = result.tail?.dropFirst(),
              let minor = UInt(mtext)
        else { throw ABCParseError.invalidVersion(tidyInput) }

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
                                  _ diagnostics: inout [ABCDiagnostic]) throws -> (entry: ABCEntry?, empty: Bool) {
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
                throw ABCParseError.misplacedField(field)
            }

        case let .symbols(symbols):
            return (.symbols(symbols), false)

        default:
            return (nil, false)
        }
    }

    private func _processTuneLines(_ reader: inout SequenceReader<[Line]>,
                                   _ diagnostics: inout [ABCDiagnostic]) throws -> ABCTune? {
        // Skip any leading empty lines before the tune content starts (e.g., after
        // multiple blank lines or skipped prose in lenient mode).
        while let line = reader.peek(), case .empty = line {
            reader.skip()
        }

        var entries: [ABCEntry] = []

        while let line = reader.peek() {
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
                                _ diagnostics: inout [ABCDiagnostic]) throws -> (ABCVersion, [Substring]) {
        var version = ABCVersion(major: ABCVersion.currentMajor,
                                 minor: ABCVersion.currentMinor)

        guard let firstText = lines.first,
              firstText.hasPrefix(Self.expectedFileIDPrefix)
        else {
            //
            // No "%abc" prefix on the first line.  In strict mode the file ID is
            // required; in lenient mode assume version 2.1 and include all lines
            // in the body.
            //
            if strictness == .strict {
                throw ABCParseError.missingFileID
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

                if v.major != ABCVersion.currentMajor || v.minor != ABCVersion.currentMinor {
                    if strictness == .strict {
                        throw ABCParseError.unsupportedVersion(v)
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
                    throw ABCParseError.missingFileID
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
