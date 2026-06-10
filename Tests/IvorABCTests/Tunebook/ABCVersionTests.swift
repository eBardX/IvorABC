// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCVersionTests {
}

// MARK: -

extension ABCVersionTests {
    @Test
    func current() {
        #expect(ABCVersion.current == ABCVersion(major: 2, minor: 1))
    }

    @Test
    func supported() {
        #expect(ABCVersion.supported == [ABCVersion(major: 1, minor: 6),
                                         ABCVersion(major: 2, minor: 0),
                                         ABCVersion(major: 2, minor: 1)])
    }

    @Test
    func init_storesValues() {
        let version = ABCVersion(major: 3,
                                 minor: 5)

        #expect(version.major == 3)
        #expect(version.minor == 5)
    }
}
