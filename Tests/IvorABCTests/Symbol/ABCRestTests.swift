// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCRestTests {
}

// MARK: -

extension ABCRestTests {
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
        let duration = ABCDuration(1, 4)
        let rest = ABCRest.regular(true, duration)

        #expect(rest.isInvisible)
    }

    @Test
    func regularIsNotMultiMeasure() {
        let duration = ABCDuration(1, 4)
        let rest = ABCRest.regular(false, duration)

        #expect(!rest.isMultiMeasure)
    }

    @Test
    func regularVisible() {
        let duration = ABCDuration(1, 8)
        let rest = ABCRest.regular(false, duration)

        #expect(!rest.isInvisible)
    }
}
