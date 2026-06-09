// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCFileIDTests {
}

// MARK: -

extension ABCFileIDTests {
    @Test
    func equality() {
        let v = ABCVersion(major: 2, minor: 1)
        let a = ABCFileID(version: v)
        let b = ABCFileID(version: v)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a = ABCFileID(version: ABCVersion(major: 2, minor: 1))
        let b = ABCFileID(version: ABCVersion(major: 2, minor: 0))

        #expect(a != b)
    }

    @Test
    func init_storesVersion() {
        let version = ABCVersion(major: 2, minor: 1)
        let fileID = ABCFileID(version: version)

        #expect(fileID.version == version)
    }
}
