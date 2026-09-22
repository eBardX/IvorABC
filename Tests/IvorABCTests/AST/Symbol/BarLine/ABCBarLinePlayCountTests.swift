// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCBarLinePlayCountTests {
}

// MARK: -

extension ABCBarLinePlayCountTests {
    @Test
    func equality() {
        let a: ABCBarLine.PlayCount = 2
        let b: ABCBarLine.PlayCount = 2

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a: ABCBarLine.PlayCount = 2
        let b: ABCBarLine.PlayCount = 3

        #expect(a != b)
    }

    @Test
    func init_nilForZero() {
        #expect(ABCBarLine.PlayCount(uintValue: 0) == nil)
    }

    @Test
    func init_storesUIntValue() {
        let count = ABCBarLine.PlayCount(uintValue: 3)

        #expect(count?.uintValue == 3)
    }

    @Test
    func integerLiteral() {
        let count: ABCBarLine.PlayCount = 4

        #expect(count.uintValue == 4)
    }

    @Test
    func isValid_positiveValuesAreValid() {
        #expect(ABCBarLine.PlayCount.isValid(1))
        #expect(ABCBarLine.PlayCount.isValid(100))
    }

    @Test
    func isValid_zeroIsInvalid() {
        #expect(!ABCBarLine.PlayCount.isValid(0))
    }
}
