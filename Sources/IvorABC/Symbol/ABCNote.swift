// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single note in ABC notation.
public struct ABCNote {

    // MARK: Public Initializers

    /// Creates a new note with the provided pitch, duration, and tie flag.
    ///
    /// - Parameter pitch:    The pitch of the note.
    /// - Parameter duration: The duration of the note.
    /// - Parameter isTied:   Whether the note is tied to the next note.
    public init(pitch: ABCPitch,
                duration: ABCDuration,
                isTied: Bool) {
        self.duration = duration
        self.isTied = isTied
        self.pitch = pitch
    }

    // MARK: Public Instance Properties

    /// The duration of this note.
    public let duration: ABCDuration

    /// A Boolean value indicating whether this note is tied to the next note.
    public let isTied: Bool

    /// The pitch of this note.
    public let pitch: ABCPitch
}

// MARK: - Equatable

extension ABCNote: Equatable {
}

// MARK: - Sendable

extension ABCNote: Sendable {
}
