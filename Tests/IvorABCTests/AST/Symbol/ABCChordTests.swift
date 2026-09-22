// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCChordTests {
}

// MARK: -

extension ABCChordTests {
    @Test
    func equality() {
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let a = makeChord([note], makeLength(1))
        let b = makeChord([note], makeLength(1))

        #expect(a == b)
    }

    @Test
    func inequality_differentLength() {
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let a = makeChord([note], makeLength(1))
        let b = makeChord([note], makeLength(2))

        #expect(a != b)
    }

    @Test
    func inequality_differentNotes() {
        let noteC = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let noteD = makeNote(makePitch(.d, .natural, 4), makeLength(1))
        let a = makeChord([noteC], makeLength(1))
        let b = makeChord([noteD], makeLength(1))

        #expect(a != b)
    }

    @Test
    func inequality_differentTie() {
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let a = makeChord([note], makeLength(1), .regular)
        let b = makeChord([note], makeLength(1))

        #expect(a != b)
    }

    @Test
    func init_nilForEmptyNotes() {
        let chord = ABCChord(notes: [],
                             length: makeLength(1),
                             tie: nil)

        #expect(chord == nil)
    }

    @Test
    func init_storesProperties() {
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let chord = ABCChord(notes: [note],
                             length: makeLength(1),
                             tie: .regular)

        #expect(chord?.notes == [note])
        #expect(chord?.length == makeLength(1))
        #expect(chord?.tie == .regular)
    }
}
