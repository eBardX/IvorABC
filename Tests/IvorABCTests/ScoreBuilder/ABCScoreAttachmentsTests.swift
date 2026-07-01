// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCScoreAttachmentsTests {
}

// MARK: -

extension ABCScoreAttachmentsTests {
    @Test
    func empty_hasNoAttachments() {
        let attachments = ABCScoreAttachments.empty

        #expect(attachments.decorations.isEmpty)
        #expect(attachments.annotations.isEmpty)
        #expect(attachments.graceNotes == nil)
        #expect(attachments.chordSymbol == nil)
    }

    @Test
    func equality() {
        let a = makeScoreAttachments([makeDecoration("roll")])
        let b = makeScoreAttachments([makeDecoration("roll")])

        #expect(a == b)
    }

    @Test
    func inequality() {
        let base = makeScoreAttachments([makeDecoration("roll")])

        let graceNotes = makeScoreGraceNotes([makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 16))],
                                             false)
        let chordSymbol = ABCChordSymbol(name: .init(root: .c))

        let diffDecorations = makeScoreAttachments([makeDecoration("trill")])
        let diffAnnotations = makeScoreAttachments([makeDecoration("roll")], [makeAnnotation(.auto, "dim.")])
        let diffGraceNotes = makeScoreAttachments([makeDecoration("roll")], [], graceNotes)
        let diffChordSymbol = makeScoreAttachments([makeDecoration("roll")], [], nil, chordSymbol)

        #expect(base != diffDecorations)
        #expect(base != diffAnnotations)
        #expect(base != diffGraceNotes)
        #expect(base != diffChordSymbol)
    }

    @Test
    func init_storesValues() {
        let decorations = [makeDecoration("roll")]
        let annotations = [makeAnnotation(.auto, "dim.")]
        let graceNotes = makeScoreGraceNotes([makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 16))],
                                             false)
        let chordSymbol = ABCChordSymbol(name: .init(root: .c))
        let attachments = ABCScoreAttachments(decorations: decorations,
                                              annotations: annotations,
                                              graceNotes: graceNotes,
                                              chordSymbol: chordSymbol)

        #expect(attachments.decorations == decorations)
        #expect(attachments.annotations == annotations)
        #expect(attachments.graceNotes == graceNotes)
        #expect(attachments.chordSymbol == chordSymbol)
    }
}
