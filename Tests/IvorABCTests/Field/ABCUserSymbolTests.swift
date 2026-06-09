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
                                decoration: "!roll!")

        #expect(uds.decoration == "!roll!")
    }

    @Test
    func equality() {
        let lhs = ABCUserSymbol(symbol: "T", decoration: "!trill!")
        let rhs = ABCUserSymbol(symbol: "T", decoration: "!trill!")

        #expect(lhs == rhs)
    }

    @Test
    func inequality_differentDecoration() {
        let lhs = ABCUserSymbol(symbol: "T", decoration: "!trill!")
        let rhs = ABCUserSymbol(symbol: "T", decoration: "!roll!")

        #expect(lhs != rhs)
    }

    @Test
    func inequality_differentSymbol() {
        let lhs = ABCUserSymbol(symbol: "T", decoration: "!trill!")
        let rhs = ABCUserSymbol(symbol: "H", decoration: "!trill!")

        #expect(lhs != rhs)
    }

    @Test
    func symbol_isStored() {
        let uds = ABCUserSymbol(symbol: "~",
                                decoration: "!roll!")

        #expect(uds.symbol == "~")
    }
}
