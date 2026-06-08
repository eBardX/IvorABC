// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCEntryTests {
}

// MARK: -

extension ABCEntryTests {
    @Test
    func equality_directive() {
        let directive = ABCDirective(name: "pagewidth", value: "21cm")

        #expect(ABCEntry.directive(directive) == .directive(directive))
    }

    @Test
    func equality_field() {
        #expect(ABCEntry.field(.title("My Tune")) == .field(.title("My Tune")))
    }

    @Test
    func equality_symbols() {
        let pitch = ABCPitch(letter: .c, accidental: .omitted, octave: 4)
        let duration = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let note = ABCNote(pitch: pitch, duration: duration, isTied: false)
        let symbols: [ABCSymbol] = [.note(note)]

        #expect(ABCEntry.symbols(symbols) == .symbols(symbols))
    }

    @Test
    func inequality() {
        let directive = ABCDirective(name: "pagewidth", value: "21cm")

        #expect(ABCEntry.directive(directive) != .field(.title("My Tune")))
        #expect(ABCEntry.field(.title("My Tune")) != .field(.title("Other Tune")))
    }
}
