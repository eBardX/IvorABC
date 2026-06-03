// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCParseFunctionsTests {
}

// MARK: -

extension ABCParseFunctionsTests {
    @Test
    func normalize() {
        #expect(IvorABC.normalize("  xyzzy  \\% keep  ") == "xyzzy \\% keep")
        #expect(IvorABC.normalize("  xyzzy  \\% keep  % ignore  ") == "xyzzy \\% keep % ignore")
        #expect(IvorABC.normalize("  xyzzy  % ignore  ") == "xyzzy % ignore")
        #expect(IvorABC.normalize("  xyzzy  %ignore \\% keep  ") == "xyzzy %ignore \\% keep")
    }

    @Test
    func parseDuration_failure() {
        #expect(parseDuration("") == nil)
        #expect(parseDuration("3//2") == nil)
    }

    @Test
    func parseDuration_success() {
        #expect(parseDuration("/") == _dur(1, 2))
        #expect(parseDuration("//") == _dur(1, 4))
        #expect(parseDuration("///") == _dur(1, 8))
        #expect(parseDuration("/2") == _dur(1, 2))
        #expect(parseDuration("2") == _dur(2, 1))
        #expect(parseDuration("3") == _dur(3, 1))
        #expect(parseDuration("3/") == _dur(3, 2))
        #expect(parseDuration("3/2") == _dur(3, 2))
        #expect(parseDuration("4") == _dur(4, 1))
        #expect(parseDuration("8") == _dur(8, 1))
    }

    @Test
    func parseField_failure() {
        #expect(throws: ABCParseError.self) { try parseField("[K:bogus") }
        #expect(throws: ABCParseError.self) { try parseField("K:B##") }
        #expect(throws: ABCParseError.self) { try parseField("Q:120") }
        #expect(throws: ABCParseError.self) { try parseField("L:1/3") }
        #expect(throws: ABCParseError.self) { try parseField("U:~") }
        #expect(throws: ABCParseError.self) { try parseField("[A:area]") }
    }

    @Test
    func parseField_success() throws {
        try expectFieldIsAlignedLyrics(parseField("w:la la la"), "la la la")
        try expectFieldIsArea(parseField("A:London"), "London")
        try expectFieldIsBook(parseField("B:My Fakebook"), "My Fakebook")
        try expectFieldIsComposer(parseField("C:J.S. Bach"), "J.S. Bach")
        try expectFieldIsContinuation(parseField("+:more text"), "more text")
        try expectFieldIsDiscography(parseField("D:Collected Works"), "Collected Works")
        try expectFieldIsFileURL(parseField("F:https://example.com"), "https://example.com")
        try expectFieldIsGroup(parseField("G:Reels"), "Reels")
        try expectFieldIsHistory(parseField("H:Traditional"), "Traditional")
        try expectFieldIsInstruction(parseField("I:linebreak $"), "linebreak $")
        try expectFieldIsKey(parseField("K:G"))
        try expectFieldIsLyrics(parseField("W:do re mi"), "do re mi")
        try expectFieldIsMacro(parseField("m:~G3 = G{A}G2"), "~G3 = G{A}G2")
        try expectFieldIsMeter(parseField("M:4/4"))
        try expectFieldIsNotes(parseField("N:See also"), "See also")
        try expectFieldIsOrigin(parseField("O:Ireland"), "Ireland")
        try expectFieldIsParts(parseField("P:AABB"), "AABB")
        try expectFieldIsRefNumber(parseField("X:1"))
        try expectFieldIsRemark(parseField("r:editorial note"), "editorial note")
        try expectFieldIsRhythm(parseField("R:Reel"), "Reel")
        try expectFieldIsSource(parseField("S:collected by ..."), "collected by ...")
        try expectFieldIsSymbolLine(parseField("s:!p! * * *"), "!p! * * *")
        try expectFieldIsTempo(parseField("Q:1/4=120"))
        try expectFieldIsTitle(parseField("T:My Tune"), "My Tune")
        try expectFieldIsTranscription(parseField("Z:John Doe"), "John Doe")
        try expectFieldIsUnitNoteLength(parseField("L:1/8"))
        try expectFieldIsUserDefined(parseField("U:~=!roll!"), _udef("~", "!roll!"))
        try expectFieldIsVoice(parseField("V:1"))
    }

