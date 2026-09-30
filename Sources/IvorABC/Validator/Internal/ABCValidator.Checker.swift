// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCValidator {

    // MARK: Internal Nested Types

    internal struct Checker {

        // MARK: Internal Initializers

        internal init(tunebook: ABCTunebook) {
            self.globalDefinedShorthands = Self.defaultGlobalDefinedShorthands
            self.issues = []
            self.tunebook = tunebook
            self.tuneDefinedShorthands = []
        }

        // MARK: Private Instance Properties

        private let tunebook: ABCTunebook

        private var currentVoiceKey: ABCVoice.ID?
        private var globalDefinedShorthands: Set<ABCShorthand>
        private var issues: [Issue]
        private var pendingAttachmentCounts: [ABCVoice.ID?: PendingAttachmentCounts] = [:]
        private var tuneDefinedShorthands: Set<ABCShorthand>
    }
}

// MARK: -

extension ABCValidator.Checker {

    // MARK: Internal Instance Methods

    internal mutating func checkTunebook() -> [ABCValidator.Issue] {
        _checkFileHeader(tunebook.fileHeader)

        for (index, tune) in tunebook.tunes.enumerated() {
            _checkTune(tune, index)
        }

        return issues
    }

    // MARK: Private Type Properties

    private static let defaultGlobalDefinedShorthands: Set<ABCShorthand> = [.hUpper,
                                                                            .lUpper,
                                                                            .mUpper,
                                                                            .oUpper,
                                                                            .pUpper,
                                                                            .sUpper,
                                                                            .tilde,
                                                                            .tUpper,
                                                                            .uLower,
                                                                            .vLower]

    // MARK: Private Instance Methods

    private mutating func _checkFileHeader(_ fileHeader: [ABCHeaderEntry]) {
        for entry in fileHeader {
            guard case let .field(field) = entry
            else { continue }

            if !field.isValidInFileHeader {
                issues.append(.misplacedFileHeaderField(field))
            }

            _updateState(field)
        }
    }

    private mutating func _checkKey(_ fields: [ABCField],
                                    _ index: Int) {
        guard let keyIndex = fields.firstIndex(where: _isKey)
        else { issues.append(.missingKey(index)); return }

        if keyIndex != fields.count - 1 {
            issues.append(.misplacedKey(index))
        }
    }

    private mutating func _checkReferenceNumber(_ fields: [ABCField],
                                                _ index: Int) {
        guard let referenceNumberIndex = fields.firstIndex(where: _isReferenceNumber)
        else { issues.append(.missingReferenceNumber(index)); return }

        if referenceNumberIndex != 0 {
            issues.append(.misplacedReferenceNumber(index))
        }
    }

    // A note, chord, rest, or bar line is where any pending grace
    // notes/chord symbol would be folded onto the upcoming event and
    // accumulation would start afresh — so this is also where a run of
    // multiple ones, wherever they fell within that stretch, is caught.
    // Counts are tracked per voice (see `currentVoiceKey`), so a `V:` switch
    // in between doesn't hide or merge counts across voices.
    private mutating func _checkSymbol(_ symbol: ABCSymbol,
                                       _ index: Int) {
        switch symbol {
        case .barLine,
             .chord,
             .note,
             .rest:
            _drainPendingAttachmentCounts(index)

        case .chordSymbol:
            pendingAttachmentCounts[currentVoiceKey,
                                    default: PendingAttachmentCounts()].chordSymbols += 1

        case .graceNotes:
            pendingAttachmentCounts[currentVoiceKey,
                                    default: PendingAttachmentCounts()].graceNotes += 1

        case let .inlineField(field):
            if case let .voice(voice) = field {
                currentVoiceKey = voice.id
            }

            if !field.isValidInline {
                issues.append(.invalidInlineField(field, index))
            }

            _updateState(field, true)

        case let .shorthand(shorthand):
            if shorthand != .dot,
               !tuneDefinedShorthands.contains(shorthand) {
                issues.append(.undefinedUserSymbol(index))
            }

        default:
            break
        }
    }

    private mutating func _checkTune(_ tune: ABCTune,
                                     _ index: Int) {
        currentVoiceKey = nil
        pendingAttachmentCounts = [:]
        tuneDefinedShorthands = globalDefinedShorthands

        _checkTuneHeader(tune.header, index)
        _checkTuneBody(tune.body, index)
    }

    private mutating func _checkTuneBody(_ body: [ABCBodyEntry],
                                         _ index: Int) {
        for entry in body {
            switch entry {
            case let .field(field):
                if case let .voice(voice) = field {
                    currentVoiceKey = voice.id
                }

                if !field.isValidInTuneBody {
                    issues.append(.misplacedTuneBodyField(field, index))
                }

                _updateState(field, true)

            case let .symbols(symbols):
                for symbol in symbols {
                    _checkSymbol(symbol, index)
                }

            default:
                break
            }
        }
    }

    private mutating func _checkTuneHeader(_ header: [ABCHeaderEntry],
                                           _ index: Int) {
        let fields = header.compactMap { entry -> ABCField? in
            guard case let .field(field) = entry
            else { return nil }

            return field
        }

        _checkReferenceNumber(fields, index)
        _checkTuneTitle(fields, index)
        _checkKey(fields, index)

        for field in fields {
            if !field.isValidInTuneHeader {
                issues.append(.misplacedTuneHeaderField(field, index))
            }

            _updateState(field, true)
        }
    }

    private mutating func _checkTuneTitle(_ fields: [ABCField],
                                          _ index: Int) {
        guard let titleIndex = fields.firstIndex(where: _isTuneTitle)
        else { issues.append(.missingTuneTitle(index)); return }

        // A misplaced title is only meaningful once the reference number is
        // first; otherwise the header is already flagged for that and a title
        // issue would just be noise.
        guard case .referenceNumber? = fields.first
        else { return }

        if titleIndex != 1 {
            issues.append(.misplacedTuneTitle(index))
        }
    }

    private mutating func _drainPendingAttachmentCounts(_ index: Int) {
        let counts = pendingAttachmentCounts[currentVoiceKey] ?? PendingAttachmentCounts()

        if counts.chordSymbols > 1 {
            issues.append(.multipleChordSymbols(index))
        }

        if counts.graceNotes > 1 {
            issues.append(.multipleGraceNotes(index))
        }

        pendingAttachmentCounts[currentVoiceKey] = PendingAttachmentCounts()
    }

    private mutating func _updateState(_ field: ABCField,
                                       _ inTune: Bool = false) {
        switch field {
        case let .userDefined(userSymbol):
            if userSymbol.definition != nil {
                if inTune {
                    tuneDefinedShorthands.insert(userSymbol.shorthand)
                } else {
                    globalDefinedShorthands.insert(userSymbol.shorthand)
                }
            } else {
                if inTune {
                    tuneDefinedShorthands.remove(userSymbol.shorthand)
                } else {
                    globalDefinedShorthands.remove(userSymbol.shorthand)
                }
            }

        default:
            break
        }
    }
}

// MARK: - Private Functions

private func _isKey(_ field: ABCField) -> Bool {
    if case .key = field {
        return true
    }

    return false
}

private func _isReferenceNumber(_ field: ABCField) -> Bool {
    if case .referenceNumber = field {
        return true
    }

    return false
}

private func _isTuneTitle(_ field: ABCField) -> Bool {
    if case .tuneTitle = field {
        return true
    }

    return false
}
