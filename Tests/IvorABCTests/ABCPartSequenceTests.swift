// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCPartSequenceTests {
}

// MARK: -

extension ABCPartSequenceTests {
    @Test
    func equality() {
        let ps1 = _pseq([_ppart("A"), _ppart("B")])
        let ps2 = _pseq([_ppart("A"), _ppart("B")])

        #expect(ps1 == ps2)
    }

    @Test
    func expansion_empty() {
        #expect(_pseq().expansion.isEmpty)
    }

    @Test
    func expansion_group() {
        #expect(_pseq([_ppart("A"), _pgroup([_ppart("C"), _ppart("D")], 3)]).expansion == "ACDCDCD")
    }

    @Test
    func expansion_nestedGroups() {
        // (A(BC)2)3 → ABCBCABCBCABCBC
        let inner = _pgroup([_ppart("B"), _ppart("C")], 2)
        let outer = _pgroup([_ppart("A"), inner], 3)

        #expect(_pseq([outer]).expansion == "ABCBCABCBCABCBC")
    }

    @Test
    func expansion_repeatCounts() {
        #expect(_pseq([_ppart("A", 2), _ppart("B", 3)]).expansion == "AABBB")
    }

    @Test
    func expansion_sequence() {
        #expect(_pseq([_ppart("A"), _ppart("B"), _ppart("A"), _ppart("B")]).expansion == "ABAB")
    }

    @Test
    func expansion_singleLetter() {
        #expect(_pseq([_ppart("A")]).expansion == "A")
    }

    @Test
    func expansion_zeroCount_producesNothing() {
        #expect(_pseq([_ppart("A", 0)]).expansion.isEmpty)
        #expect(_pseq([_pgroup([_ppart("A"), _ppart("B")], 0)]).expansion.isEmpty)
    }

    @Test
    func inequality_differentCount() {
        let ps1 = _pseq([_ppart("A")])
        let ps2 = _pseq([_ppart("A"), _ppart("B")])

        #expect(ps1 != ps2)
    }

    @Test
    func inequality_differentItems() {
        let ps1 = _pseq([_ppart("A"), _ppart("B")])
        let ps2 = _pseq([_ppart("A"), _ppart("C")])

        #expect(ps1 != ps2)
    }

    @Test
    func item_equality_crossCase() {
        #expect(_ppart("A", 1) != _pgroup([_ppart("A")], 1))
    }

    @Test
    func item_equality_group() {
        let lhs = _pgroup([_ppart("A")], 3)
        let rhs = _pgroup([_ppart("A")], 3)

        #expect(lhs == rhs)
        #expect(lhs != _pgroup([_ppart("A")], 2))
        #expect(lhs != _pgroup([_ppart("B")], 3))
    }

    @Test
    func item_equality_part() {
        let lhs = _ppart("A", 2)
        let rhs = _ppart("A", 2)

        #expect(lhs == rhs)
        #expect(lhs != _ppart("A", 1))
        #expect(lhs != _ppart("B", 2))
    }

    @Test
    func items_empty() {
        #expect(_pseq().items.isEmpty)
    }

    @Test
    func items_mixed() {
        let items: [ABCPartSequence.Item] = [_ppart("A"), _pgroup([_ppart("B"), _ppart("C")], 2)]
        let ps = _pseq(items)

        #expect(ps.items == items)
    }

    @Test
    func parsePartSequence_empty() {
        #expect(IvorABC.parsePartSequence("") == _pseq())
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
        #expect(IvorABC.parsePartSequence("A(BC)3") == _pseq([_ppart("A"),
                                                              _pgroup([_ppart("B"),
                                                                       _ppart("C")], 3)]))
    }

    @Test
    func parsePartSequence_groupNoCount() {
        #expect(IvorABC.parsePartSequence("(AB)") == _pseq([_pgroup([_ppart("A"),
                                                                     _ppart("B")])]))
    }

    @Test
    func parsePartSequence_multidigitCount() {
        #expect(IvorABC.parsePartSequence("A12") == _pseq([_ppart("A", 12)]))
    }

    @Test
    func parsePartSequence_nestedGroups() {
        // P:(A(BC)2)3  →  [group([part(A,1), group([part(B,1), part(C,1)], 2)], 3)]
        let inner = _pgroup([_ppart("B"), _ppart("C")], 2)
        let outer = _pgroup([_ppart("A"), inner], 3)

        #expect(IvorABC.parsePartSequence("(A(BC)2)3") == _pseq([outer]))
    }

    @Test
    func parsePartSequence_repeatCounts() {
        #expect(IvorABC.parsePartSequence("A2B3") == _pseq([_ppart("A", 2),
                                                            _ppart("B", 3)]))
    }

    @Test
    func parsePartSequence_sequence() {
        #expect(IvorABC.parsePartSequence("ABAB") == _pseq([_ppart("A"),
                                                            _ppart("B"),
                                                            _ppart("A"),
                                                            _ppart("B")]))
    }

    @Test
    func parsePartSequence_singleLetter() {
        #expect(IvorABC.parsePartSequence("A") == _pseq([_ppart("A")]))
    }

    @Test
    func parsePartSequence_whitespaceAroundGroup() {
        let expected = _pseq([_ppart("A"),
                              _pgroup([_ppart("B"),
                                       _ppart("C")], 2)])

        #expect(IvorABC.parsePartSequence("A ( B C )2") == expected)
    }

    @Test
    func parsePartSequence_whitespaceIgnored() {
        #expect(IvorABC.parsePartSequence("A B C") == _pseq([_ppart("A"),
                                                             _ppart("B"),
                                                             _ppart("C")]))
    }
}
