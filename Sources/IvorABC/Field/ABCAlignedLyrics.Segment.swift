// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCAlignedLyrics {

    // MARK: Public Nested Types

    /// A single token in an aligned lyrics line.
    public enum Segment {
        /// Advance to the next bar (`|`).
        case barAlign

        /// A literal hyphen (`\-`); renders as a hyphen character within a syllable.
        case escapedHyphen

        /// Extend the previous syllable over this note (`_`).
        case hold

        /// A syllable connector (`-`); links preceding and following text within the same word.
        case hyphen

        /// No syllable for this note (`*`).
        case skip

        /// A run of plain lyric text (no special characters).
        case text(String)                       // ABCText ???

        /// A word-internal space (`~`); renders as a space within a syllable.
        case tilde
    }
}

// MARK: - Equatable

extension ABCAlignedLyrics.Segment: Equatable {
}

// MARK: - Sendable

extension ABCAlignedLyrics.Segment: Sendable {
}
