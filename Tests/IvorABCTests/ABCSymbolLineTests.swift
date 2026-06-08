// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCSymbolLineTests {
}

// MARK: -

extension ABCSymbolLineTests {
    @Test
    func equality() {
        let sl1 = ABCSymbolLine(tokens: [.decoration(ABCDecoration(name: "trill")), .skip])
        let sl2 = ABCSymbolLine(tokens: [.decoration(ABCDecoration(name: "trill")), .skip])

        #expect(sl1 == sl2)
    }

    @Test
    func inequality_differentCount() {
        let sl1 = ABCSymbolLine(tokens: [.skip])
        let sl2 = ABCSymbolLine(tokens: [.skip, .skip])

        #expect(sl1 != sl2)
    }

    @Test
    func inequality_differentToken() {
        let sl1 = ABCSymbolLine(tokens: [.decoration(ABCDecoration(name: "p"))])
        let sl2 = ABCSymbolLine(tokens: [.skip])

        #expect(sl1 != sl2)
    }

    @Test
    func tokens_empty() {
        let sl = ABCSymbolLine(tokens: [])

        #expect(sl.tokens.isEmpty)
    }

    @Test
    func tokens_mixed() {
        let sl = ABCSymbolLine(tokens: [.decoration(ABCDecoration(name: "p")), .skip, .chordSymbol("Am"), .annotation("^forte")])

        #expect(sl.tokens == [.decoration(ABCDecoration(name: "p")), .skip, .chordSymbol("Am"), .annotation("^forte")])
    }
}
