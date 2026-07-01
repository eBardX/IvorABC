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
    // (`L:`), meter (`M:`), and key signature (`K:`), plus pending
    // tuplet/broken-rhythm scaling awaiting the next musical event(s).
    //
    // NOTE: Accidental context, macro/shorthand tables, and pending
    // attachment tracking are not yet part of this scope — they land in a
    // later phase.
    private struct State {
        var keySignature: ABCKeySignature?
        var meter: ABCTimeSignature?
        var pendingBrokenRhythm: ABCBrokenRhythm?
        var pendingTuplet: PendingTuplet?
        var unitNoteLength: ABCLength?

        // A tuplet scope in force: the next `remaining` musical events are
        // each scaled by `beatCount / noteCount`.
        struct PendingTuplet {
            let beatCount: UInt
            let noteCount: UInt
            var remaining: UInt
        }
    }

    // MARK: Internal Instance Methods

    internal func buildScores() -> [ABCScore] {
        let fileDefaults = _scanDefaults(tunebook.fileHeader)
        let fileEvents = _buildFileHeaderEvents(tunebook.fileHeader)

        return tunebook.tunes.map { _buildScore($0, fileDefaults, fileEvents) }
    }

    // MARK: Private Instance Methods

    // Applies the "left" side of a broken-rhythm marker to the most
    // recently appended musical event, in place.
    private func _applyBrokenRhythmToLastEvent(_ marker: ABCBrokenRhythm,
                                               _ events: inout [ABCScoreEvent]) {
        guard let index = events.indices.last
        else { return }

        let factor = _brokenRhythmFactor(marker, isLeft: true)

        switch events[index] {
        case let .chord(chord, attachments):
            events[index] = .chord(_rescaled(chord, chord.duration * factor), attachments)

        case let .note(note, attachments):
            events[index] = .note(_rescaled(note, note.duration * factor), attachments)

        case let .rest(rest, attachments):
            events[index] = .rest(_rescaled(rest, rest.duration * factor), attachments)

        default:
            break
        }
    }

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

    // Consumes any pending tuplet and/or broken-rhythm scaling and applies
    // it to `duration`.
    private func _applyPendingScaling(_ duration: ABCScoreDuration,
                                      _ state: inout State) -> ABCScoreDuration {
        var result = duration

        if let factor = _consumeTupletScale(&state) {
            result *= factor
        }

        if let factor = _consumeBrokenRhythmScale(&state) {
            result *= factor
        }

        return result
    }

    // Returns the `(numerator, denominator)` scaling factor a broken-rhythm
    // marker applies to one side of the flanking pair. `isLeft` selects
    // which side; `>`-family markers lengthen the left/shorten the right,
    // `<`-family markers reverse that.
    private func _brokenRhythmFactor(_ marker: ABCBrokenRhythm,
                                     isLeft: Bool) -> (numerator: UInt, denominator: UInt) {
        let denominator = UInt(1) << marker.factor
        let numerator = (UInt(1) << (marker.factor + 1)) - 1
        let isLong: Bool = switch marker {
        case .dotted,
             .doubleDotted,
             .tripleDotted:
            isLeft

        case .reverseDotted,
             .reverseDoubleDotted,
             .reverseTripleDotted:
            !isLeft
        }

        return isLong ? (numerator, denominator) : (1, denominator)
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
    // formula. Tuplet and broken-rhythm scaling are applied afterward, in
    // `_buildSymbolEvents`, since they depend on state that spans multiple
    // symbols.
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
        case let .multiMeasure(isInvisible, measureCount):
            let duration = _measureDuration(state) * (numerator: measureCount.uintValue,
                                                      denominator: 1)

            return ABCScoreRest(duration: duration,
                                isInvisible: isInvisible)

        case let .regular(isInvisible, length):
            return ABCScoreRest(duration: _buildDuration(length, state),
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
    // `.empty` attachments. Shorthands, slurs, overlays, and beam-breaks are
    // likewise not yet handled and are skipped.
    private func _buildSymbolEvents(_ symbols: [ABCSymbol],
                                    _ state: inout State) -> [ABCScoreEvent] {
        var events: [ABCScoreEvent] = []

        for symbol in symbols {
            switch symbol {
            case let .barLine(barLine):
                events.append(.barLine(barLine))

            case let .brokenRhythm(marker):
                _applyBrokenRhythmToLastEvent(marker, &events)
                state.pendingBrokenRhythm = marker

            case let .chord(chord):
                let built = _buildChord(chord, state)
                let duration = _applyPendingScaling(built.duration, &state)

                events.append(.chord(_rescaled(built, duration), .empty))

            case let .inlineField(field):
                _applyField(field, &state)

                if let event = _buildFieldEvent(field) {
                    events.append(event)
                }

            case let .note(note):
                let built = _buildNote(note, state)
                let duration = _applyPendingScaling(built.duration, &state)

                events.append(.note(_rescaled(built, duration), .empty))

            case let .rest(rest):
                let built = _buildRest(rest, state)
                let duration = _applyPendingScaling(built.duration, &state)

                events.append(.rest(_rescaled(built, duration), .empty))

            case let .tuplet(tuplet):
                let resolved = tuplet.resolve(meter: state.meter)

                state.pendingTuplet = State.PendingTuplet(beatCount: resolved.beatCount,
                                                          noteCount: resolved.noteCount,
                                                          remaining: resolved.affectedCount)

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

    // Consumes the pending broken-rhythm marker (if any) and returns the
    // scaling factor for the "right" side of the flanking pair.
    private func _consumeBrokenRhythmScale(_ state: inout State) -> (numerator: UInt, denominator: UInt)? {
        guard let marker = state.pendingBrokenRhythm
        else { return nil }

        state.pendingBrokenRhythm = nil

        return _brokenRhythmFactor(marker, isLeft: false)
    }

    // Consumes one unit of the pending tuplet scope (if any), clearing it
    // once exhausted, and returns the scaling factor to apply.
    private func _consumeTupletScale(_ state: inout State) -> (numerator: UInt, denominator: UInt)? {
        guard var pending = state.pendingTuplet
        else { return nil }

        pending.remaining -= 1
        state.pendingTuplet = pending.remaining == 0 ? nil : pending

        return (pending.beatCount, pending.noteCount)
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

    // The duration of one measure under the active meter, used to resolve
    // multi-measure rests. Defaults to 4/4 when no meter is active or the
    // meter carries no usable fraction (`.empty`).
    private func _measureDuration(_ state: State) -> ABCScoreDuration {
        guard let meter = state.meter
        else { return ABCScoreDuration(numerator: 4,
                                       denominator: 4).require() }

        switch meter {
        case .common,
             .empty:
            return ABCScoreDuration(numerator: 4,
                                    denominator: 4).require()

        case let .complex(additiveMeter):
            return ABCScoreDuration(numerator: additiveMeter.numerators.reduce(0, +),
                                    denominator: additiveMeter.denominator).require()

        case .cut:
            return ABCScoreDuration(numerator: 2,
                                    denominator: 2).require()

        case let .standard(standardMeter):
            return ABCScoreDuration(numerator: standardMeter.numerator,
                                    denominator: standardMeter.denominator).require()
        }
    }

    private func _rescaled(_ chord: ABCScoreChord,
                           _ duration: ABCScoreDuration) -> ABCScoreChord {
        ABCScoreChord(notes: chord.notes,
                      duration: duration,
                      tie: chord.tie).require()
    }

    private func _rescaled(_ note: ABCScoreNote,
                           _ duration: ABCScoreDuration) -> ABCScoreNote {
        ABCScoreNote(pitch: note.pitch,
                     duration: duration,
                     tie: note.tie,
                     slurStart: note.slurStart,
                     slurEnd: note.slurEnd).require()
    }

    private func _rescaled(_ rest: ABCScoreRest,
                           _ duration: ABCScoreDuration) -> ABCScoreRest {
        ABCScoreRest(duration: duration,
                     isInvisible: rest.isInvisible)
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
