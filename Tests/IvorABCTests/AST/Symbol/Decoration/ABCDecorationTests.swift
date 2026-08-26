// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCDecorationTests {
}

// MARK: -

extension ABCDecorationTests {
    @Test
    func equality() {
        let a = makeDecoration("roll")
        let b = makeDecoration("roll")

        #expect(a == b)
    }

    @Test
    func inequality_differentName() {
        let a = makeDecoration("roll")
        let b = makeDecoration("trill")

        #expect(a != b)
    }

    @Test
    func init_storesProperties() {
        let decoration = makeDecoration("roll")

        #expect(decoration.dialect == .bang)
        #expect(decoration.name == "roll")
    }

    @Test
    func name_withEmptyStringReturnsNil() {
        #expect(ABCDecoration.Name(stringValue: "") == nil)
    }
}
