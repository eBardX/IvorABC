// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCScoreTests {
}

// MARK: -

extension ABCScoreTests {
    @Test
    func equality() {
        let events = [ABCScoreEvent.barLine(makeBarLine())]
        let a = ABCScore(events: events)
        let b = ABCScore(events: events)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a = ABCScore(events: [ABCScoreEvent.barLine(makeBarLine())])
        let b = ABCScore(events: [])

        #expect(a != b)
    }

    @Test
    func init_storesEvents() {
        let events = [ABCScoreEvent.referenceNumber(makeReferenceNumber(1)),
                      ABCScoreEvent.key(makeKeySignature(.c, .major))]
        let score = ABCScore(events: events)

        #expect(score.events == events)
    }
}
