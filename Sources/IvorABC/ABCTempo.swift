// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC tempo specification.
public struct ABCTempo {

    // MARK: Public Initializers

    /// Creates a new tempo specification with the provided duration, rate, and
    /// text.
    ///
    /// - Parameter duration: The note duration on which the tempo rate is
    ///                       based, or `nil` if not specified.
    /// - Parameter rate:     The tempo rate in beats per minute, or `nil` if
    ///                       not specified.
    /// - Parameter text:     The optional tempo description text.
    public init(duration: ABCDuration?,
                rate: UInt?,
                text: String?) {
        self.duration = duration
        self.rate = rate
        self.text = text
    }

    // MARK: Public Instance Properties

    /// The note duration on which the tempo rate is based, or `nil` if not
    /// specified.
    public let duration: ABCDuration?

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
