// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension ABCKeySignature {

    // MARK: Public Nested Types

    /// The mode of an ABC key signature.
    public enum Mode {
        /// The Aeolian mode. An alias for ``minor``; see ``effectiveMode(for:)``.
        case aeolian

        /// The Dorian mode.
        case dorian

        /// An explicitly specified mode using accidentals directly.
        case explicit

        /// The Ionian mode. An alias for ``major``; see ``effectiveMode(for:)``.
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

// MARK: -

extension ABCKeySignature.Mode {

    // MARK: Public Type Methods

    /// Returns the effective mode for the given mode, resolving aliases
    /// (``aeolian`` to ``minor`` and ``ionian`` to ``major``) and leaving all
    /// other modes unchanged.
    ///
    /// - Parameter mode:   The mode to resolve.
    ///
    /// - Returns:  The canonical equivalent of `mode`.
    public static func effectiveMode(for mode: Self) -> Self {
        switch mode {
        case .aeolian:
            .minor

        case .ionian:
            .major

        default:
            mode
        }
    }
}

// MARK: - Equatable

extension ABCKeySignature.Mode: Equatable {
}

// MARK: - Sendable

extension ABCKeySignature.Mode: Sendable {
}
