// © 2026 John Gary Pusey (see LICENSE.md)

/// A fully resolved chord for playback or rendering.
///
/// All notes in the chord share a single absolute ``duration`` and ``tie``,
/// matching how a chord is written in ABC notation (e.g. `[CEG]2-`).
public struct ABCScoreChord {

    // MARK: Internal Initializers

    /// Creates a new resolved chord, or `nil` if `notes` is empty.
    ///
    /// - Parameter notes:    The resolved notes in the chord. Must not be
    ///                       empty.
    /// - Parameter duration: The absolute duration shared by every note in
    ///                       the chord.
    /// - Parameter tie:      The tie to the next chord, or `nil` if not tied.
    ///                       Defaults to `nil`.
    internal init?(notes: [ABCScoreNote],
                   duration: ABCScoreDuration,
                   tie: ABCTie? = nil) {
        guard Self._isValid(notes)
        else { return nil }

        self.duration = duration
        self.notes = notes
        self.tie = tie
    }

    // MARK: Public Instance Properties

    /// The absolute duration shared by every note in this chord.
    public let duration: ABCScoreDuration

    /// The resolved notes in this chord.
    public let notes: [ABCScoreNote]

    /// The tie to the next chord, or `nil` if this chord is not tied.
    public let tie: ABCTie?
}

// MARK: -

extension ABCScoreChord {

    // MARK: Private Type Methods

    private static func _isValid(_ notes: [ABCScoreNote]) -> Bool {
        !notes.isEmpty
    }
}

// MARK: - Equatable

extension ABCScoreChord: Equatable {
}

// MARK: - Sendable

extension ABCScoreChord: Sendable {
}
