// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCPartSequenceTests {
}

// MARK: -

extension ABCPartSequenceTests {
    @Test
    func equality() {
        let ps1 = makePartSequence([makePart("A"), makePart("B")])
        let ps2 = makePartSequence([makePart("A"), makePart("B")])

        #expect(ps1 == ps2)
    }

    @Test
    func expansion_empty() {
        #expect(makePartSequence([]).expansion.isEmpty)
    }

    @Test
    func expansion_group() {
        #expect(makePartSequence([makePart("A"), makePartGroup([makePart("C"), makePart("D")], 3)]).expansion == "ACDCDCD")
    }

    @Test
    func expansion_nestedGroups() {
        // (A(BC)2)3 → ABCBCABCBCABCBC
        let inner = makePartGroup([makePart("B"), makePart("C")], 2)
        let outer = makePartGroup([makePart("A"), inner], 3)

        #expect(makePartSequence([outer]).expansion == "ABCBCABCBCABCBC")
    }

    @Test
    func expansion_repeatCounts() {
        #expect(makePartSequence([makePart("A", 2), makePart("B", 3)]).expansion == "AABBB")
    }

    @Test
    func expansion_sequence() {
        #expect(makePartSequence([makePart("A"), makePart("B"), makePart("A"), makePart("B")]).expansion == "ABAB")
    }

    @Test
    func expansion_singleLetter() {
        #expect(makePartSequence([makePart("A")]).expansion == "A")
    }

    @Test
    func expansion_zeroCount_producesNothing() {
        #expect(makePartSequence([makePart("A", 0)]).expansion.isEmpty)
        #expect(makePartSequence([makePartGroup([makePart("A"), makePart("B")], 0)]).expansion.isEmpty)
    }

    @Test
    func inequality_differentCount() {
        let ps1 = makePartSequence([makePart("A")])
        let ps2 = makePartSequence([makePart("A"), makePart("B")])

        #expect(ps1 != ps2)
    }

    @Test
    func inequality_differentItems() {
        let ps1 = makePartSequence([makePart("A"), makePart("B")])
        let ps2 = makePartSequence([makePart("A"), makePart("C")])

        #expect(ps1 != ps2)
    }

    @Test
    func item_equality_crossCase() {
        #expect(makePart("A", 1) != makePartGroup([makePart("A")], 1))
    }

    @Test
    func item_equality_group() {
        let lhs = makePartGroup([makePart("A")], 3)
        let rhs = makePartGroup([makePart("A")], 3)

        #expect(lhs == rhs)
        #expect(lhs != makePartGroup([makePart("A")], 2))
        #expect(lhs != makePartGroup([makePart("B")], 3))
    }

    @Test
    func item_equality_part() {
        let lhs = makePart("A", 2)
        let rhs = makePart("A", 2)

        #expect(lhs == rhs)
        #expect(lhs != makePart("A", 1))
        #expect(lhs != makePart("B", 2))
    }

    @Test
    func items_empty() {
        #expect(makePartSequence([]).items.isEmpty)
    }

    @Test
    func items_mixed() {
        let items: [ABCPartSequence.Item] = [makePart("A"), makePartGroup([makePart("B"), makePart("C")], 2)]
        let ps = makePartSequence(items)

        #expect(ps.items == items)
    }

    @Test
    func parsePartSequence_empty() {
        #expect(IvorABC.parsePartSequence("") == makePartSequence([]))
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
        #expect(IvorABC.parsePartSequence("A(BC)3") == makePartSequence([makePart("A"),
                                                              makePartGroup([makePart("B"),
                                                                       makePart("C")], 3)]))
    }

    @Test
    func parsePartSequence_groupNoCount() {
        #expect(IvorABC.parsePartSequence("(AB)") == makePartSequence([makePartGroup([makePart("A"),
                                                                     makePart("B")])]))
    }

    @Test
    func parsePartSequence_multidigitCount() {
        #expect(IvorABC.parsePartSequence("A12") == makePartSequence([makePart("A", 12)]))
    }

    @Test
    func parsePartSequence_nestedGroups() {
        // P:(A(BC)2)3  →  [group([part(A,1), group([part(B,1), part(C,1)], 2)], 3)]
        let inner = makePartGroup([makePart("B"), makePart("C")], 2)
        let outer = makePartGroup([makePart("A"), inner], 3)

        #expect(IvorABC.parsePartSequence("(A(BC)2)3") == makePartSequence([outer]))
    }

    @Test
    func parsePartSequence_repeatCounts() {
        #expect(IvorABC.parsePartSequence("A2B3") == makePartSequence([makePart("A", 2),
                                                            makePart("B", 3)]))
    }

    @Test
    func parsePartSequence_sequence() {
        #expect(IvorABC.parsePartSequence("ABAB") == makePartSequence([makePart("A"),
                                                            makePart("B"),
                                                            makePart("A"),
                                                            makePart("B")]))
    }

    @Test
    func parsePartSequence_singleLetter() {
        #expect(IvorABC.parsePartSequence("A") == makePartSequence([makePart("A")]))
    }

    @Test
    func parsePartSequence_whitespaceAroundGroup() {
        let expected = makePartSequence([makePart("A"),
                              makePartGroup([makePart("B"),
                                       makePart("C")], 2)])

        #expect(IvorABC.parsePartSequence("A ( B C )2") == expected)
    }

    @Test
    func parsePartSequence_whitespaceIgnored() {
        #expect(IvorABC.parsePartSequence("A B C") == makePartSequence([makePart("A"),
                                                             makePart("B"),
                                                             makePart("C")]))
    }
}
