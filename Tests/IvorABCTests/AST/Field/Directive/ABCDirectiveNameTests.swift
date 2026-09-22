// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCDirectiveNameTests {
}

// MARK: -

extension ABCDirectiveNameTests {
    @Test
    func equality() {
        #expect(ABCDirective.Name.decoration == ABCDirective.Name(stringValue: "decoration"))
    }

    @Test
    func inequality() {
        #expect(ABCDirective.Name.decoration != ABCDirective.Name.linebreak)
    }

    @Test
    func init_allowsDigitsAndHyphensAfterFirstCharacter() {
        let name = ABCDirective.Name(stringValue: "x-directive-2")

        #expect(name?.stringValue == "x-directive-2")
    }

    @Test
    func init_nilForEmptyString() {
        #expect(ABCDirective.Name(stringValue: "") == nil)
    }

    @Test
    func init_nilForStringStartingWithDigit() {
        #expect(ABCDirective.Name(stringValue: "1abc") == nil)
    }

    @Test
    func init_nilForStringStartingWithHyphen() {
        #expect(ABCDirective.Name(stringValue: "-abc") == nil)
    }

    @Test
    func init_nilForStringWithInvalidCharacter() {
        #expect(ABCDirective.Name(stringValue: "page_width") == nil)
    }

    @Test
    func init_storesStringValue() {
        let name = ABCDirective.Name(stringValue: "abc-version")

        #expect(name?.stringValue == "abc-version")
    }

    @Test
    func typeProperties_haveExpectedStringValues() {
        #expect(ABCDirective.Name.abcCharset.stringValue == "abc-charset")
        #expect(ABCDirective.Name.abcCreator.stringValue == "abc-creator")
        #expect(ABCDirective.Name.abcInclude.stringValue == "abc-include")
        #expect(ABCDirective.Name.abcVersion.stringValue == "abc-version")
        #expect(ABCDirective.Name.decoration.stringValue == "decoration")
        #expect(ABCDirective.Name.linebreak.stringValue == "linebreak")
    }
}
