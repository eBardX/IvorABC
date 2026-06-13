// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCSymbolLineTests {
}

// MARK: -

extension ABCSymbolLineTests {
    @Test
    func equality() {
        let sl1 = ABCSymbolLine(elements: [.decoration(ABCDecoration("trill", nil, .bang)), .skip])
        let sl2 = ABCSymbolLine(elements: [.decoration(ABCDecoration("trill", nil, .bang)), .skip])

        #expect(sl1 == sl2)
    }

    @Test
    func inequality_differentCount() {
        let sl1 = ABCSymbolLine(elements: [.skip])
        let sl2 = ABCSymbolLine(elements: [.skip, .skip])

        #expect(sl1 != sl2)
    }

    @Test
    func inequality_differentToken() {
        let sl1 = ABCSymbolLine(elements: [.decoration(ABCDecoration("p", nil, .bang))])
        let sl2 = ABCSymbolLine(elements: [.skip])

        #expect(sl1 != sl2)
    }

    @Test
    func elements_empty() {
        let sl = ABCSymbolLine(elements: [])

        #expect(sl.elements.isEmpty)
    }

    @Test
    func elements_mixed() {
        let a = ABCAnnotation(position: .above, text: "forte")
        let sl = ABCSymbolLine(elements: [.decoration(ABCDecoration("p", nil, .bang)), .skip, .chordSymbol("Am"), .annotation(a)])

        #expect(sl.elements == [.decoration(ABCDecoration("p", nil, .bang)), .skip, .chordSymbol("Am"), .annotation(a)])
    }
}
