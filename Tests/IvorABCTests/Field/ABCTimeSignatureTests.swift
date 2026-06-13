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
    func equality_standard() throws {
        let meter = try #require(ABCTimeSignature.StandardMeter(numerator: 3, denominator: 4))

        #expect(ABCTimeSignature.standard(meter) == .standard(meter))
    }

    @Test
    func inequality() throws {
        let meter = try #require(ABCTimeSignature.StandardMeter(numerator: 3, denominator: 4))

        #expect(ABCTimeSignature.common != .cut)
        #expect(ABCTimeSignature.common != .empty)
        #expect(ABCTimeSignature.common != .standard(meter))
        #expect(try ABCTimeSignature.standard(meter) != .standard(#require(ABCTimeSignature.StandardMeter(numerator: 4, denominator: 4))))
    }
}
