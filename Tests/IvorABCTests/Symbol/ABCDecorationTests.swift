// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCDecorationTests {
}

// MARK: -

extension ABCDecorationTests {
    @Test
    func equality() {
        let a = ABCDecoration(name: "roll", shorthand: "~")
        let b = ABCDecoration(name: "roll", shorthand: "~")

        #expect(a == b)
    }

    @Test
    func inequality_differentName() {
        let a = ABCDecoration(name: "roll")
        let b = ABCDecoration(name: "trill")

        #expect(a != b)
    }

    @Test
    func inequality_differentShorthand() {
        let a = ABCDecoration(name: "staccato", shorthand: ".")
        let b = ABCDecoration(name: "staccato")

        #expect(a != b)
    }

    @Test
    func init_storesProperties_withShorthand() {
        let decoration = ABCDecoration(name: "roll", shorthand: "~")

        #expect(decoration.name == "roll")
        #expect(decoration.shorthand == "~")
    }

    @Test
    func init_storesProperties_withoutShorthand() {
        let decoration = ABCDecoration(name: "trill")

        #expect(decoration.name == "trill")
        #expect(decoration.shorthand == nil)
    }
}
