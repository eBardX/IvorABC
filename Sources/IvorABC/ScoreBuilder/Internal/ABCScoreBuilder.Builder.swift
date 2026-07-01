// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension ABCScoreBuilder {

    // MARK: Internal Nested Types

    internal struct Builder {

        // MARK: Internal Initializers

        internal init(tunebook: ABCTunebook,
                      options: Options) {
            self.options = options
            self.tunebook = tunebook
        }

        // MARK: Private Instance Properties

        private let options: Options
        private let tunebook: ABCTunebook
    }
}

// MARK: -

extension ABCScoreBuilder.Builder {

    // The running resolution scope: the active explicit unit note length
    // (`L:`), meter (`M:`), and key signature (`K:`).
    //
    // NOTE: Accidental context, macro/shorthand tables, and pending
    // tuplet/broken-rhythm/attachment tracking are not yet part of this
    // scope — they land in later phases.
    private struct State {
        var keySignature: ABCKeySignature?
        var meter: ABCTimeSignature?
        var unitNoteLength: ABCLength?
    }

    // MARK: Internal Instance Methods

    internal func buildScores() -> [ABCScore] {
        let fileDefaults = _scanDefaults(tunebook.fileHeader)
        let fileEvents = _buildFileHeaderEvents(tunebook.fileHeader)

        return tunebook.tunes.map { _buildScore($0, fileDefaults, fileEvents) }
    }

    // MARK: Private Instance Methods

    private func _applyField(_ field: ABCField,
                             _ state: inout State) {
        switch field {
        case let .key(keySignature):
            state.keySignature = keySignature

        case let .meter(meter):
            state.meter = meter

        case let .unitNoteLength(length):
            state.unitNoteLength = length

        default:
            break
        }
    }

    // NOTE: The pitch returned here is a placeholder. Real key-signature and
    // within-bar propagation-based accidental resolution via
    // `ABCAccidentalContext` lands in a later phase; until then, an omitted
    // accidental is simply treated as natural.
    private func _buildAccidentalPlaceholder(_ pitch: ABCPitch) -> ABCPitch {
        guard pitch.accidental == .omitted
        else { return pitch }

        return ABCPitch(letter: pitch.letter,
                        accidental: .natural,
                        octave: pitch.octave)
    }

    private func _buildBody(_ body: [ABCBodyEntry],
                            _ state: inout State) -> [ABCScoreEvent] {
        var events: [ABCScoreEvent] = []

        for entry in body {
            switch entry {
            case let .directive(directive):
                if !options.contains(.stripDirectives) {
                    events.append(.directive(directive))
                }

            case let .field(field):
                _applyField(field, &state)

                if let event = _buildFieldEvent(field) {
                    events.append(event)
                }

            case let .symbols(symbols):
                events.append(contentsOf: _buildSymbolEvents(symbols, &state))
            }
        }

        return events
    }

    private func _buildChord(_ chord: ABCChord,
                             _ state: State) -> ABCScoreChord {
        let notes = chord.notes.map { _buildNote($0, state) }

        return ABCScoreChord(notes: notes,
                             duration: _buildDuration(chord.length, state),
                             tie: chord.tie).require()
    }

    // The chord-level, note-level, and rest-level absolute duration
    // resolution below covers the base `written × unit note length`
    // formula. Tuplet and broken-rhythm scaling, and meter-based
    // multi-measure rest resolution, land in a later phase.
    private func _buildDuration(_ written: ABCLength,
                                _ state: State) -> ABCScoreDuration {
        ABCScoreDuration(written: written,
                         unitNoteLength: _effectiveUnitNoteLength(state))
    }

    private func _buildFieldEvent(_ field: ABCField) -> ABCScoreEvent? {
        switch field {
        case let .composer(text):
            .composer(text)

        case let .instruction(directive):
            options.contains(.stripDirectives) ? nil : .directive(directive)

        case let .key(keySignature):
            .key(keySignature)

        case let .meter(meter):
            .meter(meter)

        case let .part(part):
            .part(part)

        case let .referenceNumber(referenceNumber):
            .referenceNumber(referenceNumber)

        case let .tempo(tempo):
            .tempo(tempo)

        case let .tuneTitle(text):
            .title(text)

        case let .unitNoteLength(length):
            .unitNoteLength(length)

        case let .voice(voice):
            .voice(voice)

        default:
            .field(field)
        }
    }

