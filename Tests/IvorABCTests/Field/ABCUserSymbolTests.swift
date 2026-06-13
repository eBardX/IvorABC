// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCUserSymbolTests {
}

// MARK: -

extension ABCUserSymbolTests {
    @Test
    func decoration_isStored() {
        let uds = ABCUserSymbol(symbol: "~",
                                decoration: makeDecoration("roll"))

        #expect(uds.decoration.name == "roll")
        #expect(uds.decoration.dialect == .bang)
    }

    @Test
    func equality() {
        let lhs = ABCUserSymbol(symbol: "T", decoration: makeDecoration("trill"))
        let rhs = ABCUserSymbol(symbol: "T", decoration: makeDecoration("trill"))

        #expect(lhs == rhs)
    }

    @Test
    func inequality_differentDecoration() {
        let lhs = ABCUserSymbol(symbol: "T", decoration: makeDecoration("trill"))
        let rhs = ABCUserSymbol(symbol: "T", decoration: makeDecoration("roll"))

        #expect(lhs != rhs)
    }

    @Test
    func inequality_differentSymbol() {
        let lhs = ABCUserSymbol(symbol: "T", decoration: makeDecoration("trill"))
        let rhs = ABCUserSymbol(symbol: "H", decoration: makeDecoration("trill"))

        #expect(lhs != rhs)
    }

    @Test
    func symbol_isStored() {
        let uds = ABCUserSymbol(symbol: "~",
                                decoration: makeDecoration("roll"))

        #expect(uds.symbol == "~")
    }
}
