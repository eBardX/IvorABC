// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCSymbolLineTests {
}

// MARK: -

extension ABCSymbolLineTests {
    @Test
    func equality() {
        let sl1 = makeSymbolLine([.decoration(makeDecoration("trill", .bang)), .skip])
        let sl2 = makeSymbolLine([.decoration(makeDecoration("trill", .bang)), .skip])

        #expect(sl1 == sl2)
    }

    @Test
    func inequality_differentCount() {
        let sl1 = makeSymbolLine([.skip])
        let sl2 = makeSymbolLine([.skip, .skip])

        #expect(sl1 != sl2)
    }

    @Test
    func inequality_differentToken() {
        let sl1 = makeSymbolLine([.decoration(makeDecoration("p", .bang))])
        let sl2 = makeSymbolLine([.skip])

        #expect(sl1 != sl2)
    }

    @Test
    func elements_empty() {
        let sl = makeSymbolLine([])

        #expect(sl.elements.isEmpty)
    }

    @Test
    func elements_mixed() {
        let a = makeAnnotation(.above, "forte")
        let sl = makeSymbolLine([.decoration(makeDecoration("p", .bang)),
                                 .skip,
                                 .chordSymbol("Am"),
                                 .annotation(a)])

        #expect(sl.elements == [.decoration(makeDecoration("p", .bang)), .skip, .chordSymbol("Am"), .annotation(a)])
    }
}
