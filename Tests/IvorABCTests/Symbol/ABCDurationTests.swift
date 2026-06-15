// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCDurationTests {
}

// MARK: -

extension ABCDurationTests {
    @Test
    func init_reducesDurationByGCD() {
        let duration = makeDuration(6, 4)

        #expect(duration.numerator == 3)
        #expect(duration.denominator == 2)
    }

    @Test
    func init_reducesLargeValues() {
        let duration = makeDuration(96, 256)

        #expect(duration.numerator == 3)
        #expect(duration.denominator == 8)
    }

    @Test
    func init_withDenominatorOnePreservesValue() {
        let duration = makeDuration(5)

        #expect(duration.numerator == 5)
        #expect(duration.denominator == 1)
    }

    @Test
    func init_withZeroNumeratorReturnsNil() {
        #expect(ABCDuration(numerator: 0,
                            denominator: 8) == nil)
    }

    @Test
    func init_withZeroDenominatorReturnsNil() {
        #expect(ABCDuration(numerator: 1,
                            denominator: 0) == nil)
    }

    @Test
    func noReductionNeededWhenAlreadyReduced() {
        let duration = makeDuration(3, 8)

        #expect(duration.numerator == 3)
        #expect(duration.denominator == 8)
    }
}
