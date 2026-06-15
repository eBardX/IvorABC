// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCFileIDTests {
}

// MARK: -

extension ABCFileIDTests {
    @Test
    func equality() {
        let v = makeVersion(2, 1)
        let a = makeFileID(v)
        let b = makeFileID(v)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a = makeFileID(makeVersion(2, 1))
        let b = makeFileID(makeVersion(2, 0))

        #expect(a != b)
    }

    @Test
    func init_storesVersion() {
        let version = makeVersion(2, 1)
        let fileID = makeFileID(version)

        #expect(fileID.version == version)
    }
}
