// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCVersionTests {
}

// MARK: -

extension ABCVersionTests {
    @Test
    func current() {
        #expect(ABCVersion.current == makeVersion(2, 1))
    }

    @Test
    func supported() {
        #expect(ABCVersion.supported == [makeVersion(1, 6),
                                         makeVersion(2, 0),
                                         makeVersion(2, 1)])
    }

    @Test
    func init_storesValues() {
        let version = makeVersion(3, 5)

        #expect(version.major == 3)
        #expect(version.minor == 5)
    }
}
