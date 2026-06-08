// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCSymbolLineTokenTests {
}

// MARK: -

extension ABCSymbolLineTokenTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCSymbolLine.Token] = [.annotation("^forte"),
                                               .chordSymbol("Am"),
                                               .decoration(ABCDecoration(name: "p")),
                                               .skip]

        for i in allCases.indices {
            for j in allCases.indices where i != j {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test
    func equality() {
        #expect(ABCSymbolLine.Token.annotation("^forte") == .annotation("^forte"))
        #expect(ABCSymbolLine.Token.chordSymbol("Am") == .chordSymbol("Am"))
        #expect(ABCSymbolLine.Token.decoration(ABCDecoration(name: "p")) == .decoration(ABCDecoration(name: "p")))
        #expect(ABCSymbolLine.Token.skip == .skip)
    }

    @Test
    func inequality_differentAssociatedValues() {
        #expect(ABCSymbolLine.Token.annotation("^forte") != .annotation("_soft"))
        #expect(ABCSymbolLine.Token.chordSymbol("Am") != .chordSymbol("G"))
        #expect(ABCSymbolLine.Token.decoration(ABCDecoration(name: "p")) != .decoration(ABCDecoration(name: "f")))
    }
}
