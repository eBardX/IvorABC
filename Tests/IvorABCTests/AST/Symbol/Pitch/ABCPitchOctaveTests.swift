// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCPitchOctaveTests {
}

// MARK: -

extension ABCPitchOctaveTests {
    @Test
    func comparable_ordersByValue() {
        let low: ABCPitch.Octave = 3
        let high: ABCPitch.Octave = 5

        #expect(low < high)
        #expect(!(high < low))
    }

    @Test
    func equality() {
        let a: ABCPitch.Octave = 4
        let b: ABCPitch.Octave = 4

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a: ABCPitch.Octave = 4
        let b: ABCPitch.Octave = 5

        #expect(a != b)
    }

    @Test
    func init_nilForValueAboveNine() {
        #expect(ABCPitch.Octave(uintValue: 10) == nil)
    }

    @Test
    func init_storesUIntValue() {
        let octave = ABCPitch.Octave(uintValue: 4)

        #expect(octave?.uintValue == 4)
    }

    @Test
    func integerLiteral() {
        let octave: ABCPitch.Octave = 4

        #expect(octave.uintValue == 4)
    }

    @Test
    func isValid_valueAboveRangeIsInvalid() {
        #expect(!ABCPitch.Octave.isValid(10))
    }

    @Test
    func isValid_valueInRangeIsValid() {
        #expect(ABCPitch.Octave.isValid(0))
        #expect(ABCPitch.Octave.isValid(9))
    }
}
