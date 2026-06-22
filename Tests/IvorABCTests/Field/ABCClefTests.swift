// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCClefTests {
}

// MARK: -

extension ABCClefTests {
    @Test
    func equality() throws {
        let clef1 = try #require(ABCClef(name: "treble", middle: ABCClef.Middle(letter: .b, octave: 4), transpose: 0, octave: -1, stafflines: 5))
        let clef2 = try #require(ABCClef(name: "treble", middle: ABCClef.Middle(letter: .b, octave: 4), transpose: 0, octave: -1, stafflines: 5))

        #expect(clef1 == clef2)
    }

    @Test
    func inequality_differentMiddle() throws {
        let clef1 = try #require(ABCClef(middle: ABCClef.Middle(letter: .b, octave: 4)))
        let clef2 = try #require(ABCClef(middle: ABCClef.Middle(letter: .c, octave: 4)))

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentName() throws {
        let clef1 = try #require(ABCClef(name: "treble"))
        let clef2 = try #require(ABCClef(name: "bass"))

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentOctave() throws {
        let clef1 = try #require(ABCClef(octave: 1))
        let clef2 = try #require(ABCClef(octave: -1))

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentOttava() throws {
        let clef1 = try #require(ABCClef(ottava: .alta))
        let clef2 = try #require(ABCClef(ottava: .bassa))

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentStafflines() throws {
        let clef1 = try #require(ABCClef(stafflines: 5))
        let clef2 = try #require(ABCClef(stafflines: 4))

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentTranspose() throws {
        let clef1 = try #require(ABCClef(transpose: 12))
        let clef2 = try #require(ABCClef(transpose: -12))

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_nilVsNonNilName() throws {
        let clef1 = try #require(ABCClef())
        let clef2 = try #require(ABCClef(name: "treble"))

        #expect(clef1 != clef2)
    }

    @Test
    func inequality_differentLine() throws {
        let clef1 = try #require(ABCClef(name: "bass", line: 3))
        let clef2 = try #require(ABCClef(name: "bass", line: 4))

        #expect(clef1 != clef2)
    }

    @Test
    func init_defaultLine_alto() throws {
        let clef = try #require(ABCClef(name: .alto))

        #expect(clef.line == 3)
    }

    @Test
    func init_defaultLine_bass() throws {
        let clef = try #require(ABCClef(name: .bass))

        #expect(clef.line == 4)
    }

    @Test
    func init_defaultLine_tenor() throws {
        let clef = try #require(ABCClef(name: .tenor))

        #expect(clef.line == 4)
    }

    @Test
    func init_defaultLine_treble() throws {
        let clef = try #require(ABCClef(name: .treble))

        #expect(clef.line == 2)
    }

    @Test
    func init_defaultLine_unspecifiedName() throws {
        let clef = try #require(ABCClef())

        #expect(clef.line == 1)
    }

    @Test
    func init_defaultOctave() throws {
        let clef = try #require(ABCClef())

        #expect(clef.octave == 0)
    }

    @Test
    func init_defaultStafflines() throws {
        let clef = try #require(ABCClef())

        #expect(clef.stafflines == 5)
    }

    @Test
    func init_defaultTranspose() throws {
        let clef = try #require(ABCClef())

        #expect(clef.transpose == 0)
    }

    @Test
    func init_defaultValues() throws {
        let clef = try #require(ABCClef())

        #expect(clef.line == 1)
        #expect(clef.middle == nil)
        #expect(clef.name == nil)
        #expect(clef.octave == 0)
        #expect(clef.ottava == nil)
        #expect(clef.stafflines == 5)
        #expect(clef.transpose == 0)
    }

    @Test
    func init_invalidLine() {
        #expect(ABCClef(line: 0) == nil)
        #expect(ABCClef(line: -1) == nil)
        #expect(ABCClef(line: 6) == nil)
        #expect(ABCClef(name: .bass, line: 4, stafflines: 3) == nil)
    }

    @Test
    func init_validLine() throws {
        let clef = try #require(ABCClef(name: "bass", line: 4))

        #expect(clef.line == 4)
    }

    @Test
    func init_validOttava() throws {
        let above = try #require(ABCClef(ottava: .alta))
        let below = try #require(ABCClef(ottava: .bassa))

        #expect(above.ottava == .alta)
        #expect(below.ottava == .bassa)
    }

    @Test
    func init_emptyEquality() throws {
        let clef1 = try #require(ABCClef())
        let clef2 = try #require(ABCClef())

        #expect(clef1 == clef2)
    }
}
