// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCClefNameTests {
}

// MARK: -

extension ABCClefNameTests {
    @Test
    func equality() {
        #expect(ABCClef.Name.treble == ABCClef.Name(stringValue: "treble"))
    }

    @Test
    func inequality() {
        #expect(ABCClef.Name.treble != ABCClef.Name.bass)
    }

    @Test
    func init_nilForEmptyString() {
        #expect(ABCClef.Name(stringValue: "") == nil)
    }

    @Test
    func init_nilForStringWithDigit() {
        #expect(ABCClef.Name(stringValue: "treble2") == nil)
    }

    @Test
    func init_nilForStringWithUppercaseLetter() {
        #expect(ABCClef.Name(stringValue: "Treble") == nil)
    }

    @Test
    func init_storesStringValue() {
        let name = ABCClef.Name(stringValue: "tenor")

        #expect(name?.stringValue == "tenor")
    }

    @Test
    func typeProperties_haveExpectedStringValues() {
        #expect(ABCClef.Name.alto.stringValue == "alto")
        #expect(ABCClef.Name.bass.stringValue == "bass")
        #expect(ABCClef.Name.noClef.stringValue == "none")
        #expect(ABCClef.Name.percussion.stringValue == "perc")
        #expect(ABCClef.Name.tenor.stringValue == "tenor")
        #expect(ABCClef.Name.treble.stringValue == "treble")
    }
}
