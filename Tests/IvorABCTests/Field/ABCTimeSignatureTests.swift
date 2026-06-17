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
    func equality_standard() {
        let a = makeTimeSignature(3, 4)
        let b = makeTimeSignature(3, 4)

        #expect(a == b)
    }

    @Test
    func isCompound_true() {
        #expect(makeTimeSignature(6, 8).isCompound)
        #expect(makeTimeSignature(9, 8).isCompound)
        #expect(makeTimeSignature(12, 8).isCompound)
        #expect(makeTimeSignature(6, 4).isCompound)
    }

    @Test
    func isCompound_false_simpleStandard() {
        #expect(!makeTimeSignature(2, 4).isCompound)
        #expect(!makeTimeSignature(3, 4).isCompound)  // 3 is not > 3
        #expect(!makeTimeSignature(4, 4).isCompound)
        #expect(!makeTimeSignature(2, 2).isCompound)
    }

    @Test
    func isCompound_false_nonStandard() {
        #expect(!ABCTimeSignature.common.isCompound)
        #expect(!ABCTimeSignature.cut.isCompound)
        #expect(!ABCTimeSignature.empty.isCompound)
        #expect(!makeTimeSignature([2, 3], 8).isCompound)
    }

    @Test
    func inequality() {
        #expect(ABCTimeSignature.common != .cut)
        #expect(ABCTimeSignature.common != .empty)
        #expect(ABCTimeSignature.common != makeTimeSignature(3, 4))
        #expect(makeTimeSignature(3, 4) != makeTimeSignature(4, 4))
    }
}
