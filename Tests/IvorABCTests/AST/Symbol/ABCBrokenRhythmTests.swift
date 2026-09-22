// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCBrokenRhythmTests {
}

// MARK: -

extension ABCBrokenRhythmTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCBrokenRhythm] = [.dotted,
                                           .doubleDotted,
                                           .reverseDotted,
                                           .reverseDoubleDotted,
                                           .reverseTripleDotted,
                                           .tripleDotted]

        for i in allCases.indices {
            for j in allCases.indices where i != j {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test
    func equality() {
        #expect(ABCBrokenRhythm.dotted == .dotted)
    }

    @Test
    func factor_doubleDottedCases() {
        #expect(ABCBrokenRhythm.doubleDotted.factor == 2)
        #expect(ABCBrokenRhythm.reverseDoubleDotted.factor == 2)
    }

    @Test
    func factor_singleDottedCases() {
        #expect(ABCBrokenRhythm.dotted.factor == 1)
        #expect(ABCBrokenRhythm.reverseDotted.factor == 1)
    }

    @Test
    func factor_tripleDottedCases() {
        #expect(ABCBrokenRhythm.tripleDotted.factor == 3)
        #expect(ABCBrokenRhythm.reverseTripleDotted.factor == 3)
    }
}
