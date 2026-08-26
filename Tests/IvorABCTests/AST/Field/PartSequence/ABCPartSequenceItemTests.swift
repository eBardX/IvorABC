// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCPartSequenceItemTests {
}

// MARK: -

extension ABCPartSequenceItemTests {
    @Test
    func equality_group() {
        let a = makePartGroup([makePart(.a)], 2)
        let b = makePartGroup([makePart(.a)], 2)

        #expect(a == b)
    }

    @Test
    func equality_part() {
        let a = makePart(.a, 2)
        let b = makePart(.a, 2)

        #expect(a == b)
    }

    @Test
    func inequality_differentCount() {
        let a = makePart(.a, 1)
        let b = makePart(.a, 2)

        #expect(a != b)
    }

    @Test
    func inequality_differentPart() {
        let a = makePart(.a)
        let b = makePart(.b)

        #expect(a != b)
    }

    @Test
    func inequality_groupVsPart() {
        let a = makePartGroup([makePart(.a)])
        let b = makePart(.a)

        #expect(a != b)
    }

    @Test
    func inequality_nestedGroupContents() {
        let a = makePartGroup([makePart(.a), makePart(.b)])
        let b = makePartGroup([makePart(.a), makePart(.c)])

        #expect(a != b)
    }
}
