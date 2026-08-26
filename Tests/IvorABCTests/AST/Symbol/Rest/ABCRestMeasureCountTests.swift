// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCRestMeasureCountTests {
}

// MARK: -

extension ABCRestMeasureCountTests {
    @Test
    func equality() {
        let a: ABCRest.MeasureCount = 2
        let b: ABCRest.MeasureCount = 2

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a: ABCRest.MeasureCount = 2
        let b: ABCRest.MeasureCount = 3

        #expect(a != b)
    }

    @Test
    func init_nilForZero() {
        #expect(ABCRest.MeasureCount(uintValue: 0) == nil)
    }

    @Test
    func init_storesUIntValue() {
        let count = ABCRest.MeasureCount(uintValue: 4)

        #expect(count?.uintValue == 4)
    }

    @Test
    func integerLiteral() {
        let count: ABCRest.MeasureCount = 4

        #expect(count.uintValue == 4)
    }

    @Test
    func isValid_positiveValuesAreValid() {
        #expect(ABCRest.MeasureCount.isValid(1))
        #expect(ABCRest.MeasureCount.isValid(100))
    }

    @Test
    func isValid_zeroIsInvalid() {
        #expect(!ABCRest.MeasureCount.isValid(0))
    }
}
