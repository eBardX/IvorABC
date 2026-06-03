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
        let a = ABCTempo(duration: dur, rate: 120, text: "Allegro")
        let b = ABCTempo(duration: dur, rate: 120, text: "Allegro")

        #expect(a == b)
    }

    @Test
    func inequality() {
        let dur = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let base = ABCTempo(duration: dur, rate: 120, text: "Allegro")

        let diffRate = ABCTempo(duration: dur, rate: 100, text: "Allegro")
        let diffText = ABCTempo(duration: dur, rate: 120, text: "Andante")
        let diffDur = ABCTempo(duration: ABCDuration(numerator: 1, denominator: 8, reduce: false),
                               rate: 120,
                               text: "Allegro")

        #expect(base != diffRate)
        #expect(base != diffText)
        #expect(base != diffDur)
    }

    @Test
    func init_storesValues() {
        let dur = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let tempo = ABCTempo(duration: dur, rate: 120, text: "Allegro")

        #expect(tempo.duration == dur)
        #expect(tempo.rate == 120)
        #expect(tempo.text == "Allegro")
    }

    @Test
    func init_withNilValues() {
        let tempo = ABCTempo(duration: nil, rate: nil, text: nil)

        #expect(tempo.duration == nil)
        #expect(tempo.rate == nil)
        #expect(tempo.text == nil)
    }
}
