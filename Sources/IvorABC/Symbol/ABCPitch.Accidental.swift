// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension ABCPitch {
    /// The accidental of an ABC pitch.
    public enum Accidental {
        /// A double flat (𝄫).
        case doubleFlat

        /// A flat (♭).
        case flat

        /// A natural (♮).
        case natural

        /// A sharp (♯).
        case sharp

        /// A double sharp (𝄪).
        case doubleSharp

        /// No accidental was written in the source.
        case omitted
    }
}

// MARK: - Equatable

extension ABCPitch.Accidental: Equatable {
}

// MARK: - Sendable

extension ABCPitch.Accidental: Sendable {
}
