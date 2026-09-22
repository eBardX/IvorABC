// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCAlignedWordsSegmentSyllableTests {
}

// MARK: -

extension ABCAlignedWordsSegmentSyllableTests {
    @Test
    func equality() {
        let a = ABCAlignedWords.Segment.Syllable(stringValue: "la")
        let b = ABCAlignedWords.Segment.Syllable(stringValue: "la")

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a = ABCAlignedWords.Segment.Syllable(stringValue: "la")
        let b = ABCAlignedWords.Segment.Syllable(stringValue: "di")

        #expect(a != b)
    }

    @Test
    func init_nilForC0ControlCharacter() {
        #expect(ABCAlignedWords.Segment.Syllable(stringValue: "la\u{0001}") == nil)
    }

    @Test
    func init_nilForC1ControlCharacter() {
        #expect(ABCAlignedWords.Segment.Syllable(stringValue: "la\u{0080}") == nil)
    }

    @Test
    func init_nilForDEL() {
        #expect(ABCAlignedWords.Segment.Syllable(stringValue: "la\u{007f}") == nil)
    }

    @Test
    func init_nilForEmptyString() {
        #expect(ABCAlignedWords.Segment.Syllable(stringValue: "") == nil)
    }

    @Test
    func init_storesStringValue() {
        let syllable = ABCAlignedWords.Segment.Syllable(stringValue: "la-")

        #expect(syllable?.stringValue == "la-")
    }

    @Test
    func isValid_stringsWithSpacesAndHyphens() {
        #expect(ABCAlignedWords.Segment.Syllable.isValid("la "))
        #expect(ABCAlignedWords.Segment.Syllable.isValid("la-"))
    }

    @Test
    func isValid_stringWithControlCharacterIsInvalid() {
        #expect(!ABCAlignedWords.Segment.Syllable.isValid("la\n"))
    }

    @Test
    func isValid_stringWithoutControlCharactersIsValid() {
        #expect(ABCAlignedWords.Segment.Syllable.isValid("la"))
    }
}
