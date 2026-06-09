// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCClefTests {
}

// MARK: -

extension ABCClefTests {
    @Test
    func equality() {
        var clef1 = ABCClef()

        clef1.name = "treble"
        clef1.middle = "B"
        clef1.octave = -1
        clef1.stafflines = 5
        clef1.transpose = 0

        var clef2 = ABCClef()

        clef2.name = "treble"
        clef2.middle = "B"
        clef2.octave = -1
        clef2.stafflines = 5
        clef2.transpose = 0

        #expect(clef1 == clef2)
    }

    @Test
    func inequality_differentMiddle() {
        var clef1 = ABCClef()
        var clef2 = ABCClef()

        clef1.middle = "B"
        clef2.middle = "C"

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentName() {
        var clef1 = ABCClef()
        var clef2 = ABCClef()

        clef1.name = "treble"
        clef2.name = "bass"

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentOctave() {
        var clef1 = ABCClef()
        var clef2 = ABCClef()

        clef1.octave = 1
        clef2.octave = -1

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentStafflines() {
        var clef1 = ABCClef()
        var clef2 = ABCClef()

        clef1.stafflines = 5
        clef2.stafflines = 4

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentTranspose() {
        var clef1 = ABCClef()
        var clef2 = ABCClef()

        clef1.transpose = 12
        clef2.transpose = -12

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_nilVsNonNilName() {
        let clef1 = ABCClef()
        var clef2 = ABCClef()

        clef2.name = "treble"

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
