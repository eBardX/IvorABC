// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension ABCKeySignature {
    /// The mode of an ABC key signature.
    public enum Mode {
        /// The Aeolian mode.
        case aeolian

        /// The Dorian mode.
        case dorian

        /// An explicitly specified mode using accidentals directly.
        case explicit

        /// The Ionian mode.
        case ionian

        /// The Locrian mode.
        case locrian

        /// The Lydian mode.
        case lydian

        /// The major mode.
        case major

        /// The minor mode.
        case minor

        /// The Mixolydian mode.
        case mixolydian

        /// The Phrygian mode.
        case phrygian
    }
}

// MARK: - Equatable

extension ABCKeySignature.Mode: Equatable {
}

// MARK: - Sendable

extension ABCKeySignature.Mode: Sendable {
}
