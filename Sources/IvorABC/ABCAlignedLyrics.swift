// © 2026 John Gary Pusey (see LICENSE.md)

/// A parsed ABC aligned lyrics line (`w:`).
///
/// Each segment corresponds positionally to a note in the music line.
public struct ABCAlignedLyrics {

    // MARK: Public Initializers

    /// Creates a new aligned lyrics line with the given segments.
    ///
    /// - Parameter segments: The positional segments.
    public init(segments: [Segment]) {
        self.segments = segments
    }

    // MARK: Public Instance Properties

    /// The positional segments, each corresponding to a note in the music line.
    public let segments: [Segment]
}

// MARK: - Equatable

extension ABCAlignedLyrics: Equatable {
}

// MARK: - Sendable

extension ABCAlignedLyrics: Sendable {
}
