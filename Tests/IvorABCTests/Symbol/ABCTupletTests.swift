// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCTupletTests {
}

// MARK: -

extension ABCTupletTests {
    @Test
    func equality() {
        let a = makeTuplet(3, 2, 4)
        let b = makeTuplet(3, 2, 4)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a = makeTuplet(3)
        let b = makeTuplet(5)

        #expect(a != b)
    }

    @Test
    func init_storesProperties() {
        let tuplet = makeTuplet(5, 4, 6)

        #expect(tuplet.noteCount == 5)
        #expect(tuplet.beatCount == 4)
        #expect(tuplet.affectedCount == 6)
    }

    @Test
    func init_withZeroNoteCountReturnsNil() {
        #expect(ABCTuplet(noteCount: 0) == nil)
    }

    @Test
    func resolve_customValues_notOverridden() {
        let tuplet = makeTuplet(5, 7, 8)
        let result = tuplet.resolve()

        #expect(result.noteCount == 5)
        #expect(result.beatCount == 7)
        #expect(result.affectedCount == 8)
    }

    @Test
    func resolve_nilValues_defaultAffectedCountToNoteCount() {
        let tuplet = makeTuplet(5, 2, nil)
        let result = tuplet.resolve()

        #expect(result.noteCount == 5)
        #expect(result.beatCount == 2)
        #expect(result.affectedCount == 5)
    }

    @Test
    func resolve_noteCount2_defaultBeatCount3() {
        #expect(makeTuplet(2).resolve().beatCount == 3)
    }

    @Test
    func resolve_noteCount3_defaultBeatCount2() {
        #expect(makeTuplet(3).resolve().beatCount == 2)
    }

    @Test
    func resolve_noteCount4_defaultBeatCount3() {
        #expect(makeTuplet(4).resolve().beatCount == 3)
    }

    @Test
    func resolve_noteCount5_compoundMeter_beatCount3() {
        let meter = makeTimeSignature(6, 8)

        #expect(makeTuplet(5).resolve(meter: meter).beatCount == 3)
    }

    @Test
    func resolve_noteCount5_simpleMeter_beatCount2() {
        #expect(makeTuplet(5).resolve().beatCount == 2)
    }

    @Test
    func resolve_noteCount6_defaultBeatCount2() {
        #expect(makeTuplet(6).resolve().beatCount == 2)
    }

    @Test
    func resolve_noteCount8_defaultBeatCount3() {
        #expect(makeTuplet(8).resolve().beatCount == 3)
    }
}
