// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension ABCParser.Reader {

    // MARK: Internal Instance Methods

    internal func makeTunebook(_ version: ABCVersion?,
                               _ policy: ABCParser.Policy,
                               _ restLines: [ABCParser.Line]) throws -> ABCTunebook {
        let parserIsNormalized = version == .current
            && !_containsLegacyConstructs(restLines)

        var lineReader = SequenceReader(restLines)

        let fileHeaders = _processFileHeaderLines(&lineReader)
        let tunes = try _makeTunes(policy,
                                   &lineReader)

        guard !tunes.isEmpty
        else { throw ABCParser.Error.missingTunes }

        return ABCTunebook(version: version,
                           fileHeader: fileHeaders,
                           tunes: tunes,
                           isNormalized: parserIsNormalized,
                           isValidated: false)
    }

    // MARK: Private Instance Methods

    private func _bodyPart(from partSequence: ABCPartSequence) -> ABCPart? {
        guard partSequence.items.count == 1,
              case let .part(part, 1) = partSequence.items[0]
        else { return nil }

        return part
    }

    private func _containsLegacyConstructs(_ lines: [ABCParser.Line]) -> Bool {
        lines.contains {
            switch $0 {
            case let .directive(directive):
                directive.needsNormalization

            case let .field(field):
                field.needsNormalization

            case let .symbols(symbols):
                symbols.contains { $0.needsNormalization }

            default:
                false
            }
        }
    }

    private func _makeTunes(_ policy: ABCParser.Policy,
                            _ reader: inout SequenceReader<[ABCParser.Line]>) throws -> [ABCTune] {
        var tunes: [ABCTune] = []

        while let tune = try _processTuneLines(&reader,
                                               policy) {
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

    private func _processFileHeaderLine(_ line: ABCParser.Line) -> (fileHeader: ABCHeaderEntry?, empty: Bool) {
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

    private func _processFileHeaderLines(_ reader: inout SequenceReader<[ABCParser.Line]>) -> [ABCHeaderEntry] {
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
                                     _ tuneHeader: inout [ABCHeaderEntry],
                                     _ tuneBody: inout [ABCBodyEntry],
                                     _ inTuneBody: inout Bool) {
        switch entry {
        case let .directive(directive):
            tuneHeader.append(.directive(directive))

        case let .field(field):
            tuneHeader.append(.field(field))

            if case .key = field {
                inTuneBody = true
            }

        case .symbols:
            // Music code in the header region means the tune body has begun
            // without a preceding K: field. The missing key is reported by the
            // validator; the parser only needs the structural transition.
            inTuneBody = true

            tuneBody.append(entry)
        }
    }

    private func _processTuneBodyLine(_ line: ABCParser.Line) -> (entry: ABCBodyEntry?, empty: Bool) {
        switch line {
        case let .directive(directive):
            return (.directive(directive), false)

        case .empty:
            return (nil, true)

        case let .field(field):
            let effectiveField: ABCField = if case let .parts(partSequence) = field,
                                              let part = _bodyPart(from: partSequence) {
                .part(part)
            } else {
                field
            }

            return (.field(effectiveField), false)

        case let .symbols(symbols):
            return (.symbols(symbols), false)

        default:
            return (nil, false)
        }
    }

    private func _processTuneBodyLines(_ policy: ABCParser.Policy,
                                       _ reader: inout SequenceReader<[ABCParser.Line]>,
                                       _ tuneBody: inout [ABCBodyEntry]) throws {
        while let line = reader.peek() {
            if case let .continuation(text) = line {
                if let lastIndex = tuneBody.indices.last,
                   case let .field(field) = tuneBody[lastIndex],
                   let merged = _mergeContinuation(text, field) {
                    tuneBody[lastIndex] = .field(merged)
                } else if policy.mode == .strict {
                    throw ABCParser.Error.orphanedContinuation
                }

                reader.skip()

                continue
            }

            let result = _processTuneBodyLine(line)

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

    private func _processTuneHeaderLine(_ line: ABCParser.Line) -> (entry: ABCBodyEntry?, empty: Bool) {
        switch line {
        case let .directive(directive):
            (.directive(directive), false)

        case .empty:
            (nil, true)

        case let .field(field):
            (.field(field), false)

        case let .symbols(symbols):
            (.symbols(symbols), false)

        default:
            (nil, false)
        }
    }

    private func _processTuneHeaderLines(_ policy: ABCParser.Policy,
                                         _ reader: inout SequenceReader<[ABCParser.Line]>,
                                         _ tuneHeader: inout [ABCHeaderEntry],
                                         _ tuneBody: inout [ABCBodyEntry]) throws -> Bool {
        var inTuneBody = false

        while !inTuneBody,
              let line = reader.peek() {
            if case let .continuation(text) = line {
                if let lastIndex = tuneHeader.indices.last,
                   case let .field(field) = tuneHeader[lastIndex],
                   let merged = _mergeContinuation(text, field) {
                    tuneHeader[lastIndex] = .field(merged)
                } else if policy.mode == .strict {
                    throw ABCParser.Error.orphanedContinuation
                }

                reader.skip()

                continue
            }

            let result = _processTuneHeaderLine(line)

            if result.empty {
                reader.skip()

                break
            }

            guard let entry = result.entry
            else { break }

            _processHeaderEntry(entry,
                                &tuneHeader,
                                &tuneBody,
                                &inTuneBody)

            reader.skip()
        }

        return inTuneBody
    }

    private func _processTuneLines(_ reader: inout SequenceReader<[ABCParser.Line]>,
                                   _ policy: ABCParser.Policy) throws -> ABCTune? {
        // Skip any leading empty lines before the tune content starts (e.g., after
        // multiple blank lines or skipped prose in lenient mode).
        while let line = reader.peek(),
              case .empty = line {
            reader.skip()
        }

        var tuneHeader: [ABCHeaderEntry] = []
        var tuneBody: [ABCBodyEntry] = []

        let inTuneBody = try _processTuneHeaderLines(policy,
                                                     &reader,
                                                     &tuneHeader,
                                                     &tuneBody)

        if inTuneBody {
            try _processTuneBodyLines(policy,
                                      &reader,
                                      &tuneBody)
        }

        guard !tuneHeader.isEmpty || !tuneBody.isEmpty
        else { return nil }

        return ABCTune(header: tuneHeader,
                       body: tuneBody)
    }
}
