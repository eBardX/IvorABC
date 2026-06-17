// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCTunebookMigrateTests {
}

// MARK: -

extension ABCTunebookMigrateTests {
    @Test
    func migrated_fromV20_returnsCurrentVersion() {
        let v20 = makeVersion(2, 0)
        let current = ABCVersion.current
        let tunebook = makeTunebook(v20,
                                    [makeTune([.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.migrate().version == current)
    }

    @Test
    func migrated_preservesHeadersAndTunes() {
        let v20 = makeVersion(2, 0)
        let header = ABCHeader.field(.composer("J.S. Bach"))
        let tune = makeTune([.field(.title("Test"))])
        let tunebook = makeTunebook(v20, [header], [tune])
        let migrated = tunebook.migrate()

        #expect(migrated.headers == [header])
        #expect(migrated.tunes == [tune])
    }

    @Test
    func migrated_fromCurrentVersion_isNoOp() {
        let current = ABCVersion.current
        let tunebook = makeTunebook(current,
                                    [makeTune([.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.migrate() == tunebook)
    }

    @Test
    func migrated_fromV16_returnsCurrentVersion() {
        let v16 = makeVersion(1, 6)
        let tunebook = makeTunebook(v16,
                                    [makeTune([.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.migrate().version == ABCVersion.current)
    }

    @Test
    func migrated_fromV16_elemskipBecomesRemark() {
        let v16 = makeVersion(1, 6)
        let tune = makeTune([.field(.elemskip(.integer(3)))])
        let tunebook = makeTunebook(v16, [tune])
        let migrated = tunebook.migrate()

        #expect(migrated.tunes.first?.entries.contains(.field(.remark("3"))) == true)
        #expect(migrated.tunes.first?.entries.contains(.field(.elemskip(.integer(3)))) == false)
    }

    @Test
    func migrated_fromV16_headerInformationBecomesRemark() {
        let v16 = makeVersion(1, 6)
        let tunebook = makeTunebook(v16,
                                    [.field(.information("some info"))],
                                    [makeTune([.field(.key(makeKeySignature(.c, .major)))])])
        let migrated = tunebook.migrate()

        #expect(migrated.headers.contains(.field(.remark("some info"))) == true)
        #expect(migrated.headers.contains(.field(.information("some info"))) == false)
    }

    @Test
    func migrated_fromV16_tempoLegacyFlagCleared() {
        let v16 = makeVersion(1, 6)
        let dottedQuarter = makeDuration(3, 8)
        let legacyTempo = ABCTempo(durations: [dottedQuarter], rate: 40, text: nil, legacyBeatMultiple: 3)
        let tune = makeTune([.field(.tempo(legacyTempo))])
        let tunebook = makeTunebook(v16, [tune])
        let migrated = tunebook.migrate()

        let migratedTempo = migrated.tunes.first?.entries.compactMap { entry -> ABCTempo? in
            guard case let .field(f) = entry, case let .tempo(t) = f
            else { return nil }

            return t
        }.first

        #expect(migratedTempo?.legacyBeatMultiple == nil)
        #expect(migratedTempo?.durations == [dottedQuarter])
        #expect(migratedTempo?.rate == 40)
    }
}
