// © 2026 John Gary Pusey (see LICENSE.md)

/// Clef and transposition properties that can appear in a `K:` or `V:` field.
public struct ABCClef {

    // MARK: Public Instance Properties

    /// The note shown in the middle of the staff (e.g., `"B"`), or `nil` if
    /// not specified.
    public var middle: String?

    /// The clef name (e.g., `"treble"`, `"bass"`, `"alto"`, `"tenor"`,
    /// `"perc"`, `"none"`), or `nil` if not specified.
    public var name: String?

    /// Transposition in octaves, or `nil` if not specified.
    public var octave: Int?

    /// The number of staff lines, or `nil` if not specified.
    public var stafflines: Int?

    /// Transposition in semitones, or `nil` if not specified.
    public var transpose: Int?
}

// MARK: - Equatable

extension ABCClef: Equatable {
}

// MARK: - Sendable

extension ABCClef: Sendable {
}
