// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension ABCParser {

    // MARK: Internal Instance Methods

    internal func makeTunebook(_ version: ABCVersion,
                               _ restLines: [Line],
                               _ diagnostics: inout [Diagnostic]) throws -> ABCTunebook {
        var lineReader = SequenceReader(restLines)

        let fileHeaders = _processFileHeaderLines(&lineReader)
        let tunes = try _makeTunes(&lineReader, &diagnostics)

        guard let tunebook = ABCTunebook(version: version,
                                         fileHeader: fileHeaders,
                                         tunes: tunes)
        else { throw ABCParser.Error.missingTunes }

        return tunebook
    }

    // MARK: Private Instance Methods

    private func _handleMissingKeyField(inTuneBody: Bool,
                                        _ diagnostics: inout [Diagnostic]) throws {
        guard !inTuneBody
        else { return }

        if strictness == .strict {
            throw Error.missingKeyField
        } else {
            diagnostics.append(.missingKeyField)
        }
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

            return ABCText(stringValue: stringValue).require()
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

        case let .words(text):
            return .words(joinText(text))

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

        case let .tuneTitle(text):
            return .tuneTitle(joinText(text))

        case let .transcription(text):
            return .transcription(joinText(text))

        default:
            return nil
        }
    }

    private func _processFileHeaderLine(_ line: Line) -> (fileHeader: ABCHeaderEntry?, empty: Bool) {
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

    private func _processFileHeaderLines(_ reader: inout SequenceReader<[Line]>) -> [ABCHeaderEntry] {
        var fileHeaders: [ABCHeaderEntry] = []

        while let line = reader.peek() {
            if case let .continuation(text) = line {
                if let lastIndex = fileHeaders.indices.last,
                   case let .field(field) = fileHeaders[lastIndex],
                   let merged = _mergeContinuation(text, field) {
                    fileHeaders[lastIndex] = .field(merged)
                }

                reader.skip()
                continue
            }

            let result = _processFileHeaderLine(line)

            if result.empty {
                reader.skip()
                break
            }

            guard let fileHeader = result.fileHeader
            else { break }

            fileHeaders.append(fileHeader)

            reader.skip()
        }

        return fileHeaders
    }

    private func _processHeaderEntry(_ entry: ABCBodyEntry,
                                     tuneHeader: inout [ABCHeaderEntry],
                                     tuneBody: inout [ABCBodyEntry],
                                     fieldCount: inout Int,
                                     pastTitleSection: inout Bool,
                                     inTuneBody: inout Bool,
                                     _ diagnostics: inout [Diagnostic]) throws {
        switch entry {
        case let .directive(directive):
            tuneHeader.append(.directive(directive))

        case let .field(field):
            fieldCount += 1

            if strictness == .strict {
                if fieldCount == 1 {
                    guard case .referenceNumber = field
                    else { throw Error.missingReferenceNumber }
                } else if case .tuneTitle = field, pastTitleSection {
                    throw Error.misplacedField(field)
                }
            }

            switch field {
            case .referenceNumber,
                 .tuneTitle:
                break

            default:
                pastTitleSection = true
            }

            tuneHeader.append(.field(field))
            if case .key = field {
                inTuneBody = true
            }

        case .symbols:
            if strictness == .strict {
                throw Error.missingKeyField
            } else {
                diagnostics.append(.missingKeyField)
                inTuneBody = true
                tuneBody.append(entry)
            }
        }
    }

    private func _processTuneBodyLine(_ line: Line,
                                      _ diagnostics: inout [Diagnostic]) throws -> (entry: ABCBodyEntry?, empty: Bool) {
        switch line {
        case let .directive(directive):
            return (.directive(directive), false)

        case .empty:
            return (nil, true)

        case let .field(field):
            if field.isValidInTuneBody {
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

    private func _processTuneHeaderLine(_ line: Line,
                                        _ diagnostics: inout [Diagnostic]) throws -> (entry: ABCBodyEntry?, empty: Bool) {
        switch line {
        case let .directive(directive):
            return (.directive(directive), false)

        case .empty:
            return (nil, true)

        case let .field(field):
            if field.isValidInTuneHeader {
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

    private func _processTuneBodyLines(_ reader: inout SequenceReader<[Line]>,
                                       tuneBody: inout [ABCBodyEntry],
                                       _ diagnostics: inout [Diagnostic]) throws {
        while let line = reader.peek() {
            if case let .continuation(text) = line {
                if let lastIndex = tuneBody.indices.last,
                   case let .field(field) = tuneBody[lastIndex],
                   let merged = _mergeContinuation(text, field) {
                    tuneBody[lastIndex] = .field(merged)
                } else if strictness == .strict {
                    throw Error.orphanedContinuation
                }

                reader.skip()

                continue
            }

            let result = try _processTuneBodyLine(line, &diagnostics)

            if result.empty {
                reader.skip()

                break
            }

            guard let entry = result.entry
            else { break }

            tuneBody.append(entry)

            reader.skip()
        }
    }

    private func _processTuneHeaderLines(_ reader: inout SequenceReader<[Line]>,
                                         tuneHeader: inout [ABCHeaderEntry],
                                         tuneBody: inout [ABCBodyEntry],
                                         _ diagnostics: inout [Diagnostic]) throws -> Bool {
        var fieldCount = 0
        var pastTitleSection = false
        var inTuneBody = false

        while !inTuneBody,
              let line = reader.peek() {
            if case let .continuation(text) = line {
                if let lastIndex = tuneHeader.indices.last,
                   case let .field(field) = tuneHeader[lastIndex],
                   let merged = _mergeContinuation(text, field) {
                    tuneHeader[lastIndex] = .field(merged)
                } else if strictness == .strict {
                    throw Error.orphanedContinuation
                }

                reader.skip()

                continue
            }

            let result = try _processTuneHeaderLine(line, &diagnostics)

            if result.empty {
                reader.skip()

                break
            }

            guard let entry = result.entry
            else { break }

            try _processHeaderEntry(entry,
                                    tuneHeader: &tuneHeader,
                                    tuneBody: &tuneBody,
                                    fieldCount: &fieldCount,
                                    pastTitleSection: &pastTitleSection,
                                    inTuneBody: &inTuneBody,
                                    &diagnostics)

            reader.skip()
        }

        return inTuneBody
    }

    private func _processTuneLines(_ reader: inout SequenceReader<[Line]>,
                                   _ diagnostics: inout [Diagnostic]) throws -> ABCTune? {
        // Skip any leading empty lines before the tune content starts (e.g., after
        // multiple blank lines or skipped prose in lenient mode).
        while let line = reader.peek(),
              case .empty = line {
            reader.skip()
        }

        var tuneHeader: [ABCHeaderEntry] = []
        var tuneBody: [ABCBodyEntry] = []

        let inTuneBody = try _processTuneHeaderLines(&reader,
                                                     tuneHeader: &tuneHeader,
                                                     tuneBody: &tuneBody,
                                                     &diagnostics)

        if inTuneBody {
            try _processTuneBodyLines(&reader,
                                      tuneBody: &tuneBody,
                                      &diagnostics)
        }

        guard !tuneHeader.isEmpty || !tuneBody.isEmpty
        else { return nil }

        try _handleMissingKeyField(inTuneBody: inTuneBody, &diagnostics)

        return ABCTune(header: tuneHeader,
                       body: tuneBody)
    }
}
