// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCScoreBuilder {

    // MARK: Public Nested Types

    /// Options controlling how ``ABCScoreBuilder/build(_:options:)`` builds a
    /// tunebook's scores.
    public struct Options: OptionSet {

        // MARK: Public Initializers

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        // MARK: Public Instance Properties

        public let rawValue: UInt8
    }
}

// MARK: -

extension ABCScoreBuilder.Options {

    // MARK: Public Type Properties

    /// Skip the offending event instead of throwing when a resolution or
    /// expansion failure occurs.
    public static let ignoreErrors = Self(rawValue: 1 << 0)

    /// Apply playback-oriented transforms: tie coalescing, repeat/variant-
    /// ending/parts expansion, bar-line/meter/key dropping, and tempo
    /// normalization.
    ///
    /// Not yet implemented. Setting this option causes
    /// ``ABCScoreBuilder/build(_:options:)`` to throw
    /// ``ABCScoreBuilder/Error/unsupportedOption``.
    public static let optimizeForPlayback = Self(rawValue: 1 << 1)

    /// Omit ``ABCScoreEvent/directive(_:)`` events.
    public static let stripDirectives = Self(rawValue: 1 << 2)
}

// MARK: - Sendable

extension ABCScoreBuilder.Options: Sendable {
}
