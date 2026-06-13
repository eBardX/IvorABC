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
        #expect(makeVariantEnding(endings: []) == nil)
    }

    @Test
    func init_stringValue_emptyEndings() {
        #expect(makeVariantEnding(stringValue: "[") == nil)
    }

    @Test
    func init_stringValue_invalidNumber() {
        #expect(makeVariantEnding(stringValue: "[abc") == nil)
    }

    @Test
    func init_stringValue_invalidPrefix() {
        #expect(makeVariantEnding(stringValue: "1") == nil)
    }

    @Test
    func init_stringValue_multiple() throws {
        let ending = try #require(makeVariantEnding(stringValue: "[1,2"))

        #expect(ending.endings == [1...1, 2...2])
    }

    @Test
    func init_stringValue_range() throws {
        let ending = try #require(makeVariantEnding(stringValue: "[1-3"))

        #expect(ending.endings == [1...3])
    }

    @Test
    func init_stringValue_single() throws {
        let ending = try #require(makeVariantEnding(stringValue: "[1"))

        #expect(ending.endings == [1...1])
    }

    @Test
    func stringValue_multiple() {
        let ending = makeVariantEnding([1...1, 2...2])

        #expect(ending.stringValue == "[1,2")
    }

    @Test
    func stringValue_range() {
        let ending = makeVariantEnding([1...3])

        #expect(ending.stringValue == "[1-3")
    }

    @Test
    func stringValue_single() {
        let ending = makeVariantEnding([1...1])

        #expect(ending.stringValue == "[1")
    }
}
