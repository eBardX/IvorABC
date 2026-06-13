// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct CharacterExtensionsTests {
}

// MARK: -

extension CharacterExtensionsTests {
    @Test
    func isABCAlphanumeric_withDigit() {
        let char: Character = "5"

        #expect(char.isABCAlphanumeric)
    }

    @Test
    func isABCAlphanumeric_withLetter() {
        let char: Character = "a"

        #expect(char.isABCAlphanumeric)
    }

    @Test
    func isABCAlphanumeric_withSymbol() {
        let char: Character = "!"

        #expect(!char.isABCAlphanumeric)
    }

    @Test
    func isABCDigit_false() {
        #expect(!Character("a").isABCDigit)
        #expect(!Character("/").isABCDigit)
    }

    @Test
    func isABCDigit_true() {
        for char in "0123456789" {
            #expect(char.isABCDigit)
        }
    }

    @Test
    func isABCDirectiveNameHead_false() {
        #expect(!Character("0").isABCDirectiveNameHead)
        #expect(!Character("-").isABCDirectiveNameHead)
    }

    @Test
    func isABCDirectiveNameHead_true() {
        #expect(Character("a").isABCDirectiveNameHead)
        #expect(Character("Z").isABCDirectiveNameHead)
    }

    @Test
    func isABCDirectiveNameTail_false() {
        #expect(!Character("!").isABCDirectiveNameTail)
        #expect(!Character(" ").isABCDirectiveNameTail)
    }

    @Test
    func isABCDirectiveNameTail_true() {
        #expect(Character("a").isABCDirectiveNameTail)
        #expect(Character("0").isABCDirectiveNameTail)
        #expect(Character("-").isABCDirectiveNameTail)
        #expect(Character(":").isABCDirectiveNameTail)
    }

    @Test
    func isABCHexDigit_false() {
        #expect(!Character("g").isABCHexDigit)
        #expect(!Character("G").isABCHexDigit)
        #expect(!Character("z").isABCHexDigit)
    }

    @Test
    func isABCHexDigit_true() {
        for char in "0123456789ABCDEFabcdef" {
            #expect(char.isABCHexDigit)
        }
    }

    @Test
    func isABCLetter_false() {
        #expect(!Character("0").isABCLetter)
        #expect(!Character("!").isABCLetter)
        #expect(!Character(" ").isABCLetter)
    }

    @Test
    func isABCLetter_true() {
        for char in "abcdefghijklmnopqrstuvwxyz" {
            #expect(char.isABCLetter)
        }

        for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            #expect(char.isABCLetter)
        }
    }

    @Test
    func isABCVisible_false_c0Controls() {
        #expect(!Character("\u{00}").isABCVisible)  // NUL
        #expect(!Character("\u{09}").isABCVisible)  // tab
        #expect(!Character("\u{0a}").isABCVisible)  // LF
        #expect(!Character("\u{0d}").isABCVisible)  // CR
        #expect(!Character("\u{1f}").isABCVisible)  // US (last C0)
    }

    @Test
    func isABCVisible_false_del_c1_nbsp() {
        #expect(!Character("\u{7f}").isABCVisible)  // DEL
        #expect(!Character("\u{80}").isABCVisible)  // first C1
        #expect(!Character("\u{9f}").isABCVisible)  // last C1
        #expect(!Character("\u{a0}").isABCVisible)  // NBSP
    }

    @Test
    func isABCVisible_false_cgj() {
        #expect(!Character("\u{034f}").isABCVisible)  // Combining Grapheme Joiner
    }

    @Test
    func isABCVisible_false_zeroWidth() {
        #expect(!Character("\u{200b}").isABCVisible)  // zero-width space
        #expect(!Character("\u{200c}").isABCVisible)  // ZWNJ
        #expect(!Character("\u{200d}").isABCVisible)  // ZWJ
        #expect(!Character("\u{feff}").isABCVisible)  // BOM
    }

    @Test
    func isABCVisible_true() {
        #expect(Character(" ").isABCVisible)   // regular space (U+0020, just above C0)
        #expect(Character("a").isABCVisible)
        #expect(Character("Z").isABCVisible)
        #expect(Character("5").isABCVisible)
        #expect(Character("!").isABCVisible)
        #expect(Character("é").isABCVisible)  // U+00E9, above NBSP
        #expect(Character("♯").isABCVisible)  // U+266F
    }

    @Test
    func isABCWhitespace_false() {
        #expect(!Character("a").isABCWhitespace)
        #expect(!Character("\n").isABCWhitespace)
        #expect(!Character("\r").isABCWhitespace)
    }

    @Test
    func isABCWhitespace_true() {
        #expect(Character("\t").isABCWhitespace)
        #expect(Character(" ").isABCWhitespace)
    }
}
