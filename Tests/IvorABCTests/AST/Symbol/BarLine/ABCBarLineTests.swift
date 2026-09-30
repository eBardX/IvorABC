// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCBarLineTests {
}

// MARK: -

extension ABCBarLineTests {
    @Test
    func equality() {
        let a = makeBarLine(.double)
        let b = makeBarLine(.double)

        #expect(a == b)
    }

    @Test
    func inequality_differentDotted() {
        let a = makeBarLine(isDotted: true)
        let b = makeBarLine(isDotted: false)

        #expect(a != b)
    }

    @Test
    func inequality_differentKind() {
        let a = makeBarLine(.double)
        let b = makeBarLine(.end)

        #expect(a != b)
    }

    @Test
    func inequality_differentPlayCounts() {
        let a = makeBarLine(.repeat, precedingPlayCount: 2, followingPlayCount: 1)
        let b = makeBarLine(.repeat, precedingPlayCount: 3, followingPlayCount: 1)

        #expect(a != b)
    }

    @Test
    func init_nilForNonRepeatWithFollowingPlayCountGreaterThanOne() {
        let barLine = ABCBarLine(kind: .standard,
                                 precedingPlayCount: 1,
                                 followingPlayCount: 2,
                                 isDotted: false)

        #expect(barLine == nil)
    }

    @Test
    func init_nilForNonRepeatWithPrecedingPlayCountGreaterThanOne() {
        let barLine = ABCBarLine(kind: .standard,
                                 precedingPlayCount: 2,
                                 followingPlayCount: 1,
                                 isDotted: false)

        #expect(barLine == nil)
    }

    @Test
    func init_nilForRepeatWithBothPlayCountsOne() {
        let barLine = ABCBarLine(kind: .repeat,
                                 precedingPlayCount: 1,
                                 followingPlayCount: 1,
                                 isDotted: false)

        #expect(barLine == nil)
    }

    @Test
    func init_storesPropertiesWithDefaults() {
        let barLine = ABCBarLine(kind: .standard)

        #expect(barLine?.kind == .standard)
        #expect(barLine?.precedingPlayCount == 1)
        #expect(barLine?.followingPlayCount == 1)
        #expect(barLine?.isDotted == false)
    }

    @Test
    func init_succeedsForRepeatWithFollowingPlayCountGreaterThanOne() {
        let barLine = ABCBarLine(kind: .repeat,
                                 precedingPlayCount: 1,
                                 followingPlayCount: 2,
                                 isDotted: false)

        #expect(barLine != nil)
    }

    @Test
    func init_succeedsForRepeatWithPrecedingPlayCountGreaterThanOne() {
        let barLine = ABCBarLine(kind: .repeat,
                                 precedingPlayCount: 2,
                                 followingPlayCount: 1,
                                 isDotted: false)

        #expect(barLine != nil)
    }
}
