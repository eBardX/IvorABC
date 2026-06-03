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
