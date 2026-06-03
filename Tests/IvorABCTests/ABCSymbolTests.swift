// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCSymbolTests {
}

// MARK: -

extension ABCSymbolTests {
    @Test
    func equality_annotation() {
        #expect(ABCSymbol.annotation("^Allegro") == .annotation("^Allegro"))
    }

    @Test
    func equality_barRepeat() {
        #expect(ABCSymbol.barRepeat(":") == .barRepeat(":"))
    }

    @Test
    func equality_brokenRhythm() {
        #expect(ABCSymbol.brokenRhythm(">") == .brokenRhythm(">"))
    }

    @Test
    func equality_chord() {
        let pitch = ABCPitch(letter: .c, accidental: .natural, octave: 4)
        let duration = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let note = ABCNote(pitch: pitch, duration: duration, isTied: false)

        #expect(ABCSymbol.chord([note]) == .chord([note]))
    }

    @Test
    func equality_chordSymbol() {
        #expect(ABCSymbol.chordSymbol("Am") == .chordSymbol("Am"))
    }

    @Test
    func equality_decoration() {
        #expect(ABCSymbol.decoration("!p!") == .decoration("!p!"))
    }

    @Test
    func equality_graceNotes() {
        let pitch = ABCPitch(letter: .g, accidental: .natural, octave: 4)
        let duration = ABCDuration(numerator: 1, denominator: 8, reduce: false)
        let note = ABCNote(pitch: pitch, duration: duration, isTied: false)

        #expect(ABCSymbol.graceNotes(false, [note]) == .graceNotes(false, [note]))
        #expect(ABCSymbol.graceNotes(true, [note]) == .graceNotes(true, [note]))
    }

    @Test
    func equality_inlineField() {
        #expect(ABCSymbol.inlineField(.title("My Tune")) == .inlineField(.title("My Tune")))
    }

    @Test
    func equality_note() {
        let pitch = ABCPitch(letter: .a, accidental: .natural, octave: 4)
        let duration = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let note = ABCNote(pitch: pitch, duration: duration, isTied: false)

        #expect(ABCSymbol.note(note) == .note(note))
    }

    @Test
    func equality_rest() {
        let duration = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let rest = ABCRest.regular(false, duration)

        #expect(ABCSymbol.rest(rest) == .rest(rest))
    }

    @Test
    func equality_slur() {
        #expect(ABCSymbol.slur("(") == .slur("("))
    }

    @Test
    func equality_tuplet() {
        #expect(ABCSymbol.tuplet(3, 2, 3) == .tuplet(3, 2, 3))
    }

    @Test
    func equality_variantEnding() {
        #expect(ABCSymbol.variantEnding("1") == .variantEnding("1"))
    }

    @Test
    func inequality() {
        #expect(ABCSymbol.annotation("foo") != .annotation("bar"))
        #expect(ABCSymbol.annotation("foo") != .chordSymbol("foo"))
        #expect(ABCSymbol.overlay != .slur("("))
        #expect(ABCSymbol.tuplet(3, 2, 3) != .tuplet(3, 2, 4))
    }
}
