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

        #expect(ABCBodyEntry.directive(directive) == .directive(directive))
    }

    @Test
    func equality_field() {
        #expect(ABCBodyEntry.field(.tuneTitle("My Tune")) == .field(.tuneTitle("My Tune")))
    }

    @Test
    func equality_symbols() {
        let pitch = makePitch(.c, .omitted, 4)
        let length = makeLength(1, 4)
        let note = makeNote(pitch, length)
        let symbols: [ABCSymbol] = [.note(note)]

        #expect(ABCBodyEntry.symbols(symbols) == .symbols(symbols))
    }

    @Test
    func inequality() {
        let directive = makeDirective("pagewidth", "21cm")

        #expect(ABCBodyEntry.directive(directive) != .field(.tuneTitle("My Tune")))
        #expect(ABCBodyEntry.field(.tuneTitle("My Tune")) != .field(.tuneTitle("Other Tune")))
    }
}
