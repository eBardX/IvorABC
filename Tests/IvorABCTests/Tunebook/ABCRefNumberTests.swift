// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCRefNumberTests {
}

// MARK: -

extension ABCRefNumberTests {
    @Test
    func equality() {
        let a = makeRefNumber(42)
        let b = makeRefNumber(42)

        #expect(a == b)
    }

    @Test
    func inequality() {
        #expect(ABCRefNumber(uintValue: 1) != makeRefNumber(2))
    }

    @Test
    func init_storesValue() {
        let refNumber = makeRefNumber(7)

        #expect(refNumber.uintValue == 7)
    }
}
