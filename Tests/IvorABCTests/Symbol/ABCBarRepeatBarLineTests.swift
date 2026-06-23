// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCBarRepeatBarLineTests {
}

// MARK: -

extension ABCBarRepeatBarLineTests {
    @Test
    func endToEnd_eachCanonicalSpellingParsesToOneBarRepeat() throws {
        let expected: [(String, ABCBarRepeat)] = [("|", makeBarRepeat()),
                                                  ("||", makeBarRepeat(.double)),
                                                  ("|]", makeBarRepeat(.end)),
                                                  ("[|", makeBarRepeat(.double)),
                                                  ("[|]", makeBarRepeat(.invisible)),
                                                  ("|:", makeBarRepeat(.repeat, followingPlayCount: 2)),
                                                  (":|", makeBarRepeat(.repeat, precedingPlayCount: 2)),
                                                  ("::", makeBarRepeat(.repeat, precedingPlayCount: 2, followingPlayCount: 2)),
                                                  (":|:", makeBarRepeat(.repeat, precedingPlayCount: 2, followingPlayCount: 2)),
                                                  (":||:", makeBarRepeat(.repeat, precedingPlayCount: 2, followingPlayCount: 2))]

        for (input, barRepeat) in expected {
            let symbols = try matchSymbols(input)

            #expect(symbols == [.barRepeat(barRepeat)],
                    "input \(input) should parse to a single bar repeat")
        }
    }

    @Test
    func endToEnd_dottedBarlinePreservedAcrossBarLines() throws {
        #expect(try matchSymbols(".|") == [.barRepeat(makeBarRepeat(isDotted: true))])
        #expect(try matchSymbols(".:|:") == [.barRepeat(makeBarRepeat(.repeat, precedingPlayCount: 2, followingPlayCount: 2, isDotted: true))])
    }

    @Test
    func endToEnd_equivalentSpellingsAreEqualSymbols() throws {
        let collapsed = try matchSymbols("::")
        let singleBar = try matchSymbols(":|:")
        let doubleBar = try matchSymbols(":||:")

        #expect(collapsed == singleBar)
        #expect(collapsed == doubleBar)
    }

    // MARK: N-fold repeats

    @Test
    func endToEnd_nFold_repeatStart() throws {
        #expect(try matchSymbols("|::") == [.barRepeat(makeBarRepeat(.repeat, followingPlayCount: 3))])
        #expect(try matchSymbols("|:::") == [.barRepeat(makeBarRepeat(.repeat, followingPlayCount: 4))])
    }

    @Test
    func endToEnd_nFold_repeatEnd() throws {
        #expect(try matchSymbols("::|") == [.barRepeat(makeBarRepeat(.repeat, precedingPlayCount: 3))])
        #expect(try matchSymbols(":::|") == [.barRepeat(makeBarRepeat(.repeat, precedingPlayCount: 4))])
    }

    @Test
    func endToEnd_nFold_repeatEndStart() throws {
        #expect(try matchSymbols(":|::") == [.barRepeat(makeBarRepeat(.repeat, precedingPlayCount: 2, followingPlayCount: 3))])
        #expect(try matchSymbols("::|:") == [.barRepeat(makeBarRepeat(.repeat, precedingPlayCount: 3, followingPlayCount: 2))])
        #expect(try matchSymbols("::|::") == [.barRepeat(makeBarRepeat(.repeat, precedingPlayCount: 3, followingPlayCount: 3))])
    }

    // MARK: Liberal forms

    @Test
    func endToEnd_liberal_multipleGlyphs() throws {
        #expect(try matchSymbols("|[|") == [.barRepeat(makeBarRepeat(.double))])
        #expect(try matchSymbols("[|[|") == [.barRepeat(makeBarRepeat(.double))])
    }

    @Test
    func endToEnd_liberal_glyphWithNFoldRepeat() throws {
        #expect(try matchSymbols("[|:::") == [.barRepeat(makeBarRepeat(.repeat, followingPlayCount: 4))])
    }

    // MARK: Invalid forms

    @Test
    func endToEnd_ambiguousColonOnlySequencesAreRejected() {
        #expect(throws: (any Error).self,
                "bare ::: (no pipe, >2 colons) is ambiguous and should be rejected") {
            _ = try matchSymbols(":::")
        }
    }
}
