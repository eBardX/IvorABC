// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC key signature.
public enum ABCKeySignature {
    /// An empty (key-less) key signature.
    case empty

    /// A Highland pipes key signature with no accidentals (`K:HP`).
    case highlandPipes

    /// A Highland pipes key signature with preset accidentals F♯, C♯, G♯ (`K:Hp`).
    case highlandPipesPreset

    /// A standard key signature with the specified tonic, mode, and
    /// accidentals.
    case standard(Tonic, Mode, [Accidental])
}

// MARK: -

extension ABCKeySignature {

    // MARK: Public Nested Types

    /// A type alias for ``ABCPitch`` used to represent accidentals in a key
    /// signature.
    public typealias Accidental = ABCPitch
}

// MARK: - Equatable

extension ABCKeySignature: Equatable {
}

// MARK: - Sendable

extension ABCKeySignature: Sendable {
}
