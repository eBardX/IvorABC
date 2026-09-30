// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCClefMiddleTests {
}

// MARK: -

extension ABCClefMiddleTests {
    @Test
    func equality() {
        let m1 = ABCClef.Middle(letter: .b, octave: 4)
        let m2 = ABCClef.Middle(letter: .b, octave: 4)

        #expect(m1 == m2)
    }

    @Test
    func inequality_differentLetter() {
        let m1 = ABCClef.Middle(letter: .b, octave: 4)
        let m2 = ABCClef.Middle(letter: .c, octave: 4)

        #expect(m1 != m2)
    }

    @Test
    func inequality_differentOctave() {
        let m1 = ABCClef.Middle(letter: .b, octave: 4)
        let m2 = ABCClef.Middle(letter: .b, octave: 5)

        #expect(m1 != m2)
    }

    @Test
    func init_setsProperties() {
        let m = ABCClef.Middle(letter: .d, octave: 5)

        #expect(m.letter == .d)
        #expect(m.octave == 5)
    }
}
