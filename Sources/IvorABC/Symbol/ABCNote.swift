// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single note in ABC notation.
public struct ABCNote {

    // MARK: Public Initializers

    /// Creates a new note with the provided pitch, length, and tie.
    ///
    /// - Parameter pitch:  The pitch of the note.
    /// - Parameter length: The written length of the note, expressed as a
    ///                     multiplier of the unit note length (`L:`). A value of
    ///                     `1/1` is a note written with no length modifier.
    /// - Parameter tie:    The tie to the next note, or `nil` if not tied.
    public init(pitch: ABCPitch,
                length: ABCLength,
                tie: ABCTie?) {
        self.length = length
        self.pitch = pitch
        self.tie = tie
    }

    // MARK: Public Instance Properties

    /// The written length of this note as a multiplier of the unit note length.
    ///
    /// This is the length exactly as written — e.g. `2/1` for `C2`, `1/2` for
    /// `C/`, `1/1` for a bare `C`. It is *not* an absolute length; it must be
    /// resolved against the active unit note length (`L:`).
    public let length: ABCLength

    /// The pitch of this note.
    public let pitch: ABCPitch

    /// The tie to the next note, or `nil` if this note is not tied.
    public let tie: ABCTie?
}

// NOTE: Resolver-related — parked (disabled via `#if false`) pending a
// redesigned resolver.
#if false

// MARK: -

extension ABCNote {

    // MARK: Public Instance Methods

    /// Resolves this note's written length against a unit note length to produce
    /// its absolute length as a fraction of a whole note.
    ///
    /// - Parameter unitNoteLength: The active unit note length (`L:`).
    ///
    /// - Returns:  The absolute length, or `nil` if the resolved value cannot
    ///             be represented as an ``ABCLength``.
    public func resolve(unitNoteLength: ABCLength) -> ABCLength? {
        ABCLength(numerator: length.numerator * unitNoteLength.numerator,
                  denominator: length.denominator * unitNoteLength.denominator)
    }
}

#endif

// MARK: - Equatable

extension ABCNote: Equatable {
}

// MARK: - Sendable

extension ABCNote: Sendable {
}
