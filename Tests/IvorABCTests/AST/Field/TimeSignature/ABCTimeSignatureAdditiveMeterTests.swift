// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCTimeSignatureAdditiveMeterTests {
}

// MARK: -

extension ABCTimeSignatureAdditiveMeterTests {
    @Test
    func init_storesValues() throws {
        let meter = try #require(ABCTimeSignature.AdditiveMeter(numerators: [2, 3, 2],
                                                                denominator: 8))

        #expect(meter.numerators == [2, 3, 2])
        #expect(meter.denominator == 8)
    }

    @Test
    func init_withDenominatorAbove64ReturnsNil() {
        #expect(ABCTimeSignature.AdditiveMeter(numerators: [2, 3],
                                               denominator: 128) == nil)
    }

    @Test
    func init_withEmptyNumeratorsReturnsNil() {
        #expect(ABCTimeSignature.AdditiveMeter(numerators: [],
                                               denominator: 8) == nil)
    }

    @Test
    func init_withNonPowerOfTwoDenominatorReturnsNil() {
        #expect(ABCTimeSignature.AdditiveMeter(numerators: [2, 3],
                                               denominator: 6) == nil)
    }

    @Test
    func init_withZeroDenominatorReturnsNil() {
        #expect(ABCTimeSignature.AdditiveMeter(numerators: [2, 3],
                                               denominator: 0) == nil)
    }

    @Test
    func init_withZeroNumeratorInGroupReturnsNil() {
        #expect(ABCTimeSignature.AdditiveMeter(numerators: [2, 0, 3],
                                               denominator: 8) == nil)
    }
}
