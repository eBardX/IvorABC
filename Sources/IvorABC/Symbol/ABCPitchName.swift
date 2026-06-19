// © 2026 John Gary Pusey (see LICENSE.md)

/// A pitch name in ABC music notation: a note letter with an optional flat or sharp accidental.
///
/// Unlike ``ABCPitch``, `ABCPitchName` carries no octave information and supports only
/// flat and sharp accidentals. It is used wherever a pitch class is needed without octave
/// context, such as key signature tonics and chord symbol roots.
public enum ABCPitchName {
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

// MARK: - Equatable

extension ABCPitchName: Equatable {
}

// MARK: - Sendable

extension ABCPitchName: Sendable {
}
