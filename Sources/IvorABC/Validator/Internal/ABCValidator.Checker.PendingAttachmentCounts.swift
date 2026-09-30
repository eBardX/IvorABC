// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCValidator.Checker {

    // MARK: Internal Nested Types

    // Chord-symbol/grace-note counts pending since the last note, chord,
    // rest, or bar line, tracked per voice so a count isn't lost or falsely
    // merged across a mid-tune `V:` switch.
    internal struct PendingAttachmentCounts {

        // MARK: Internal Instance Properties

        internal var chordSymbols = 0
        internal var graceNotes = 0
    }
}
