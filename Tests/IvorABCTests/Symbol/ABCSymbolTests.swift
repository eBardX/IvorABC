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
        let a = makeAnnotation(.above, "Allegro")

        #expect(ABCSymbol.annotation(a) == .annotation(a))
    }

    @Test
    func equality_barRepeat() {
        let bar = makeBarRepeat()
        #expect(ABCSymbol.barRepeat(bar) == .barRepeat(bar))
    }

    @Test
    func equality_brokenRhythm() {
        #expect(ABCSymbol.brokenRhythm(.dotted) == .brokenRhythm(.dotted))
    }

    @Test
    func equality_chord() {
        let pitch = makePitch(.c, .omitted, 4)
        let duration = makeDuration(1, 4)
        let note = makeNote(pitch, duration)

        #expect(ABCSymbol.chord(makeChord([note], duration))
                == .chord(makeChord([note], duration)))
    }

    @Test
    func equality_chordSymbol() {
        let cs = ABCChordSymbol(name: .init(root: .a, kind: "m"))

        #expect(ABCSymbol.chordSymbol(cs) == .chordSymbol(cs))
    }

    @Test
    func equality_decoration() {
        #expect(ABCSymbol.decoration(makeDecoration("p", .bang)) == .decoration(makeDecoration("p", .bang)))
    }

    @Test
    func equality_graceNotes() {
        let pitch = makePitch(.g, .omitted, 4)
        let duration = makeDuration(1, 8)
        let note = makeNote(pitch, duration)

        #expect(ABCSymbol.graceNotes(makeGraceNotes([note], false))
                == .graceNotes(makeGraceNotes([note], false)))
        #expect(ABCSymbol.graceNotes(makeGraceNotes([note], true))
                == .graceNotes(makeGraceNotes([note], true)))
    }

    @Test
    func equality_inlineField() {
        #expect(ABCSymbol.inlineField(.tuneTitle("My Tune")) == .inlineField(.tuneTitle("My Tune")))
    }

    @Test
    func equality_note() {
        let pitch = makePitch(.a, .omitted, 4)
        let duration = makeDuration(1, 4)
        let note = makeNote(pitch, duration)

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
        #expect(ABCSymbol.slur(.startRegular) == .slur(.startRegular))
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
        #expect(ABCSymbol.annotation(makeAnnotation(.above, "foo")) != .chordSymbol(ABCChordSymbol(name: .init(root: .f))))
        #expect(ABCSymbol.overlay != .slur(.startRegular))
        #expect(ABCSymbol.tuplet(makeTuplet(3, 2, 3))
                != .tuplet(makeTuplet(3, 2, 4)))
    }
}
