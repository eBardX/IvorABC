// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

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
        let duration = makeDuration(1, 4)
        let note = ABCNote(pitch: pitch, duration: duration, isTied: false)

        #expect(ABCSymbol.chord(makeChord([note], duration, false))
                    == .chord(makeChord([note], duration, false)))
    }

    @Test
    func equality_chordSymbol() {
        #expect(ABCSymbol.chordSymbol("Am") == .chordSymbol("Am"))
    }

    @Test
    func equality_decoration() {
        #expect(ABCSymbol.decoration(makeDecoration("p", nil, .bang)) == .decoration(makeDecoration("p", nil, .bang)))
    }

    @Test
    func equality_graceNotes() {
        let pitch = ABCPitch(letter: .g, accidental: .omitted, octave: 4)
        let duration = makeDuration(1, 8)
        let note = ABCNote(pitch: pitch, duration: duration, isTied: false)

        #expect(ABCSymbol.graceNotes(makeGraceNotes([note], false))
                    == .graceNotes(makeGraceNotes([note], false)))
        #expect(ABCSymbol.graceNotes(makeGraceNotes([note], true))
                    == .graceNotes(makeGraceNotes([note], true)))
    }

    @Test
    func equality_inlineField() {
        #expect(ABCSymbol.inlineField(.title("My Tune")) == .inlineField(.title("My Tune")))
    }

    @Test
    func equality_note() {
        let pitch = ABCPitch(letter: .a, accidental: .omitted, octave: 4)
        let duration = makeDuration(1, 4)
        let note = ABCNote(pitch: pitch, duration: duration, isTied: false)

        #expect(ABCSymbol.note(note) == .note(note))
    }

    @Test
    func equality_rest() {
        let duration = makeDuration(1, 4)
        let rest = ABCRest.regular(false, duration)

        #expect(ABCSymbol.rest(rest) == .rest(rest))
    }

    @Test
    func equality_slur() {
        #expect(ABCSymbol.slur("(") == .slur("("))
    }

    @Test
    func equality_spacer() {
        let duration = makeDuration(1, 8)

        #expect(ABCSymbol.spacer(duration) == .spacer(duration))
    }

    @Test
    func equality_tuplet() {
        let t = makeTuplet(3, 2, 3)

        #expect(ABCSymbol.tuplet(t) == .tuplet(t))
    }

    @Test
    func equality_variantEnding() {
        #expect(ABCSymbol.variantEnding(makeVariantEnding([1...1])) == .variantEnding(makeVariantEnding([1...1])))
    }

    @Test
    func inequality() {
        #expect(ABCSymbol.annotation(makeAnnotation(.above, "foo")) != .annotation(makeAnnotation(.below, "foo")))
        #expect(ABCSymbol.annotation(makeAnnotation(.above, "foo")) != .chordSymbol("foo"))
        #expect(ABCSymbol.overlay != .slur("("))
        #expect(ABCSymbol.tuplet(makeTuplet(3, 2, 3))
                    != .tuplet(makeTuplet(3, 2, 4)))
    }

    @Test
    func resolveBrokenRhythm_doubleRight_lengthensAndShortens() {
        let result = ABCSymbol.brokenRhythm(">>").resolveBrokenRhythm(left: makeDuration(1, 4),
                                                                      right: makeDuration(1, 4))

        #expect(result?.left == makeDuration(7, 16))
        #expect(result?.right == makeDuration(1, 16))
    }

    @Test
    func resolveBrokenRhythm_nonBrokenRhythm_returnsNil() {
        let note = ABCSymbol.note(ABCNote(pitch: makePitch(.c, .natural, 4),
                                          duration: makeDuration(1, 4),
                                          isTied: false))

        #expect(note.resolveBrokenRhythm(left: makeDuration(1, 4), right: makeDuration(1, 4)) == nil)
    }

    @Test
    func resolveBrokenRhythm_singleLeft_halvesAndDots() {
        let result = ABCSymbol.brokenRhythm("<").resolveBrokenRhythm(left: makeDuration(1, 4),
                                                                     right: makeDuration(1, 4))

        #expect(result?.left == makeDuration(1, 8))
        #expect(result?.right == makeDuration(3, 8))
    }

    @Test
    func resolveBrokenRhythm_singleRight_dotsDurationAndHalvesNext() {
        let result = ABCSymbol.brokenRhythm(">").resolveBrokenRhythm(left: makeDuration(1, 4),
                                                                     right: makeDuration(1, 4))

        #expect(result?.left == makeDuration(3, 8))
        #expect(result?.right == makeDuration(1, 8))
    }

    @Test
    func resolveBrokenRhythm_tripleRight_lengthensAndShortens() {
        let result = ABCSymbol.brokenRhythm(">>>").resolveBrokenRhythm(left: makeDuration(1, 4),
                                                                       right: makeDuration(1, 4))

        #expect(result?.left == makeDuration(15, 32))
        #expect(result?.right == makeDuration(1, 32))
    }
}
