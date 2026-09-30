// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCGraceNotesTests {
}

// MARK: -

extension ABCGraceNotesTests {
    @Test
    func equality() {
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let a = makeGraceNotes([note], true)
        let b = makeGraceNotes([note], true)

        #expect(a == b)
    }

    @Test
    func inequality_differentIsSlashed() {
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let a = makeGraceNotes([note], true)
        let b = makeGraceNotes([note], false)

        #expect(a != b)
    }

    @Test
    func inequality_differentNotes() {
        let noteC = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let noteD = makeNote(makePitch(.d, .natural, 4), makeLength(1))
        let a = makeGraceNotes([noteC], true)
        let b = makeGraceNotes([noteD], true)

        #expect(a != b)
    }

    @Test
    func init_nilForEmptyNotes() {
        let graceNotes = ABCGraceNotes(notes: [],
                                       isSlashed: false)

        #expect(graceNotes == nil)
    }

    @Test
    func init_storesProperties() {
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let graceNotes = ABCGraceNotes(notes: [note],
                                       isSlashed: true)

        #expect(graceNotes?.notes == [note])
        #expect(graceNotes?.isSlashed == true)
    }
}
