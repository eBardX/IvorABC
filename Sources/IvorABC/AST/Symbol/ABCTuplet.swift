// © 2026 John Gary Pusey (see LICENSE.md)

/// A tuplet specification in ABC music notation.
///
/// See §4.13 (“Duplets, triplets, quadruplets, etc.”) of the ABC 2.1 standard.
public struct ABCTuplet {

    // MARK: Public Initializers

    /// Creates a new tuplet specification, or `nil` if the arguments are
    /// invalid.
    ///
    /// `noteCount` must be in the range 2–9, matching the values defined by
    /// the ABC standard. When given explicitly, `beatCount` and
    /// `affectedCount` must each be greater than zero.
    ///
    /// - Parameter noteCount:     The number of notes in the tuplet group.
    /// - Parameter beatCount:     The number of beats the group occupies, or
    ///                            `nil` when not explicitly written in the
    ///                            source.
    /// - Parameter affectedCount: The number of notes the specification applies
    ///                            to, or `nil` when not explicitly written in the
    ///                            source.
    public init?(noteCount: UInt,
                 beatCount: UInt? = nil,
                 affectedCount: UInt? = nil) {
        guard Self._isValid(noteCount, beatCount, affectedCount)
        else { return nil }

        self.affectedCount = affectedCount
        self.beatCount = beatCount
        self.noteCount = noteCount
    }

    // MARK: Public Instance Properties

    /// The number of notes the specification applies to, or `nil` when not
    /// explicitly written in the source.
    public let affectedCount: UInt?

    /// The number of beats the group occupies, or `nil` when not explicitly
    /// written in the source.
    public let beatCount: UInt?

    /// The number of notes in the tuplet group.
    public let noteCount: UInt
}

// MARK: -

extension ABCTuplet {

    // MARK: Private Type Methods

    private static func _isValid(_ noteCount: UInt,
                                 _ beatCount: UInt?,
                                 _ affectedCount: UInt?) -> Bool {
        guard (2...9).contains(noteCount)
        else { return false }

        if let beatCount, beatCount == 0 {
            return false
        }

        if let affectedCount, affectedCount == 0 {
            return false
        }

        return true
    }
}

// MARK: - Equatable

extension ABCTuplet: Equatable {
}

// MARK: - Sendable

extension ABCTuplet: Sendable {
}
