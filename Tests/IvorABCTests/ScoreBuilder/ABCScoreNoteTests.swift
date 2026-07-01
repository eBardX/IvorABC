// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCScoreNoteTests {
}

// MARK: -

extension ABCScoreNoteTests {
    @Test
    func equality() {
        let pitch = makePitch(.c, .sharp, 4)
        let duration = makeScoreDuration(1, 4)
        let a = makeScoreNote(pitch, duration)
        let b = makeScoreNote(pitch, duration)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let pitch = makePitch(.c, .sharp, 4)
        let duration = makeScoreDuration(1, 4)
        let base = makeScoreNote(pitch, duration)

        let diffPitch = makeScoreNote(makePitch(.d, .sharp, 4), duration)
        let diffDuration = makeScoreNote(pitch, makeScoreDuration(1, 8))
        let diffTie = makeScoreNote(pitch, duration, .regular)
        let diffSlurStart = makeScoreNote(pitch, duration, slurStart: true)
        let diffSlurEnd = makeScoreNote(pitch, duration, slurEnd: true)

        #expect(base != diffPitch)
        #expect(base != diffDuration)
        #expect(base != diffTie)
        #expect(base != diffSlurStart)
        #expect(base != diffSlurEnd)
    }

    @Test
    func init_storesValues() {
        let pitch = makePitch(.f, .natural, 5)
        let duration = makeScoreDuration(3, 8)
        let note = ABCScoreNote(pitch: pitch,
                                duration: duration,
                                tie: .regular,
                                slurStart: true,
                                slurEnd: true)

        #expect(note?.pitch == pitch)
        #expect(note?.duration == duration)
        #expect(note?.tie == .regular)
        #expect(note?.slurStart == true)
        #expect(note?.slurEnd == true)
    }

    @Test
    func init_defaultsTieAndSlurFlags() {
        let note = makeScoreNote(makePitch(.c, .natural, 4),
                                 makeScoreDuration(1, 4))

        #expect(note.tie == nil)
        #expect(note.slurStart == false)
        #expect(note.slurEnd == false)
    }

    @Test
    func init_withOmittedAccidentalReturnsNil() {
        let pitch = makePitch(.c, .omitted, 4)

        #expect(ABCScoreNote(pitch: pitch,
                             duration: makeScoreDuration(1, 4)) == nil)
    }
}
