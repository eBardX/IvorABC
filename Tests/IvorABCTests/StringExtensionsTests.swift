// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct StringExtensionsTests {
}

// MARK: -

extension StringExtensionsTests {
    @Test
    func test_normalizedABCWhitespaceCollapses() {
        #expect("  x  y zz    y".normalizedABCWhitespace() == "x y zz y")
    }

    @Test
    func test_normalizedABCWhitespaceEmptyString() {
        #expect("".normalizedABCWhitespace().isEmpty)
    }

    @Test
    func test_normalizedABCWhitespaceNoTrimLeading() {
        #expect("  abc  ".normalizedABCWhitespace(trimLeadingWhitespace: false) == " abc")
    }

    @Test
    func test_normalizedABCWhitespaceNoTrimTrailing() {
        #expect("  abc  ".normalizedABCWhitespace(trimTrailingWhitespace: false) == "abc ")
    }

    @Test
    func test_normalizedABCWhitespaceOnlyWhitespace() {
        #expect("   ".normalizedABCWhitespace().isEmpty)
    }

    @Test
    func test_normalizedABCWhitespaceTabsAndSpaces() {
        #expect("a\t\tb".normalizedABCWhitespace() == "a b")
    }

    @Test
    func test_normalizedABCWhitespaceTrimsBothEnds() {
        #expect("  abc  ".normalizedABCWhitespace() == "abc")
    }
}
