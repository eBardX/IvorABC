// © 2026 John Gary Pusey (see LICENSE.md)

/// A group of fully resolved grace notes for playback or rendering.
///
/// Grace notes are ornamental: they are not part of the main duration
/// timeline, so a consumer typically renders or plays them outside the
/// accumulated duration of the notes/chords/rests they attach to.
public struct ABCScoreGraceNotes {

    // MARK: Public Initializers

    /// Creates a new grace note group with the provided slash flag and
    /// resolved notes, or `nil` if `notes` is empty.
    ///
    /// - Parameter notes:     The resolved notes in the group. Must not be
    ///                        empty.
    /// - Parameter isSlashed: Whether the grace note group has a slash
    ///                        (acciaccatura).
    public init?(notes: [ABCScoreNote],     // make this internal ???
                 isSlashed: Bool) {
        guard Self._isValid(notes)
        else { return nil }

        self.isSlashed = isSlashed
        self.notes = notes
    }

    // MARK: Public Instance Properties

    /// Whether this grace note group has a slash (acciaccatura).
    public let isSlashed: Bool

    /// The resolved notes in this grace note group.
    public let notes: [ABCScoreNote]
}

// MARK: -

extension ABCScoreGraceNotes {

    // MARK: Private Type Methods

    private static func _isValid(_ notes: [ABCScoreNote]) -> Bool {
        !notes.isEmpty
    }
}

// MARK: - Equatable

extension ABCScoreGraceNotes: Equatable {
}

// MARK: - Sendable

extension ABCScoreGraceNotes: Sendable {
}
