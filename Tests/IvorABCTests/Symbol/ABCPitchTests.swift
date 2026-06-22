// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCPitchTests {
}

// MARK: -

extension ABCPitchTests {
    @Test
    func equality() {
        let a = makePitch(.c, .omitted, 4)
        let b = makePitch(.c, .omitted, 4)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let base = makePitch(.c, .omitted, 4)

        #expect(base != makePitch(.d, .omitted, 4))
        #expect(base != makePitch(.c, .sharp, 4))
        #expect(base != makePitch(.c, .omitted, 5))
    }

    @Test
    func init_storesValues() {
        let pitch = makePitch(.g, .flat, 3)

        #expect(pitch.letter == .g)
        #expect(pitch.accidental == .flat)
        #expect(pitch.octave == 3)
    }
}
