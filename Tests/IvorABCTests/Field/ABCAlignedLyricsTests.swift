// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCAlignedLyricsTests {
}

// MARK: -

extension ABCAlignedLyricsTests {
    @Test
    func equality() {
        let al1 = ABCAlignedLyrics(segments: [.text("grace"), .hold])
        let al2 = ABCAlignedLyrics(segments: [.text("grace"), .hold])

        #expect(al1 == al2)
    }

    @Test
    func inequality_differentCount() {
        let al1 = ABCAlignedLyrics(segments: [.text("grace")])
        let al2 = ABCAlignedLyrics(segments: [.text("grace"), .hold])

        #expect(al1 != al2)
    }

    @Test
    func inequality_differentSegment() {
        let al1 = ABCAlignedLyrics(segments: [.text("grace")])
        let al2 = ABCAlignedLyrics(segments: [.skip])

        #expect(al1 != al2)
    }

    @Test
    func parseAlignedLyrics_allSpecials() {
        let expected = makeAlignedLyrics([.text("syl"),
                                 .hyphen,
                                 .text("la"),
                                 .hyphen,
                                 .text("ble"),
                                 .text("grace"),
                                 .hold,
                                 .skip,
                                 .barAlign,
                                 .text("next")])

        #expect(IvorABC.parseAlignedLyrics("syl-la-ble grace _ * | next") == expected)
    }

    @Test
    func parseAlignedLyrics_barAlign() {
        #expect(IvorABC.parseAlignedLyrics("A | B") == makeAlignedLyrics([.text("A"), .barAlign, .text("B")]))
    }

    @Test
    func parseAlignedLyrics_empty() {
        #expect(IvorABC.parseAlignedLyrics("") == makeAlignedLyrics())
    }

    @Test
    func parseAlignedLyrics_escapedHyphen() {
        #expect(IvorABC.parseAlignedLyrics("don\\-t") == makeAlignedLyrics([.text("don"), .escapedHyphen, .text("t")]))
    }

    @Test
    func parseAlignedLyrics_hold() {
        #expect(IvorABC.parseAlignedLyrics("grace _") == makeAlignedLyrics([.text("grace"), .hold]))
    }

    @Test
    func parseAlignedLyrics_hyphenAndSpace() {
        let expected = makeAlignedLyrics([.text("A"),
                                 .hyphen,
                                 .text("ma"),
                                 .hyphen,
                                 .text("zing"),
                                 .text("grace")])

        #expect(IvorABC.parseAlignedLyrics("A-ma-zing grace") == expected)
    }

    @Test
    func parseAlignedLyrics_hyphenatedWord() {
        #expect(IvorABC.parseAlignedLyrics("A-ma-zing") == makeAlignedLyrics([.text("A"), .hyphen, .text("ma"), .hyphen, .text("zing")]))
    }

    @Test
    func parseAlignedLyrics_singleSyllable() {
        #expect(IvorABC.parseAlignedLyrics("grace") == makeAlignedLyrics([.text("grace")]))
    }

    @Test
    func parseAlignedLyrics_skip() {
        #expect(IvorABC.parseAlignedLyrics("* grace") == makeAlignedLyrics([.skip, .text("grace")]))
    }

    @Test
    func parseAlignedLyrics_tilde() {
        #expect(IvorABC.parseAlignedLyrics("how~sweet") == makeAlignedLyrics([.text("how"), .tilde, .text("sweet")]))
    }

    @Test
    func parseAlignedLyrics_wordBoundaries() {
        #expect(IvorABC.parseAlignedLyrics("la la la") == makeAlignedLyrics([.text("la"), .text("la"), .text("la")]))
    }

    @Test
    func segments_empty() {
        let al = ABCAlignedLyrics(segments: [])

        #expect(al.segments.isEmpty)
    }

    @Test
    func segments_mixed() {
        let al = ABCAlignedLyrics(segments: [.text("A"), .hyphen, .text("ma"), .hold, .skip, .barAlign])

        #expect(al.segments == [.text("A"), .hyphen, .text("ma"), .hold, .skip, .barAlign])
    }
}
