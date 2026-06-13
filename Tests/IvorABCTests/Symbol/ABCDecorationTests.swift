// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCDecorationTests {
}

// MARK: -

extension ABCDecorationTests {
    @Test
    func equality() throws {
        let a = try #require(ABCDecoration(name: "roll", shorthand: "~"))
        let b = try #require(ABCDecoration(name: "roll", shorthand: "~"))

        #expect(a == b)
    }

    @Test
    func inequality_differentName() throws {
        let a = try #require(ABCDecoration(name: "roll"))
        let b = try #require(ABCDecoration(name: "trill"))

        #expect(a != b)
    }

    @Test
    func inequality_differentShorthand() throws {
        let a = try #require(ABCDecoration(name: "staccato", shorthand: "."))
        let b = try #require(ABCDecoration(name: "staccato"))

        #expect(a != b)
    }

    @Test
    func init_storesProperties_withShorthand() throws {
        let decoration = try #require(ABCDecoration(name: "roll", shorthand: "~"))

        #expect(decoration.dialect == .bang)
        #expect(decoration.name == "roll")
        #expect(decoration.shorthand == "~")
    }

    @Test
    func init_storesProperties_withoutShorthand() throws {
        let decoration = try #require(ABCDecoration(name: "trill"))

        #expect(decoration.dialect == .bang)
        #expect(decoration.name == "trill")
        #expect(decoration.shorthand == nil)
    }

    @Test
    func init_withEmptyNameReturnsNil() {
        #expect(ABCDecoration(name: "") == nil)
    }
}
