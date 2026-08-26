// © 2026 John Gary Pusey (see LICENSE.md)

/// A parsed ABC aligned lyrics line (`w:`).
///
/// The `segments` array is a flat token sequence. Note positions are bounded by
/// word boundaries (consecutive `syllable` tokens) and explicit `continuation`
/// tokens.
///
/// See §5.1 (“Alignment”) of the ABC 2.1 standard.
public struct ABCAlignedWords {

    // MARK: Public Initializers

    /// Creates a new aligned lyrics line with the given segments.
    ///
    /// - Parameter segments: The lyric tokens.
    public init(segments: [Segment]) {
        self.segments = segments
    }

    // MARK: Public Instance Properties

    /// The tokenized lyrics sequence.
    public let segments: [Segment]
}

// MARK: - Equatable

extension ABCAlignedWords: Equatable {
}

// MARK: - Sendable

extension ABCAlignedWords: Sendable {
}
