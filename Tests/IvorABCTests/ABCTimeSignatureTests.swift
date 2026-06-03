// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCTimeSignatureTests {
}

// MARK: -

extension ABCTimeSignatureTests {
    @Test
    func equality_common() {
        #expect(ABCTimeSignature.common == .common)
    }

    @Test
    func equality_cut() {
        #expect(ABCTimeSignature.cut == .cut)
    }

    @Test
    func equality_empty() {
        #expect(ABCTimeSignature.empty == .empty)
    }

    @Test
    func equality_explicit() {
        let frac = ABCFraction(numerator: 3, denominator: 4, reduce: false)

        #expect(ABCTimeSignature.explicit(frac) == .explicit(frac))
    }

    @Test
    func inequality() {
        let frac = ABCFraction(numerator: 3, denominator: 4, reduce: false)

        #expect(ABCTimeSignature.common != .cut)
        #expect(ABCTimeSignature.common != .empty)
        #expect(ABCTimeSignature.common != .explicit(frac))
        #expect(ABCTimeSignature.explicit(frac) != .explicit(ABCFraction(numerator: 4,
                                                                          denominator: 4,
                                                                          reduce: false)))
    }
}
