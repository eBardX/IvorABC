// © 2025–2026 John Gary Pusey (see LICENSE.md)

// swiftlint:disable file_length

@testable import IvorABC
import Testing
import XestiTools

struct ABCParseFunctionsTests {
}

// MARK: -

extension ABCParseFunctionsTests {
    @Test
    func normalize() {
        #expect(IvorABC.normalize("  xyzzy  \\% keep  ") == "xyzzy % keep")
        #expect(IvorABC.normalize("  xyzzy  \\% keep  % ignore  ") == "xyzzy % keep % ignore")
        #expect(IvorABC.normalize("  xyzzy  % ignore  ") == "xyzzy % ignore")
        #expect(IvorABC.normalize("  xyzzy  %ignore \\% keep  ") == "xyzzy %ignore % keep")
    }

    @Test
    func parseAnnotation_decodesAmpersandEntity() {
        #expect(parseAnnotation(Substring("\"<P&amp;L\"")) == makeAnnotation(.left, "P&L"))
    }

    @Test
    func parseAnnotation_decodesBackslash() {
        #expect(parseAnnotation(Substring("\"^a\\\\b\"")) == makeAnnotation(.above, "a\\b"))
    }

    @Test
    func parseAnnotation_decodesPercent() {
        #expect(parseAnnotation(Substring("\"^100\\%\"")) == makeAnnotation(.above, "100%"))
    }

    @Test
    func parseAnnotation_decodesUnicodeEscapeToQuote() {
        #expect(parseAnnotation(Substring("\"^a\\u0022b\"")) == makeAnnotation(.above, "a\"b"))
    }

    @Test
    func parseDuration_failure() {
        #expect(parseDuration("") == nil)
        #expect(parseDuration("3//2") == nil)
    }

    @Test
    func parseDuration_success() {
        #expect(parseDuration("/") == makeDuration(1, 2))
        #expect(parseDuration("//") == makeDuration(1, 4))
        #expect(parseDuration("///") == makeDuration(1, 8))
        #expect(parseDuration("/2") == makeDuration(1, 2))
        #expect(parseDuration("2") == makeDuration(2, 1))
        #expect(parseDuration("3") == makeDuration(3, 1))
        #expect(parseDuration("3/") == makeDuration(3, 2))
        #expect(parseDuration("3/2") == makeDuration(3, 2))
        #expect(parseDuration("4") == makeDuration(4, 1))
        #expect(parseDuration("8") == makeDuration(8, 1))
    }

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
    func parseKeySignature_clef() throws {
        let bassClef = try #require(ABCClef(name: "bass"))
        let percClef = try #require(ABCClef(name: "perc"))
        let trebleClef = try #require(ABCClef(name: "treble"))
        let transposeClef = try #require(ABCClef(transpose: -2))
        let combinedClef = try #require(ABCClef(name: "bass", transpose: -2))
        let percStafflinesClef = try #require(ABCClef(name: "perc", stafflines: 1))
        let trebleAbove8Clef = try #require(ABCClef(name: "treble", ottava: .alta))
        let bassBelow8Clef = try #require(ABCClef(name: "bass", ottava: .bassa))
        let middleTransposeClef = try #require(ABCClef(name: "bass", middle: ABCClef.Middle(letter: .d, octave: 5), transpose: -24))

        // clef= prefix form
        #expect(parseKeySignature("G clef=bass") == makeKeySignature(.g, .major, bassClef))
        #expect(parseKeySignature("C transpose=-2") == makeKeySignature(.c, .major, transposeClef))
        #expect(parseKeySignature("C major transpose=-2") == makeKeySignature(.c, .major, transposeClef))
        #expect(parseKeySignature("G clef=bass transpose=-2") == makeKeySignature(.g, .major, combinedClef))
        #expect(parseKeySignature("clef=treble") == .clefOnly(trebleClef))
        #expect(parseKeySignature("none clef=treble") == .clefOnly(trebleClef))

        // bare clef name form (no clef= prefix)
        #expect(parseKeySignature("perc stafflines=1") == .clefOnly(percStafflinesClef))
        #expect(parseKeySignature("G bass") == makeKeySignature(.g, .major, bassClef))
        #expect(parseKeySignature("G perc") == makeKeySignature(.g, .major, percClef))

        // +8 / -8 ottava markers
        #expect(parseKeySignature("clef=treble+8") == .clefOnly(trebleAbove8Clef))
        #expect(parseKeySignature("clef=bass-8") == .clefOnly(bassBelow8Clef))
        #expect(parseKeySignature("treble+8") == .clefOnly(trebleAbove8Clef))

        // m= and t= abbreviations
        #expect(parseKeySignature("C t=-2") == makeKeySignature(.c, .major, transposeClef))
        #expect(parseKeySignature("bass middle=d t=-24") == .clefOnly(middleTransposeClef))
        #expect(parseKeySignature("bass m=d t=-24") == .clefOnly(middleTransposeClef))

        // line number (clef= prefix form)
        let bass3Clef = try #require(ABCClef(name: "bass", line: 3))
        let alto2Clef = try #require(ABCClef(name: "alto", line: 2))
        let treble2Above8Clef = try #require(ABCClef(name: "treble", line: 2, ottava: .alta))

        #expect(parseKeySignature("clef=bass3") == .clefOnly(bass3Clef))
        #expect(parseKeySignature("clef=alto2") == .clefOnly(alto2Clef))
        #expect(parseKeySignature("clef=treble2+8") == .clefOnly(treble2Above8Clef))
        #expect(parseKeySignature("G clef=bass3") == makeKeySignature(.g, .major, bass3Clef))

        // line number (bare form)
        #expect(parseKeySignature("bass3") == .clefOnly(bass3Clef))
        #expect(parseKeySignature("treble2+8") == .clefOnly(treble2Above8Clef))
    }

