// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCSymbolLineParseFunctionsTests {
}

// MARK: -

extension ABCSymbolLineParseFunctionsTests {
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
}
