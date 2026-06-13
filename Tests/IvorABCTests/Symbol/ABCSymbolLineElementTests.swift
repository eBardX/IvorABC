// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCSymbolLineElementTests {
}

// MARK: -

extension ABCSymbolLineElementTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCSymbolLine.Element] = [.annotation(ABCAnnotation(position: .above,
                                                                           text: "forte")),
                                                 .chordSymbol("Am"),
                                                 .decoration(ABCDecoration("p", nil, .bang)),
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

        #expect(ABCSymbolLine.Element.annotation(a) == .annotation(a))
        #expect(ABCSymbolLine.Element.chordSymbol("Am") == .chordSymbol("Am"))
        #expect(ABCSymbolLine.Element.decoration(ABCDecoration("p", nil, .bang)) == .decoration(ABCDecoration("p", nil, .bang)))
        #expect(ABCSymbolLine.Element.skip == .skip)
    }

    @Test
    func inequality_differentAssociatedValues() {
        let above = ABCAnnotation(position: .above, text: "forte")
        let below = ABCAnnotation(position: .below, text: "soft")

        #expect(ABCSymbolLine.Element.annotation(above) != .annotation(below))
        #expect(ABCSymbolLine.Element.chordSymbol("Am") != .chordSymbol("G"))
        #expect(ABCSymbolLine.Element.decoration(ABCDecoration("p", nil, .bang)) != .decoration(ABCDecoration("f", nil, .bang)))
    }
}
