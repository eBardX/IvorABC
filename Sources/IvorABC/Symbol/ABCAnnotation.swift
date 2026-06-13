// © 2026 John Gary Pusey (see LICENSE.md)

/// An annotation in ABC music notation.
public struct ABCAnnotation {

    // MARK: Public Instance Properties

    /// The position of the annotation relative to the staff.
    public let position: Position

    /// The annotation text, without the surrounding quotes or positioning prefix.
    public let text: String

    // MARK: Public Initializers

    /// Creates a new annotation.
    ///
    /// - Parameter position: The position of the annotation relative to the
    ///                       staff.
    /// - Parameter text:     The annotation text, without the surrounding quotes
    ///                       or positioning prefix.
    public init(position: Position,
                text: String) {
        self.position = position
        self.text = text        // validate?
    }
}

// MARK: - Equatable

extension ABCAnnotation: Equatable {
}

// MARK: - Sendable

extension ABCAnnotation: Sendable {
}
