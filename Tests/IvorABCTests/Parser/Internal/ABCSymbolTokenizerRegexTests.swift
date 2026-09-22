// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCSymbolTokenizerRegexTests {
}

// MARK: -

extension ABCSymbolTokenizerRegexTests {
    @Test
    func regexAnnotation_matchesQuotedText() throws {
        #expect(try ABCSymbolTokenizer.regexAnnotation.wholeMatch(in: "\"^dim.\"") != nil)
    }

    @Test
    func regexAnnotation_rejectsUnknownPlacement() throws {
        #expect(try ABCSymbolTokenizer.regexAnnotation.wholeMatch(in: "\"?dim.\"") == nil)
    }

    @Test
    func regexBarLine_matchesNFoldRepeat() throws {
        #expect(try ABCSymbolTokenizer.regexBarLine.wholeMatch(in: "|:::") != nil)
    }

    @Test
    func regexBarLine_matchesStandardBar() throws {
        #expect(try ABCSymbolTokenizer.regexBarLine.wholeMatch(in: "|") != nil)
    }

    @Test
    func regexBrokenRhythm_matchesUpToThreeChevrons() throws {
        #expect(try ABCSymbolTokenizer.regexBrokenRhythm.wholeMatch(in: "<<<") != nil)
    }

    @Test
    func regexBrokenRhythm_rejectsFourChevrons() throws {
        #expect(try ABCSymbolTokenizer.regexBrokenRhythm.wholeMatch(in: "<<<<") == nil)
    }

    @Test
    func regexChordSymbol_matchesSlashChordWithParenthesized() throws {
        #expect(try ABCSymbolTokenizer.regexChordSymbol.wholeMatch(in: "\"Gm7/B(Em)\"") != nil)
    }

    @Test
    func regexDecoration_matchesBangForm() throws {
        #expect(try ABCSymbolTokenizer.regexDecoration.wholeMatch(in: "!roll!") != nil)
    }

    @Test
    func regexDecoration_matchesLegacyPlusForm() throws {
        #expect(try ABCSymbolTokenizer.regexDecoration.wholeMatch(in: "+roll+") != nil)
    }

    @Test
    func regexInlineField_matchesLetterColonValue() throws {
        #expect(try ABCSymbolTokenizer.regexInlineField.wholeMatch(in: "[K:C]") != nil)
    }

    @Test
    func regexNote_matchesAccidentalOctaveLengthAndTie() throws {
        #expect(try ABCSymbolTokenizer.regexNote.wholeMatch(in: "^C,2-") != nil)
    }

    @Test
    func regexRest_matchesLetterWithLength() throws {
        #expect(try ABCSymbolTokenizer.regexRest.wholeMatch(in: "z2") != nil)
    }

    @Test
    func regexRest_rejectsNonRestLetter() throws {
        #expect(try ABCSymbolTokenizer.regexRest.wholeMatch(in: "q2") == nil)
    }

    @Test
    func regexShorthand_matchesTilde() throws {
        #expect(try ABCSymbolTokenizer.regexShorthand.wholeMatch(in: "~") != nil)
    }

    @Test
    func regexSpacer_matchesYWithLength() throws {
        #expect(try ABCSymbolTokenizer.regexSpacer.wholeMatch(in: "y/2") != nil)
    }

    @Test
    func regexTuplet_matchesFullPQRForm() throws {
        #expect(try ABCSymbolTokenizer.regexTuplet.wholeMatch(in: "(3:2:3") != nil)
    }

    @Test
    func regexTuplet_rejectsSingleDigitCount() throws {
        #expect(try ABCSymbolTokenizer.regexTuplet.wholeMatch(in: "(1") == nil)
    }

    @Test
    func regexVariantEnding_matchesRangeList() throws {
        #expect(try ABCSymbolTokenizer.regexVariantEnding.wholeMatch(in: "[1,3-4") != nil)
    }

    @Test
    func regexVariantEnding_rejectsBarLineColon() throws {
        #expect(try ABCSymbolTokenizer.regexVariantEnding.wholeMatch(in: "[1:") == nil)
    }
}
