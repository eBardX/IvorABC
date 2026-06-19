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
    public init?(placement: Placement,
                 text: String) {
        guard Self._isValid(placement, text)
        else { return nil }

        self.placement = placement
        self.text = text
    }
}

// MARK: -

extension ABCAnnotation {

    // MARK: Private Type Methods

    private static func _isValid(_ placement: Placement,
                                 _ text: String) -> Bool {
        !text.isEmpty
    }
}

// MARK: - Equatable

extension ABCAnnotation: Equatable {
}

// MARK: - Sendable

extension ABCAnnotation: Sendable {
}
