// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCAlignedWordsSegmentTests {
}

// MARK: -

extension ABCAlignedWordsSegmentTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCAlignedWords.Segment] = [.barAlign,
                                                   .continuation,
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
        #expect(ABCAlignedWords.Segment.barAlign == .barAlign)
        #expect(ABCAlignedWords.Segment.continuation == .continuation)
        #expect(ABCAlignedWords.Segment.hold == .hold)
        #expect(ABCAlignedWords.Segment.skip == .skip)
        #expect(ABCAlignedWords.Segment.syllable("grace") == .syllable("grace"))
    }

    @Test
    func inequality_differentAssociatedValues() {
        #expect(ABCAlignedWords.Segment.syllable("A") != .syllable("B"))
    }
}
