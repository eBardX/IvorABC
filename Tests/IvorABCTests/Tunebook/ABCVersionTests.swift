// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCVersionTests {
}

// MARK: -

extension ABCVersionTests {
    @Test
    func current() {
        #expect(ABCVersion.current == .v2_1)
    }

    @Test
    func supported() {
        #expect(ABCVersion.supported == [.v1_6, .v2_0, .v2_1])
    }

    @Test
    func init_storesValues() {
        let version = makeVersion(3, 5)

        #expect(version.major == 3)
        #expect(version.minor == 5)
    }

    @Test
    func lessThan_sameMajorLesserMinor_returnsTrue() {
        #expect(makeVersion(2, 0) < .v2_1)
    }

    @Test
    func lessThan_sameMajorGreaterMinor_returnsFalse() {
        #expect(!(makeVersion(2, 1) < .v2_0))
    }

    @Test
    func lessThan_equalVersions_returnsFalse() {
        #expect(!(makeVersion(2, 1) < .v2_1))
    }

    @Test
    func lessThan_lesserMajorHigherMinor_returnsTrue() {
        #expect(makeVersion(1, 6) < .v2_0)
    }

    @Test
    func lessThan_greaterMajorLowerMinor_returnsFalse() {
        #expect(!(makeVersion(2, 0) < .v1_6))
    }

    @Test
    func greaterThan_greaterMinor_returnsTrue() {
        #expect(makeVersion(2, 1) > .v2_0)
    }

    @Test
    func lessThanOrEqual_equalVersions_returnsTrue() {
        #expect(makeVersion(2, 1) <= .v2_1)
    }

    @Test
    func greaterThanOrEqual_equalVersions_returnsTrue() {
        #expect(makeVersion(2, 1) >= .v2_1)
    }
}
