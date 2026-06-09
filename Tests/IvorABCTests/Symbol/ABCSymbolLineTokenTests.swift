// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCSymbolLineTokenTests {
}

// MARK: -

extension ABCSymbolLineTokenTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCSymbolLine.Token] = [.annotation(ABCAnnotation(position: .above, text: "forte")),
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
        let a = ABCAnnotation(position: .above, text: "forte")

        #expect(ABCSymbolLine.Token.annotation(a) == .annotation(a))
        #expect(ABCSymbolLine.Token.chordSymbol("Am") == .chordSymbol("Am"))
        #expect(ABCSymbolLine.Token.decoration(ABCDecoration(name: "p")) == .decoration(ABCDecoration(name: "p")))
        #expect(ABCSymbolLine.Token.skip == .skip)
    }

    @Test
    func inequality_differentAssociatedValues() {
        let above = ABCAnnotation(position: .above, text: "forte")
        let below = ABCAnnotation(position: .below, text: "soft")

        #expect(ABCSymbolLine.Token.annotation(above) != .annotation(below))
        #expect(ABCSymbolLine.Token.chordSymbol("Am") != .chordSymbol("G"))
        #expect(ABCSymbolLine.Token.decoration(ABCDecoration(name: "p")) != .decoration(ABCDecoration(name: "f")))
    }
}
