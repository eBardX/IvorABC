// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCSymbolTests {
}

// MARK: -

extension ABCSymbolTests {
    @Test
    func equality_annotation() {
        let a = ABCAnnotation(position: .above, text: "Allegro")

        #expect(ABCSymbol.annotation(a) == .annotation(a))
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
        let pitch = ABCPitch(letter: .c, accidental: .omitted, octave: 4)
        let duration = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let note = ABCNote(pitch: pitch, duration: duration, isTied: false)

        #expect(ABCSymbol.chord(ABCChord(notes: [note], duration: duration, isTied: false))
                    == .chord(ABCChord(notes: [note], duration: duration, isTied: false)))
    }

    @Test
    func equality_chordSymbol() {
        #expect(ABCSymbol.chordSymbol("Am") == .chordSymbol("Am"))
    }

    @Test
    func equality_decoration() {
        #expect(ABCSymbol.decoration(ABCDecoration(name: "p")) == .decoration(ABCDecoration(name: "p")))
    }

    @Test
    func equality_graceNotes() {
        let pitch = ABCPitch(letter: .g, accidental: .omitted, octave: 4)
        let duration = ABCDuration(numerator: 1, denominator: 8, reduce: false)
        let note = ABCNote(pitch: pitch, duration: duration, isTied: false)

        #expect(ABCSymbol.graceNotes(ABCGraceNotes(isSlashed: false, notes: [note]))
                    == .graceNotes(ABCGraceNotes(isSlashed: false, notes: [note])))
        #expect(ABCSymbol.graceNotes(ABCGraceNotes(isSlashed: true, notes: [note]))
                    == .graceNotes(ABCGraceNotes(isSlashed: true, notes: [note])))
    }

    @Test
    func equality_inlineField() {
        #expect(ABCSymbol.inlineField(.title("My Tune")) == .inlineField(.title("My Tune")))
    }

    @Test
    func equality_note() {
        let pitch = ABCPitch(letter: .a, accidental: .omitted, octave: 4)
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
    func equality_spacer() {
        let duration = ABCDuration(numerator: 1, denominator: 8, reduce: false)

        #expect(ABCSymbol.spacer(duration) == .spacer(duration))
    }

    @Test
    func equality_tuplet() {
        let t = ABCTuplet(noteCount: 3, beatCount: 2, affectedCount: 3)

        #expect(ABCSymbol.tuplet(t) == .tuplet(t))
    }

    @Test
    func equality_variantEnding() {
        #expect(ABCSymbol.variantEnding(ABCVariantEnding(endings: [1...1])) == .variantEnding(ABCVariantEnding(endings: [1...1])))
    }

    @Test
    func inequality() {
        #expect(ABCSymbol.annotation(ABCAnnotation(position: .above, text: "foo")) != .annotation(ABCAnnotation(position: .below, text: "foo")))
        #expect(ABCSymbol.annotation(ABCAnnotation(position: .above, text: "foo")) != .chordSymbol("foo"))
        #expect(ABCSymbol.overlay != .slur("("))
        #expect(ABCSymbol.tuplet(ABCTuplet(noteCount: 3, beatCount: 2, affectedCount: 3))
                    != .tuplet(ABCTuplet(noteCount: 3, beatCount: 2, affectedCount: 4)))
    }

    @Test
    func resolveBrokenRhythm_doubleRight_lengthensAndShortens() {
        let result = ABCSymbol.brokenRhythm(">>").resolveBrokenRhythm(left: _dur(1, 4),
                                                                      right: _dur(1, 4))

        #expect(result?.left == _dur(7, 16))
        #expect(result?.right == _dur(1, 16))
    }

    @Test
    func resolveBrokenRhythm_nonBrokenRhythm_returnsNil() {
        let note = ABCSymbol.note(ABCNote(pitch: _pit(.c, .natural, 4),
                                          duration: _dur(1, 4),
                                          isTied: false))

        #expect(note.resolveBrokenRhythm(left: _dur(1, 4), right: _dur(1, 4)) == nil)
    }

    @Test
    func resolveBrokenRhythm_singleLeft_halvesAndDots() {
        let result = ABCSymbol.brokenRhythm("<").resolveBrokenRhythm(left: _dur(1, 4),
                                                                     right: _dur(1, 4))

        #expect(result?.left == _dur(1, 8))
        #expect(result?.right == _dur(3, 8))
    }

    @Test
    func resolveBrokenRhythm_singleRight_dotsDurationAndHalvesNext() {
        let result = ABCSymbol.brokenRhythm(">").resolveBrokenRhythm(left: _dur(1, 4),
                                                                     right: _dur(1, 4))

        #expect(result?.left == _dur(3, 8))
        #expect(result?.right == _dur(1, 8))
    }

    @Test
    func resolveBrokenRhythm_tripleRight_lengthensAndShortens() {
        let result = ABCSymbol.brokenRhythm(">>>").resolveBrokenRhythm(left: _dur(1, 4),
                                                                       right: _dur(1, 4))

        #expect(result?.left == _dur(15, 32))
        #expect(result?.right == _dur(1, 32))
    }
}
