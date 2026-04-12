// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCRestTests {
}

// MARK: -

extension ABCRestTests {
    @Test
    func test_multiMeasureInvisible() {
        let rest = ABCRest.multiMeasure(true, 4)

        #expect(rest.isInvisible)
    }

    @Test
    func test_multiMeasureIsMultiMeasure() {
        let rest = ABCRest.multiMeasure(false, 2)

        #expect(rest.isMultiMeasure)
    }

    @Test
    func test_multiMeasureVisible() {
        let rest = ABCRest.multiMeasure(false, 3)

        #expect(!rest.isInvisible)
    }

    @Test
    func test_regularInvisible() {
        let duration = ABCDuration(numerator: 1,
                                   denominator: 4,
                                   reduce: false)
        let rest = ABCRest.regular(true, duration)

        #expect(rest.isInvisible)
    }

    @Test
    func test_regularIsNotMultiMeasure() {
        let duration = ABCDuration(numerator: 1,
                                   denominator: 4,
                                   reduce: false)
        let rest = ABCRest.regular(false, duration)

        #expect(!rest.isMultiMeasure)
    }

    @Test
    func test_regularVisible() {
        let duration = ABCDuration(numerator: 1,
                                   denominator: 8,
                                   reduce: false)
        let rest = ABCRest.regular(false, duration)

        #expect(!rest.isInvisible)
    }
}
