// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCUserSymbolTests {
}

// MARK: -

extension ABCUserSymbolTests {
    @Test
    func decoration_isStored() {
        let uds = makeUserSymbol("~", makeDecoration("roll"))

        #expect(uds.decoration.name == "roll")
        #expect(uds.decoration.dialect == .bang)
    }

    @Test
    func equality() {
        let lhs = makeUserSymbol("T", makeDecoration("trill"))
        let rhs = makeUserSymbol("T", makeDecoration("trill"))

        #expect(lhs == rhs)
    }

    @Test
    func inequality_differentDecoration() {
        let lhs = makeUserSymbol("T", makeDecoration("trill"))
        let rhs = makeUserSymbol("T", makeDecoration("roll"))

        #expect(lhs != rhs)
    }

    @Test
    func inequality_differentSymbol() {
        let lhs = makeUserSymbol("T", makeDecoration("trill"))
        let rhs = makeUserSymbol("H", makeDecoration("trill"))

        #expect(lhs != rhs)
    }

    @Test
    func symbol_isStored() {
        let uds = makeUserSymbol("~", makeDecoration("roll"))

        #expect(uds.symbol == "~")
    }
}
