// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC tempo specification.
public struct ABCTempo {

    // MARK: Public Initializers

    /// Creates a new tempo specification with the provided lengths, rate, and
    /// text, or `nil` if any argument fails its validity constraint.
    ///
    /// - Parameter lengths:  The note lengths that together form the beat
    ///                         unit on which the tempo rate is based. Empty if
    ///                         not specified. For a compound beat such as
    ///                         `Q:1/4 3/8 1/4 3/8=40`, this array has more than
    ///                         one element. Must have at most 4 elements. Must
    ///                         be empty if `rate` is `nil`.
    /// - Parameter rate:       The tempo rate in beats per minute, or `nil` if
    ///                         not specified. Must be positive if specified.
    /// - Parameter text:       The tempo description text, or `nil` if not
    ///                         specified.
    public init?(lengths: [ABCLength],
                 rate: UInt?,
                 text: String?) {
        self.init(lengths: lengths,
                  rate: rate,
                  text: text,
                  beatMultiplier: nil)
    }

    // MARK: Public Instance Properties

    /// The `n` from a deprecated `Q:Cn=rate` / `Q:C=rate` C-form tempo (or a
    /// bare `Q:rate`), or `nil` for all other tempo forms. The value is `1` for
    /// a bare `Q:C=rate` or `Q:rate`.
    ///
    /// While this property is non-`nil` the tempo is *unresolved*: ``lengths``
    /// is empty and the beat is `n` times the active unit note length (`L:`).
    /// ``ABCNormalizer`` resolves such a tempo to a single absolute ``lengths``
    /// entry and clears this property.
    ///
    /// Always `nil` for directly-constructed tempos; may be non-`nil` for tempos
    /// produced by the parser from deprecated input until normalized.
    public let beatMultiplier: UInt?

    /// The note lengths that together form the beat unit on which the tempo
    /// rate is based. Empty if not specified. For a compound beat such as
    /// `Q:1/4 3/8 1/4 3/8=40`, this array has more than one element.
    public let lengths: [ABCLength]

    /// The tempo rate in beats per minute, or `nil` if not specified.
    public let rate: UInt?

    /// The tempo description text, or `nil` if not specified.
    public let text: String?
}

// MARK: -

extension ABCTempo {

    // MARK: Internal Initializers

    internal init?(lengths: [ABCLength],
                   rate: UInt?,
                   text: String?,
                   beatMultiplier: UInt?) {
        guard Self._isValid(lengths, rate, text, beatMultiplier)
        else { return nil }

        self.lengths = lengths
        self.beatMultiplier = beatMultiplier
        self.rate = rate
        self.text = text
    }

    // MARK: Private Type Methods

    private static func _isValid(_ lengths: [ABCLength],
                                 _ rate: UInt?,
                                 _ text: String?,
                                 _ beatMultiplier: UInt?) -> Bool {
        lengths.count <= 4
        && rate != 0
        && beatMultiplier != 0
        && (beatMultiplier == nil || (lengths.isEmpty && rate != nil))
        && (lengths.isEmpty || rate != nil)
    }
}

// MARK: - Equatable

extension ABCTempo: Equatable {
}

// MARK: - Sendable

extension ABCTempo: Sendable {
}
