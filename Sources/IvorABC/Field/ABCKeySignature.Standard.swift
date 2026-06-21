// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension ABCKeySignature {

    // MARK: Public Nested Types

    /// The associated value type for the ``ABCKeySignature/standard(_:)`` case.
    public struct Standard {

        // MARK: Public Initializers

        /// Creates a new standard key signature specification, or returns `nil`
        /// if `tonic` and `mode` do not form a recognized key signature.
        ///
        /// `.explicit` mode is always accepted regardless of tonic.
        ///
        /// - Parameter tonic:              The tonic note of the key signature.
        /// - Parameter mode:               The mode of the key signature.
        /// - Parameter extraAccidentals:   Extra accidentals to overlay on the key
        ///                                 (e.g., `K:D Phr ^f`). Defaults to none.
        /// - Parameter clef:               Optional clef and transposition properties.
        ///                                 Defaults to `nil`.
        public init?(tonic: Tonic,
                     mode: Mode,
                     extraAccidentals: [ExtraAccidental] = [],
                     clef: Clef? = nil) {
            guard Self._isValid(tonic, mode, extraAccidentals, clef)
            else { return nil }

            self.clef = clef
            self.extraAccidentals = extraAccidentals
            self.mode = mode
            self.tonic = tonic
        }

        // MARK: Public Instance Properties

        /// Optional clef and transposition properties.
        public let clef: Clef?

        /// Extra accidentals overlaid on the key signature beyond those
        /// implied by the tonic and mode (e.g., `K:D Phr ^f`).
        public let extraAccidentals: [ExtraAccidental]

        /// The mode of the key signature.
        public let mode: Mode

        /// The tonic note of the key signature.
        public let tonic: Tonic
    }
}

// MARK: -

extension ABCKeySignature.Standard {

    // MARK: Internal Type Properties

    internal static let accidentalCounts: [ABCKeySignature.Tonic: [ABCKeySignature.Mode: Int]] =
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

    // MARK: Private Type Methods

    private static func _isValid(_ tonic: ABCKeySignature.Tonic,
                                 _ mode: ABCKeySignature.Mode,
                                 _ extraAccidentals: [ABCKeySignature.ExtraAccidental],
                                 _ clef: ABCKeySignature.Clef?) -> Bool {
        let emode = ABCKeySignature.Mode.effectiveMode(for: mode)

        guard emode == .explicit || Self.accidentalCounts[tonic]?[emode] != nil
        else { return false }

        for xacc in extraAccidentals where xacc.accidental == .omitted {
            return false
        }

        return true
    }
}

// MARK: - Equatable

extension ABCKeySignature.Standard: Equatable {
}

// MARK: - Sendable

extension ABCKeySignature.Standard: Sendable {
}
