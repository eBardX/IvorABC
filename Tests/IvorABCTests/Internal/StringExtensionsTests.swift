// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct StringExtensionsTests {
}

// MARK: -

extension StringExtensionsTests {
    @Test
    func normalizedABCWhitespace_collapses() {
        #expect("  x  y zz    y".normalizedABCWhitespace() == "x y zz y")
    }

    @Test
    func normalizedABCWhitespace_emptyString() {
        #expect("".normalizedABCWhitespace().isEmpty)
    }

    @Test
    func normalizedABCWhitespace_noTrimLeading() {
        #expect("  abc  ".normalizedABCWhitespace(trimLeadingWhitespace: false) == " abc")
    }

    @Test
    func normalizedABCWhitespace_noTrimTrailing() {
        #expect("  abc  ".normalizedABCWhitespace(trimTrailingWhitespace: false) == "abc ")
    }

    @Test
    func normalizedABCWhitespace_onlyWhitespace() {
        #expect("   ".normalizedABCWhitespace().isEmpty)
    }

    @Test
    func normalizedABCWhitespace_tabsAndSpaces() {
        #expect("a\t\tb".normalizedABCWhitespace() == "a b")
    }

    @Test
    func normalizedABCWhitespace_trimsBothEnds() {
        #expect("  abc  ".normalizedABCWhitespace() == "abc")
    }
}
