// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCNoteTests {
}

// MARK: -

extension ABCNoteTests {
    @Test
    func equality() {
        let pitch = makePitch(.c, .omitted, 4)
        let duration = makeDuration(1, 4)
        let a = makeNote(pitch, duration)
        let b = makeNote(pitch, duration)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let pitch = makePitch(.c, .omitted, 4)
        let duration = makeDuration(1, 4)
        let base = makeNote(pitch, duration)

        let diffPitch = makeNote(makePitch(.d, .omitted, 4), duration)
        let diffDuration = makeNote(pitch, makeDuration(1, 8))
        let diffTie = makeNote(pitch, duration, .regular)

        #expect(base != diffPitch)
        #expect(base != diffDuration)
        #expect(base != diffTie)
    }

    @Test
    func init_storesValues() {
        let pitch = makePitch(.f, .sharp, 5)
        let duration = makeDuration(3, 8)
        let note = makeNote(pitch, duration, .regular)

        #expect(note.pitch == pitch)
        #expect(note.duration == duration)
        #expect(note.tie == .regular)
    }
}
