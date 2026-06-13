// © 2026 John Gary Pusey (see LICENSE.md)

/// A tuplet specification in ABC music notation.
public struct ABCTuplet {

    // MARK: Public Initializers

    /// Creates a new tuplet specification, or `nil` if `noteCount` is zero.
    ///
    /// - Parameter noteCount:     The number of notes in the tuplet group.
    ///                            Must be greater than zero.
    /// - Parameter beatCount:     The number of beats the group occupies, or
    ///                            `nil` when not explicitly written in the
    ///                            source.
    /// - Parameter affectedCount: The number of notes the specification applies
    ///                            to, or `nil` when not explicitly written in the
    ///                            source.
    public init?(noteCount: UInt,
                 beatCount: UInt? = nil,
                 affectedCount: UInt? = nil) {
        guard noteCount > 0 // other validation?
        else { return nil }

        self.affectedCount = affectedCount
        self.beatCount = beatCount
        self.noteCount = noteCount
    }

    // MARK: Public Instance Properties

    /// The number of notes the specification applies to, or `nil` when not
    /// explicitly written in the source.
    public let affectedCount: UInt?

    /// The number of notes in the tuplet group.
    public let noteCount: UInt

    /// The number of beats the group occupies, or `nil` when not explicitly
    /// written in the source.
    public let beatCount: UInt?
}

// MARK: -

extension ABCTuplet {

    // MARK: Public Instance Methods

    /// Returns the fully resolved `(noteCount, beatCount, affectedCount)`
    /// components with ABC default rules applied for any `nil` component.
    ///
    /// `affectedCount` defaults to `noteCount`. `beatCount` defaults based on
    /// `noteCount` and whether `meter` is a compound meter: 3 when
    /// `noteCount` is 2, 4, or 8; 2 when `noteCount` is 3 or 6; otherwise 3
    /// in compound meter or 2 in simple meter.
    ///
    /// - Parameter meter:  The current time signature, used to resolve a
    ///                     `nil` `beatCount` for non-standard tuplet sizes.
    ///                     Pass `nil` or omit to assume simple meter.
    ///
    /// - Returns:  The resolved `(noteCount, beatCount, affectedCount)` tuple.
    public func resolve(meter: ABCTimeSignature? = nil) -> (noteCount: UInt, beatCount: UInt, affectedCount: UInt) {
        (noteCount,
         beatCount ?? Self._defaultBeatCount(noteCount: noteCount,
                                             isCompound: meter?.isCompound ?? false),
         affectedCount ?? noteCount)
    }

    // MARK: Private Type Methods

    private static func _defaultBeatCount(noteCount: UInt,
                                          isCompound: Bool) -> UInt {
        switch noteCount {
        case 2,
             4,
             8:
            3

        case 3,
             6:
            2

        default:
            isCompound ? 3 : 2
        }
    }
}

// MARK: - Equatable

extension ABCTuplet: Equatable {
}

// MARK: - Sendable

extension ABCTuplet: Sendable {
}
