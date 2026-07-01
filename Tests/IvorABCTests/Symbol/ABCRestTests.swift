// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCRestTests {
}

// MARK: -

extension ABCRestTests {
    @Test
    func measureCount_zeroIsInvalid() {
        #expect(ABCRest.MeasureCount(uintValue: 0) == nil)
    }

    @Test
    func multiMeasureInvisible() {
        let rest = ABCRest.multiMeasure(true, 4)

        #expect(rest.isInvisible)
    }

    @Test
    func multiMeasureIsMultiMeasure() {
        let rest = ABCRest.multiMeasure(false, 2)

        #expect(rest.isMultiMeasure)
    }

    @Test
    func multiMeasureVisible() {
        let rest = ABCRest.multiMeasure(false, 3)

        #expect(!rest.isInvisible)
    }

    @Test
    func regularInvisible() {
        let length = makeLength(1, 4)
        let rest = ABCRest.regular(true, length)

        #expect(rest.isInvisible)
    }

    @Test
    func regularIsNotMultiMeasure() {
        let length = makeLength(1, 4)
        let rest = ABCRest.regular(false, length)

        #expect(!rest.isMultiMeasure)
    }

    @Test
    func regularVisible() {
        let length = makeLength(1, 8)
        let rest = ABCRest.regular(false, length)

        #expect(!rest.isInvisible)
    }
}
