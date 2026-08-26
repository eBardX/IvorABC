// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCDecorationNameTests {
}

// MARK: -

extension ABCDecorationNameTests {
    @Test
    func equality() {
        let a = ABCDecoration.Name(stringValue: "roll")
        let b = ABCDecoration.Name(stringValue: "roll")

        #expect(a == b)
    }

    @Test
    func inequality() {
        #expect(ABCDecoration.Name(stringValue: "roll") != ABCDecoration.Name(stringValue: "trill"))
    }

    @Test
    func init_allowsSpecialCharacters() {
        let name = ABCDecoration.Name(stringValue: "5.(+<>")

        #expect(name?.stringValue == "5.(+<>")
    }

    @Test
    func init_nilForEmptyString() {
        #expect(ABCDecoration.Name(stringValue: "") == nil)
    }

    @Test
    func init_nilForStringWithInvalidCharacter() {
        #expect(ABCDecoration.Name(stringValue: "roll!") == nil)
    }

    @Test
    func init_storesStringValue() {
        let name = ABCDecoration.Name(stringValue: "trill")

        #expect(name?.stringValue == "trill")
    }

    @Test
    func isValid_emptyStringIsInvalid() {
        #expect(!ABCDecoration.Name.isValid(""))
    }

    @Test
    func isValid_stringWithAllowedCharactersIsValid() {
        #expect(ABCDecoration.Name.isValid("roll"))
        #expect(ABCDecoration.Name.isValid("5.(+<>"))
    }

    @Test
    func isValid_stringWithDisallowedCharacterIsInvalid() {
        #expect(!ABCDecoration.Name.isValid("roll!"))
    }
}
