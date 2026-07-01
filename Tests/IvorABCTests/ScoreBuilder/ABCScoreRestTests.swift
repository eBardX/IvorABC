// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCScoreRestTests {
}

// MARK: -

extension ABCScoreRestTests {
    @Test
    func equality() {
        let duration = makeScoreDuration(1, 4)
        let a = makeScoreRest(duration)
        let b = makeScoreRest(duration)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let duration = makeScoreDuration(1, 4)
        let base = makeScoreRest(duration)

        let diffDuration = makeScoreRest(makeScoreDuration(1, 8))
        let diffInvisible = makeScoreRest(duration, true)

        #expect(base != diffDuration)
        #expect(base != diffInvisible)
    }

    @Test
    func init_storesValues() {
        let duration = makeScoreDuration(3, 8)
        let rest = ABCScoreRest(duration: duration,
                                isInvisible: true)

        #expect(rest.duration == duration)
        #expect(rest.isInvisible == true)
    }

    @Test
    func init_defaultsToVisible() {
        let rest = ABCScoreRest(duration: makeScoreDuration(1, 4))

        #expect(rest.isInvisible == false)
    }
}
