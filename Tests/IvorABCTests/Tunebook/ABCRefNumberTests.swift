// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCRefNumberTests {
}

// MARK: -

extension ABCRefNumberTests {
    @Test
    func equality() {
        let a = ABCRefNumber(uintValue: 42)
        let b = ABCRefNumber(uintValue: 42)

        #expect(a == b)
    }

    @Test
    func inequality() {
        #expect(ABCRefNumber(uintValue: 1) != ABCRefNumber(uintValue: 2))
    }

    @Test
    func init_storesValue() {
        let refNumber = ABCRefNumber(uintValue: 7)

        #expect(refNumber.uintValue == 7)
    }
}
