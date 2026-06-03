// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCPitchTests {
}

// MARK: -

extension ABCPitchTests {
    @Test
    func equality() {
        let a = ABCPitch(letter: .c, accidental: .natural, octave: 4)
        let b = ABCPitch(letter: .c, accidental: .natural, octave: 4)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let base = ABCPitch(letter: .c, accidental: .natural, octave: 4)

        #expect(base != ABCPitch(letter: .d, accidental: .natural, octave: 4))
        #expect(base != ABCPitch(letter: .c, accidental: .sharp, octave: 4))
        #expect(base != ABCPitch(letter: .c, accidental: .natural, octave: 5))
    }

    @Test
    func init_storesValues() {
        let pitch = ABCPitch(letter: .g, accidental: .flat, octave: 3)

        #expect(pitch.letter == .g)
        #expect(pitch.accidental == .flat)
        #expect(pitch.octave == 3)
    }
}