    @Test
    func parseKeySignature_failure() {
        #expect(parseKeySignature("B##") == nil)
        #expect(parseKeySignature("C# neutral") == nil)
    }

    @Test
    func parseKeySignature_success() {
        #expect(parseKeySignature("") == .empty)
        #expect(parseKeySignature("ADor") == .standard(.a, .dorian, []))
        #expect(parseKeySignature("AMix") == .standard(.a, .mixolydian, []))
        #expect(parseKeySignature("D =c") == .standard(.d, .major, [_pit(.c, .natural, 5)]))
        #expect(parseKeySignature("D exp _b _e ^f") == .standard(.d,
                                                                 .explicit,
                                                                 [_pit(.b, .flat, 5),
                                                                  _pit(.e, .flat, 5),
                                                                  _pit(.f, .sharp, 5)]))
        #expect(parseKeySignature("D maj =c") == .standard(.d, .major, [_pit(.c, .natural, 5)]))
        #expect(parseKeySignature("D Phr ^f") == .standard(.d, .phrygian, [_pit(.f, .sharp, 5)]))
        #expect(parseKeySignature("D") == .standard(.d, .major, []))
        #expect(parseKeySignature("Dm") == .standard(.d, .minor, []))
        #expect(parseKeySignature("Eb") == .standard(.eFlat, .major, []))
        #expect(parseKeySignature("F# mixolydian") == .standard(.fSharp, .mixolydian, []))
        #expect(parseKeySignature("F#Mix") == .standard(.fSharp, .mixolydian, []))
        #expect(parseKeySignature("F#MIX") == .standard(.fSharp, .mixolydian, []))
        #expect(parseKeySignature("G") == .standard(.g, .major, []))
        #expect(parseKeySignature("HP") == .highlandPipes)
        #expect(parseKeySignature("Hp") == .highlandPipesPreset)
        #expect(parseKeySignature("none") == .empty)
    }

    @Test
    func parseNote_failure() {
        #expect(parseNote("") == nil)
    }

    @Test
    func parseNote_success() {
        #expect(parseNote("_d") == ((.d, .flat, 5), nil, false))
        #expect(parseNote("_d''/") == ((.d, .flat, 7), _dur(1, 2), false))
        #expect(parseNote("=A") == ((.a, .natural, 4), nil, false))
        #expect(parseNote("=E") == ((.e, .natural, 4), nil, false))
        #expect(parseNote("=E,//-") == ((.e, .natural, 3), _dur(1, 4), true))
        #expect(parseNote("=E2") == ((.e, .natural, 4), _dur(2, 1), false))
        #expect(parseNote("a") == ((.a, nil, 5), nil, false))
        #expect(parseNote("A,,3") == ((.a, nil, 2), _dur(3, 1), false))
        #expect(parseNote("A/") == ((.a, nil, 4), _dur(1, 2), false))
        #expect(parseNote("a2") == ((.a, nil, 5), _dur(2, 1), false))
        #expect(parseNote("a4") == ((.a, nil, 5), _dur(4, 1), false))
        #expect(parseNote("b") == ((.b, nil, 5), nil, false))
        #expect(parseNote("B/") == ((.b, nil, 4), _dur(1, 2), false))
        #expect(parseNote("B2") == ((.b, nil, 4), _dur(2, 1), false))
        #expect(parseNote("B4") == ((.b, nil, 4), _dur(4, 1), false))
        #expect(parseNote("c") == ((.c, nil, 5), nil, false))
        #expect(parseNote("c/") == ((.c, nil, 5), _dur(1, 2), false))
        #expect(parseNote("c2") == ((.c, nil, 5), _dur(2, 1), false))
        #expect(parseNote("c3") == ((.c, nil, 5), _dur(3, 1), false))
        #expect(parseNote("d") == ((.d, nil, 5), nil, false))
        #expect(parseNote("d/") == ((.d, nil, 5), _dur(1, 2), false))
        #expect(parseNote("D//") == ((.d, nil, 4), _dur(1, 4), false))
        #expect(parseNote("d2") == ((.d, nil, 5), _dur(2, 1), false))
        #expect(parseNote("e-") == ((.e, nil, 5), nil, true))
        #expect(parseNote("e'/") == ((.e, nil, 6), _dur(1, 2), false))
        #expect(parseNote("e2") == ((.e, nil, 5), _dur(2, 1), false))
        #expect(parseNote("e3") == ((.e, nil, 5), _dur(3, 1), false))
        #expect(parseNote("f''''-") == ((.f, nil, 9), nil, true))
        #expect(parseNote("f/") == ((.f, nil, 5), _dur(1, 2), false))
        #expect(parseNote("f2") == ((.f, nil, 5), _dur(2, 1), false))
        #expect(parseNote("F3/2") == ((.f, nil, 4), _dur(3, 2), false))
        #expect(parseNote("F8") == ((.f, nil, 4), _dur(8, 1), false))
        #expect(parseNote("g") == ((.g, nil, 5), nil, false))
        #expect(parseNote("G,/2") == ((.g, nil, 3), _dur(1, 2), false))
        #expect(parseNote("g'2") == ((.g, nil, 6), _dur(2, 1), false))
        #expect(parseNote("g/") == ((.g, nil, 5), _dur(1, 2), false))
    }

    @Test
    func parsePitch_failure() {
        #expect(parsePitch("") == nil)
        #expect(parsePitch("___b") == nil)
        #expect(parsePitch("^_d") == nil)
        #expect(parsePitch("^^^C") == nil)
        #expect(parsePitch("==A") == nil)
    }

    @Test
    func parsePitch_success() {
        #expect(parsePitch("__b") == (.b, .doubleFlat, 5))
        #expect(parsePitch("__E','") == (.e, .doubleFlat, 5))
        #expect(parsePitch("__G',',") == (.g, .doubleFlat, 4))
        #expect(parsePitch("_a'") == (.a, .flat, 6))
        #expect(parsePitch("_D,,") == (.d, .flat, 2))
        #expect(parsePitch("_F,,,") == (.f, .flat, 1))
        #expect(parsePitch("^^C") == (.c, .doubleSharp, 4))
        #expect(parsePitch("^^e,',") == (.e, .doubleSharp, 4))
        #expect(parsePitch("^^g,','") == (.g, .doubleSharp, 5))
        #expect(parsePitch("^B,") == (.b, .sharp, 3))
        #expect(parsePitch("^d") == (.d, .sharp, 5))
        #expect(parsePitch("^f'''") == (.f, .sharp, 8))
        #expect(parsePitch("=A") == (.a, .natural, 4))
        #expect(parsePitch("=c''") == (.c, .natural, 7))
        #expect(parsePitch("A") == (.a, nil, 4))
        #expect(parsePitch("a") == (.a, nil, 5))
        #expect(parsePitch("B") == (.b, nil, 4))
        #expect(parsePitch("b") == (.b, nil, 5))
        #expect(parsePitch("C") == (.c, nil, 4))
        #expect(parsePitch("c") == (.c, nil, 5))
        #expect(parsePitch("D") == (.d, nil, 4))
        #expect(parsePitch("d") == (.d, nil, 5))
        #expect(parsePitch("E") == (.e, nil, 4))
        #expect(parsePitch("e") == (.e, nil, 5))
        #expect(parsePitch("F") == (.f, nil, 4))
        #expect(parsePitch("f") == (.f, nil, 5))
        #expect(parsePitch("G") == (.g, nil, 4))
        #expect(parsePitch("g") == (.g, nil, 5))
    }

    @Test
    func parseRefNumber_failure() {
        #expect(parseRefNumber("") == nil)
        #expect(parseRefNumber("0") == nil)
    }

    @Test
    func parseRefNumber_success() {
        #expect(parseRefNumber("1") == _rnum(1))
        #expect(parseRefNumber("007") == _rnum(7))
        #expect(parseRefNumber("5836472") == _rnum(5_836_472))
    }

    @Test
    func parseRest_failure() {
        #expect(parseRest("") == nil)
        #expect(parseRest("X3/2") == nil)
        #expect(parseRest("y") == nil)
        #expect(parseRest("Y4") == nil)
    }

    @Test
    func parseRest_success() {
        #expect(parseRest("x") == ("x", nil))
        #expect(parseRest("x//") == ("x", _dur(1, 4)))
        #expect(parseRest("X2") == ("X", _dur(2, 1)))
        #expect(parseRest("z") == ("z", nil))
        #expect(parseRest("z3/2") == ("z", _dur(3, 2)))
        #expect(parseRest("Z4") == ("Z", _dur(4, 1)))
    }

    @Test
    func parseTempo_compoundBeat_failure() {
        #expect(parseTempo("3/8+1/4=44") == nil)
        #expect(parseTempo("1/4+1/4+1/4=120") == nil)
        #expect(parseTempo("1/4 +3/8+ 1/4 + 3/8=40") == nil)
    }

    @Test
    func parseTempo_compoundBeat_success() {
        let d38 = _dur(3, 8)
        let d14 = _dur(1, 4)
        let d12 = _dur(1, 2)

        #expect(parseTempo("3/8 1/4=44") == _tempo([d38, d14], 44))
        #expect(parseTempo("3/8 1/4 = 44") == _tempo([d38, d14], 44))
        #expect(parseTempo("1/4 1/4 1/4=120") == _tempo([d14, d14, d14], 120))
        #expect(parseTempo("1/2 1/4=60") == _tempo([d12, d14], 60))
        #expect(parseTempo("1/4 3/8 1/4 3/8=40") == _tempo([d14, d38, d14, d38], 40))
    }

    @Test
    func parseTempo_failure() {
        #expect(parseTempo("") == nil)
        #expect(parseTempo("120") == nil)
        #expect(parseTempo("C = 120") == nil)
    }

    @Test
    func parseTempo_success() {
        #expect(parseTempo("\"Allegro\" 1/4=120") == _tempo(1, 4, 120, "Allegro"))
        #expect(parseTempo("\"Andante\"") == _tempo("Andante"))
        #expect(parseTempo("\"Andante mosso\" 1/4 = 110") == _tempo(1, 4, 110, "Andante mosso"))
        #expect(parseTempo("1/2=120") == _tempo(1, 2, 120))
        #expect(parseTempo("1/4 = 110 \"Andante mosso\"") == _tempo(1, 4, 110, "Andante mosso"))
        #expect(parseTempo("3/8=50 \"Slowly\"") == _tempo(3, 8, 50, "Slowly"))
    }

    @Test
    func parseTimeSignature_complex_failure() {
        #expect(parseTimeSignature("(2+3+2)/3") == nil)     // bad denominator
        #expect(parseTimeSignature("(2+3+2)") == nil)       // missing denominator
        #expect(parseTimeSignature("+3/8") == nil)          // leading +
        #expect(parseTimeSignature("2+/8") == nil)          // trailing +
        #expect(parseTimeSignature("2+0/8") == nil)         // zero numerator part
    }

    @Test
    func parseTimeSignature_complex_success() {
        #expect(parseTimeSignature("(2+3+2)/8") == _tsig([2, 3, 2], 8))
        #expect(parseTimeSignature("2+3+2/8") == _tsig([2, 3, 2], 8))
        #expect(parseTimeSignature("(3+3)/8") == _tsig([3, 3], 8))
        #expect(parseTimeSignature("3+3/8") == _tsig([3, 3], 8))
        #expect(parseTimeSignature("(2+3)/4") == _tsig([2, 3], 4))
        #expect(parseTimeSignature("3+3+2/8") == _tsig([3, 3, 2], 8))
    }

    @Test
    func parseTimeSignature_failure() {
        #expect(parseTimeSignature("") == nil)
        #expect(parseTimeSignature("4/3") == nil)
    }

    @Test
    func parseTimeSignature_success() {
        #expect(parseTimeSignature("C") == .common)
        #expect(parseTimeSignature("C|") == .cut)
        #expect(parseTimeSignature("12/8") == _tsig(12, 8))
        #expect(parseTimeSignature("3/4") == _tsig(3, 4))
        #expect(parseTimeSignature("4/4") == _tsig(4, 4))
        #expect(parseTimeSignature("6/8") == _tsig(6, 8))
        #expect(parseTimeSignature("9/8") == _tsig(9, 8))
    }

    @Test
    func parseTuplet_failure() {
        #expect(parseTuplet("") == nil)
        #expect(parseTuplet("(3:::") == nil)
    }

    @Test
    func parseTuplet_success() {
        #expect(parseTuplet("(3") == (3, nil, nil))
        #expect(parseTuplet("(3::") == (3, nil, nil))
        #expect(parseTuplet("(3:2") == (3, 2, nil))
        #expect(parseTuplet("(3:2:3") == (3, 2, 3))
        #expect(parseTuplet("(3::2") == (3, nil, 2))
        #expect(parseTuplet("(3:2:2") == (3, 2, 2))
        #expect(parseTuplet("(3:2:4") == (3, 2, 4))
    }

    @Test
    func parseUnitNoteLength_failure() {
        #expect(parseUnitNoteLength("") == nil)
        #expect(parseUnitNoteLength("0") == nil)
        #expect(parseUnitNoteLength("1//") == nil)
    }

    @Test
    func parseUnitNoteLength_success() {
        #expect(parseUnitNoteLength("1") == _dur(1, 1))
        #expect(parseUnitNoteLength("1/1") == _dur(1, 1))
        #expect(parseUnitNoteLength("1/2") == _dur(1, 2))
        #expect(parseUnitNoteLength("1/4") == _dur(1, 4))
        #expect(parseUnitNoteLength("1/8") == _dur(1, 8))
        #expect(parseUnitNoteLength("1/16") == _dur(1, 16))
        #expect(parseUnitNoteLength("1/32") == _dur(1, 32))
        #expect(parseUnitNoteLength("1/64") == _dur(1, 64))
        #expect(parseUnitNoteLength("1/128") == _dur(1, 128))
        #expect(parseUnitNoteLength("1/256") == _dur(1, 256))
        #expect(parseUnitNoteLength("1/512") == _dur(1, 512))
    }

    @Test
    func parseUserDefinedSymbol_failure() {
        #expect(parseUserDefinedSymbol("") == nil)
        #expect(parseUserDefinedSymbol("~") == nil)
        #expect(parseUserDefinedSymbol("~=") == nil)
        #expect(parseUserDefinedSymbol("= !roll!") == nil)
    }

    @Test
    func parseUserDefinedSymbol_success() {
        #expect(parseUserDefinedSymbol("T=!trill!") == _udef("T", "!trill!"))
        #expect(parseUserDefinedSymbol("T = !trill!") == _udef("T", "!trill!"))
        #expect(parseUserDefinedSymbol("~=!roll!") == _udef("~", "!roll!"))
        #expect(parseUserDefinedSymbol("~ = !roll!") == _udef("~", "!roll!"))
        #expect(parseUserDefinedSymbol("H=!fermata!") == _udef("H", "!fermata!"))
    }

    @Test
    func parseVoice_failure() {
        #expect(parseVoice("") == nil)
    }

    @Test
    func parseVoice_success() {
        #expect(parseVoice("1 clef=treble name=\"Soprano\"sname=\"A\"") == _voice("1", ["clef": "treble",
                                                                                        "name": "Soprano",
                                                                                        "sname": "A"]))
        #expect(parseVoice("2") == _voice("2"))
        #expect(parseVoice("3 clef = bass middle = d name = \"Tenor\" sname = \"B\"") == _voice("3", ["clef": "bass",
                                                                                                      "middle": "d",
                                                                                                      "name": "Tenor",
                                                                                                      "sname": "B"]))
        #expect(parseVoice("B1   middle=d   clef=bass      name=\"Basso I\"     snm=\"B.I\"    transpose=-24") == _voice("B1", ["middle": "d",
                                                                                                                                "clef": "bass",
                                                                                                                                "name": "Basso I",
                                                                                                                                "snm": "B.I",
                                                                                                                                "transpose": "-24"]))
        #expect(parseVoice("T1") == _voice("T1"))
        #expect(parseVoice("T2               clef=treble-8    name=\"Tenore II\"    snm=\"T.II\"") == _voice("T2", ["clef": "treble-8",
                                                                                                                    "name": "Tenore II",
                                                                                                                    "snm": "T.II"]))
    }

    @Test
    func tidy() {
        #expect(IvorABC.tidy("  xyzzy  \\% keep  ") == "xyzzy  \\% keep")
        #expect(IvorABC.tidy("  xyzzy  \\% keep  % ignore  ") == "xyzzy  \\% keep")
        #expect(IvorABC.tidy("  xyzzy  % ignore  ") == "xyzzy")
        #expect(IvorABC.tidy("  xyzzy  %ignore \\% keep  ") == "xyzzy")
    }

    @Test
    func trim() {
        #expect(IvorABC.trim("  xyzzy  \\% keep  ") == "xyzzy  \\% keep")
        #expect(IvorABC.trim("  xyzzy  \\% keep  % ignore  ") == "xyzzy  \\% keep  % ignore")
        #expect(IvorABC.trim("  xyzzy  % ignore  ") == "xyzzy  % ignore")
        #expect(IvorABC.trim("  xyzzy  %ignore \\% keep  ") == "xyzzy  %ignore \\% keep")
    }

    @Test
    func trimPrefix() {
        #expect(IvorABC.trimPrefix("  xyzzy  \\% keep  ") == "xyzzy  \\% keep  ")
        #expect(IvorABC.trimPrefix("  xyzzy  \\% keep  % ignore  ") == "xyzzy  \\% keep  % ignore  ")
        #expect(IvorABC.trimPrefix("  xyzzy  % ignore  ") == "xyzzy  % ignore  ")
        #expect(IvorABC.trimPrefix("  xyzzy  %ignore \\% keep  ") == "xyzzy  %ignore \\% keep  ")
    }

    @Test
    func trimSuffix() {
        #expect(IvorABC.trimSuffix("  xyzzy  \\% keep  ") == "  xyzzy  \\% keep")
        #expect(IvorABC.trimSuffix("  xyzzy  \\% keep  % ignore  ") == "  xyzzy  \\% keep  % ignore")
        #expect(IvorABC.trimSuffix("  xyzzy  % ignore  ") == "  xyzzy  % ignore")
        #expect(IvorABC.trimSuffix("  xyzzy  %ignore \\% keep  ") == "  xyzzy  %ignore \\% keep")
    }

    @Test
    func uncomment() {
        #expect(IvorABC.uncomment("% this is a comment").isEmpty)
        #expect(IvorABC.uncomment("this is not a comment") == "this is not a comment")
        #expect(IvorABC.uncomment("  xyzzy  \\% keep  ") == "  xyzzy  \\% keep  ")
        #expect(IvorABC.uncomment("  xyzzy  \\% keep  % ignore  ") == "  xyzzy  \\% keep  ")
        #expect(IvorABC.uncomment("  xyzzy  % ignore  ") == "  xyzzy  ")
        #expect(IvorABC.uncomment("  xyzzy  %ignore \\% keep  ") == "  xyzzy  ")
    }
}
