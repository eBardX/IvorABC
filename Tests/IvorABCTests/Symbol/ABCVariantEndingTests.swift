// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCVariantEndingTests {
}

// MARK: -

extension ABCVariantEndingTests {
    @Test
    func equality() {
        let a = makeVariantEnding([1...1])
        let b = makeVariantEnding([1...1])

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a = makeVariantEnding([1...1])
        let b = makeVariantEnding([2...2])

        #expect(a != b)
    }

    @Test
    func init_storesEndings() {
        let ending = makeVariantEnding([1...3, 5...5])

        #expect(ending.endings == [1...3, 5...5])
    }

    @Test
    func init_withEmptyEndingsReturnsNil() {
        #expect(ABCVariantEnding(endings: []) == nil)
    }

    @Test
    func init_withZeroEndingReturnsNil() {
        #expect(ABCVariantEnding(endings: [0...0]) == nil)
    }

    @Test
    func init_withRangeStartingAtZeroReturnsNil() {
        #expect(ABCVariantEnding(endings: [1...2, 0...3]) == nil)
    }
}
