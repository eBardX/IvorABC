// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCTempoTests {
}

// MARK: -

extension ABCTempoTests {
    @Test
    func equality() {
        let dur = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let a = ABCTempo(durations: [dur], rate: 120, text: "Allegro")
        let b = ABCTempo(durations: [dur], rate: 120, text: "Allegro")

        #expect(a == b)
    }

    @Test
    func equality_compoundDurations() {
        let d1 = ABCDuration(numerator: 3, denominator: 8, reduce: false)
        let d2 = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let a = ABCTempo(durations: [d1, d2], rate: 44, text: nil)
        let b = ABCTempo(durations: [d1, d2], rate: 44, text: nil)

        #expect(a == b)
    }

    @Test
    func equality_emptyDurations() {
        let a = ABCTempo(durations: [], rate: nil, text: "Andante")
        let b = ABCTempo(durations: [], rate: nil, text: "Andante")

        #expect(a == b)
    }

    @Test
    func inequality() {
        let dur = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let base = ABCTempo(durations: [dur], rate: 120, text: "Allegro")

        let diffRate = ABCTempo(durations: [dur], rate: 100, text: "Allegro")
        let diffText = ABCTempo(durations: [dur], rate: 120, text: "Andante")
        let diffDur = ABCTempo(durations: [ABCDuration(numerator: 1, denominator: 8, reduce: false)],
                               rate: 120,
                               text: "Allegro")
        let extraDur = ABCTempo(durations: [dur,
                                            ABCDuration(numerator: 1, denominator: 8, reduce: false)],
                                rate: 120,
                                text: "Allegro")
        let noDurs = ABCTempo(durations: [], rate: 120, text: "Allegro")

        #expect(base != diffRate)
        #expect(base != diffText)
        #expect(base != diffDur)
        #expect(base != extraDur)
        #expect(base != noDurs)
    }

    @Test
    func init_compoundDurations() {
        let d1 = ABCDuration(numerator: 3, denominator: 8, reduce: false)
        let d2 = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let tempo = ABCTempo(durations: [d1, d2], rate: 44, text: nil)

        #expect(tempo.durations == [d1, d2])
        #expect(tempo.rate == 44)
        #expect(tempo.text == nil)
    }

    @Test
    func init_emptyDurations() {
        let tempo = ABCTempo(durations: [], rate: nil, text: nil)

        #expect(tempo.durations.isEmpty)
        #expect(tempo.rate == nil)
        #expect(tempo.text == nil)
    }

    @Test
    func init_singleDuration() {
        let dur = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let tempo = ABCTempo(durations: [dur], rate: 120, text: "Allegro")

        #expect(tempo.durations == [dur])
        #expect(tempo.rate == 120)
        #expect(tempo.text == "Allegro")
    }

    @Test
    func init_legacyBeatMultiple_defaultsToNil() {
        let dur = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let tempo = ABCTempo(durations: [dur], rate: 120, text: nil)

        #expect(tempo.legacyBeatMultiple == nil)
    }

    @Test
    func init_legacyBeatMultiple_storesValue() {
        let dur = ABCDuration(numerator: 3, denominator: 8, reduce: false)
        let tempo = ABCTempo(durations: [dur], rate: 40, text: nil, legacyBeatMultiple: 3)

        #expect(tempo.legacyBeatMultiple == 3)
    }

    @Test
    func inequality_legacyBeatMultiple() {
        let dur = ABCDuration(numerator: 1, denominator: 8, reduce: false)
        let withFlag = ABCTempo(durations: [dur], rate: 120, text: nil, legacyBeatMultiple: 1)
        let withoutFlag = ABCTempo(durations: [dur], rate: 120, text: nil)

        #expect(withFlag != withoutFlag)
    }
}
