// © 2026 John Gary Pusey (see LICENSE.md)

import IvorABC
import Testing

struct ABCAccidentalContextTests {
}

// MARK: -

extension ABCAccidentalContextTests {

    // MARK: No key signature

    @Test
    func resolveAccidental_noKey_noWrittenAccidental_returnsNatural() {
        let ctx = ABCAccidentalContext()
        let note = ABCNote(pitch: ABCPitch(letter: .f, accidental: .omitted, octave: 4),
                           duration: ABCDuration(numerator: 1, denominator: 8, reduce: false),
                           isTied: false)

        #expect(ctx.resolveAccidental(for: note) == .natural)
    }

    @Test
    func resolveAccidental_noKey_writtenSharp_returnsSharp() {
        let ctx = ABCAccidentalContext()
        let note = ABCNote(pitch: ABCPitch(letter: .f, accidental: .sharp, octave: 4),
                           duration: ABCDuration(numerator: 1, denominator: 8, reduce: false),
                           isTied: false)

        #expect(ctx.resolveAccidental(for: note) == .sharp)
    }

    // MARK: Key signature accidentals

    @Test
    func resolveAccidental_keySignature_impliedAccidental() {
        // G major has F♯
        let ctx = ABCAccidentalContext(keySignature: .standard(.g, .major, [], nil))
        let note = ABCNote(pitch: ABCPitch(letter: .f, accidental: .omitted, octave: 4),
                           duration: ABCDuration(numerator: 1, denominator: 8, reduce: false),
                           isTied: false)

        #expect(ctx.resolveAccidental(for: note) == .sharp)
    }

    @Test
    func resolveAccidental_keySignature_writtenAccidentalOverridesKey() {
        // G major has F♯, but written ♮ overrides it
        let ctx = ABCAccidentalContext(keySignature: .standard(.g, .major, [], nil))
        let note = ABCNote(pitch: ABCPitch(letter: .f, accidental: .natural, octave: 4),
                           duration: ABCDuration(numerator: 1, denominator: 8, reduce: false),
                           isTied: false)

        #expect(ctx.resolveAccidental(for: note) == .natural)
    }

    @Test
    func resolveAccidental_keySignature_unaffectedPitch_returnsNatural() {
        // G major has no accidental on C
        let ctx = ABCAccidentalContext(keySignature: .standard(.g, .major, [], nil))
        let note = ABCNote(pitch: ABCPitch(letter: .c, accidental: .omitted, octave: 4),
                           duration: ABCDuration(numerator: 1, denominator: 8, reduce: false),
                           isTied: false)

        #expect(ctx.resolveAccidental(for: note) == .natural)
    }

    // MARK: Bar-level propagation

    @Test
    func resolveAccidental_barPropagation_propagatesAcrossOctaves() {
        var ctx = ABCAccidentalContext()
        let dur = ABCDuration(numerator: 1, denominator: 8, reduce: false)

        // First note: F♯ written
        let first = ABCNote(pitch: ABCPitch(letter: .f, accidental: .sharp, octave: 4),
                            duration: dur,
                            isTied: false)

        ctx.update(with: first)

        // Second note: F in same octave, no written accidental — should inherit ♯
        let second = ABCNote(pitch: ABCPitch(letter: .f, accidental: .omitted, octave: 4),
                             duration: dur,
                             isTied: false)

        #expect(ctx.resolveAccidental(for: second) == .sharp)

        // Third note: F in a different octave — accidental still propagates
        let third = ABCNote(pitch: ABCPitch(letter: .f, accidental: .omitted, octave: 5),
                            duration: dur,
                            isTied: false)

        #expect(ctx.resolveAccidental(for: third) == .sharp)
    }

    @Test
    func resolveAccidental_barPropagation_naturalCancelsKeyAccidental() {
        // G major has F♯; explicit ♮ cancels it for the rest of the bar
        var ctx = ABCAccidentalContext(keySignature: .standard(.g, .major, [], nil))
        let dur = ABCDuration(numerator: 1, denominator: 8, reduce: false)

        let cancel = ABCNote(pitch: ABCPitch(letter: .f, accidental: .natural, octave: 4),
                             duration: dur,
                             isTied: false)

        ctx.update(with: cancel)

        let following = ABCNote(pitch: ABCPitch(letter: .f, accidental: .omitted, octave: 4),
                                duration: dur,
                                isTied: false)

        #expect(ctx.resolveAccidental(for: following) == .natural)
    }

    // MARK: Bar reset

    @Test
    func resolveAccidental_afterReset_barAccidentalCleared() {
        var ctx = ABCAccidentalContext()
        let dur = ABCDuration(numerator: 1, denominator: 8, reduce: false)

        let sharp = ABCNote(pitch: ABCPitch(letter: .f, accidental: .sharp, octave: 4),
                            duration: dur,
                            isTied: false)

        ctx.update(with: sharp)
        ctx.reset()

        let after = ABCNote(pitch: ABCPitch(letter: .f, accidental: .omitted, octave: 4),
                            duration: dur,
                            isTied: false)

        #expect(ctx.resolveAccidental(for: after) == .natural)
    }

    @Test
    func resolveAccidental_afterReset_keyAccidentalRestored() {
        // G major: F♯ from key, cancelled in bar, restored after reset
        var ctx = ABCAccidentalContext(keySignature: .standard(.g, .major, [], nil))
        let dur = ABCDuration(numerator: 1, denominator: 8, reduce: false)

        let cancel = ABCNote(pitch: ABCPitch(letter: .f, accidental: .natural, octave: 4),
                             duration: dur,
                             isTied: false)

        ctx.update(with: cancel)
        ctx.reset()

        let after = ABCNote(pitch: ABCPitch(letter: .f, accidental: .omitted, octave: 4),
                            duration: dur,
                            isTied: false)

        #expect(ctx.resolveAccidental(for: after) == .sharp)
    }
}
