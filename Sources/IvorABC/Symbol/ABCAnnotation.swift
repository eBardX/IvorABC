// © 2026 John Gary Pusey (see LICENSE.md)

/// An annotation in ABC music notation.
public struct ABCAnnotation {

    // MARK: Public Instance Properties

    /// The placement of the annotation relative to the staff.
    public let placement: Placement

    /// The annotation text, without the surrounding quotes or placement prefix.
    public let text: String

    // MARK: Public Initializers

    /// Creates a new annotation.
    ///
    /// - Parameter placement: The placement of the annotation relative to the
    ///                        staff.
    /// - Parameter text:      The annotation text, without the surrounding quotes
    ///                        or placement prefix.
    public init(placement: Placement,
                text: String) {
        self.placement = placement
        self.text = text            // validate ???
    }
}

// MARK: - Equatable

extension ABCAnnotation: Equatable {
}

// MARK: - Sendable

extension ABCAnnotation: Sendable {
}
