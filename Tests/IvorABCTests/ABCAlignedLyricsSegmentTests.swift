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
                                                     .continuation("b"),
                                                     .hold,
                                                     .skip,
                                                     .syllable("a")]

        for i in allCases.indices {
            for j in allCases.indices where i != j {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test
    func equality() {
        #expect(ABCAlignedLyrics.Segment.barAlign == .barAlign)
        #expect(ABCAlignedLyrics.Segment.continuation("la") == .continuation("la"))
        #expect(ABCAlignedLyrics.Segment.hold == .hold)
        #expect(ABCAlignedLyrics.Segment.skip == .skip)
        #expect(ABCAlignedLyrics.Segment.syllable("grace") == .syllable("grace"))
    }

    @Test
    func inequality_differentAssociatedValues() {
        #expect(ABCAlignedLyrics.Segment.continuation("A") != .continuation("B"))
        #expect(ABCAlignedLyrics.Segment.syllable("A") != .syllable("B"))
    }
}
