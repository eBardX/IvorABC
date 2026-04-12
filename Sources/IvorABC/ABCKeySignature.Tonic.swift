// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension ABCKeySignature {
    /// The tonic (root note) of an ABC key signature.
    public enum Tonic {
        /// The note A.
        case a

        /// The note A♭.
        case aFlat

        /// The note A♯.
        case aSharp

        /// The note B.
        case b

        /// The note B♭.
        case bFlat

        /// The note B♯.
        case bSharp

        /// The note C.
        case c

        /// The note C♭.
        case cFlat

        /// The note C♯.
        case cSharp

        /// The note D.
        case d

        /// The note D♭.
        case dFlat

        /// The note D♯.
        case dSharp

        /// The note E.
        case e

        /// The note E♭.
        case eFlat

        /// The note E♯.
        case eSharp

        /// The note F.
        case f

        /// The note F♭.
        case fFlat

        /// The note F♯.
        case fSharp

        /// The note G.
        case g

        /// The note G♭.
        case gFlat

        /// The note G♯.
        case gSharp
    }
}

// MARK: - Equatable

extension ABCKeySignature.Tonic: Equatable {
}

// MARK: - Sendable

extension ABCKeySignature.Tonic: Sendable {
}
