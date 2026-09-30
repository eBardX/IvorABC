// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCElemskipTests {
}

// MARK: -

extension ABCElemskipTests {
    @Test
    func equality_decimal() {
        #expect(ABCElemskip.decimal(1.5) == .decimal(1.5))
    }

    @Test
    func equality_integer() {
        #expect(ABCElemskip.integer(2) == .integer(2))
    }

    @Test
    func inequality_decimalVsInteger() {
        #expect(ABCElemskip.decimal(2) != .integer(2))
    }

    @Test
    func inequality_differentDecimalValues() {
        #expect(ABCElemskip.decimal(1.5) != .decimal(2.5))
    }

    @Test
    func inequality_differentIntegerValues() {
        #expect(ABCElemskip.integer(1) != .integer(2))
    }
}
