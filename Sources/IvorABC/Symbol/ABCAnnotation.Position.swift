// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCAnnotation {

    // MARK: Public Nested Types

    /// The positioning of an annotation relative to the staff.
    public enum Position {  // rename to `Positioning` or `Placement` ???
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

// MARK: - Equatable

extension ABCAnnotation.Position: Equatable {
}

// MARK: - Sendable

extension ABCAnnotation.Position: Sendable {
}
