// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCEntryTests {
}

// MARK: -

extension ABCEntryTests {
    @Test
    func equality_directive() {
        let directive = makeDirective("pagewidth", "21cm")

        #expect(ABCEntry.directive(directive) == .directive(directive))
    }

    @Test
    func equality_field() {
        #expect(ABCEntry.field(.title("My Tune")) == .field(.title("My Tune")))
    }

    @Test
    func equality_symbols() {
        let pitch = makePitch(.c, .omitted, 4)
        let duration = makeDuration(1, 4)
        let note = makeNote(pitch, duration, false)
        let symbols: [ABCSymbol] = [.note(note)]

        #expect(ABCEntry.symbols(symbols) == .symbols(symbols))
    }

    @Test
    func inequality() {
        let directive = makeDirective("pagewidth", "21cm")

        #expect(ABCEntry.directive(directive) != .field(.title("My Tune")))
        #expect(ABCEntry.field(.title("My Tune")) != .field(.title("Other Tune")))
    }
}
