// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC tempo specification.
public struct ABCTempo {

    // MARK: Public Initializers

    /// Creates a new tempo specification with the provided durations, rate, and
    /// text, or `nil` if any argument fails its validity constraint.
    ///
    /// - Parameter durations:  The note durations that together form the beat
    ///                         unit on which the tempo rate is based. Empty if
    ///                         not specified. For a compound beat such as
    ///                         `Q:1/4 3/8 1/4 3/8=40`, this array has more than
    ///                         one element. Must have at most 4 elements. Must
    ///                         be empty if `rate` is `nil`.
    /// - Parameter rate:       The tempo rate in beats per minute, or `nil` if
    ///                         not specified. Must be positive if specified.
    /// - Parameter text:       The tempo description text, or `nil` if not
    ///                         specified.
    public init?(durations: [ABCDuration],
                 rate: UInt?,
                 text: String?) {
        self.init(durations: durations,
                  rate: rate,
                  text: text,
                  beatMultiplier: nil)
    }

    // MARK: Public Instance Properties

    /// The `n` from an ABC 1.6 `Q:Cn=rate` C-form tempo, or `nil` for all
    /// other tempo forms. The value is `1` for a bare `Q:C=rate`. The
    /// `durations` array always holds the fully-resolved beat regardless of
    /// whether this property is set.
    ///
    /// Always `nil` for directly-constructed tempos; may be non-`nil` for
    /// tempos produced by the parser from legacy ABC 1.6 input.
    public let beatMultiplier: UInt?

    /// The note durations that together form the beat unit on which the tempo
    /// rate is based. Empty if not specified. For a compound beat such as
    /// `Q:1/4 3/8 1/4 3/8=40`, this array has more than one element.
    public let durations: [ABCDuration]

    /// The tempo rate in beats per minute, or `nil` if not specified.
    public let rate: UInt?

    /// The tempo description text, or `nil` if not specified.
    public let text: String?
}

// MARK: -

extension ABCTempo {

    // MARK: Internal Initializers

    internal init?(durations: [ABCDuration],
                   rate: UInt?,
                   text: String?,
                   beatMultiplier: UInt?) {
        guard Self._isValid(durations, rate, text, beatMultiplier)
        else { return nil }

        self.durations = durations
        self.beatMultiplier = beatMultiplier
        self.rate = rate
        self.text = text
    }

    // MARK: Private Type Methods

    private static func _isValid(_ durations: [ABCDuration],
                                 _ rate: UInt?,
                                 _ text: String?,
                                 _ beatMultiplier: UInt?) -> Bool {
        durations.count <= 4
        && rate != 0
        && beatMultiplier != 0
        && (beatMultiplier == nil || durations.count == 1)
        && (durations.isEmpty || rate != nil)
    }
}

// MARK: - Equatable

extension ABCTempo: Equatable {
}

// MARK: - Sendable

extension ABCTempo: Sendable {
}
