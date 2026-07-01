// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCScoreChordTests {
}

// MARK: -

extension ABCScoreChordTests {
    @Test
    func equality() {
        let notes = [makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 4))]
        let duration = makeScoreDuration(1, 4)
        let a = makeScoreChord(notes, duration)
        let b = makeScoreChord(notes, duration)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let noteA = makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 4))
        let noteB = makeScoreNote(makePitch(.e, .natural, 4), makeScoreDuration(1, 4))
        let duration = makeScoreDuration(1, 4)
        let base = makeScoreChord([noteA], duration)

        let diffNotes = makeScoreChord([noteA, noteB], duration)
        let diffDuration = makeScoreChord([noteA], makeScoreDuration(1, 8))
        let diffTie = makeScoreChord([noteA], duration, .regular)

        #expect(base != diffNotes)
        #expect(base != diffDuration)
        #expect(base != diffTie)
    }

    @Test
    func init_storesValues() {
        let notes = [makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 4)),
                     makeScoreNote(makePitch(.e, .natural, 4), makeScoreDuration(1, 4))]
        let duration = makeScoreDuration(1, 4)
        let chord = ABCScoreChord(notes: notes,
                                  duration: duration,
                                  tie: .regular)

        #expect(chord?.notes == notes)
        #expect(chord?.duration == duration)
        #expect(chord?.tie == .regular)
    }

    @Test
    func init_withEmptyNotesReturnsNil() {
        #expect(ABCScoreChord(notes: [],
                              duration: makeScoreDuration(1, 4)) == nil)
    }
}
