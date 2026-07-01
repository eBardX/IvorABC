// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCAccidentalContextTests {
}

// MARK: -

extension ABCAccidentalContextTests {
    @Test
    func resolveAccidental_afterReset_barAccidentalCleared() {
        var ctx = ABCAccidentalContext()
        let len = makeLength(1, 8)

        let sharp = makeNote(makePitch(.f, .sharp, 4),
                             len)

        ctx.update(with: sharp)
        ctx.reset()

        let after = makeNote(makePitch(.f, .omitted, 4),
                             len)

        #expect(ctx.resolveAccidental(for: after) == .natural)
    }

    @Test
    func resolveAccidental_afterReset_keyAccidentalRestored() {
        // G major: F♯ from key, cancelled in bar, restored after reset
        var ctx = ABCAccidentalContext(keySignature: makeKeySignature(.g, .major))
        let len = makeLength(1, 8)

        let cancel = makeNote(makePitch(.f, .natural, 4),
                              len)

        ctx.update(with: cancel)
        ctx.reset()

        let after = makeNote(makePitch(.f, .omitted, 4),
                             len)

        #expect(ctx.resolveAccidental(for: after) == .sharp)
    }

    @Test
    func resolveAccidental_barPropagation_naturalCancelsKeyAccidental() {
        // G major has F♯; explicit ♮ cancels it for the rest of the bar
        var ctx = ABCAccidentalContext(keySignature: makeKeySignature(.g, .major))
        let len = makeLength(1, 8)

        let cancel = makeNote(makePitch(.f, .natural, 4),
                              len)

        ctx.update(with: cancel)

        let following = makeNote(makePitch(.f, .omitted, 4),
                                 len)

        #expect(ctx.resolveAccidental(for: following) == .natural)
    }

    @Test
    func resolveAccidental_barPropagation_propagatesAcrossOctaves() {
        var ctx = ABCAccidentalContext()
        let len = makeLength(1, 8)

        // First note: F♯ written
        let first = makeNote(makePitch(.f, .sharp, 4),
                             len)

        ctx.update(with: first)

        // Second note: F in same octave, no written accidental — should inherit ♯
        let second = makeNote(makePitch(.f, .omitted, 4),
                              len)

        #expect(ctx.resolveAccidental(for: second) == .sharp)

        // Third note: F in a different octave — accidental still propagates
        let third = makeNote(makePitch(.f, .omitted, 5),
                             len)

        #expect(ctx.resolveAccidental(for: third) == .sharp)
    }

    @Test
    func resolveAccidental_keySignature_impliedAccidental() {
        // G major has F♯
        let ctx = ABCAccidentalContext(keySignature: makeKeySignature(.g, .major))
        let note = makeNote(makePitch(.f, .omitted, 4),
                            makeLength(1, 8))

        #expect(ctx.resolveAccidental(for: note) == .sharp)
    }

    @Test
    func resolveAccidental_keySignature_unaffectedPitch_returnsNatural() {
        // G major has no accidental on C
        let ctx = ABCAccidentalContext(keySignature: makeKeySignature(.g, .major))
        let note = makeNote(makePitch(.c, .omitted, 4),
                            makeLength(1, 8))

        #expect(ctx.resolveAccidental(for: note) == .natural)
    }

    @Test
    func resolveAccidental_keySignature_writtenAccidentalOverridesKey() {
        // G major has F♯, but written ♮ overrides it
        let ctx = ABCAccidentalContext(keySignature: makeKeySignature(.g, .major))
        let note = makeNote(makePitch(.f, .natural, 4),
                            makeLength(1, 8))

        #expect(ctx.resolveAccidental(for: note) == .natural)
    }

    @Test
    func resolveAccidental_noKey_noWrittenAccidental_returnsNatural() {
        let ctx = ABCAccidentalContext()
        let note = makeNote(makePitch(.f, .omitted, 4),
                            makeLength(1, 8))

        #expect(ctx.resolveAccidental(for: note) == .natural)
    }

    @Test
    func resolveAccidental_noKey_writtenSharp_returnsSharp() {
        let ctx = ABCAccidentalContext()
        let note = makeNote(makePitch(.f, .sharp, 4),
                            makeLength(1, 8))

        #expect(ctx.resolveAccidental(for: note) == .sharp)
    }
}
