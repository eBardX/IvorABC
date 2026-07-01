// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCBrokenRhythmTests {
}

// MARK: -

extension ABCBrokenRhythmTests {
    @Test
    func resolve_doubleRight_lengthensAndShortens() {
        let result = ABCBrokenRhythm.doubleDotted.resolve(left: makeLength(1, 4),
                                                          right: makeLength(1, 4))

        #expect(result?.left == makeLength(7, 16))
        #expect(result?.right == makeLength(1, 16))
    }

    @Test
    func resolve_singleLeft_halvesAndDots() {
        let result = ABCBrokenRhythm.reverseDotted.resolve(left: makeLength(1, 4),
                                                           right: makeLength(1, 4))

        #expect(result?.left == makeLength(1, 8))
        #expect(result?.right == makeLength(3, 8))
    }

    @Test
    func resolve_singleRight_dotsLengthAndHalvesNext() {
        let result = ABCBrokenRhythm.dotted.resolve(left: makeLength(1, 4),
                                                    right: makeLength(1, 4))

        #expect(result?.left == makeLength(3, 8))
        #expect(result?.right == makeLength(1, 8))
    }

    @Test
    func resolve_tripleRight_lengthensAndShortens() {
        let result = ABCBrokenRhythm.tripleDotted.resolve(left: makeLength(1, 4),
                                                          right: makeLength(1, 4))

        #expect(result?.left == makeLength(15, 32))
        #expect(result?.right == makeLength(1, 32))
    }
}
