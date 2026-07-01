// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A chord in ABC notation.
public struct ABCChord {

    // MARK: Public Initializers

    /// Creates a new chord with the provided notes, length, and tie, or
    /// `nil` if `notes` is empty.
    ///
    /// - Parameter notes:  The notes in the chord. Must not be empty.
    /// - Parameter length: The chord-level written length (written after the
    ///                     closing `]`), as a multiplier of the unit note length.
    /// - Parameter tie:    The tie to the next chord or note, or `nil` if not tied.
    public init?(notes: [ABCNote],
                 length: ABCLength,
                 tie: ABCTie?) {
        guard Self._isValid(notes, length, tie)
        else { return nil }

        self.length = length
        self.notes = notes
        self.tie = tie
    }

    // MARK: Public Instance Properties

    /// The chord-level written length (written after the closing `]`), as a
    /// multiplier of the unit note length.
    public let length: ABCLength

    /// The notes in this chord.
    public let notes: [ABCNote]

    /// The tie to the next chord or note, or `nil` if this chord is not tied.
    public let tie: ABCTie?
}

// MARK: -

extension ABCChord {

    // MARK: Private Type Methods

    private static func _isValid(_ notes: [ABCNote],
                                 _ length: ABCLength,
                                 _ tie: ABCTie?) -> Bool {
        !notes.isEmpty
    }
}

// MARK: - Equatable

extension ABCChord: Equatable {
}

// MARK: - Sendable

extension ABCChord: Sendable {
}