    @Test
    func parseKeySignature_failure() {
        #expect(parseKeySignature("B##") == nil)
        #expect(parseKeySignature("C# neutral") == nil)
        #expect(parseKeySignature("G clef=bass unknown=x") == nil)
        #expect(parseKeySignature("G transpose=abc") == nil)
    }

    @Test
    func parseKeySignature_success() {
        #expect(parseKeySignature("") == .empty)
        #expect(parseKeySignature("ADor") == makeKeySignature(.a, .dorian))
        #expect(parseKeySignature("AMix") == makeKeySignature(.a, .mixolydian))
        #expect(parseKeySignature("D =c") == makeKeySignature(.d, .major, [makePitch(.c, .natural, 5)]))
        #expect(parseKeySignature("D exp _b _e ^f") == makeKeySignature(.d,
                                                                        .explicit,
                                                                        [makePitch(.b, .flat, 5),
                                                                         makePitch(.e, .flat, 5),
                                                                         makePitch(.f, .sharp, 5)]))
        #expect(parseKeySignature("D maj =c") == makeKeySignature(.d, .major, [makePitch(.c, .natural, 5)]))
        #expect(parseKeySignature("D Phr ^f") == makeKeySignature(.d, .phrygian, [makePitch(.f, .sharp, 5)]))
        #expect(parseKeySignature("D") == makeKeySignature(.d, .major))
        #expect(parseKeySignature("Dm") == makeKeySignature(.d, .minor))
        #expect(parseKeySignature("Eb") == makeKeySignature(.eFlat, .major))
        #expect(parseKeySignature("F# mixolydian") == makeKeySignature(.fSharp, .mixolydian))
        #expect(parseKeySignature("F#Mix") == makeKeySignature(.fSharp, .mixolydian))
        #expect(parseKeySignature("F#MIX") == makeKeySignature(.fSharp, .mixolydian))
        #expect(parseKeySignature("G") == makeKeySignature(.g, .major))
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
        #expect(parseNote("_d") == ((.d, .flat, 5), nil, nil))
        #expect(parseNote("_d''/") == ((.d, .flat, 7), makeDuration(1, 2), nil))
        #expect(parseNote("=A") == ((.a, .natural, 4), nil, nil))
        #expect(parseNote("=E") == ((.e, .natural, 4), nil, nil))
        #expect(parseNote("=E,//-") == ((.e, .natural, 3), makeDuration(1, 4), ABCTie.regular))
        #expect(parseNote("=E2") == ((.e, .natural, 4), makeDuration(2, 1), nil))
        #expect(parseNote("a") == ((.a, .omitted, 5), nil, nil))
        #expect(parseNote("A,,3") == ((.a, .omitted, 2), makeDuration(3, 1), nil))
        #expect(parseNote("A/") == ((.a, .omitted, 4), makeDuration(1, 2), nil))
        #expect(parseNote("a2") == ((.a, .omitted, 5), makeDuration(2, 1), nil))
        #expect(parseNote("a4") == ((.a, .omitted, 5), makeDuration(4, 1), nil))
        #expect(parseNote("b") == ((.b, .omitted, 5), nil, nil))
        #expect(parseNote("B/") == ((.b, .omitted, 4), makeDuration(1, 2), nil))
        #expect(parseNote("B2") == ((.b, .omitted, 4), makeDuration(2, 1), nil))
        #expect(parseNote("B4") == ((.b, .omitted, 4), makeDuration(4, 1), nil))
        #expect(parseNote("c") == ((.c, .omitted, 5), nil, nil))
        #expect(parseNote("c/") == ((.c, .omitted, 5), makeDuration(1, 2), nil))
        #expect(parseNote("c2") == ((.c, .omitted, 5), makeDuration(2, 1), nil))
        #expect(parseNote("c3") == ((.c, .omitted, 5), makeDuration(3, 1), nil))
        #expect(parseNote("d") == ((.d, .omitted, 5), nil, nil))
        #expect(parseNote("d/") == ((.d, .omitted, 5), makeDuration(1, 2), nil))
        #expect(parseNote("D//") == ((.d, .omitted, 4), makeDuration(1, 4), nil))
        #expect(parseNote("d2") == ((.d, .omitted, 5), makeDuration(2, 1), nil))
        #expect(parseNote("e-") == ((.e, .omitted, 5), nil, ABCTie.regular))
        #expect(parseNote("e'/") == ((.e, .omitted, 6), makeDuration(1, 2), nil))
        #expect(parseNote("e2") == ((.e, .omitted, 5), makeDuration(2, 1), nil))
        #expect(parseNote("e3") == ((.e, .omitted, 5), makeDuration(3, 1), nil))
        #expect(parseNote("f''''-") == ((.f, .omitted, 9), nil, ABCTie.regular))
        #expect(parseNote("f/") == ((.f, .omitted, 5), makeDuration(1, 2), nil))
        #expect(parseNote("f2") == ((.f, .omitted, 5), makeDuration(2, 1), nil))
        #expect(parseNote("F3/2") == ((.f, .omitted, 4), makeDuration(3, 2), nil))
        #expect(parseNote("F8") == ((.f, .omitted, 4), makeDuration(8, 1), nil))
        #expect(parseNote("g") == ((.g, .omitted, 5), nil, nil))
        #expect(parseNote("G,/2") == ((.g, .omitted, 3), makeDuration(1, 2), nil))
        #expect(parseNote("g'2") == ((.g, .omitted, 6), makeDuration(2, 1), nil))
        #expect(parseNote("g/") == ((.g, .omitted, 5), makeDuration(1, 2), nil))
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
        #expect(parsePitch("A") == (.a, .omitted, 4))
        #expect(parsePitch("a") == (.a, .omitted, 5))
        #expect(parsePitch("B") == (.b, .omitted, 4))
        #expect(parsePitch("b") == (.b, .omitted, 5))
        #expect(parsePitch("C") == (.c, .omitted, 4))
        #expect(parsePitch("c") == (.c, .omitted, 5))
        #expect(parsePitch("D") == (.d, .omitted, 4))
        #expect(parsePitch("d") == (.d, .omitted, 5))
        #expect(parsePitch("E") == (.e, .omitted, 4))
        #expect(parsePitch("e") == (.e, .omitted, 5))
        #expect(parsePitch("F") == (.f, .omitted, 4))
        #expect(parsePitch("f") == (.f, .omitted, 5))
        #expect(parsePitch("G") == (.g, .omitted, 4))
        #expect(parsePitch("g") == (.g, .omitted, 5))
    }

    @Test
    func parseRefNumber_failure() {
        #expect(parseReferenceNumber("") == nil)
        #expect(parseReferenceNumber("0") == nil)
    }

    @Test
    func parseRefNumber_success() {
        #expect(parseReferenceNumber("1") == makeReferenceNumber(1))
        #expect(parseReferenceNumber("007") == makeReferenceNumber(7))
        #expect(parseReferenceNumber("5836472") == makeReferenceNumber(5_836_472))
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
        #expect(parseRest("x//") == ("x", makeDuration(1, 4)))
        #expect(parseRest("X2") == ("X", makeDuration(2, 1)))
        #expect(parseRest("z") == ("z", nil))
        #expect(parseRest("z3/2") == ("z", makeDuration(3, 2)))
        #expect(parseRest("Z4") == ("Z", makeDuration(4, 1)))
    }

    @Test
    func parseSymbolLine_failure() {
        #expect(parseSymbolLine("bogus") == nil)
        #expect(parseSymbolLine("!p! bogus !f!") == nil)
        #expect(parseSymbolLine(".") == nil)
        #expect(parseSymbolLine("~") == nil)
        #expect(parseSymbolLine("!!") == nil)
    }

    @Test
    func parseSymbolLine_success() {
        #expect(parseSymbolLine("") == makeSymbolLine([]))
        #expect(parseSymbolLine("*") == makeSymbolLine([.skip]))
        #expect(parseSymbolLine("**") == makeSymbolLine([.skip, .skip]))
        #expect(parseSymbolLine("!p!") == makeSymbolLine([.decoration(makeDecoration("p", .bang))]))
        #expect(parseSymbolLine("!pp!") == makeSymbolLine([.decoration(makeDecoration("pp", .bang))]))
        #expect(parseSymbolLine("\"Am\"") == makeSymbolLine([.chordSymbol(ABCChordSymbol(name: .init(root: .a, kind: "m")))]))
        #expect(parseSymbolLine("\"^forte\"") == makeSymbolLine([.annotation(makeAnnotation(.above, "forte"))]))
        #expect(parseSymbolLine("\"_text\"") == makeSymbolLine([.annotation(makeAnnotation(.below, "text"))]))
        #expect(parseSymbolLine("!p! * * *") == makeSymbolLine([.decoration(makeDecoration("p", .bang)), .skip, .skip, .skip]))
        #expect(parseSymbolLine("!pp! * !f!") == makeSymbolLine([.decoration(makeDecoration("pp", .bang)),
                                                                 .skip,
                                                                 .decoration(makeDecoration("f", .bang))]))
        #expect(parseSymbolLine("\"Am\" * !trill!") == makeSymbolLine([.chordSymbol(ABCChordSymbol(name: .init(root: .a, kind: "m"))),
                                                                       .skip,
                                                                       .decoration(makeDecoration("trill", .bang))]))
        let aboveAnnotation = makeAnnotation(.above, "p")
        #expect(parseSymbolLine("\"^p\" \"Am\" *") == makeSymbolLine([.annotation(aboveAnnotation),
                                                                      .chordSymbol(ABCChordSymbol(name: .init(root: .a, kind: "m"))),
                                                                      .skip]))
    }

    @Test
    func parseTempo_compoundBeat_failure() {
        #expect(parseTempo("3/8+1/4=44") == nil)
        #expect(parseTempo("1/4+1/4+1/4=120") == nil)
        #expect(parseTempo("1/4 +3/8+ 1/4 + 3/8=40") == nil)
    }

    @Test
    func parseTempo_compoundBeat_success() {
        let d38 = makeDuration(3, 8)
        let d14 = makeDuration(1, 4)
        let d12 = makeDuration(1, 2)

        #expect(parseTempo("3/8 1/4=44") == makeTempo([d38, d14], 44))
        #expect(parseTempo("3/8 1/4 = 44") == makeTempo([d38, d14], 44))
        #expect(parseTempo("1/4 1/4 1/4=120") == makeTempo([d14, d14, d14], 120))
        #expect(parseTempo("1/2 1/4=60") == makeTempo([d12, d14], 60))
        #expect(parseTempo("1/4 3/8 1/4 3/8=40") == makeTempo([d14, d38, d14, d38], 40))
    }

    @Test
    func parseTempo_failure() {
        #expect(parseTempo("") == nil)
        #expect(parseTempo("120") == nil)
        #expect(parseTempo("C = 120") == nil)
    }

    @Test
    func parseTempo_success() {
        #expect(parseTempo("\"Allegro\" 1/4=120") == makeTempo(1, 4, 120, "Allegro"))
        #expect(parseTempo("\"Andante\"") == makeTempo("Andante"))
        #expect(parseTempo("\"Andante mosso\" 1/4 = 110") == makeTempo(1, 4, 110, "Andante mosso"))
        #expect(parseTempo("1/2=120") == makeTempo(1, 2, 120))
        #expect(parseTempo("1/4 = 110 \"Andante mosso\"") == makeTempo(1, 4, 110, "Andante mosso"))
        #expect(parseTempo("3/8=50 \"Slowly\"") == makeTempo(3, 8, 50, "Slowly"))
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
        #expect(parseTimeSignature("(2+3+2)/8") == makeTimeSignature([2, 3, 2], 8))
        #expect(parseTimeSignature("2+3+2/8") == makeTimeSignature([2, 3, 2], 8))
        #expect(parseTimeSignature("(3+3)/8") == makeTimeSignature([3, 3], 8))
        #expect(parseTimeSignature("3+3/8") == makeTimeSignature([3, 3], 8))
        #expect(parseTimeSignature("(2+3)/4") == makeTimeSignature([2, 3], 4))
        #expect(parseTimeSignature("3+3+2/8") == makeTimeSignature([3, 3, 2], 8))
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
        #expect(parseTimeSignature("12/8") == makeTimeSignature(12, 8))
        #expect(parseTimeSignature("3/4") == makeTimeSignature(3, 4))
        #expect(parseTimeSignature("4/4") == makeTimeSignature(4, 4))
        #expect(parseTimeSignature("6/8") == makeTimeSignature(6, 8))
        #expect(parseTimeSignature("9/8") == makeTimeSignature(9, 8))
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
        #expect(parseUnitNoteLength("1") == makeDuration(1, 1))
        #expect(parseUnitNoteLength("1/1") == makeDuration(1, 1))
        #expect(parseUnitNoteLength("1/2") == makeDuration(1, 2))
        #expect(parseUnitNoteLength("1/4") == makeDuration(1, 4))
        #expect(parseUnitNoteLength("1/8") == makeDuration(1, 8))
        #expect(parseUnitNoteLength("1/16") == makeDuration(1, 16))
        #expect(parseUnitNoteLength("1/32") == makeDuration(1, 32))
        #expect(parseUnitNoteLength("1/64") == makeDuration(1, 64))
        #expect(parseUnitNoteLength("1/128") == makeDuration(1, 128))
        #expect(parseUnitNoteLength("1/256") == makeDuration(1, 256))
        #expect(parseUnitNoteLength("1/512") == makeDuration(1, 512))
    }

    @Test
    func parseUserSymbol_failure() {
        #expect(parseUserSymbol("") == nil)
        #expect(parseUserSymbol("~") == nil)
        #expect(parseUserSymbol("~=") == nil)
        #expect(parseUserSymbol("= !roll!") == nil)
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
    func parseUserSymbol_success() {
        #expect(parseUserSymbol("T=!trill!") == makeUserSymbol(.tUpper, makeDecoration("trill")))
        #expect(parseUserSymbol("T = !trill!") == makeUserSymbol(.tUpper, makeDecoration("trill")))
        #expect(parseUserSymbol("~=!roll!") == makeUserSymbol(.tilde, makeDecoration("roll")))
        #expect(parseUserSymbol("~ = !roll!") == makeUserSymbol(.tilde, makeDecoration("roll")))
        #expect(parseUserSymbol("H=!fermata!") == makeUserSymbol(.hUpper, makeDecoration("fermata")))
        #expect(parseUserSymbol("H=\"^fermata\"") == makeUserSymbol(.hUpper, .annotation(makeAnnotation(.above, "fermata"))))
        #expect(parseUserSymbol("T = \"_col legno\"") == makeUserSymbol(.tUpper, .annotation(makeAnnotation(.below, "col legno"))))
    }

    @Test
    func parseVoice_failure() {
        #expect(parseVoice("") == nil)
    }

    @Test
    func parseVoice_bareClefName() throws {
        let bassClef = try #require(ABCClef(name: "bass"))
        let bassMidClef = try #require(ABCClef(name: "bass", middle: ABCClef.Middle(letter: .d, octave: 5)))

        #expect(parseVoice("B bass") == makeVoice("B", clef: bassClef))
        #expect(parseVoice("B middle=d bass") == makeVoice("B", clef: bassMidClef))
    }

    @Test
    func parseVoice_success() throws {
        let trebleClef = try #require(ABCClef(name: "treble"))
        let bassMidClef = try #require(ABCClef(name: "bass", middle: ABCClef.Middle(letter: .d, octave: 5)))
        let bassMidTransposeClef = try #require(ABCClef(name: "bass", middle: ABCClef.Middle(letter: .d, octave: 5), transpose: -24))
        let trebleBelow8Clef = try #require(ABCClef(name: "treble", ottava: .bassa))

        #expect(parseVoice("1 clef=treble name=\"Soprano\"sname=\"A\"") == makeVoice("1",
                                                                                     clef: trebleClef,
                                                                                     ["name": "Soprano",
                                                                                      "sname": "A"]))
        #expect(parseVoice("2") == makeVoice("2"))
        #expect(parseVoice("3 clef = bass middle = d name = \"Tenor\" sname = \"B\"") ==
                makeVoice("3",
                          clef: bassMidClef,
                          ["name": "Tenor",
                           "sname": "B"]))
        #expect(parseVoice("B1   middle=d   clef=bass      name=\"Basso I\"     snm=\"B.I\"    transpose=-24") ==
                makeVoice("B1",
                          clef: bassMidTransposeClef,
                          ["name": "Basso I",
                           "snm": "B.I"]))
        #expect(parseVoice("T1") == makeVoice("T1"))
        #expect(parseVoice("T2               clef=treble-8    name=\"Tenore II\"    snm=\"T.II\"") ==
                makeVoice("T2",
                          clef: trebleBelow8Clef,
                          ["name": "Tenore II",
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
