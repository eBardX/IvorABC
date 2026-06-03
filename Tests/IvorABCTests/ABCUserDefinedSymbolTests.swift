// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCUserDefinedSymbolTests {
}

// MARK: -

extension ABCUserDefinedSymbolTests {
    @Test
    func decoration_isStored() {
        let uds = ABCUserDefinedSymbol(symbol: "~",
                                       decoration: "!roll!")

        #expect(uds.decoration == "!roll!")
    }

    @Test
    func symbol_isStored() {
        let uds = ABCUserDefinedSymbol(symbol: "~",
                                       decoration: "!roll!")

        #expect(uds.symbol == "~")
    }

    @Test
    func equatable_equal() {
        let lhs = ABCUserDefinedSymbol(symbol: "T", decoration: "!trill!")
        let rhs = ABCUserDefinedSymbol(symbol: "T", decoration: "!trill!")

        #expect(lhs == rhs)
    }

    @Test
    func equatable_differentDecoration() {
        let lhs = ABCUserDefinedSymbol(symbol: "T", decoration: "!trill!")
        let rhs = ABCUserDefinedSymbol(symbol: "T", decoration: "!roll!")

        #expect(lhs != rhs)
    }

    @Test
    func equatable_differentSymbol() {
        let lhs = ABCUserDefinedSymbol(symbol: "T", decoration: "!trill!")
        let rhs = ABCUserDefinedSymbol(symbol: "H", decoration: "!trill!")

        #expect(lhs != rhs)
    }
}
