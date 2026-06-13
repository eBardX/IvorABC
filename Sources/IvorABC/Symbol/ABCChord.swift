// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A chord in ABC notation.
public struct ABCChord {

    // MARK: Public Initializers

    /// Creates a new chord with the provided notes, duration, and tie flag, or
    /// `nil` if `notes` is empty.
    ///
    /// - Parameter notes:    The notes in the chord. Must not be empty.
    /// - Parameter duration: The chord-level duration (written after the closing `]`).
    /// - Parameter isTied:   Whether the chord is tied to the next chord or note.
    public init?(notes: [ABCNote],
                 duration: ABCDuration,
                 isTied: Bool) {
        guard !notes.isEmpty
        else { return nil }

        self.init(notes, duration, isTied)
    }

    // MARK: Public Instance Properties

    /// The chord-level duration (written after the closing `]`).
    public let duration: ABCDuration

    /// A Boolean value indicating whether this chord is tied to the next chord or note.
    public let isTied: Bool

    /// The notes in this chord.
    public let notes: [ABCNote]

    // MARK: Internal Initializers

    internal init(_ notes: [ABCNote],
                  _ duration: ABCDuration,
                  _ isTied: Bool) {
        self.duration = duration
        self.isTied = isTied
        self.notes = notes
    }
}

// MARK: - Equatable

extension ABCChord: Equatable {
}

// MARK: - Sendable

extension ABCChord: Sendable {
}
