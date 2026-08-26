// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCAlignedWords {

    // MARK: Public Nested Types

    /// A single segment of an aligned lyrics line.
    public enum Segment {
        /// A bar-alignment marker (`|`); advances to the next bar.
        case barAlign

        /// A word continuation marker (`-`); links this syllable to the next
        /// note within the same word, rendering a hyphen between them.
        case continuation

        /// A hold marker (`_`); extends the previous syllable over this note.
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
