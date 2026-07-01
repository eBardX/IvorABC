// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Functions

internal func makeTunebook(_ version: ABCVersion?,
                           _ policy: ABCParser.Policy,
                           _ restLines: [ABCParser.Line]) throws -> ABCTunebook {
    let parserIsNormalized = version == .current
        && !_containsLegacyConstructs(restLines)

    var lineReader = SequenceReader(restLines)

    let fileHeader = try _makeFileHeader(&lineReader, policy)
    let tunes = try _makeTunes(&lineReader, policy)

    guard !tunes.isEmpty
    else { throw ABCParser.Error.missingTunes }

    return ABCTunebook(version: version,
                       fileHeader: fileHeader,
                       tunes: tunes,
                       isNormalized: parserIsNormalized,
                       isValidated: false)
}

// MARK: Private Functions

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

private func _makeFileHeader(_ lineReader: inout SequenceReader<[ABCParser.Line]>,
                             _ policy: ABCParser.Policy) throws -> [ABCHeaderEntry] {
    var fileHeader: [ABCHeaderEntry] = []

    while let line = lineReader.peek() {
        if case let .continuation(text) = line {
            if let lastIndex = fileHeader.indices.last,
               case let .field(field) = fileHeader[lastIndex],
               let merged = _mergeContinuation(text, field) {
                fileHeader[lastIndex] = .field(merged)
            } else if policy.mode == .strict {
                throw ABCParser.Error.orphanedContinuation
            }

            lineReader.skip()

            continue
        }

        let result = _makeFileHeaderEntry(line)

        if result.isEmpty {
            lineReader.skip()

            break
        }

        guard let headerEntry = result.headerEntry
        else { break }

        fileHeader.append(headerEntry)

        lineReader.skip()
    }

    return fileHeader
}

private func _makeFileHeaderEntry(_ line: ABCParser.Line) -> (headerEntry: ABCHeaderEntry?, isEmpty: Bool) {
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

private func _makeTune(_ lineReader: inout SequenceReader<[ABCParser.Line]>,
                       _ policy: ABCParser.Policy) throws -> ABCTune? {
    while true {
        while let line = lineReader.peek(),
              case .empty = line {
            lineReader.skip()
        }

        // Input fully consumed: a clean end of file, not a malformed tune.
        guard lineReader.peek() != nil
        else { return nil }

        let tuneHeader = try _makeTuneHeader(&lineReader, policy)

        // - No tune body: Allowed. Section 2.2.1 (line 276): "It is legal to
        //   write an abc tune without a tune body. This feature can be used to
        //   document tunes without transcribing them."
        // - No tune header: Section 3.1.1 (line 537) and section 4.1 (line 728)
        //   require an X: field and a closing K: field.
        //
        // ABCValidator enforces that (Issue.missingReferenceNumber /
        // Issue.missingKey). Here, an empty tuneHeader means the current line
        // couldn't be assembled into a tune header at all (_makeTuneHeader
        // leaves such a line unconsumed): a hard parse error in strict mode,
        // and a single skipped line (retrying from what follows) in loose mode,
        // rather than content silently dropped from the tunebook.
        guard !tuneHeader.isEmpty
        else {
            guard policy.mode == .loose
            else { throw ABCParser.Error.invalidTuneHeader }

            lineReader.skip()

            continue
        }

        let tuneBody = try _makeTuneBody(&lineReader, policy)

        return ABCTune(header: tuneHeader,
                       body: tuneBody)
    }
}

private func _makeTuneBody(_ lineReader: inout SequenceReader<[ABCParser.Line]>,
                           _ policy: ABCParser.Policy) throws -> [ABCBodyEntry] {
    var tuneBody: [ABCBodyEntry] = []

    while let line = lineReader.peek() {
        if case let .continuation(text) = line {
            if let lastIndex = tuneBody.indices.last,
               case let .field(field) = tuneBody[lastIndex],
               let merged = _mergeContinuation(text, field) {
                tuneBody[lastIndex] = .field(merged)
            } else if policy.mode == .strict {
                throw ABCParser.Error.orphanedContinuation
            }

            lineReader.skip()

            continue
        }

        let result = _makeTuneBodyEntry(line)

        if result.isEmpty {
            lineReader.skip()

            break
        }

        guard let bodyEntry = result.bodyEntry
        else { break }

        tuneBody.append(bodyEntry)

        lineReader.skip()
    }

    return tuneBody
}

private func _makeTuneBodyEntry(_ line: ABCParser.Line) -> (bodyEntry: ABCBodyEntry?, isEmpty: Bool) {
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

        guard effectiveField.isValidInTuneBody
        else { return (nil, false) }

        return (.field(effectiveField), false)

    case let .symbols(symbols):
        return (.symbols(symbols), false)

    default:
        return (nil, false)
    }
}

private func _makeTuneHeader(_ lineReader: inout SequenceReader<[ABCParser.Line]>,
                             _ policy: ABCParser.Policy) throws -> [ABCHeaderEntry] {
    var tuneHeader: [ABCHeaderEntry] = []

    while let line = lineReader.peek() {
        if case let .continuation(text) = line {
            if let lastIndex = tuneHeader.indices.last,
               case let .field(field) = tuneHeader[lastIndex],
               let merged = _mergeContinuation(text, field) {
                tuneHeader[lastIndex] = .field(merged)
            } else if policy.mode == .strict {
                throw ABCParser.Error.orphanedContinuation
            }

            lineReader.skip()

            continue
        }

        let result = _makeTuneHeaderEntry(line)

        if result.isEmpty {
            lineReader.skip()

            break
        }

        guard let headerEntry = result.headerEntry
        else { break }

        tuneHeader.append(headerEntry)

        lineReader.skip()

        if case .field(.key) = headerEntry {
            break
        }
    }

    return tuneHeader
}

private func _makeTuneHeaderEntry(_ line: ABCParser.Line) -> (headerEntry: ABCHeaderEntry?, isEmpty: Bool) {
    switch line {
    case let .directive(directive):
        (.directive(directive), false)

    case .empty:
        (nil, true)

    case let .field(field) where field.isValidInTuneHeader:
        (.field(field), false)

    default:
        (nil, false)
    }
}

private func _makeTunes(_ lineReader: inout SequenceReader<[ABCParser.Line]>,
                        _ policy: ABCParser.Policy) throws -> [ABCTune] {
    var tunes: [ABCTune] = []

    while let tune = try _makeTune(&lineReader, policy) {
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
