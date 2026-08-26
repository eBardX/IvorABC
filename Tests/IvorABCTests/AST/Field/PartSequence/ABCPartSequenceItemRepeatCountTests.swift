// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCPartSequenceItemRepeatCountTests {
}

// MARK: -

extension ABCPartSequenceItemRepeatCountTests {
    @Test
    func equality() {
        let a: ABCPartSequence.Item.RepeatCount = 3
        let b: ABCPartSequence.Item.RepeatCount = 3

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a: ABCPartSequence.Item.RepeatCount = 2
        let b: ABCPartSequence.Item.RepeatCount = 3

        #expect(a != b)
    }

    @Test
    func init_nilForZero() {
        #expect(ABCPartSequence.Item.RepeatCount(uintValue: 0) == nil)
    }

    @Test
    func init_storesUIntValue() {
        let count = ABCPartSequence.Item.RepeatCount(uintValue: 3)

        #expect(count?.uintValue == 3)
    }

    @Test
    func integerLiteral() {
        let count: ABCPartSequence.Item.RepeatCount = 5

        #expect(count.uintValue == 5)
    }

    @Test
    func isValid_positiveValuesAreValid() {
        #expect(ABCPartSequence.Item.RepeatCount.isValid(1))
        #expect(ABCPartSequence.Item.RepeatCount.isValid(100))
    }

    @Test
    func isValid_zeroIsInvalid() {
        #expect(!ABCPartSequence.Item.RepeatCount.isValid(0))
    }
}
