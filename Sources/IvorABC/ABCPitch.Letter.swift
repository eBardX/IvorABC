// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension ABCPitch {
    /// The letter name of an ABC pitch.
    public enum Letter {
        /// The note A.
        case a

        /// The note B.
        case b

        /// The note C.
        case c

        /// The note D.
        case d

        /// The note E.
        case e

        /// The note F.
        case f

        /// The note G.
        case g
    }
}

// MARK: - Equatable

extension ABCPitch.Letter: Equatable {
}

// MARK: - Sendable

extension ABCPitch.Letter: Sendable {
}
