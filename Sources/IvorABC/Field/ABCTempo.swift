// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC tempo specification.
public struct ABCTempo {

    // MARK: Public Initializers

    /// Creates a new tempo specification with the provided durations, rate,
    /// text, and optional legacy beat multiplier, or `nil` if any argument
    /// fails its validity constraint.
    ///
    /// - Parameter durations:          The note durations that together form
    ///                                 the beat unit on which the tempo rate
    ///                                 is based. Empty if not specified. For a
    ///                                 compound beat such as
    ///                                 `Q:1/4 3/8 1/4 3/8=40`, this array has
    ///                                 more than one element. Must have at most
    ///                                 4 elements. Must be empty if `rate` is
    ///                                 `nil`.
    /// - Parameter rate:               The tempo rate in beats per minute, or
    ///                                 `nil` if not specified. Must be positive
    ///                                 if specified.
    /// - Parameter text:               The tempo description text, or `nil` if
    ///                                 not specified.
    /// - Parameter legacyBeatMultiple: The `n` from an ABC 1.6 `Q:Cn=rate`
    ///                                 form (1 for bare `Q:C=rate`), or `nil`
    ///                                 if this tempo was not parsed from a 1.6
    ///                                 C-form. ``ABCTunebook/migrate()`` clears
    ///                                 this to `nil` when upgrading to ABC 2.1.
    ///                                 Must be positive if specified. When
    ///                                 specified, `durations` must have exactly
    ///                                 one element.
    public init?(durations: [ABCDuration],
                 rate: UInt?,
                 text: String?,
                 legacyBeatMultiple: UInt? = nil) {
        guard Self._isValid(durations, rate, text, legacyBeatMultiple)
        else { return nil }

        self.durations = durations
        self.legacyBeatMultiple = legacyBeatMultiple
        self.rate = rate
        self.text = text
    }

    // MARK: Public Instance Properties

    /// The note durations that together form the beat unit on which the tempo
    /// rate is based. Empty if not specified. For a compound beat such as
    /// `Q:1/4 3/8 1/4 3/8=40`, this array has more than one element.
    public let durations: [ABCDuration]

    /// The `n` from an ABC 1.6 `Q:Cn=rate` C-form tempo, or `nil` for all
    /// other tempo forms. The value is `1` for a bare `Q:C=rate`. The
    /// `durations` array always holds the fully-resolved beat regardless of
    /// whether this property is set.
    public let legacyBeatMultiple: UInt?

    /// The tempo rate in beats per minute, or `nil` if not specified.
    public let rate: UInt?

    /// The tempo description text, or `nil` if not specified.
    public let text: String?
}

// MARK: -

extension ABCTempo {

    // MARK: Private Type Methods

    private static func _isValid(_ durations: [ABCDuration],
                                 _ rate: UInt?,
                                 _ text: String?,
                                 _ legacyBeatMultiple: UInt?) -> Bool {
        durations.count <= 4
        && rate != 0
        && legacyBeatMultiple != 0
        && (legacyBeatMultiple == nil || durations.count == 1)
        && (durations.isEmpty || rate != nil)
    }
}

// MARK: - Equatable

extension ABCTempo: Equatable {
}

// MARK: - Sendable

extension ABCTempo: Sendable {
}
