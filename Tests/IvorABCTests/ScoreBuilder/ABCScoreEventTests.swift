// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCScoreEventTests {
}

// MARK: -

extension ABCScoreEventTests {
    @Test
    func equality() {
        let note = makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 4))
        let a = ABCScoreEvent.note(note, .empty)
        let b = ABCScoreEvent.note(note, .empty)

        #expect(a == b)
    }

    @Test
    func inequality_acrossCases() {
        let rest = ABCScoreEvent.rest(makeScoreRest(makeScoreDuration(1, 4)), .empty)
        let barLine = ABCScoreEvent.barLine(makeBarLine())

        #expect(rest != barLine)
    }

    @Test
    func inequality_withinSameCase() {
        let note = makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 4))
        let attachments = ABCScoreAttachments(decorations: [makeDecoration("roll")])
        let base = ABCScoreEvent.note(note, .empty)
        let diffAttachments = ABCScoreEvent.note(note, attachments)

        #expect(base != diffAttachments)
    }
}
