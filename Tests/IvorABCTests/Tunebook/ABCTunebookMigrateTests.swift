// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCTunebookMigrateTests {
}

// MARK: -

extension ABCTunebookMigrateTests {
    @Test
    func migrated_fromCurrentVersion_isNoOp() {
        let tunebook = makeTunebook(.current,
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.migrate() == tunebook)
    }

    @Test
    func migrated_fromV16_elemskipBecomesRemark() {
        let tune = makeTune(header: [.field(.elemskip(.integer(3)))])
        let tunebook = makeTunebook(.v1_6, [tune])
        let migrated = tunebook.migrate()

        #expect(migrated.tunes.first?.header.contains(.field(.remark("3"))) == true)
        #expect(migrated.tunes.first?.header.contains(.field(.elemskip(.integer(3)))) == false)
    }

    @Test
    func migrated_fromV16_headerInformationBecomesRemark() {
        let tunebook = makeTunebook(.v1_6,
                                    [.field(.information("some info"))],
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])
        let migrated = tunebook.migrate()

        #expect(migrated.fileHeader.contains(.field(.remark("some info"))) == true)
        #expect(migrated.fileHeader.contains(.field(.information("some info"))) == false)
    }

    @Test
    func migrated_fromV16_returnsCurrentVersion() {
        let tunebook = makeTunebook(.v1_6,
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.migrate().version == .current)
    }

    @Test
    func migrated_fromV16_tempoLegacyFlagCleared() {
        let dottedQuarter = makeDuration(3, 8)
        let legacyTempo = ABCTempo(durations: [dottedQuarter], rate: 40, text: nil, legacyBeatMultiple: 3).require()
        let tune = makeTune(header: [.field(.tempo(legacyTempo))])
        let tunebook = makeTunebook(.v1_6, [tune])
        let migrated = tunebook.migrate()

        let migratedTempo = migrated.tunes.first?.header.compactMap { entry -> ABCTempo? in
            guard case let .field(f) = entry,
                  case let .tempo(t) = f
            else { return nil }

            return t
        }.first

        #expect(migratedTempo?.legacyBeatMultiple == nil)
        #expect(migratedTempo?.durations == [dottedQuarter])
        #expect(migratedTempo?.rate == 40)
    }

    @Test
    func migrated_fromV20_returnsCurrentVersion() {
        let current = ABCVersion.current
        let tunebook = makeTunebook(.v2_0,
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.migrate().version == current)
    }

    @Test
    func migrated_preservesFileHeaderAndTunes() {
        let fileHeader = ABCHeaderEntry.field(.composer("J.S. Bach"))
        let tune = makeTune(header: [.field(.tuneTitle("Test"))])
        let tunebook = makeTunebook(.v2_0, [fileHeader], [tune])
        let migrated = tunebook.migrate()

        #expect(migrated.fileHeader == [fileHeader])
        #expect(migrated.tunes == [tune])
    }
}
