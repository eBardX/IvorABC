// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCFieldParseFunctionsTests {
}

// MARK: -

extension ABCFieldParseFunctionsTests {
    @Test
    func parseField_alignedLyrics_decodesTextEscapes() throws {
        try expectFieldIsAlignedWords(parseField("w:f\\'o"),
                                      makeAlignedWords([.syllable("fó")]))
        try expectFieldIsAlignedWords(parseField("w:foo\\%bar"),
                                      makeAlignedWords([.syllable("foo%bar")]))
        try expectFieldIsAlignedWords(parseField("w:A-m\\\"a-zing"),
                                      makeAlignedWords([.syllable("A"), .continuation, .syllable("mä"), .continuation, .syllable("zing")]))
    }

    @Test
    func parseField_failure() {
        #expect(throws: ABCParser.Error.self) { try parseField("[K:bogus") }
        #expect(throws: ABCParser.Error.self) { try parseField("K:B##") }
        #expect(throws: ABCParser.Error.self) { try parseField("Q:120") }
        #expect(throws: ABCParser.Error.self) { try parseField("L:1/3") }
        #expect(throws: ABCParser.Error.self) { try parseField("U:~") }
        #expect(throws: ABCParser.Error.self) { try parseField("[A:area]") }
    }

    @Test
    func parseField_success() throws {
        try expectFieldIsAlignedWords(parseField("w:la la la"),
                                      makeAlignedWords([.syllable("la"), .syllable("la"), .syllable("la")]))
        try expectFieldIsArea(parseField("A:London"), "London")
        try expectFieldIsBook(parseField("B:My Fakebook"), "My Fakebook")
        try expectFieldIsComposer(parseField("C:J.S. Bach"), "J.S. Bach")
        try expectFieldIsDiscography(parseField("D:Collected Works"), "Collected Works")
        try expectFieldIsFileURL(parseField("F:https://example.com"), "https://example.com")
        try expectFieldIsGroup(parseField("G:Reels"), "Reels")
        try expectFieldIsHistory(parseField("H:Traditional"), "Traditional")
        try expectFieldIsInstruction(parseField("I:linebreak $"),
                                     makeDirective("linebreak", "$"))
        try expectFieldIsKey(parseField("K:G"))
        try expectFieldIsLyrics(parseField("W:do re mi"), "do re mi")
        try expectFieldIsMacro(parseField("m:~G3 = G{A}G2"), makeMacro("~G3", "G{A}G2"))
        try expectFieldIsMeter(parseField("M:4/4"))
        try expectFieldIsNotes(parseField("N:See also"), "See also")
        try expectFieldIsOrigin(parseField("O:Ireland"), "Ireland")
        try expectFieldIsParts(parseField("P:AABB"),
                               makePartSequence([makePart(.a), makePart(.a), makePart(.b), makePart(.b)]))
        try expectFieldIsRefNumber(parseField("X:1"))
        try expectFieldIsRemark(parseField("r:editorial note"), "editorial note")
        try expectFieldIsRhythm(parseField("R:Reel"), "Reel")
        try expectFieldIsSource(parseField("S:collected by ..."), "collected by ...")
        try expectFieldIsSymbolLine(parseField("s:!p! * * *"),
                                    makeSymbolLine([.decoration(makeDecoration("p", .bang)), .skip, .skip, .skip]))
        try expectFieldIsTempo(parseField("Q:1/4=120"))
        try expectFieldIsTitle(parseField("T:My Tune"), "My Tune")
        try expectFieldIsTranscription(parseField("Z:John Doe"), "John Doe")
        try expectFieldIsUnitNoteLength(parseField("L:1/8"))
        try expectFieldIsUserSymbol(parseField("U:~=!roll!"), makeUserSymbol(.tilde, makeDecoration("roll")))
        try expectFieldIsVoice(parseField("V:1"))
    }

    @Test
    func parseUnitNoteLength_failure() {
        #expect(parseUnitNoteLength("") == nil)
        #expect(parseUnitNoteLength("0") == nil)
        #expect(parseUnitNoteLength("1//") == nil)
    }

    @Test
    func parseUnitNoteLength_success() {
        #expect(parseUnitNoteLength("1") == makeLength(1, 1))
        #expect(parseUnitNoteLength("1/1") == makeLength(1, 1))
        #expect(parseUnitNoteLength("1/2") == makeLength(1, 2))
        #expect(parseUnitNoteLength("1/4") == makeLength(1, 4))
        #expect(parseUnitNoteLength("1/8") == makeLength(1, 8))
        #expect(parseUnitNoteLength("1/16") == makeLength(1, 16))
        #expect(parseUnitNoteLength("1/32") == makeLength(1, 32))
        #expect(parseUnitNoteLength("1/64") == makeLength(1, 64))
        #expect(parseUnitNoteLength("1/128") == makeLength(1, 128))
        #expect(parseUnitNoteLength("1/256") == makeLength(1, 256))
        #expect(parseUnitNoteLength("1/512") == makeLength(1, 512))
    }

    @Test
    func parseUserSymbol_deassignment() {
        #expect(parseUserSymbol("T=!nil!") == makeUserSymbol(.tUpper))
        #expect(parseUserSymbol("T = !nil!") == makeUserSymbol(.tUpper))
        #expect(parseUserSymbol("~=!none!") == makeUserSymbol(.tilde))
        #expect(parseUserSymbol("~ = !none!") == makeUserSymbol(.tilde))
        #expect(parseUserSymbol("T=+nil+") == makeUserSymbol(.tUpper))
        #expect(parseUserSymbol("T = +nil+") == makeUserSymbol(.tUpper))
        #expect(parseUserSymbol("~=+none+") == makeUserSymbol(.tilde))
        #expect(parseUserSymbol("~ = +none+") == makeUserSymbol(.tilde))
    }

    @Test
    func parseUserSymbol_failure() {
        #expect(parseUserSymbol("") == nil)
        #expect(parseUserSymbol("~") == nil)
        #expect(parseUserSymbol("~=") == nil)
        #expect(parseUserSymbol("= !roll!") == nil)
    }

    @Test
    func parseUserSymbol_success() {
        #expect(parseUserSymbol("T=!trill!") == makeUserSymbol(.tUpper, makeDecoration("trill")))
        #expect(parseUserSymbol("T = !trill!") == makeUserSymbol(.tUpper, makeDecoration("trill")))
        #expect(parseUserSymbol("~=!roll!") == makeUserSymbol(.tilde, makeDecoration("roll")))
        #expect(parseUserSymbol("~ = !roll!") == makeUserSymbol(.tilde, makeDecoration("roll")))
        #expect(parseUserSymbol("H=!fermata!") == makeUserSymbol(.hUpper, makeDecoration("fermata")))
        #expect(parseUserSymbol("H=\"^fermata\"") == makeUserSymbol(.hUpper, .annotation(makeAnnotation(.above, "fermata"))))
        #expect(parseUserSymbol("T = \"_col legno\"") == makeUserSymbol(.tUpper, .annotation(makeAnnotation(.below, "col legno"))))
    }
}
