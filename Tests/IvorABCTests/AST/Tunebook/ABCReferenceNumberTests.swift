// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCReferenceNumberTests {
}

// MARK: -

extension ABCReferenceNumberTests {
    @Test
    func equality() {
        let a = makeReferenceNumber(42)
        let b = makeReferenceNumber(42)

        #expect(a == b)
    }

    @Test
    func inequality() {
        #expect(ABCReferenceNumber(1) != makeReferenceNumber(2))
    }

    @Test
    func init_storesValue() {
        let refNumber = makeReferenceNumber(7)

        #expect(refNumber.uintValue == 7)
    }
}
