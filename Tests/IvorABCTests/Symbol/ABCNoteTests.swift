// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCNoteTests {
}

// MARK: -

extension ABCNoteTests {
    @Test
    func equality() {
        let pitch = ABCPitch(letter: .c, accidental: .omitted, octave: 4)
        let duration = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let a = ABCNote(pitch: pitch, duration: duration, isTied: false)
        let b = ABCNote(pitch: pitch, duration: duration, isTied: false)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let pitch = ABCPitch(letter: .c, accidental: .omitted, octave: 4)
        let duration = ABCDuration(numerator: 1, denominator: 4, reduce: false)
        let base = ABCNote(pitch: pitch, duration: duration, isTied: false)

        let diffPitch = ABCNote(pitch: ABCPitch(letter: .d, accidental: .omitted, octave: 4),
                                duration: duration,
                                isTied: false)
        let diffDuration = ABCNote(pitch: pitch,
                                   duration: ABCDuration(numerator: 1, denominator: 8, reduce: false),
                                   isTied: false)
        let diffTied = ABCNote(pitch: pitch, duration: duration, isTied: true)

        #expect(base != diffPitch)
        #expect(base != diffDuration)
        #expect(base != diffTied)
    }

    @Test
    func init_storesValues() {
        let pitch = ABCPitch(letter: .f, accidental: .sharp, octave: 5)
        let duration = ABCDuration(numerator: 3, denominator: 8, reduce: false)
        let note = ABCNote(pitch: pitch, duration: duration, isTied: true)

        #expect(note.pitch == pitch)
        #expect(note.duration == duration)
        #expect(note.isTied)
    }
}
