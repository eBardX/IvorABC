// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCAlignedLyricsTests {
}

// MARK: -

extension ABCAlignedLyricsTests {
    @Test
    func equality() {
        let al1 = makeAlignedLyrics([.syllable("grace"), .hold])
        let al2 = makeAlignedLyrics([.syllable("grace"), .hold])

        #expect(al1 == al2)
    }

    @Test
    func inequality_differentCount() {
        let al1 = makeAlignedLyrics([.syllable("grace")])
        let al2 = makeAlignedLyrics([.syllable("grace"), .hold])

        #expect(al1 != al2)
    }

    @Test
    func inequality_differentSegment() {
        let al1 = makeAlignedLyrics([.syllable("grace")])
        let al2 = makeAlignedLyrics([.skip])

        #expect(al1 != al2)
    }

    @Test
    func parseAlignedLyrics_allSpecials() {
        let expected = makeAlignedLyrics([.syllable("syl"),
                                          .continuation,
                                          .syllable("la"),
                                          .continuation,
                                          .syllable("ble"),
                                          .syllable("grace"),
                                          .hold,
                                          .skip,
                                          .barAlign,
                                          .syllable("next")])

        #expect(IvorABC.parseAlignedLyrics("syl-la-ble grace _ * | next") == expected)
    }

    @Test
    func parseAlignedLyrics_barAlign() {
        #expect(IvorABC.parseAlignedLyrics("A | B") == makeAlignedLyrics([.syllable("A"), .barAlign, .syllable("B")]))
    }

    @Test
    func parseAlignedLyrics_empty() {
        #expect(IvorABC.parseAlignedLyrics("") == makeAlignedLyrics())
    }

    @Test
    func parseAlignedLyrics_hold() {
        #expect(IvorABC.parseAlignedLyrics("grace _") == makeAlignedLyrics([.syllable("grace"), .hold]))
    }

    @Test
    func parseAlignedLyrics_internalSpace() {
        #expect(IvorABC.parseAlignedLyrics("how~sweet") == makeAlignedLyrics([.syllable("how sweet")]))
    }

    @Test
    func parseAlignedLyrics_literalHyphenInSyllable() {
        #expect(IvorABC.parseAlignedLyrics("don\\-t") == makeAlignedLyrics([.syllable("don-t")]))
    }

    @Test
    func parseAlignedLyrics_continuationAndSpace() {
        let expected = makeAlignedLyrics([.syllable("A"),
                                          .continuation,
                                          .syllable("ma"),
                                          .continuation,
                                          .syllable("zing"),
                                          .syllable("grace")])

        #expect(IvorABC.parseAlignedLyrics("A-ma-zing grace") == expected)
    }

    @Test
    func parseAlignedLyrics_wordContinuation() {
        #expect(IvorABC.parseAlignedLyrics("A-ma-zing") == makeAlignedLyrics([.syllable("A"),
                                                                              .continuation,
                                                                              .syllable("ma"),
                                                                              .continuation,
                                                                              .syllable("zing")]))
    }

    @Test
    func parseAlignedLyrics_singleSyllable() {
        #expect(IvorABC.parseAlignedLyrics("grace") == makeAlignedLyrics([.syllable("grace")]))
    }

    @Test
    func parseAlignedLyrics_skip() {
        #expect(IvorABC.parseAlignedLyrics("* grace") == makeAlignedLyrics([.skip, .syllable("grace")]))
    }

    @Test
    func parseAlignedLyrics_wordBoundaries() {
        #expect(IvorABC.parseAlignedLyrics("la la la") == makeAlignedLyrics([.syllable("la"), .syllable("la"), .syllable("la")]))
    }

    @Test
    func segments_empty() {
        let al = makeAlignedLyrics([])

        #expect(al.segments.isEmpty)
    }

    @Test
    func segments_mixed() {
        let al = makeAlignedLyrics([.syllable("A"), .continuation, .syllable("ma"), .hold, .skip, .barAlign])

        #expect(al.segments == [.syllable("A"), .continuation, .syllable("ma"), .hold, .skip, .barAlign])
    }
}
