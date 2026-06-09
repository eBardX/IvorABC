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
