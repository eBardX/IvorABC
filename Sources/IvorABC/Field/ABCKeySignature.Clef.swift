// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCKeySignature {

    // MARK: Public Nested Types

    /// Clef and transposition properties that can appear in a `K:` field.
    public struct Clef {

        // MARK: Public Initializers

        /// Creates a new clef specification.
        ///
        /// All parameters default to `nil`, meaning unspecified.
        ///
        /// - Parameter name:       The clef name (e.g., `"treble"`, `"bass"`,
        ///                         `"alto"`, `"tenor"`, `"perc"`, `"none"`).
        /// - Parameter middle:     The note shown in the middle of the staff
        ///                         (e.g., `"B"`).
        /// - Parameter octave:     Transposition in octaves.
        /// - Parameter stafflines: The number of staff lines.
        /// - Parameter transpose:  Transposition in semitones.
        public init(name: String? = nil,
                    middle: String? = nil,
                    octave: Int? = nil,
                    stafflines: Int? = nil,
                    transpose: Int? = nil) {    // validate ???
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
}

// MARK: - Equatable

extension ABCKeySignature.Clef: Equatable {
}

// MARK: - Sendable

extension ABCKeySignature.Clef: Sendable {
}
