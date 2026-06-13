// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCAnnotation {

    // MARK: Public Nested Types

    /// The positioning of an annotation relative to the staff.
    public enum Position {
        /// Above the staff (`^`).
        case above

        /// Automatically positioned by the renderer (`@`).
        case auto

        /// Below the staff (`_`).
        case below

        /// To the left of the note (`<`).
        case left

        /// To the right of the note (`>`).
        case right
    }
}

// MARK: -

extension ABCAnnotation.Position {

    // MARK: Internal Initializers

    internal init?(prefix: Character) {
        switch prefix {
        case "^":
            self = .above

        case "@":
            self = .auto

        case "_":
            self = .below

        case "<":
            self = .left

        case ">":
            self = .right

        default:
            return nil
        }
    }

    // MARK: Internal Instance Properties

    internal var prefix: Character {
        switch self {
        case .above:
            "^"

        case .auto:
            "@"

        case .below:
            "_"

        case .left:
            "<"

        case .right:
            ">"
        }
    }
}

// MARK: - Equatable

extension ABCAnnotation.Position: Equatable {
}

// MARK: - Sendable

extension ABCAnnotation.Position: Sendable {
}
