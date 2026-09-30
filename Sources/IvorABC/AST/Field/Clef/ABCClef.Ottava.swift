// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCClef {

    // MARK: Public Nested Types

    /// The ottava marker on an ABC clef (`+8` or `-8`).
    public enum Ottava {

        /// The `+8` ottava marker; draws ‘8’ above the staff and transposes up
        /// one octave for playback.
        case alta

        /// The `-8` ottava marker; draws ‘8’ below the staff and transposes down
        /// one octave for playback.
        case bassa
    }
}

// MARK: - Equatable

extension ABCClef.Ottava: Equatable {
}

// MARK: - Sendable

extension ABCClef.Ottava: Sendable {
}
