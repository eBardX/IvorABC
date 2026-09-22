// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension ABCPitch {

    // MARK: Public Nested Types

    /// The accidental of an ABC pitch.
    public enum Accidental {
        /// A double flat (𝄫).
        case doubleFlat

        /// A double sharp (𝄪).
        case doubleSharp

        /// A flat (♭).
        case flat

        /// A natural (♮).
        case natural

        /// No accidental was written in the source.
        case omitted

        /// A sharp (♯).
        case sharp
    }
}

// MARK: - Equatable

extension ABCPitch.Accidental: Equatable {
}

// MARK: - Sendable

extension ABCPitch.Accidental: Sendable {
}
