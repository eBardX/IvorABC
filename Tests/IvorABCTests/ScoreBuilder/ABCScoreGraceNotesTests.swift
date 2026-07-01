// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCScoreGraceNotesTests {
}

// MARK: -

extension ABCScoreGraceNotesTests {
    @Test
    func equality() {
        let notes = [makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 16))]
        let a = makeScoreGraceNotes(notes, false)
        let b = makeScoreGraceNotes(notes, false)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let noteA = makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 16))
        let noteB = makeScoreNote(makePitch(.d, .natural, 4), makeScoreDuration(1, 16))
        let base = makeScoreGraceNotes([noteA], false)

        let diffNotes = makeScoreGraceNotes([noteB], false)
        let diffSlashed = makeScoreGraceNotes([noteA], true)

        #expect(base != diffNotes)
        #expect(base != diffSlashed)
    }

    @Test
    func init_storesValues() {
        let notes = [makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 16))]
        let graceNotes = ABCScoreGraceNotes(notes: notes,
                                            isSlashed: true)

        #expect(graceNotes?.notes == notes)
        #expect(graceNotes?.isSlashed == true)
    }

    @Test
    func init_withEmptyNotesReturnsNil() {
        #expect(ABCScoreGraceNotes(notes: [],
                                   isSlashed: false) == nil)
    }
}
