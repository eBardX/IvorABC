// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC tempo specification.
public struct ABCTempo {

    // MARK: Public Initializers

    /// Creates a new tempo specification with the provided durations, rate, and
    /// text.
    ///
    /// - Parameter durations: The note durations that together form the beat
    ///                        unit on which the tempo rate is based. Empty if
    ///                        not specified. For a compound beat such as
    ///                        `Q:1/4 3/8 1/4 3/8=40`, this array has more than
    ///                        one element.
    /// - Parameter rate:      The tempo rate in beats per minute, or `nil` if
    ///                        not specified.
    /// - Parameter text:      The optional tempo description text.
    public init(durations: [ABCDuration],
                rate: UInt?,
                text: String?) {
        self.durations = durations
        self.rate = rate
        self.text = text
    }

    // MARK: Public Instance Properties

    /// The note durations that together form the beat unit on which the tempo
    /// rate is based. Empty if not specified. For a compound beat such as
    /// `Q:1/4 3/8 1/4 3/8=40`, this array has more than one element.
    public let durations: [ABCDuration]

    /// The tempo rate in beats per minute, or `nil` if not specified.
    public let rate: UInt?

    /// The optional tempo description text.
    public let text: String?
}

// MARK: - Equatable

extension ABCTempo: Equatable {
}

// MARK: - Sendable

extension ABCTempo: Sendable {
}
