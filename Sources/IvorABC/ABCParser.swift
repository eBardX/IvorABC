// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

private import XestiTools

/// A parser for ABC notation.
public struct ABCParser {

    // MARK: Public Initializers

    /// Creates a new ABC parser.
    public init() {
        self.tokenizer = ABCSymbolTokenizer(tracing: .silent)
    }

    // MARK: Internal Instance Properties

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
        guard let input = String(data: data,
                                 encoding: .utf8)
        else { throw ABCParseError.dataConversionFailed }

        let rawLines = input.split(separator: /\n|(?:\r\n?)/,
                                   omittingEmptySubsequences: false)
        let lines = _joinContinuationLines(rawLines)

        var context = ABCParseContext()

        //
        // First line MUST be a valid fileID:
        //
        guard let firstText = lines.first,
              let firstLine = try _parseLine(firstText, &context)
        else { throw ABCParseError.missingFileID }

        let fileID = try _validateFileID(firstLine)

        let bodyLines = Array(lines.dropFirst())

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

            guard let line = try _parseLine(text, &context)
            else { continue }

            restLines.append(line)
        }

        return try _makeTunebook(fileID,
                                 restLines)
    }

    // MARK: Private Type Properties

    private static let expectedBeginDirectivePrefix = "%%begin"
    private static let expectedDirectivePrefix      = "%%"
    private static let expectedEndDirectivePrefix   = "%%end"
    private static let expectedFileIDPrefix         = "%abc"

    // MARK: Private Instance Methods

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

    private func _makeTunebook(_ fileID: ABCFileID,
                               _ restLines: [Line]) throws -> ABCTunebook {
        var lineReader = SequenceReader(restLines)

        let headers = _processHeaderLines(&lineReader)
        let tunes = try _makeTunes(&lineReader)

        return ABCTunebook(version: fileID.version,
                           headers: headers,
                           tunes: tunes)
    }

    private func _makeTunes(_ reader: inout SequenceReader<[Line]>) throws -> [ABCTune] {
        var tunes: [ABCTune] = []

        while let tune = try _processTuneLines(&reader) {
            tunes.append(tune)
        }

        return tunes
    }

    private func _isEndDirectiveLine(_ input: Substring,
                                     _ endDirective: String) -> Bool {
        guard input.hasPrefix(endDirective)
        else { return false }

        let rest = uncomment(input.dropFirst(endDirective.count))

        return rest.isEmpty || rest.allSatisfy { $0.isABCWhitespace }
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

    private func _parseEmptyLine(_ input: Substring) throws -> Line? {
        guard input.isEmpty || input.allSatisfy({ $0.isABCWhitespace })
        else { return nil }

        return .empty
    }

    private func _parseFieldLine(_ input: Substring,
                                 _ context: inout ABCParseContext) throws -> Line? {
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

        let field = try parseField(tidyInput)

        context.update(with: field)

        return .field(field)
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
                            _ context: inout ABCParseContext) throws -> Line? {
        try _parseEmptyLine(input)
        ?? _parseFileIDLine(input)
        ?? _parseDirectiveLine(input)
        ?? _parseFieldLine(input, &context)
        ?? _parseSymbolsLine(input, &context)
    }

    private func _parseSymbolsLine(_ input: Substring,
                                   _ context: inout ABCParseContext) throws -> Line? {
        var matcher = try ABCSymbolMatcher(tokens: tokenizer.tokenize(String(input)))

        let symbols = try matcher.matchSymbols(&context)

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

    private func _processTuneLine(_ line: Line) throws -> (entry: ABCEntry?, empty: Bool) {
        switch line {
        case let .directive(directive):
            return (.directive(directive), false)

        case .empty:
            return (nil, true)

        case let .field(field):
            if field.isValidInTuneHeader || field.isValidInTuneBody {
                return (.field(field), false)
            } else {
                throw ABCParseError.misplacedField(field)
            }

        case let .symbols(symbols):
            return (.symbols(symbols), false)

        default:
            return (nil, false)
        }
    }

    private func _processTuneLines(_ reader: inout SequenceReader<[Line]>) throws -> ABCTune? {
        var entries: [ABCEntry] = []

        while let line = reader.peek() {
            let result = try _processTuneLine(line)

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

    private func _validateFileID(_ line: Line) throws -> ABCFileID {
        switch line {
        case let .fileID(fileID):
            let version = fileID.version

            guard version.major == ABCVersion.currentMajor,
                  version.minor == ABCVersion.currentMinor
            else { throw ABCParseError.unsupportedVersion(version) }

            return fileID

        default:
            throw ABCParseError.missingFileID
        }
    }
}
