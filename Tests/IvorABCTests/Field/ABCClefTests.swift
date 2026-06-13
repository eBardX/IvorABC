// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCClefTests {
}

// MARK: -

extension ABCClefTests {
    @Test
    func equality() {
        let clef1 = ABCClef(name: "treble", middle: "B", octave: -1, stafflines: 5, transpose: 0)
        let clef2 = ABCClef(name: "treble", middle: "B", octave: -1, stafflines: 5, transpose: 0)

        #expect(clef1 == clef2)
    }

    @Test
    func inequality_differentMiddle() {
        let clef1 = ABCClef(middle: "B")
        let clef2 = ABCClef(middle: "C")

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentName() {
        let clef1 = ABCClef(name: "treble")
        let clef2 = ABCClef(name: "bass")

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentOctave() {
        let clef1 = ABCClef(octave: 1)
        let clef2 = ABCClef(octave: -1)

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentStafflines() {
        let clef1 = ABCClef(stafflines: 5)
        let clef2 = ABCClef(stafflines: 4)

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentTranspose() {
        let clef1 = ABCClef(transpose: 12)
        let clef2 = ABCClef(transpose: -12)

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_nilVsNonNilName() {
        let clef1 = ABCClef()
        let clef2 = ABCClef(name: "treble")

        #expect(clef1 != clef2)
    }

    @Test
    func init_defaultsAllPropertiesNil() {
        let clef = ABCClef()

        #expect(clef.middle == nil)
        #expect(clef.name == nil)
        #expect(clef.octave == nil)
        #expect(clef.stafflines == nil)
        #expect(clef.transpose == nil)
    }

    @Test
    func init_emptyEquality() {
        let clef1 = ABCClef()
        let clef2 = ABCClef()

        #expect(clef1 == clef2)
    }
}
