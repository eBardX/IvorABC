// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCAlignedWords {

    // MARK: Public Nested Types

    /// A single segment of an aligned lyrics line.
    public enum Segment {
        /// Advance to the next bar (`|`).
        case barAlign

        /// A word continuation marker (`-`); links this syllable to the next
        /// note within the same word, rendering a hyphen between them.
        case continuation

        /// Extend the previous syllable over this note (`_`).
        case hold

        /// No syllable for this note (`*`).
        case skip

        /// A lyric syllable.
        case syllable(Syllable)
    }
}

// MARK: - Equatable

extension ABCAlignedWords.Segment: Equatable {
}

// MARK: - Sendable

extension ABCAlignedWords.Segment: Sendable {
}
