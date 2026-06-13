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
        let duration = makeDuration(1, 4)
        let a = ABCNote(pitch: pitch, duration: duration, isTied: false)
        let b = ABCNote(pitch: pitch, duration: duration, isTied: false)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let pitch = ABCPitch(letter: .c, accidental: .omitted, octave: 4)
        let duration = makeDuration(1, 4)
        let base = ABCNote(pitch: pitch, duration: duration, isTied: false)

        let diffPitch = ABCNote(pitch: ABCPitch(letter: .d, accidental: .omitted, octave: 4),
                                duration: duration,
                                isTied: false)
        let diffDuration = ABCNote(pitch: pitch,
                                   duration: makeDuration(1, 8),
                                   isTied: false)
        let diffTied = ABCNote(pitch: pitch, duration: duration, isTied: true)

        #expect(base != diffPitch)
        #expect(base != diffDuration)
        #expect(base != diffTied)
    }

    @Test
    func init_storesValues() {
        let pitch = ABCPitch(letter: .f, accidental: .sharp, octave: 5)
        let duration = makeDuration(3, 8)
        let note = ABCNote(pitch: pitch, duration: duration, isTied: true)

        #expect(note.pitch == pitch)
        #expect(note.duration == duration)
        #expect(note.isTied)
    }
}
