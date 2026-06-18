// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single note in ABC notation.
public struct ABCNote {

    // MARK: Public Initializers

    /// Creates a new note with the provided pitch, duration, and tie.
    ///
    /// - Parameter pitch:    The pitch of the note.
    /// - Parameter duration: The duration of the note.
    /// - Parameter tie:      The tie to the next note, or `nil` if not tied.
    public init(pitch: ABCPitch,
                duration: ABCDuration,
                tie: ABCTie?) {
        self.duration = duration
        self.pitch = pitch
        self.tie = tie
    }

    // MARK: Public Instance Properties

    /// The duration of this note.
    public let duration: ABCDuration

    /// The pitch of this note.
    public let pitch: ABCPitch

    /// The tie to the next note, or `nil` if this note is not tied.
    public let tie: ABCTie?
}

// MARK: - Equatable

extension ABCNote: Equatable {
}

// MARK: - Sendable

extension ABCNote: Sendable {
}
