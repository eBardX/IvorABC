// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCBrokenRhythmTests {
}

// MARK: -

extension ABCBrokenRhythmTests {
    @Test
    func resolve_doubleRight_lengthensAndShortens() {
        let result = ABCBrokenRhythm.doubleDotted.resolve(left: makeDuration(1, 4),
                                                          right: makeDuration(1, 4))

        #expect(result?.left == makeDuration(7, 16))
        #expect(result?.right == makeDuration(1, 16))
    }

    @Test
    func resolve_singleLeft_halvesAndDots() {
        let result = ABCBrokenRhythm.reverseDotted.resolve(left: makeDuration(1, 4),
                                                           right: makeDuration(1, 4))

        #expect(result?.left == makeDuration(1, 8))
        #expect(result?.right == makeDuration(3, 8))
    }

    @Test
    func resolve_singleRight_dotsDurationAndHalvesNext() {
        let result = ABCBrokenRhythm.dotted.resolve(left: makeDuration(1, 4),
                                                    right: makeDuration(1, 4))

        #expect(result?.left == makeDuration(3, 8))
        #expect(result?.right == makeDuration(1, 8))
    }

    @Test
    func resolve_tripleRight_lengthensAndShortens() {
        let result = ABCBrokenRhythm.tripleDotted.resolve(left: makeDuration(1, 4),
                                                          right: makeDuration(1, 4))

        #expect(result?.left == makeDuration(15, 32))
        #expect(result?.right == makeDuration(1, 32))
    }
}
