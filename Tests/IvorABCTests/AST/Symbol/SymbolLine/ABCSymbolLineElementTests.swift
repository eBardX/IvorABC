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
                                                 .chordSymbol(ABCChordSymbol(name: .init(root: .a, kind: "m"))),
                                                 .decoration(makeDecoration("p", .bang)),
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
        let cs = ABCChordSymbol(name: .init(root: .a, kind: "m"))

        #expect(ABCSymbolLine.Element.chordSymbol(cs) == .chordSymbol(cs))
        #expect(ABCSymbolLine.Element.decoration(makeDecoration("p", .bang)) == .decoration(makeDecoration("p", .bang)))
        #expect(ABCSymbolLine.Element.skip == .skip)
    }

    @Test
    func inequality_differentAssociatedValues() {
        let above = makeAnnotation(.above, "forte")
        let below = makeAnnotation(.below, "soft")

        #expect(ABCSymbolLine.Element.annotation(above) != .annotation(below))
        #expect(ABCSymbolLine.Element.chordSymbol(ABCChordSymbol(name: .init(root: .a, kind: "m")))
                    != .chordSymbol(ABCChordSymbol(name: .init(root: .g))))
        #expect(ABCSymbolLine.Element.decoration(makeDecoration("p", .bang)) != .decoration(makeDecoration("f", .bang)))
    }
}
