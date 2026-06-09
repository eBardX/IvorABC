// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCFractionTests {
}

// MARK: -

extension ABCFractionTests {
    @Test
    func init_reducesFractionByGCD() {
        let fraction = ABCFraction(numerator: 6,
                                   denominator: 4,
                                   reduce: true)

        #expect(fraction.numerator == 3)
        #expect(fraction.denominator == 2)
    }

    @Test
    func init_reducesLargeValues() {
        let fraction = ABCFraction(numerator: 120,
                                   denominator: 360,
                                   reduce: true)

        #expect(fraction.numerator == 1)
        #expect(fraction.denominator == 3)
    }

    @Test
    func init_withDenominatorOneSkipsReduction() {
        let fraction = ABCFraction(numerator: 5,
                                   denominator: 1,
                                   reduce: true)

        #expect(fraction.numerator == 5)
        #expect(fraction.denominator == 1)
    }

    @Test
    func init_withReduceFalsePreservesFraction() {
        let fraction = ABCFraction(numerator: 6,
                                   denominator: 4,
                                   reduce: false)

        #expect(fraction.numerator == 6)
        #expect(fraction.denominator == 4)
    }

    @Test
    func init_withZeroNumeratorSetsDenominatorToOne() {
        let fraction = ABCFraction(numerator: 0,
                                   denominator: 8,
                                   reduce: true)

        #expect(fraction.numerator == 0)
        #expect(fraction.denominator == 1)
    }

    @Test
    func noReductionNeededWhenAlreadyReduced() {
        let fraction = ABCFraction(numerator: 3,
                                   denominator: 8,
                                   reduce: true)

        #expect(fraction.numerator == 3)
        #expect(fraction.denominator == 8)
    }
}
