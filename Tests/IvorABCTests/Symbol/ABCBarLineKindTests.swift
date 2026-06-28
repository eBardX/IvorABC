// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCBarLineKindTests {
}

// MARK: -

extension ABCBarLineKindTests {
    @Test
    func endToEnd_eachCanonicalSpellingParsesToOneBarLine() throws {
        let expected: [(String, ABCBarLine)] = [("|", makeBarLine()),
                                                ("||", makeBarLine(.double)),
                                                ("|]", makeBarLine(.end)),
                                                ("[|", makeBarLine(.double)),
                                                ("[|]", makeBarLine(.invisible)),
                                                ("|:", makeBarLine(.repeat, followingPlayCount: 2)),
                                                (":|", makeBarLine(.repeat, precedingPlayCount: 2)),
                                                ("::", makeBarLine(.repeat, precedingPlayCount: 2, followingPlayCount: 2)),
                                                (":|:", makeBarLine(.repeat, precedingPlayCount: 2, followingPlayCount: 2)),
                                                (":||:", makeBarLine(.repeat, precedingPlayCount: 2, followingPlayCount: 2))]

        for (input, barLine) in expected {
            let symbols = try matchSymbols(input)

            #expect(symbols == [.barLine(barLine)],
                    "input \(input) should parse to a single bar line")
        }
    }

    @Test
    func endToEnd_dottedBarlinePreservedAcrossBarLines() throws {
        #expect(try matchSymbols(".|") == [.barLine(makeBarLine(isDotted: true))])
        #expect(try matchSymbols(".:|:") == [.barLine(makeBarLine(.repeat, precedingPlayCount: 2, followingPlayCount: 2, isDotted: true))])
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
        #expect(try matchSymbols("|::") == [.barLine(makeBarLine(.repeat, followingPlayCount: 3))])
        #expect(try matchSymbols("|:::") == [.barLine(makeBarLine(.repeat, followingPlayCount: 4))])
    }

    @Test
    func endToEnd_nFold_repeatEnd() throws {
        #expect(try matchSymbols("::|") == [.barLine(makeBarLine(.repeat, precedingPlayCount: 3))])
        #expect(try matchSymbols(":::|") == [.barLine(makeBarLine(.repeat, precedingPlayCount: 4))])
    }

    @Test
    func endToEnd_nFold_repeatEndStart() throws {
        #expect(try matchSymbols(":|::") == [.barLine(makeBarLine(.repeat, precedingPlayCount: 2, followingPlayCount: 3))])
        #expect(try matchSymbols("::|:") == [.barLine(makeBarLine(.repeat, precedingPlayCount: 3, followingPlayCount: 2))])
        #expect(try matchSymbols("::|::") == [.barLine(makeBarLine(.repeat, precedingPlayCount: 3, followingPlayCount: 3))])
    }

    // MARK: Liberal forms

    @Test
    func endToEnd_liberal_multipleGlyphs() throws {
        #expect(try matchSymbols("|[|") == [.barLine(makeBarLine(.double))])
        #expect(try matchSymbols("[|[|") == [.barLine(makeBarLine(.double))])
    }

    @Test
    func endToEnd_liberal_glyphWithNFoldRepeat() throws {
        #expect(try matchSymbols("[|:::") == [.barLine(makeBarLine(.repeat, followingPlayCount: 4))])
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
