// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCSymbolLineElementTests {
}

// MARK: -

extension ABCSymbolLineElementTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCSymbolLine.Element] = [.annotation(makeAnnotation(.above, "forte")),
                                                 .chordSymbol("Am"),
                                                 .decoration(makeDecoration("p", nil, .bang)),
                                                 .skip]

        for i in allCases.indices {
            for j in allCases.indices where i != j {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test
    func equality() {
        let a = makeAnnotation(.above, "forte")

        #expect(ABCSymbolLine.Element.annotation(a) == .annotation(a))
        #expect(ABCSymbolLine.Element.chordSymbol("Am") == .chordSymbol("Am"))
        #expect(ABCSymbolLine.Element.decoration(makeDecoration("p", nil, .bang)) == .decoration(makeDecoration("p", nil, .bang)))
        #expect(ABCSymbolLine.Element.skip == .skip)
    }

    @Test
    func inequality_differentAssociatedValues() {
        let above = makeAnnotation(.above, "forte")
        let below = makeAnnotation(.below, "soft")

        #expect(ABCSymbolLine.Element.annotation(above) != .annotation(below))
        #expect(ABCSymbolLine.Element.chordSymbol("Am") != .chordSymbol("G"))
        #expect(ABCSymbolLine.Element.decoration(makeDecoration("p", nil, .bang)) != .decoration(makeDecoration("f", nil, .bang)))
    }
}
