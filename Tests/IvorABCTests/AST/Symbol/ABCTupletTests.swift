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
    func init_withNoteCount10_extendedForm_returnsNil() {
        #expect(ABCTuplet(noteCount: 10, beatCount: 6, affectedCount: 10) == nil)
    }

    @Test
    func init_withNoteCount10_simpleForm_returnsNil() {
        #expect(ABCTuplet(noteCount: 10) == nil)
    }

    @Test
    func init_withNoteCount1_extendedForm_returnsNil() {
        #expect(ABCTuplet(noteCount: 1, beatCount: 2, affectedCount: 1) == nil)
    }

    @Test
    func init_withNoteCount1_simpleForm_returnsNil() {
        #expect(ABCTuplet(noteCount: 1) == nil)
    }

    @Test
    func init_withNoteCount2_simpleForm_isNotNil() {
        #expect(ABCTuplet(noteCount: 2) != nil)
    }

    @Test
    func init_withNoteCount9_simpleForm_isNotNil() {
        #expect(ABCTuplet(noteCount: 9) != nil)
    }

    @Test
    func init_withZeroAffectedCount_returnsNil() {
        #expect(ABCTuplet(noteCount: 3, affectedCount: 0) == nil)
    }

    @Test
    func init_withZeroBeatCount_returnsNil() {
        #expect(ABCTuplet(noteCount: 3, beatCount: 0) == nil)
    }

    @Test
    func init_withZeroNoteCountReturnsNil() {
        #expect(ABCTuplet(noteCount: 0) == nil)
    }
}
