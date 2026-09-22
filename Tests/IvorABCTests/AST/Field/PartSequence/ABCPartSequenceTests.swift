// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCPartSequenceTests {
}

// MARK: -

extension ABCPartSequenceTests {
    @Test
    func equality() {
        let ps1 = makePartSequence([makePart(.a), makePart(.b)])
        let ps2 = makePartSequence([makePart(.a), makePart(.b)])

        #expect(ps1 == ps2)
    }

    @Test
    func expansion_group() {
        #expect(makePartSequence([makePart(.a), makePartGroup([makePart(.c), makePart(.d)], 3)]).expansion == "ACDCDCD")
    }

    @Test
    func expansion_nestedGroups() {
        // (A(BC)2)3 → ABCBCABCBCABCBC
        let inner = makePartGroup([makePart(.b), makePart(.c)], 2)
        let outer = makePartGroup([makePart(.a), inner], 3)

        #expect(makePartSequence([outer]).expansion == "ABCBCABCBCABCBC")
    }

    @Test
    func expansion_repeatCounts() {
        #expect(makePartSequence([makePart(.a, 2), makePart(.b, 3)]).expansion == "AABBB")
    }

    @Test
    func expansion_sequence() {
        #expect(makePartSequence([makePart(.a), makePart(.b), makePart(.a), makePart(.b)]).expansion == "ABAB")
    }

    @Test
    func expansion_singleLetter() {
        #expect(makePartSequence([makePart(.a)]).expansion == "A")
    }

    @Test
    func inequality_differentCount() {
        let ps1 = makePartSequence([makePart(.a)])
        let ps2 = makePartSequence([makePart(.a), makePart(.b)])

        #expect(ps1 != ps2)
    }

    @Test
    func inequality_differentItems() {
        let ps1 = makePartSequence([makePart(.a), makePart(.b)])
        let ps2 = makePartSequence([makePart(.a), makePart(.c)])

        #expect(ps1 != ps2)
    }

    @Test
    func item_equality_crossCase() {
        #expect(makePart(.a, 1) != makePartGroup([makePart(.a)], 1))
    }

    @Test
    func item_equality_group() {
        let lhs = makePartGroup([makePart(.a)], 3)
        let rhs = makePartGroup([makePart(.a)], 3)

        #expect(lhs == rhs)
        #expect(lhs != makePartGroup([makePart(.a)], 2))
        #expect(lhs != makePartGroup([makePart(.b)], 3))
    }

    @Test
    func item_equality_part() {
        let lhs = makePart(.a, 2)
        let rhs = makePart(.a, 2)

        #expect(lhs == rhs)
        #expect(lhs != makePart(.a, 1))
        #expect(lhs != makePart(.b, 2))
    }

    @Test
    func items_mixed() {
        let items: [ABCPartSequence.Item] = [makePart(.a), makePartGroup([makePart(.b), makePart(.c)], 2)]
        let ps = makePartSequence(items)

        #expect(ps.items == items)
    }

    @Test
    func parsePartSequence_failure_empty() {
        #expect(IvorABC.parsePartSequence("") == nil)
    }

    @Test
    func parsePartSequence_failure_invalidCharacter() {
        #expect(IvorABC.parsePartSequence("!") == nil)
        #expect(IvorABC.parsePartSequence("A!B") == nil)
    }

    @Test
    func parsePartSequence_failure_lowercaseLetter() {
        #expect(IvorABC.parsePartSequence("a") == nil)
    }

    @Test
    func parsePartSequence_failure_unmatchedCloseParen() {
        #expect(IvorABC.parsePartSequence("AB)") == nil)
    }

    @Test
    func parsePartSequence_failure_unmatchedOpenParen() {
        #expect(IvorABC.parsePartSequence("(AB") == nil)
    }

    @Test
    func parsePartSequence_group() {
        #expect(IvorABC.parsePartSequence("A(BC)3") == makePartSequence([makePart(.a),
                                                                         makePartGroup([makePart(.b),
                                                                                        makePart(.c)], 3)]))
    }

    @Test
    func parsePartSequence_groupNoCount() {
        #expect(IvorABC.parsePartSequence("(AB)") == makePartSequence([makePartGroup([makePart(.a),
                                                                                      makePart(.b)])]))
    }

    @Test
    func parsePartSequence_multidigitCount() {
        #expect(IvorABC.parsePartSequence("A12") == makePartSequence([makePart(.a, 12)]))
    }

    @Test
    func parsePartSequence_nestedGroups() {
        // P:(A(BC)2)3  →  [group([part(A,1), group([part(B,1), part(C,1)], 2)], 3)]
        let inner = makePartGroup([makePart(.b), makePart(.c)], 2)
        let outer = makePartGroup([makePart(.a), inner], 3)

        #expect(IvorABC.parsePartSequence("(A(BC)2)3") == makePartSequence([outer]))
    }

    @Test
    func parsePartSequence_repeatCounts() {
        #expect(IvorABC.parsePartSequence("A2B3") == makePartSequence([makePart(.a, 2),
                                                                       makePart(.b, 3)]))
    }

    @Test
    func parsePartSequence_sequence() {
        #expect(IvorABC.parsePartSequence("ABAB") == makePartSequence([makePart(.a),
                                                                       makePart(.b),
                                                                       makePart(.a),
                                                                       makePart(.b)]))
    }

    @Test
    func parsePartSequence_singleLetter() {
        #expect(IvorABC.parsePartSequence("A") == makePartSequence([makePart(.a)]))
    }

    @Test
    func parsePartSequence_whitespaceAroundGroup() {
        let expected = makePartSequence([makePart(.a),
                                         makePartGroup([makePart(.b),
                                                        makePart(.c)], 2)])

        #expect(IvorABC.parsePartSequence("A ( B C )2") == expected)
    }

    @Test
    func parsePartSequence_whitespaceIgnored() {
        #expect(IvorABC.parsePartSequence("A B C") == makePartSequence([makePart(.a),
                                                                        makePart(.b),
                                                                        makePart(.c)]))
    }
}
