// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension ABCPitch {
    /// The letter name of an ABC pitch.
    public enum Letter {
        /// The pitch letter A.
        case a

        /// The pitch letter B.
        case b

        /// The pitch letter C.
        case c

        /// The pitch letter D.
        case d

        /// The pitch letter E.
        case e

        /// The pitch letter F.
        case f

        /// The pitch letter G.
        case g
    }
}

// MARK: - Equatable

extension ABCPitch.Letter: Equatable {
}

// MARK: - Sendable

extension ABCPitch.Letter: Sendable {
}
