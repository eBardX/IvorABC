// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCChordSymbolNameTests {
}

// MARK: -

extension ABCChordSymbolNameTests {
    @Test
    func equality() {
        let a = ABCChordSymbol.Name(root: .g, kind: "m")
        let b = ABCChordSymbol.Name(root: .g, kind: "m")

        #expect(a == b)
    }

    @Test
    func inequality_differentKind() {
        let a = ABCChordSymbol.Name(root: .g, kind: "m")
        let b = ABCChordSymbol.Name(root: .g, kind: "7")

        #expect(a != b)
    }

    @Test
    func inequality_differentRoot() {
        let a = ABCChordSymbol.Name(root: .g)
        let b = ABCChordSymbol.Name(root: .c)

        #expect(a != b)
    }

    @Test
    func init_storesPropertiesWithDefaultKind() {
        let name = ABCChordSymbol.Name(root: .d)

        #expect(name.root == .d)
        #expect(name.kind == nil)
    }

    @Test
    func init_storesProvidedProperties() {
        let name = ABCChordSymbol.Name(root: .d, kind: "maj7")

        #expect(name.root == .d)
        #expect(name.kind == "maj7")
    }
}
