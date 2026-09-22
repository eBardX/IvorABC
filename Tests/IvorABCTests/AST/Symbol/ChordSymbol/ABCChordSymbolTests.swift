// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCChordSymbolTests {
}

// MARK: -

extension ABCChordSymbolTests {
    @Test
    func equality() {
        let a = ABCChordSymbol(name: .init(root: .g))
        let b = ABCChordSymbol(name: .init(root: .g))

        #expect(a == b)
    }

    @Test
    func inequality_differentBass() {
        let a = ABCChordSymbol(name: .init(root: .g), bass: .b)
        let b = ABCChordSymbol(name: .init(root: .g), bass: .c)

        #expect(a != b)
    }

    @Test
    func inequality_differentName() {
        let a = ABCChordSymbol(name: .init(root: .g))
        let b = ABCChordSymbol(name: .init(root: .c))

        #expect(a != b)
    }

    @Test
    func inequality_differentParenthesized() {
        let a = ABCChordSymbol(name: .init(root: .g), parenthesized: .init(root: .e))
        let b = ABCChordSymbol(name: .init(root: .g), parenthesized: .init(root: .a))

        #expect(a != b)
    }

    @Test
    func init_storesPropertiesWithDefaults() {
        let chordSymbol = ABCChordSymbol(name: .init(root: .g))

        #expect(chordSymbol.name == .init(root: .g))
        #expect(chordSymbol.bass == nil)
        #expect(chordSymbol.parenthesized == nil)
    }

    @Test
    func init_storesProvidedProperties() {
        let chordSymbol = ABCChordSymbol(name: .init(root: .g, kind: "m"),
                                         bass: .b,
                                         parenthesized: .init(root: .e))

        #expect(chordSymbol.name == .init(root: .g, kind: "m"))
        #expect(chordSymbol.bass == .b)
        #expect(chordSymbol.parenthesized == .init(root: .e))
    }
}
