// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCAlignedWordsTests {
}

// MARK: -

extension ABCAlignedWordsTests {
    @Test
    func equality() {
        let al1 = makeAlignedWords([.syllable("grace"), .hold])
        let al2 = makeAlignedWords([.syllable("grace"), .hold])

        #expect(al1 == al2)
    }

    @Test
    func inequality_differentCount() {
        let al1 = makeAlignedWords([.syllable("grace")])
        let al2 = makeAlignedWords([.syllable("grace"), .hold])

        #expect(al1 != al2)
    }

    @Test
    func inequality_differentSegment() {
        let al1 = makeAlignedWords([.syllable("grace")])
        let al2 = makeAlignedWords([.skip])

        #expect(al1 != al2)
    }

    @Test
    func parseAlignedWords_allSpecials() {
        let expected = makeAlignedWords([.syllable("syl"),
                                         .continuation,
                                         .syllable("la"),
                                         .continuation,
                                         .syllable("ble"),
                                         .syllable("grace"),
                                         .hold,
                                         .skip,
                                         .barAlign,
                                         .syllable("next")])

        #expect(IvorABC.parseAlignedWords("syl-la-ble grace _ * | next") == expected)
    }

    @Test
    func parseAlignedWords_barAlign() {
        #expect(IvorABC.parseAlignedWords("A | B") == makeAlignedWords([.syllable("A"), .barAlign, .syllable("B")]))
    }

    @Test
    func parseAlignedWords_empty() {
        #expect(IvorABC.parseAlignedWords("") == makeAlignedWords())
    }

    @Test
    func parseAlignedWords_hold() {
        #expect(IvorABC.parseAlignedWords("grace _") == makeAlignedWords([.syllable("grace"), .hold]))
    }

    @Test
    func parseAlignedWords_internalSpace() {
        #expect(IvorABC.parseAlignedWords("how~sweet") == makeAlignedWords([.syllable("how sweet")]))
    }

    @Test
    func parseAlignedWords_literalHyphenInSyllable() {
        #expect(IvorABC.parseAlignedWords("don\\-t") == makeAlignedWords([.syllable("don-t")]))
    }

    @Test
    func parseAlignedWords_continuationAndSpace() {
        let expected = makeAlignedWords([.syllable("A"),
                                         .continuation,
                                         .syllable("ma"),
                                         .continuation,
                                         .syllable("zing"),
                                         .syllable("grace")])

        #expect(IvorABC.parseAlignedWords("A-ma-zing grace") == expected)
    }

    @Test
    func parseAlignedWords_wordContinuation() {
        #expect(IvorABC.parseAlignedWords("A-ma-zing") == makeAlignedWords([.syllable("A"),
                                                                            .continuation,
                                                                            .syllable("ma"),
                                                                            .continuation,
                                                                            .syllable("zing")]))
    }

    @Test
    func parseAlignedWords_singleSyllable() {
        #expect(IvorABC.parseAlignedWords("grace") == makeAlignedWords([.syllable("grace")]))
    }

    @Test
    func parseAlignedWords_skip() {
        #expect(IvorABC.parseAlignedWords("* grace") == makeAlignedWords([.skip, .syllable("grace")]))
    }

    @Test
    func parseAlignedWords_wordBoundaries() {
        #expect(IvorABC.parseAlignedWords("la la la") == makeAlignedWords([.syllable("la"), .syllable("la"), .syllable("la")]))
    }

    @Test
    func segments_empty() {
        let al = makeAlignedWords([])

        #expect(al.segments.isEmpty)
    }

    @Test
    func segments_mixed() {
        let al = makeAlignedWords([.syllable("A"), .continuation, .syllable("ma"), .hold, .skip, .barAlign])

        #expect(al.segments == [.syllable("A"), .continuation, .syllable("ma"), .hold, .skip, .barAlign])
    }
}
