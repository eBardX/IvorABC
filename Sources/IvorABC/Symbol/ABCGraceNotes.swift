// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A group of grace notes in ABC notation.
public struct ABCGraceNotes {

    // MARK: Public Initializers

    /// Creates a new grace note group with the provided slash flag and notes.
    ///
    /// - Parameter isSlashed: Whether the grace note group has a slash (acciaccatura).
    /// - Parameter notes:     The notes in the group.
    public init(isSlashed: Bool,
                notes: [ABCNote]) {
        self.isSlashed = isSlashed
        self.notes = notes
    }

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this grace note group has a slash (acciaccatura).
    public let isSlashed: Bool

    /// The notes in this grace note group.
    public let notes: [ABCNote]
}

// MARK: - Equatable

extension ABCGraceNotes: Equatable {
}

// MARK: - Sendable

extension ABCGraceNotes: Sendable {
}
