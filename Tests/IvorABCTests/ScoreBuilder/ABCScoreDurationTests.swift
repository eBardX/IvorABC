// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCScoreDurationTests {
}

// MARK: -

extension ABCScoreDurationTests {
    @Test
    func addition_reducesResult() {
        let duration = makeScoreDuration(1, 4) + makeScoreDuration(1, 4)

        #expect(duration.numerator == 1)
        #expect(duration.denominator == 2)
    }

    @Test
    func addition_withDifferentDenominators() {
        let duration = makeScoreDuration(1, 3) + makeScoreDuration(1, 6)

        #expect(duration.numerator == 1)
        #expect(duration.denominator == 2)
    }

    @Test
    func comparable_ordersByValue() {
        #expect(makeScoreDuration(1, 4) < makeScoreDuration(1, 2))
        #expect(makeScoreDuration(1, 3) > makeScoreDuration(1, 4))
        #expect(!(makeScoreDuration(1, 2) < makeScoreDuration(2, 4)))
    }

    @Test
    func init_allowsNonPowerOf2Denominator() {
        let duration = makeScoreDuration(1, 12)

        #expect(duration.numerator == 1)
        #expect(duration.denominator == 12)
    }

    @Test
    func init_reducesByGCD() {
        let duration = makeScoreDuration(6, 4)

        #expect(duration.numerator == 3)
        #expect(duration.denominator == 2)
    }

    @Test
    func init_withZeroDenominatorReturnsNil() {
        #expect(ABCScoreDuration(numerator: 1,
                                 denominator: 0) == nil)
    }

    @Test
    func init_withZeroNumeratorReturnsNil() {
        #expect(ABCScoreDuration(numerator: 0,
                                 denominator: 4) == nil)
    }

    @Test
    func initFromLength_preservesValue() {
        let duration = ABCScoreDuration(length: makeLength(3, 8))

        #expect(duration.numerator == 3)
        #expect(duration.denominator == 8)
    }

    @Test
    func initFromWrittenAndUnit_multipliesAndReduces() {
        // A written length of 2/1 (e.g. "C2") against a unit note length of
        // 1/8 resolves to an absolute duration of 1/4.
        let duration = ABCScoreDuration(written: makeLength(2, 1),
                                        unitNoteLength: makeLength(1, 8))

        #expect(duration.numerator == 1)
        #expect(duration.denominator == 4)
    }

    @Test
    func multiplication_byDuration_reducesResult() {
        // A triplet: an eighth note (1/8) scaled by 2/3 gives 1/12.
        let duration = makeScoreDuration(1, 8) * makeScoreDuration(2, 3)

        #expect(duration.numerator == 1)
        #expect(duration.denominator == 12)
    }

    @Test
    func multiplication_byFractionPair_reducesResult() {
        let duration = makeScoreDuration(1, 8) * (numerator: 2, denominator: 3)

        #expect(duration.numerator == 1)
        #expect(duration.denominator == 12)
    }

    @Test
    func multiplicationAssignment_byFractionPair_reducesResult() {
        var duration = makeScoreDuration(1, 8)

        duration *= (numerator: 2, denominator: 3)

        #expect(duration.numerator == 1)
        #expect(duration.denominator == 12)
    }
}
