// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCVersionTests {
}

// MARK: -

extension ABCVersionTests {
    @Test
    func test_currentMajor() {
        #expect(ABCVersion.currentMajor == 2)
    }

    @Test
    func test_currentMinor() {
        #expect(ABCVersion.currentMinor == 1)
    }

    @Test
    func test_initStoresValues() {
        let version = ABCVersion(major: 3,
                                 minor: 5)

        #expect(version.major == 3)
        #expect(version.minor == 5)
    }
}
