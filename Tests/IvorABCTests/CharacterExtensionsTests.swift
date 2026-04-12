// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct CharacterExtensionsTests {
}

// MARK: -

extension CharacterExtensionsTests {
    @Test
    func test_isABCAlphanumericWithDigit() {
        let char: Character = "5"

        #expect(char.isABCAlphanumeric)
    }

    @Test
    func test_isABCAlphanumericWithLetter() {
        let char: Character = "a"

        #expect(char.isABCAlphanumeric)
    }

    @Test
    func test_isABCAlphanumericWithSymbol() {
        let char: Character = "!"

        #expect(!char.isABCAlphanumeric)
    }

    @Test
    func test_isABCDigitFalse() {
        #expect(!Character("a").isABCDigit)
        #expect(!Character("/").isABCDigit)
    }

    @Test
    func test_isABCDigitTrue() {
        for char in "0123456789" {
            #expect(char.isABCDigit)
        }
    }

    @Test
    func test_isABCDirectiveNameHeadFalse() {
        #expect(!Character("0").isABCDirectiveNameHead)
        #expect(!Character("-").isABCDirectiveNameHead)
    }

    @Test
    func test_isABCDirectiveNameHeadTrue() {
        #expect(Character("a").isABCDirectiveNameHead)
        #expect(Character("Z").isABCDirectiveNameHead)
    }

    @Test
    func test_isABCDirectiveNameTailFalse() {
        #expect(!Character("!").isABCDirectiveNameTail)
        #expect(!Character(" ").isABCDirectiveNameTail)
    }

    @Test
    func test_isABCDirectiveNameTailTrue() {
        #expect(Character("a").isABCDirectiveNameTail)
        #expect(Character("0").isABCDirectiveNameTail)
        #expect(Character("-").isABCDirectiveNameTail)
        #expect(Character(":").isABCDirectiveNameTail)
    }

    @Test
    func test_isABCHexDigitFalse() {
        #expect(!Character("g").isABCHexDigit)
        #expect(!Character("G").isABCHexDigit)
        #expect(!Character("z").isABCHexDigit)
    }

    @Test
    func test_isABCHexDigitTrue() {
        for char in "0123456789ABCDEFabcdef" {
            #expect(char.isABCHexDigit)
        }
    }

    @Test
    func test_isABCLetterFalse() {
        #expect(!Character("0").isABCLetter)
        #expect(!Character("!").isABCLetter)
        #expect(!Character(" ").isABCLetter)
    }

    @Test
    func test_isABCLetterTrue() {
        for char in "abcdefghijklmnopqrstuvwxyz" {
            #expect(char.isABCLetter)
        }

        for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            #expect(char.isABCLetter)
        }
    }

    @Test
    func test_isABCWhitespaceFalse() {
        #expect(!Character("a").isABCWhitespace)
        #expect(!Character("\n").isABCWhitespace)
        #expect(!Character("\r").isABCWhitespace)
    }

    @Test
    func test_isABCWhitespaceTrue() {
        #expect(Character("\t").isABCWhitespace)
        #expect(Character(" ").isABCWhitespace)
    }
}
