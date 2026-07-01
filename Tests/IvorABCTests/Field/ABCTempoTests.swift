// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCTempoTests {
}

// MARK: -

extension ABCTempoTests {
    @Test
    func equality() {
        let len = makeLength(1, 4)
        let a = makeTempo([len], 120, "Allegro")
        let b = makeTempo([len], 120, "Allegro")

        #expect(a == b)
    }

    @Test
    func equality_compoundLengths() {
        let d1 = makeLength(3, 8)
        let d2 = makeLength(1, 4)
        let a = makeTempo([d1, d2], 44)
        let b = makeTempo([d1, d2], 44)

        #expect(a == b)
    }

    @Test
    func equality_emptyLengths() {
        let a = makeTempo([], nil, "Andante")
        let b = makeTempo([], nil, "Andante")

        #expect(a == b)
    }

    @Test
    func inequality() {
        let len = makeLength(1, 4)
        let base = makeTempo([len], 120, "Allegro")
        let diffRate = makeTempo([len], 100, "Allegro")
        let diffText = makeTempo([len], 120, "Andante")
        let diffDur = makeTempo([makeLength(1, 8)], 120, "Allegro")
        let extraLen = makeTempo([len, makeLength(1, 8)], 120, "Allegro")
        let noDurs = makeTempo([], 120, "Allegro")

        #expect(base != diffRate)
        #expect(base != diffText)
        #expect(base != diffDur)
        #expect(base != extraLen)
        #expect(base != noDurs)
    }

    @Test
    func init_compoundLengths() {
        let d1 = makeLength(3, 8)
        let d2 = makeLength(1, 4)
        let tempo = makeTempo([d1, d2], 44)

        #expect(tempo.lengths == [d1, d2])
        #expect(tempo.rate == 44)
        #expect(tempo.text == nil)
    }

    @Test
    func init_emptyLengths() {
        let tempo = makeTempo([])

        #expect(tempo.lengths.isEmpty)
        #expect(tempo.rate == nil)
        #expect(tempo.text == nil)
    }

    @Test
    func init_singleLength() {
        let len = makeLength(1, 4)
        let tempo = makeTempo([len], 120, "Allegro")

        #expect(tempo.lengths == [len])
        #expect(tempo.rate == 120)
        #expect(tempo.text == "Allegro")
    }

    @Test
    func init_beatMultiplier_defaultsToNil() {
        let len = makeLength(1, 4)
        let tempo = makeTempo([len], 120)

        #expect(tempo.beatMultiplier == nil)
    }

    @Test
    func init_beatMultiplier_storesValue() {
        // An unresolved C-form tempo: no lengths, multiplier recorded.
        let tempo = ABCTempo(lengths: [], rate: 40, text: nil, beatMultiplier: 3).require()

        #expect(tempo.beatMultiplier == 3)
        #expect(tempo.lengths.isEmpty)
    }

    @Test
    func init_beatMultiplier_withLengthsIsInvalid() {
        // beatMultiplier marks an unresolved C-form, so lengths must be empty.
        #expect(ABCTempo(lengths: [makeLength(1, 8)],
                         rate: 120,
                         text: nil,
                         beatMultiplier: 1) == nil)
    }

    @Test
    func inequality_beatMultiplier() {
        let withFlag = ABCTempo(lengths: [], rate: 120, text: nil, beatMultiplier: 1).require()
        let withoutFlag = ABCTempo(lengths: [], rate: 120, text: nil, beatMultiplier: nil).require()

        #expect(withFlag != withoutFlag)
    }
}
