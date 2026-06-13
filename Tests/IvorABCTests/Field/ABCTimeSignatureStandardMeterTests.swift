// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCTimeSignatureStandardMeterTests {
}

// MARK: -

extension ABCTimeSignatureStandardMeterTests {
    @Test
    func init_storesValues() throws {
        let meter = try #require(ABCTimeSignature.StandardMeter(numerator: 6,
                                                                denominator: 4))

        #expect(meter.numerator == 6)
        #expect(meter.denominator == 4)
    }

    @Test
    func init_withDenominatorAbove64ReturnsNil() {
        #expect(ABCTimeSignature.StandardMeter(numerator: 1,
                                               denominator: 128) == nil)
    }

    @Test
    func init_withNonPowerOfTwoDenominatorReturnsNil() {
        #expect(ABCTimeSignature.StandardMeter(numerator: 3,
                                               denominator: 5) == nil)
    }

    @Test
    func init_withZeroDenominatorReturnsNil() {
        #expect(ABCTimeSignature.StandardMeter(numerator: 1,
                                               denominator: 0) == nil)
    }

    @Test
    func init_withZeroNumeratorReturnsNil() {
        #expect(ABCTimeSignature.StandardMeter(numerator: 0,
                                               denominator: 8) == nil)
    }
}
