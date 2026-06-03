// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCAlignedLyricsTests {
}

// MARK: -

extension ABCAlignedLyricsTests {
    @Test
    func equality() {
        let al1 = ABCAlignedLyrics(segments: [.syllable("grace"), .hold])
        let al2 = ABCAlignedLyrics(segments: [.syllable("grace"), .hold])

        #expect(al1 == al2)
    }

    @Test
    func inequality_differentCount() {
        let al1 = ABCAlignedLyrics(segments: [.syllable("grace")])
        let al2 = ABCAlignedLyrics(segments: [.syllable("grace"), .hold])

        #expect(al1 != al2)
    }

    @Test
    func inequality_differentSegment() {
        let al1 = ABCAlignedLyrics(segments: [.syllable("grace")])
        let al2 = ABCAlignedLyrics(segments: [.skip])

        #expect(al1 != al2)
    }

    @Test
    func parseAlignedLyrics_allSpecials() {
        let expected = _alyrics([.syllable("syl"),
                                 .continuation("la"),
                                 .continuation("ble"),
                                 .syllable("grace"),
                                 .hold,
                                 .skip,
                                 .barAlign,
                                 .syllable("next")])

        #expect(IvorABC.parseAlignedLyrics("syl-la-ble grace _ * | next") == expected)
    }

    @Test
    func parseAlignedLyrics_barAlign() {
        #expect(IvorABC.parseAlignedLyrics("A | B") == _alyrics([.syllable("A"), .barAlign, .syllable("B")]))
    }

    @Test
    func parseAlignedLyrics_empty() {
        #expect(IvorABC.parseAlignedLyrics("") == _alyrics())
    }

    @Test
    func parseAlignedLyrics_escapedHyphen() {
        #expect(IvorABC.parseAlignedLyrics("don\\-t") == _alyrics([.syllable("don-t")]))
    }

    @Test
    func parseAlignedLyrics_hold() {
        #expect(IvorABC.parseAlignedLyrics("grace _") == _alyrics([.syllable("grace"), .hold]))
    }

    @Test
    func parseAlignedLyrics_hyphenAndSpace() {
        let expected = _alyrics([.syllable("A"),
                                 .continuation("ma"),
                                 .continuation("zing"),
                                 .syllable("grace")])

        #expect(IvorABC.parseAlignedLyrics("A-ma-zing grace") == expected)
    }

    @Test
    func parseAlignedLyrics_hyphenatedWord() {
        #expect(IvorABC.parseAlignedLyrics("A-ma-zing") == _alyrics([.syllable("A"), .continuation("ma"), .continuation("zing")]))
    }

    @Test
    func parseAlignedLyrics_singleSyllable() {
        #expect(IvorABC.parseAlignedLyrics("grace") == _alyrics([.syllable("grace")]))
    }

    @Test
    func parseAlignedLyrics_skip() {
        #expect(IvorABC.parseAlignedLyrics("* grace") == _alyrics([.skip, .syllable("grace")]))
    }

    @Test
    func parseAlignedLyrics_tildeMeansSpace() {
        #expect(IvorABC.parseAlignedLyrics("how~sweet") == _alyrics([.syllable("how sweet")]))
    }

    @Test
    func parseAlignedLyrics_wordBoundaries() {
        #expect(IvorABC.parseAlignedLyrics("la la la") == _alyrics([.syllable("la"), .syllable("la"), .syllable("la")]))
    }

    @Test
    func segments_empty() {
        let al = ABCAlignedLyrics(segments: [])

        #expect(al.segments.isEmpty)
    }

    @Test
    func segments_mixed() {
        let al = ABCAlignedLyrics(segments: [.syllable("A"), .continuation("ma"), .hold, .skip, .barAlign])

        #expect(al.segments == [.syllable("A"), .continuation("ma"), .hold, .skip, .barAlign])
    }
}
