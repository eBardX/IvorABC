// © 2026 John Gary Pusey (see LICENSE.md)

/// Clef and transposition properties that can appear in a `K:` or `V:` field.
public struct ABCClef {

    // MARK: Public Initializers

    public init(name: String? = nil,
                middle: String? = nil,
                octave: Int? = nil,
                stafflines: Int? = nil,
                transpose: Int? = nil) {
        self.middle = middle
        self.name = name
        self.octave = octave
        self.stafflines = stafflines
        self.transpose = transpose
    }

    // MARK: Public Instance Properties

    /// The note shown in the middle of the staff (e.g., `"B"`), or `nil` if
    /// not specified.
    public let middle: String?

    /// The clef name (e.g., `"treble"`, `"bass"`, `"alto"`, `"tenor"`,
    /// `"perc"`, `"none"`), or `nil` if not specified.
    public let name: String?

    /// Transposition in octaves, or `nil` if not specified.
    public let octave: Int?

    /// The number of staff lines, or `nil` if not specified.
    public let stafflines: Int?

    /// Transposition in semitones, or `nil` if not specified.
    public let transpose: Int?
}

// MARK: - Equatable

extension ABCClef: Equatable {
}

// MARK: - Sendable

extension ABCClef: Sendable {
}
