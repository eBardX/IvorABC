// © 2026 John Gary Pusey (see LICENSE.md)

/// A fully resolved note for playback or rendering.
///
/// Unlike ``ABCNote``, whose ``ABCPitch/accidental`` may be `.omitted` and
/// whose length is written relative to the unit note length, `ABCScoreNote`
/// always carries an explicit accidental and an absolute duration.
public struct ABCScoreNote {

    // MARK: Public Initializers

    /// Creates a new resolved note, or `nil` if `pitch` has an omitted
    /// accidental.
    ///
    /// - Parameter pitch:      The resolved pitch. Must not have an
    ///                         `.omitted` accidental.
    /// - Parameter duration:   The absolute duration of the note.
    /// - Parameter tie:        The tie to the next note, or `nil` if not
    ///                         tied. Defaults to `nil`.
    /// - Parameter slurStart:  Whether a slur starts on this note. Defaults
    ///                         to `false`.
    /// - Parameter slurEnd:    Whether a slur ends on this note. Defaults to
    ///                         `false`.
    public init?(pitch: ABCPitch,               // make this internal ???
                 duration: ABCScoreDuration,
                 tie: ABCTie? = nil,
                 slurStart: Bool = false,
                 slurEnd: Bool = false) {
        guard Self._isValid(pitch)
        else { return nil }

        self.duration = duration
        self.pitch = pitch
        self.slurEnd = slurEnd
        self.slurStart = slurStart
        self.tie = tie
    }

    // MARK: Public Instance Properties

    /// The absolute duration of this note.
    public let duration: ABCScoreDuration

    /// The resolved pitch of this note. Never has an `.omitted` accidental.
    public let pitch: ABCPitch

    /// Whether a slur ends on this note.
    public let slurEnd: Bool

    /// Whether a slur starts on this note.
    public let slurStart: Bool

    /// The tie to the next note, or `nil` if this note is not tied.
    public let tie: ABCTie?
}

// MARK: -

extension ABCScoreNote {

    // MARK: Private Type Methods

    private static func _isValid(_ pitch: ABCPitch) -> Bool {
        pitch.accidental != .omitted
    }
}

// MARK: - Equatable

extension ABCScoreNote: Equatable {
}

// MARK: - Sendable

extension ABCScoreNote: Sendable {
}
