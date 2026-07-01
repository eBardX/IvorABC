// © 2026 John Gary Pusey (see LICENSE.md)

// NOTE: Parked alongside ABCResolver — disabled via `#if false`, preserved
// pending a redesigned resolver.
#if false

private import XestiTools

extension ABCResolver {

    // MARK: Internal Nested Types

    internal struct Resolver {

        // MARK: Internal Initializers

        internal init(tunebook: ABCTunebook) {
            self.tunebook = tunebook
        }

        // MARK: Private Instance Properties

        private let tunebook: ABCTunebook
    }
}

// MARK: -

extension ABCResolver.Resolver {

    // MARK: Internal Nested Types

    // The running resolution scope: the active explicit unit note length (`L:`),
    // meter (`M:`), and key signature (`K:`).
    private struct State {
        var unitNoteLength: ABCLength?
        var meter: ABCTimeSignature?
        var keySignature: ABCKeySignature?
    }

    // MARK: Internal Instance Methods

    internal func resolveTunebook() -> ABCTunebook {
        // `L:`/`M:` declared in the file header carry forward as each tune's
        // starting scope.
        let fileDefaults = _scanDefaults(tunebook.fileHeader)
        let tunes = tunebook.tunes.map { _resolveTune($0, fileDefaults) }

        return ABCTunebook(version: tunebook.version,
                           fileHeader: tunebook.fileHeader,
                           tunes: tunes,
                           isNormalized: tunebook.isNormalized,
                           isValidated: tunebook.isValidated,
                           isResolved: true)
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

    private func _resolveBody(_ body: [ABCBodyEntry],
                              _ state: inout State,
                              _ accidentals: inout ABCAccidentalContext) -> [ABCBodyEntry] {
        body.map { entry in
            switch entry {
            case let .field(field):
                _applyField(field, &state)

                if case .key = field {
                    accidentals = ABCAccidentalContext(keySignature: state.keySignature)
                }

                return entry

            case .directive:
                return entry

            case let .symbols(symbols):
                return .symbols(_resolveSymbols(symbols, &state, &accidentals))
            }
        }
    }

    private func _resolveChord(_ chord: ABCChord,
                               _ state: State,
                               _ accidentals: inout ABCAccidentalContext) -> ABCChord {
        var notes: [ABCNote] = []

        for note in chord.notes {
            notes.append(_resolveNote(note, state, &accidentals))
        }

        return ABCChord(notes: notes,
                        length: _resolveLength(chord.length, state),
                        tie: chord.tie).require()
    }

    private func _resolveGraceNotes(_ graceNotes: ABCGraceNotes,
                                    _ state: State,
                                    _ accidentals: inout ABCAccidentalContext) -> ABCGraceNotes {
        var notes: [ABCNote] = []

        for note in graceNotes.notes {
            notes.append(_resolveNote(note, state, &accidentals))
        }

        return ABCGraceNotes(notes: notes,
                             isSlashed: graceNotes.isSlashed).require()
    }

    private func _resolveLength(_ written: ABCLength,
                                _ state: State) -> ABCLength {
        let base = _effectiveUnitNoteLength(state)

        return ABCLength(numerator: written.numerator * base.numerator,
                         denominator: written.denominator * base.denominator) ?? written
    }

    private func _resolveNote(_ note: ABCNote,
                              _ state: State,
                              _ accidentals: inout ABCAccidentalContext) -> ABCNote {
        let accidental = accidentals.resolveAccidental(for: note)

        accidentals.update(with: note)

        let pitch = ABCPitch(letter: note.pitch.letter,
                             accidental: accidental,
                             octave: note.pitch.octave)

        return ABCNote(pitch: pitch,
                       length: _resolveLength(note.length, state),
                       tie: note.tie)
    }

    private func _resolveRest(_ rest: ABCRest,
                              _ state: State) -> ABCRest {
        switch rest {
        case .multiMeasure:
            rest

        case let .regular(invisible, length):
            .regular(invisible, _resolveLength(length, state))
        }
    }

    private func _resolveSymbols(_ symbols: [ABCSymbol],
                                 _ state: inout State,
                                 _ accidentals: inout ABCAccidentalContext) -> [ABCSymbol] {
        var result: [ABCSymbol] = []

        for symbol in symbols {
            switch symbol {
            case .barLine:
                accidentals.reset()

                result.append(symbol)

            case let .chord(chord):
                result.append(.chord(_resolveChord(chord, state, &accidentals)))

            case let .graceNotes(graceNotes):
                result.append(.graceNotes(_resolveGraceNotes(graceNotes, state, &accidentals)))

            case let .inlineField(field):
                _applyField(field, &state)

                if case .key = field {
                    accidentals = ABCAccidentalContext(keySignature: state.keySignature)
                }

                result.append(symbol)

            case let .note(note):
                result.append(.note(_resolveNote(note, state, &accidentals)))

            case let .rest(rest):
                result.append(.rest(_resolveRest(rest, state)))

            case let .spacer(length):
                result.append(.spacer(_resolveLength(length, state)))

            default:
                result.append(symbol)
            }
        }

        return result
    }

    private func _resolveTune(_ tune: ABCTune,
                              _ fileDefaults: State) -> ABCTune {
        var state = fileDefaults

        for entry in tune.header {
            if case let .field(field) = entry {
                _applyField(field, &state)
            }
        }

        var accidentals = ABCAccidentalContext(keySignature: state.keySignature)
        let body = _resolveBody(tune.body, &state, &accidentals)

        return ABCTune(header: tune.header,
                       body: body).require()
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

#endif
