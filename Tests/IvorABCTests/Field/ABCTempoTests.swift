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
        let dur = makeDuration(1, 4)
        let a = makeTempo([dur], 120, "Allegro")
        let b = makeTempo([dur], 120, "Allegro")

        #expect(a == b)
    }

    @Test
    func equality_compoundDurations() {
        let d1 = makeDuration(3, 8)
        let d2 = makeDuration(1, 4)
        let a = makeTempo([d1, d2], 44)
        let b = makeTempo([d1, d2], 44)

        #expect(a == b)
    }

    @Test
    func equality_emptyDurations() {
        let a = makeTempo([], nil, "Andante")
        let b = makeTempo([], nil, "Andante")

        #expect(a == b)
    }

    @Test
    func inequality() {
        let dur = makeDuration(1, 4)
        let base = makeTempo([dur], 120, "Allegro")
        let diffRate = makeTempo([dur], 100, "Allegro")
        let diffText = makeTempo([dur], 120, "Andante")
        let diffDur = makeTempo([makeDuration(1, 8)], 120, "Allegro")
        let extraDur = makeTempo([dur, makeDuration(1, 8)], 120, "Allegro")
        let noDurs = makeTempo([], 120, "Allegro")

        #expect(base != diffRate)
        #expect(base != diffText)
        #expect(base != diffDur)
        #expect(base != extraDur)
        #expect(base != noDurs)
    }

    @Test
    func init_compoundDurations() {
        let d1 = makeDuration(3, 8)
        let d2 = makeDuration(1, 4)
        let tempo = makeTempo([d1, d2], 44)

        #expect(tempo.durations == [d1, d2])
        #expect(tempo.rate == 44)
        #expect(tempo.text == nil)
    }

    @Test
    func init_emptyDurations() {
        let tempo = makeTempo([])

        #expect(tempo.durations.isEmpty)
        #expect(tempo.rate == nil)
        #expect(tempo.text == nil)
    }

    @Test
    func init_singleDuration() {
        let dur = makeDuration(1, 4)
        let tempo = makeTempo([dur], 120, "Allegro")

        #expect(tempo.durations == [dur])
        #expect(tempo.rate == 120)
        #expect(tempo.text == "Allegro")
    }

    @Test
    func init_legacyBeatMultiple_defaultsToNil() {
        let dur = makeDuration(1, 4)
        let tempo = makeTempo([dur], 120)

        #expect(tempo.legacyBeatMultiple == nil)
    }

    @Test
    func init_legacyBeatMultiple_storesValue() {
        let dur = makeDuration(3, 8)
        let tempo = ABCTempo(durations: [dur], rate: 40, text: nil, legacyBeatMultiple: 3).require()

        #expect(tempo.legacyBeatMultiple == 3)
    }

    @Test
    func inequality_legacyBeatMultiple() {
        let dur = makeDuration(1, 8)
        let withFlag = ABCTempo(durations: [dur], rate: 120, text: nil, legacyBeatMultiple: 1).require()
        let withoutFlag = makeTempo([dur], 120)

        #expect(withFlag != withoutFlag)
    }
}
