// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCAnnotation {

    // MARK: Public Nested Types

    /// The placement of an annotation relative to the following note, rest, or
    /// bar line.
    public enum Placement {
        /// Place above the following note, rest, or bar line (`^`).
        case above

        /// Place at the discretion of the interpreting program  (`@`).
        case auto

        /// Place below the following note, rest, or bar line (`_`).
        case below

        /// Place to the left of the following note, rest, or bar line (`<`).
        case left

        /// Place to the right of the following note, rest, or bar line (`>`).
        case right
    }
}

// MARK: - Equatable

extension ABCAnnotation.Placement: Equatable {
}

// MARK: - Sendable

extension ABCAnnotation.Placement: Sendable {
}