    private func _buildFileHeaderEvents(_ fileHeader: [ABCHeaderEntry]) -> [ABCScoreEvent] {
        fileHeader.compactMap { entry in
            switch entry {
            case let .directive(directive):
                options.contains(.stripDirectives) ? nil : .directive(directive)

            case let .field(field):
                _buildFieldEvent(field)
            }
        }
    }

    private func _buildNote(_ note: ABCNote,
                            _ state: State) -> ABCScoreNote {
        ABCScoreNote(pitch: _buildAccidentalPlaceholder(note.pitch),
                     duration: _buildDuration(note.length, state),
                     tie: note.tie).require()
    }

    private func _buildRest(_ rest: ABCRest,
                            _ state: State) -> ABCScoreRest {
        switch rest {
        case let .multiMeasure(isInvisible, _):
            // Placeholder: resolving against the active meter and the
            // written measure count lands in a later phase.
            ABCScoreRest(duration: ABCScoreDuration(numerator: 1).require(),
                         isInvisible: isInvisible)

        case let .regular(isInvisible, length):
            ABCScoreRest(duration: _buildDuration(length, state),
                         isInvisible: isInvisible)
        }
    }

    private func _buildScore(_ tune: ABCTune,
                             _ fileDefaults: State,
                             _ fileEvents: [ABCScoreEvent]) -> ABCScore {
        var state = fileDefaults
        let headerEvents = _buildTuneHeaderEvents(tune.header, &state)
        let bodyEvents = _buildBody(tune.body, &state)

        return ABCScore(events: fileEvents + headerEvents + bodyEvents)
    }

    // Decorations, annotations, grace notes, and chord symbols are folded
    // into attachments in a later phase; for now every musical event carries
    // `.empty` attachments. Shorthands, tuplets, broken rhythms, slurs,
    // overlays, and beam-breaks are likewise not yet handled and are
    // skipped.
    private func _buildSymbolEvents(_ symbols: [ABCSymbol],
                                    _ state: inout State) -> [ABCScoreEvent] {
        var events: [ABCScoreEvent] = []

        for symbol in symbols {
            switch symbol {
            case let .barLine(barLine):
                events.append(.barLine(barLine))

            case let .chord(chord):
                events.append(.chord(_buildChord(chord, state), .empty))

            case let .inlineField(field):
                _applyField(field, &state)

                if let event = _buildFieldEvent(field) {
                    events.append(event)
                }

            case let .note(note):
                events.append(.note(_buildNote(note, state), .empty))

            case let .rest(rest):
                events.append(.rest(_buildRest(rest, state), .empty))

            case let .variantEnding(variantEnding):
                events.append(.variantEnding(variantEnding))

            default:
                break
            }
        }

        return events
    }

    private func _buildTuneHeaderEvents(_ header: [ABCHeaderEntry],
                                        _ state: inout State) -> [ABCScoreEvent] {
        var events: [ABCScoreEvent] = []

        for entry in header {
            switch entry {
            case let .directive(directive):
                if !options.contains(.stripDirectives) {
                    events.append(.directive(directive))
                }

            case let .field(field):
                _applyField(field, &state)

                if let event = _buildFieldEvent(field) {
                    events.append(event)
                }
            }
        }

        return events
    }

    private func _effectiveUnitNoteLength(_ state: State) -> ABCLength {
        if let unitNoteLength = state.unitNoteLength {
            return unitNoteLength
        }

        if let meter = state.meter {
            return _unitNoteLength(from: meter)
        }

        return ABCLength(numerator: 1,
                         denominator: 8).require()
    }

    private func _scanDefaults(_ fileHeader: [ABCHeaderEntry]) -> State {
        var state = State()

        for entry in fileHeader {
            if case let .field(field) = entry {
                _applyField(field, &state)
            }
        }

        return state
    }

    private func _unitNoteLength(from meter: ABCTimeSignature) -> ABCLength {
        if case let .standard(standard) = meter,
           standard.doubleValue < 0.75 {
            return ABCLength(numerator: 1,
                             denominator: 16).require()
        }

        return ABCLength(numerator: 1,
                         denominator: 8).require()
    }
}
