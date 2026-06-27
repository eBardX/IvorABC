// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCTunebookTests {
}

// MARK: -

extension ABCTunebookTests {
    @Test
    func equality() {
        let tune = makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])
        let a = makeTunebook(.v2_1, [tune])
        let b = makeTunebook(.v2_1, [tune])

        #expect(a == b)
    }

    @Test
    func equality_ignoresIsNormalized() {
        let tune = makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])
        let unnormalized = makeTunebook(.v2_1, [tune])
        let normalized = unnormalized.normalized()

        #expect(unnormalized == normalized)
    }

    @Test
    func inequality() {
        let tune = makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])

        #expect(makeTunebook(.v2_1, [tune]) !=
                makeTunebook(.v2_0, [tune]))

        let header = ABCHeaderEntry.field(.composer("Bach"))

        #expect(makeTunebook(.v2_1, [tune]) !=
                makeTunebook(.v2_1, [header], [tune]))
    }

    @Test
    func isNormalized_publicInit_isFalse() {
        let tunebook = makeTunebook(.v2_1, [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(!tunebook.isNormalized)
    }

    @Test
    func isValidated_publicInit_isFalse() {
        let tunebook = makeTunebook(.v2_1, [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(!tunebook.isValidated)
    }

    @Test
    func init_withEmptyTunes_returnsNil() {
        #expect(ABCTunebook(version: .v2_1,
                            fileHeader: [],
                            tunes: []) == nil)
    }

    @Test
    func init_storesValues() {
        let header = ABCHeaderEntry.field(.composer("J.S. Bach"))
        let tune = makeTune(header: [.field(.tuneTitle("Test"))])
        let tunebook = makeTunebook(.v2_1, [header], [tune])

        #expect(tunebook.version == .v2_1)
        #expect(tunebook.fileHeader == [header])
        #expect(tunebook.tunes == [tune])
        #expect(!tunebook.isNormalized)
        #expect(!tunebook.isValidated)
    }
}
