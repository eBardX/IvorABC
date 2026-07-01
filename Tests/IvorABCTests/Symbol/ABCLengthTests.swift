// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCLengthTests {
}

// MARK: -

extension ABCLengthTests {
    @Test
    func init_reducesLengthByGCD() {
        let length = makeLength(6, 4)

        #expect(length.numerator == 3)
        #expect(length.denominator == 2)
    }

    @Test
    func init_reducesLargeValues() {
        let length = makeLength(96, 256)

        #expect(length.numerator == 3)
        #expect(length.denominator == 8)
    }

    @Test
    func init_withDenominatorOnePreservesValue() {
        let length = makeLength(5)

        #expect(length.numerator == 5)
        #expect(length.denominator == 1)
    }

    @Test
    func init_withZeroNumeratorReturnsNil() {
        #expect(ABCLength(numerator: 0,
                          denominator: 8) == nil)
    }

    @Test
    func init_withZeroDenominatorReturnsNil() {
        #expect(ABCLength(numerator: 1,
                          denominator: 0) == nil)
    }

    @Test
    func noReductionNeededWhenAlreadyReduced() {
        let length = makeLength(3, 8)

        #expect(length.numerator == 3)
        #expect(length.denominator == 8)
    }
}
