// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCTunebookTests {
}

// MARK: -

extension ABCTunebookTests {
    @Test
    func equality() {
        let version = ABCVersion(major: 2, minor: 1)
        let a = ABCTunebook(version: version, headers: [], tunes: [])
        let b = ABCTunebook(version: version, headers: [], tunes: [])

        #expect(a == b)
    }

    @Test
    func inequality() {
        let v21 = ABCVersion(major: 2, minor: 1)
        let v20 = ABCVersion(major: 2, minor: 0)

        #expect(ABCTunebook(version: v21, headers: [], tunes: []) !=
                ABCTunebook(version: v20, headers: [], tunes: []))

        let header = ABCHeader.field(.composer("Bach"))

        #expect(ABCTunebook(version: v21, headers: [], tunes: []) !=
                ABCTunebook(version: v21, headers: [header], tunes: []))
    }

    @Test
    func migrated_fromV20_returnsCurrentVersion() {
        let v20 = ABCVersion(major: 2, minor: 0)
        let current = ABCVersion.current
        let tunebook = ABCTunebook(version: v20, headers: [], tunes: [])

        #expect(tunebook.migrated().version == current)
    }

    @Test
    func migrated_preservesHeadersAndTunes() {
        let v20 = ABCVersion(major: 2, minor: 0)
        let header = ABCHeader.field(.composer("J.S. Bach"))
        let tune = ABCTune(entries: [.field(.title("Test"))])
        let tunebook = ABCTunebook(version: v20, headers: [header], tunes: [tune])
        let migrated = tunebook.migrated()

        #expect(migrated.headers == [header])
        #expect(migrated.tunes == [tune])
    }

    @Test
    func migrated_fromCurrentVersion_isNoOp() {
        let current = ABCVersion.current
        let tunebook = ABCTunebook(version: current, headers: [], tunes: [])

        #expect(tunebook.migrated() == tunebook)
    }

    @Test
    func migrated_fromV16_returnsCurrentVersion() {
        let v16 = ABCVersion(major: 1, minor: 6)
        let tunebook = ABCTunebook(version: v16, headers: [], tunes: [])

        #expect(tunebook.migrated().version == ABCVersion.current)
    }

    @Test
    func migrated_fromV16_legacyFieldBecomesRemark() {
        let v16 = ABCVersion(major: 1, minor: 6)
        let tune = ABCTune(entries: [.field(.legacy("E", "skip value"))])
        let tunebook = ABCTunebook(version: v16, headers: [], tunes: [tune])
        let migrated = tunebook.migrated()

        #expect(migrated.tunes.first?.entries.contains(.field(.remark("skip value"))) == true)
        #expect(migrated.tunes.first?.entries.contains(.field(.legacy("E", "skip value"))) == false)
    }

    @Test
    func migrated_fromV16_headerLegacyFieldBecomesRemark() {
        let v16 = ABCVersion(major: 1, minor: 6)
        let tunebook = ABCTunebook(version: v16,
                                   headers: [.field(.legacy("I", "some info"))],
                                   tunes: [])
        let migrated = tunebook.migrated()

        #expect(migrated.headers.contains(.field(.remark("some info"))) == true)
        #expect(migrated.headers.contains(.field(.legacy("I", "some info"))) == false)
    }

    @Test
    func migrated_fromV16_tempoLegacyFlagCleared() {
        let v16 = ABCVersion(major: 1, minor: 6)
        let dottedQuarter = ABCDuration(numerator: 3, denominator: 8, reduce: false)
        let legacyTempo = ABCTempo(durations: [dottedQuarter], rate: 40, text: nil, legacyBeatMultiple: 3)
        let tune = ABCTune(entries: [.field(.tempo(legacyTempo))])
        let tunebook = ABCTunebook(version: v16, headers: [], tunes: [tune])
        let migrated = tunebook.migrated()

        let migratedTempo = migrated.tunes.first?.entries.compactMap { entry -> ABCTempo? in
            guard case let .field(f) = entry, case let .tempo(t) = f
            else { return nil }

            return t
        }.first

        #expect(migratedTempo?.legacyBeatMultiple == nil)
        #expect(migratedTempo?.durations == [dottedQuarter])
        #expect(migratedTempo?.rate == 40)
    }

    @Test
    func init_storesValues() {
        let version = ABCVersion(major: 2, minor: 1)
        let header = ABCHeader.field(.composer("J.S. Bach"))
        let tune = ABCTune(entries: [.field(.title("Test"))])
        let tunebook = ABCTunebook(version: version,
                                   headers: [header],
                                   tunes: [tune])

        #expect(tunebook.version == version)
        #expect(tunebook.headers == [header])
        #expect(tunebook.tunes == [tune])
    }
}
