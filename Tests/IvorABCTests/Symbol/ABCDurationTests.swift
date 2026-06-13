// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCDurationTests {
}

// MARK: -

extension ABCDurationTests {
    @Test
    func init_reducesDurationByGCD() throws {
        let duration = try #require(ABCDuration(numerator: 6,
                                                denominator: 4))

        #expect(duration.numerator == 3)
        #expect(duration.denominator == 2)
    }

    @Test
    func init_reducesLargeValues() throws {
        let duration = try #require(ABCDuration(numerator: 96,
                                                denominator: 256))

        #expect(duration.numerator == 3)
        #expect(duration.denominator == 8)
    }

    @Test
    func init_withDenominatorOnePreservesValue() throws {
        let duration = try #require(ABCDuration(numerator: 5,
                                                denominator: 1))

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
    func noReductionNeededWhenAlreadyReduced() throws {
        let duration = try #require(ABCDuration(numerator: 3,
                                                denominator: 8))

        #expect(duration.numerator == 3)
        #expect(duration.denominator == 8)
    }
}
