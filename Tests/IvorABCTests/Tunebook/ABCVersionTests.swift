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

    @Test
    func lessThan_sameMajorLesserMinor_returnsTrue() {
        #expect(makeVersion(2, 0) < makeVersion(2, 1))
    }

    @Test
    func lessThan_sameMajorGreaterMinor_returnsFalse() {
        #expect(!(makeVersion(2, 1) < makeVersion(2, 0)))
    }

    @Test
    func lessThan_equalVersions_returnsFalse() {
        let v = makeVersion(2, 1)

        #expect(!(v < makeVersion(2, 1)))
    }

    @Test
    func lessThan_lesserMajorHigherMinor_returnsTrue() {
        #expect(makeVersion(1, 6) < makeVersion(2, 0))
    }

    @Test
    func lessThan_greaterMajorLowerMinor_returnsFalse() {
        #expect(!(makeVersion(2, 0) < makeVersion(1, 6)))
    }

    @Test
    func greaterThan_greaterMinor_returnsTrue() {
        #expect(makeVersion(2, 1) > makeVersion(2, 0))
    }

    @Test
    func lessThanOrEqual_equalVersions_returnsTrue() {
        let v = makeVersion(2, 1)

        #expect(v <= makeVersion(2, 1))
    }

    @Test
    func greaterThanOrEqual_equalVersions_returnsTrue() {
        let v = makeVersion(2, 1)

        #expect(v >= makeVersion(2, 1))
    }
}
