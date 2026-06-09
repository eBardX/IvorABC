// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC key signature.
public enum ABCKeySignature {
    /// A clef-only specification (no tonic), e.g., `K:clef=treble`.
    case clefOnly(ABCClef)

    /// An empty (key-less) key signature.
    case empty

    /// A Highland pipes key signature with no accidentals (`K:HP`).
    case highlandPipes

    /// A Highland pipes key signature with preset accidentals F♯, C♯, G♯ (`K:Hp`).
    case highlandPipesPreset

    /// A standard key signature with the specified tonic, mode, accidentals,
    /// and optional clef properties.
    case standard(Tonic, Mode, [Accidental], ABCClef?)
}

// MARK: -

extension ABCKeySignature {

    // MARK: Public Nested Types

    /// A type alias for ``ABCPitch`` used to represent accidentals in a key
    /// signature.
    public typealias Accidental = ABCPitch

    // MARK: Public Instance Properties

    /// The accidentals implied by this key signature, keyed by pitch letter.
    ///
    /// Combines the accidentals from the tonic and mode with any explicit
    /// added accidentals (e.g., `K:G add♯F`). Does not include bar-level
    /// accidentals set by notes during the piece — use ``ABCAccidentalContext``
    /// to track those.
    public var keyAccidentals: [ABCPitch.Letter: ABCPitch.Accidental] {
        var result = _baseAccidentals

        if case let .standard(_, _, pitches, _) = self {
            for pitch in pitches where pitch.accidental != .omitted {
                result[pitch.letter] = pitch.accidental
            }
        }

        return result
    }

    // MARK: Private Instance Properties

    private var _baseAccidentals: [ABCPitch.Letter: ABCPitch.Accidental] {
        switch self {
        case .clefOnly,
             .empty,
             .highlandPipes:
            return [:]

        case .highlandPipesPreset:
            return [.c: .sharp,
                    .f: .sharp,
                    .g: .natural]

        case let .standard(tonic, mode, _, _):
            guard let emode = _effectiveMode(for: mode),
                  let count = Self._accidentalCounts[tonic]?[emode]
            else { return [:] }

            return Self._accidentals[count] ?? [:]
        }
    }

    // MARK: Private Instance Methods

    private func _effectiveMode(for mode: Mode) -> Mode? {
        switch mode {
        case .aeolian:
            .minor

        case .explicit:
            nil

        case .ionian:
            .major

        default:
            mode
        }
    }

    // MARK: Private Type Properties

    private static let _accidentalCounts: [Tonic: [Mode: Int]] =
        [.a: [.dorian: 1, .locrian: -2, .lydian: 4, .major: 3, .minor: 0, .mixolydian: 2, .phrygian: -1],
         .aFlat: [.dorian: -6, .lydian: -3, .major: -4, .minor: -7, .mixolydian: -5],
         .aSharp: [.locrian: 5, .minor: 7, .phrygian: 6],
         .b: [.dorian: 3, .locrian: 0, .lydian: 6, .major: 5, .minor: 2, .mixolydian: 4, .phrygian: 1],
         .bFlat: [.dorian: -4, .locrian: -7, .lydian: -1, .major: -2, .minor: -5, .mixolydian: -3, .phrygian: -6],
         .bSharp: [.locrian: 7],
         .c: [.dorian: -2, .locrian: -5, .lydian: 1, .major: 0, .minor: -3, .mixolydian: -1, .phrygian: -4],
         .cFlat: [.lydian: -6, .major: -7],
         .cSharp: [.dorian: 5, .locrian: 2, .lydian: 7, .minor: 4, .mixolydian: 6, .phrygian: 3],
         .d: [.dorian: 0, .locrian: -3, .lydian: 3, .major: 2, .minor: -1, .mixolydian: 1, .phrygian: -2],
         .dFlat: [.dorian: -7, .lydian: -4, .major: -5, .mixolydian: -6],
         .dSharp: [.dorian: 7, .locrian: 4, .minor: 6, .phrygian: 5],
         .e: [.dorian: 2, .locrian: -1, .lydian: 5, .major: 4, .minor: 1, .mixolydian: 3, .phrygian: 0],
         .eFlat: [.dorian: -5, .lydian: -2, .major: -3, .minor: -6, .mixolydian: -4, .phrygian: -7],
         .eSharp: [.locrian: 6, .phrygian: 7],
         .f: [.dorian: -3, .locrian: -6, .lydian: 0, .major: -1, .minor: -4, .mixolydian: -2, .phrygian: -5],
         .fFlat: [.lydian: -7],
         .fSharp: [.dorian: 4, .locrian: 1, .lydian: 7, .major: 6, .minor: 3, .mixolydian: 5, .phrygian: 2],
         .g: [.dorian: -1, .locrian: -4, .lydian: 2, .major: 1, .minor: -2, .mixolydian: 0, .phrygian: -3],
         .gFlat: [.lydian: -5, .major: -6, .mixolydian: -7],
         .gSharp: [.dorian: 6, .locrian: 3, .minor: 5, .mixolydian: 7, .phrygian: 4]]

    private static let _accidentals: [Int: [ABCPitch.Letter: ABCPitch.Accidental]] =
        [-7: [.a: .flat, .b: .flat, .c: .flat, .d: .flat, .e: .flat, .f: .flat, .g: .flat],
         -6: [.a: .flat, .b: .flat, .c: .flat, .d: .flat, .e: .flat, .g: .flat],
         -5: [.a: .flat, .b: .flat, .d: .flat, .e: .flat, .g: .flat],
         -4: [.a: .flat, .b: .flat, .d: .flat, .e: .flat],
         -3: [.a: .flat, .b: .flat, .e: .flat],
         -2: [.b: .flat, .e: .flat],
         -1: [.b: .flat],
         0: [:],
         1: [.f: .sharp],
         2: [.c: .sharp, .f: .sharp],
         3: [.c: .sharp, .f: .sharp, .g: .sharp],
         4: [.c: .sharp, .d: .sharp, .f: .sharp, .g: .sharp],
         5: [.a: .sharp, .c: .sharp, .d: .sharp, .f: .sharp, .g: .sharp],
         6: [.a: .sharp, .c: .sharp, .d: .sharp, .e: .sharp, .f: .sharp, .g: .sharp],
         7: [.a: .sharp, .b: .sharp, .c: .sharp, .d: .sharp, .e: .sharp, .f: .sharp, .g: .sharp]]
}

// MARK: - Equatable

extension ABCKeySignature: Equatable {
}

// MARK: - Sendable

extension ABCKeySignature: Sendable {
}
