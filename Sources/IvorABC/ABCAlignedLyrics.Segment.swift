// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCAlignedLyrics {

    // MARK: Public Nested Types

    /// A single positional segment in an aligned lyrics line.
    public enum Segment {
        /// A lyric syllable at a word boundary (preceded by a space or at start).
        ///
        /// A `~` in the source is stored as a space within the syllable text.
        case syllable(String)

        /// A lyric syllable at a hyphen boundary (preceded by `-`).
        ///
        /// A hyphen will appear between this syllable and the preceding one.
        case continuation(String)

        /// Extend the previous syllable over this note (`_`).
        case hold

        /// No syllable for this note (`*`).
        case skip

        /// Advance to the next bar (`|`).
        case barAlign
    }
}

// MARK: - Equatable

extension ABCAlignedLyrics.Segment: Equatable {
}

// MARK: - Sendable

extension ABCAlignedLyrics.Segment: Sendable {
}
