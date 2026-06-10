// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCAlignedLyricsSegmentTests {
}

// MARK: -

extension ABCAlignedLyricsSegmentTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCAlignedLyrics.Segment] = [.barAlign,
                                                    .escapedHyphen,
                                                    .hold,
                                                    .hyphen,
                                                    .skip,
                                                    .text("a"),
                                                    .tilde]

        for i in allCases.indices {
            for j in allCases.indices where i != j {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test
    func equality() {
        #expect(ABCAlignedLyrics.Segment.barAlign == .barAlign)
        #expect(ABCAlignedLyrics.Segment.escapedHyphen == .escapedHyphen)
        #expect(ABCAlignedLyrics.Segment.hold == .hold)
        #expect(ABCAlignedLyrics.Segment.hyphen == .hyphen)
        #expect(ABCAlignedLyrics.Segment.skip == .skip)
        #expect(ABCAlignedLyrics.Segment.text("grace") == .text("grace"))
        #expect(ABCAlignedLyrics.Segment.tilde == .tilde)
    }

    @Test
    func inequality_differentAssociatedValues() {
        #expect(ABCAlignedLyrics.Segment.text("A") != .text("B"))
    }
}
