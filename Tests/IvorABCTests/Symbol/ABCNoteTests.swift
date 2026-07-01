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
        let length = makeLength(1, 4)
        let a = makeNote(pitch, length)
        let b = makeNote(pitch, length)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let pitch = makePitch(.c, .omitted, 4)
        let length = makeLength(1, 4)
        let base = makeNote(pitch, length)

        let diffPitch = makeNote(makePitch(.d, .omitted, 4), length)
        let diffLength = makeNote(pitch, makeLength(1, 8))
        let diffTie = makeNote(pitch, length, .regular)

        #expect(base != diffPitch)
        #expect(base != diffLength)
        #expect(base != diffTie)
    }

    @Test
    func init_storesValues() {
        let pitch = makePitch(.f, .sharp, 5)
        let length = makeLength(3, 8)
        let note = makeNote(pitch, length, .regular)

        #expect(note.pitch == pitch)
        #expect(note.length == length)
        #expect(note.tie == .regular)
    }
}
