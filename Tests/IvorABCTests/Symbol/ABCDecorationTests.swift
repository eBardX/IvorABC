// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCDecorationTests {
}

// MARK: -

extension ABCDecorationTests {
    @Test
    func equality() {
        let a = makeDecoration("roll", "~")
        let b = makeDecoration("roll", "~")

        #expect(a == b)
    }

    @Test
    func inequality_differentName() {
        let a = makeDecoration("roll")
        let b = makeDecoration("trill")

        #expect(a != b)
    }

    @Test
    func inequality_differentShorthand() {
        let a = makeDecoration("staccato", ".")
        let b = makeDecoration("staccato")

        #expect(a != b)
    }

    @Test
    func init_storesProperties_withShorthand() {
        let decoration = makeDecoration("roll", "~")

        #expect(decoration.dialect == .bang)
        #expect(decoration.name == "roll")
        #expect(decoration.shorthand == "~")
    }

    @Test
    func init_storesProperties_withoutShorthand() {
        let decoration = makeDecoration("trill")

        #expect(decoration.dialect == .bang)
        #expect(decoration.name == "trill")
        #expect(decoration.shorthand == nil)
    }

    @Test
    func init_withEmptyNameReturnsNil() {
        #expect(ABCDecoration(name: "") == nil)
    }
}
