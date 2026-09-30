// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCProcessFunctionsTests {
}

// MARK: -

extension ABCProcessFunctionsTests {
    @Test
    func makeTunebook_bodyContinuationMergesIntoPrecedingTextField() throws {
        let policy = ABCParser.Policy(version: .current)
        let lines: [ABCParser.Line] = [.field(.referenceNumber(makeReferenceNumber(1))),
                                       .field(.tuneTitle("Test")),
                                       .field(.key(makeKeySignature(.c, .major))),
                                       .field(.notes("first")),
                                       .continuation("second")]
        let tunebook = try makeTunebook(.current, policy, lines)
        let notes = tunebook.tunes[0].body.compactMap { entry -> String? in
            guard case let .field(.notes(text)) = entry
            else { return nil }

            return text.stringValue
        }.first

        #expect(notes == "first second")
    }

    @Test
    func makeTunebook_isNotNormalized() throws {
        let policy = ABCParser.Policy(version: .current)
        let lines: [ABCParser.Line] = [.field(.referenceNumber(makeReferenceNumber(1))),
                                       .field(.tuneTitle("Test")),
                                       .field(.key(makeKeySignature(.c, .major)))]
        let tunebook = try makeTunebook(.current, policy, lines)

        #expect(!tunebook.isNormalized)
    }

    @Test
    func makeTunebook_missingTunesThrows() {
        let policy = ABCParser.Policy(version: .current)
        let lines: [ABCParser.Line] = []

        #expect(throws: ABCParser.Error.missingTunes) {
            try makeTunebook(.current, policy, lines)
        }
    }

    @Test
    func makeTunebook_orphanedContinuationInStrictModeThrows() {
        let policy = ABCParser.Policy(version: .current)
        let lines: [ABCParser.Line] = [.field(.referenceNumber(makeReferenceNumber(1))),
                                       .field(.tuneTitle("Test")),
                                       .field(.key(makeKeySignature(.c, .major))),
                                       .continuation("orphan")]

        #expect(throws: ABCParser.Error.orphanedContinuation) {
            try makeTunebook(.current, policy, lines)
        }
    }

    @Test
    func makeTunebook_singlePartSequenceCollapsesToPartField() throws {
        let policy = ABCParser.Policy(version: .current)
        let lines: [ABCParser.Line] = [.field(.referenceNumber(makeReferenceNumber(1))),
                                       .field(.tuneTitle("Test")),
                                       .field(.key(makeKeySignature(.c, .major))),
                                       .field(.parts(makePartSequence([makePart(.a)])))]
        let tunebook = try makeTunebook(.current, policy, lines)

        expectFieldIsPart(tunebook.tunes[0].body.compactMap { entry -> ABCField? in
            guard case let .field(field) = entry
            else { return nil }

            return field
        }.first.require(),
                          .a)
    }
}
