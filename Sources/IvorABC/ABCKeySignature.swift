// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC key signature.
public enum ABCKeySignature {
    /// An empty (key-less) key signature.
    case empty

    /// A Highland pipes key signature.
    case highlandPipes

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
