// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCClef {

    // MARK: Public Nested Types

    /// The pitch displayed on the middle (3rd) line of the staff: a pitch
    /// letter with an octave, but without an accidental.
    public struct Middle {

        // MARK: Public Initializers

        /// Creates a new middle pitch with the given letter and octave.
        ///
        /// - Parameter letter: The letter name of the pitch.
        /// - Parameter octave: The octave number of the pitch.
        public init(letter: ABCPitch.Letter,
                    octave: ABCPitch.Octave) {
            self.letter = letter
            self.octave = octave
        }

        // MARK: Public Instance Properties

        /// The letter name of this pitch.
        public let letter: ABCPitch.Letter

        /// The octave number of this pitch.
        public let octave: ABCPitch.Octave
    }
}

// MARK: - Equatable

extension ABCClef.Middle: Equatable {
}

// MARK: - Sendable

extension ABCClef.Middle: Sendable {
}
