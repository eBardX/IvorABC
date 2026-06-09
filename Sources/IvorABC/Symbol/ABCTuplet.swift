// © 2026 John Gary Pusey (see LICENSE.md)

/// A tuplet specification in ABC music notation.
public struct ABCTuplet {

    // MARK: Public Instance Properties

    /// The number of notes in the tuplet group.
    public let noteCount: UInt

    /// The number of beats the group occupies, or `nil` when not explicitly
    /// written in the source.
    public let beatCount: UInt?

    /// The number of notes the specification applies to, or `nil` when not
    /// explicitly written in the source.
    public let affectedCount: UInt?

    // MARK: Public Initializers

    /// Creates a new tuplet specification.
    ///
    /// - Parameter noteCount:     The number of notes in the tuplet group.
    /// - Parameter beatCount:     The number of beats the group occupies, or
    ///                            `nil` when not explicitly written in the
    ///                            source.
    /// - Parameter affectedCount: The number of notes the specification applies
    ///                            to, or `nil` when not explicitly written in the
    ///                            source.
    public init(noteCount: UInt,
                beatCount: UInt? = nil,
                affectedCount: UInt? = nil) {
        self.noteCount = noteCount
        self.beatCount = beatCount
        self.affectedCount = affectedCount
    }
}

// MARK: -

extension ABCTuplet {

    // MARK: Internal Computed Properties

    internal var stringValue: String {
        var result = "(\(noteCount)"

        if let q = beatCount {
            result += ":\(q)"

            if let r = affectedCount {
                result += ":\(r)"
            }
        }

        return result
    }

    // MARK: Internal Initializers

    /// Parses a tuplet from the ABC token text (e.g. `(3` or `(3:2` or
    /// `(3:2:4`).
    internal init?(stringValue: some StringProtocol) {
        guard let result = parseTuplet(String(stringValue)[...])
        else { return nil }

        self.noteCount = result.pcount
        self.beatCount = result.qcount
        self.affectedCount = result.rcount
    }

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
