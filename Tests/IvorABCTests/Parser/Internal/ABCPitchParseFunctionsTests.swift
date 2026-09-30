// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCPitchParseFunctionsTests {
}

// MARK: -

extension ABCPitchParseFunctionsTests {
    @Test
    func parseNote_failure() {
        #expect(parseNote("") == nil)
    }

    @Test
    func parseNote_success() {
        #expect(parseNote("_d") == ((.d, .flat, 5), nil, nil))
        #expect(parseNote("_d''/") == ((.d, .flat, 7), makeLength(1, 2), nil))
        #expect(parseNote("=A") == ((.a, .natural, 4), nil, nil))
        #expect(parseNote("=E") == ((.e, .natural, 4), nil, nil))
        #expect(parseNote("=E,//-") == ((.e, .natural, 3), makeLength(1, 4), ABCTie.regular))
        #expect(parseNote("=E2") == ((.e, .natural, 4), makeLength(2, 1), nil))
        #expect(parseNote("a") == ((.a, .omitted, 5), nil, nil))
        #expect(parseNote("A,,3") == ((.a, .omitted, 2), makeLength(3, 1), nil))
        #expect(parseNote("A/") == ((.a, .omitted, 4), makeLength(1, 2), nil))
        #expect(parseNote("a2") == ((.a, .omitted, 5), makeLength(2, 1), nil))
        #expect(parseNote("a4") == ((.a, .omitted, 5), makeLength(4, 1), nil))
        #expect(parseNote("b") == ((.b, .omitted, 5), nil, nil))
        #expect(parseNote("B/") == ((.b, .omitted, 4), makeLength(1, 2), nil))
        #expect(parseNote("B2") == ((.b, .omitted, 4), makeLength(2, 1), nil))
        #expect(parseNote("B4") == ((.b, .omitted, 4), makeLength(4, 1), nil))
        #expect(parseNote("c") == ((.c, .omitted, 5), nil, nil))
        #expect(parseNote("c/") == ((.c, .omitted, 5), makeLength(1, 2), nil))
        #expect(parseNote("c2") == ((.c, .omitted, 5), makeLength(2, 1), nil))
        #expect(parseNote("c3") == ((.c, .omitted, 5), makeLength(3, 1), nil))
        #expect(parseNote("d") == ((.d, .omitted, 5), nil, nil))
        #expect(parseNote("d/") == ((.d, .omitted, 5), makeLength(1, 2), nil))
        #expect(parseNote("D//") == ((.d, .omitted, 4), makeLength(1, 4), nil))
        #expect(parseNote("d2") == ((.d, .omitted, 5), makeLength(2, 1), nil))
        #expect(parseNote("e-") == ((.e, .omitted, 5), nil, ABCTie.regular))
        #expect(parseNote("e'/") == ((.e, .omitted, 6), makeLength(1, 2), nil))
        #expect(parseNote("e2") == ((.e, .omitted, 5), makeLength(2, 1), nil))
        #expect(parseNote("e3") == ((.e, .omitted, 5), makeLength(3, 1), nil))
        #expect(parseNote("f''''-") == ((.f, .omitted, 9), nil, ABCTie.regular))
        #expect(parseNote("f/") == ((.f, .omitted, 5), makeLength(1, 2), nil))
        #expect(parseNote("f2") == ((.f, .omitted, 5), makeLength(2, 1), nil))
        #expect(parseNote("F3/2") == ((.f, .omitted, 4), makeLength(3, 2), nil))
        #expect(parseNote("F8") == ((.f, .omitted, 4), makeLength(8, 1), nil))
        #expect(parseNote("g") == ((.g, .omitted, 5), nil, nil))
        #expect(parseNote("G,/2") == ((.g, .omitted, 3), makeLength(1, 2), nil))
        #expect(parseNote("g'2") == ((.g, .omitted, 6), makeLength(2, 1), nil))
        #expect(parseNote("g/") == ((.g, .omitted, 5), makeLength(1, 2), nil))
    }

    @Test
    func parsePitch_failure() {
        #expect(parsePitch("") == nil)
        #expect(parsePitch("___b") == nil)
        #expect(parsePitch("^_d") == nil)
        #expect(parsePitch("^^^C") == nil)
        #expect(parsePitch("==A") == nil)
    }

    @Test
    func parsePitch_success() {
        #expect(parsePitch("__b") == (.b, .doubleFlat, 5))
        #expect(parsePitch("__E','") == (.e, .doubleFlat, 5))
        #expect(parsePitch("__G',',") == (.g, .doubleFlat, 4))
        #expect(parsePitch("_a'") == (.a, .flat, 6))
        #expect(parsePitch("_D,,") == (.d, .flat, 2))
        #expect(parsePitch("_F,,,") == (.f, .flat, 1))
        #expect(parsePitch("^^C") == (.c, .doubleSharp, 4))
        #expect(parsePitch("^^e,',") == (.e, .doubleSharp, 4))
        #expect(parsePitch("^^g,','") == (.g, .doubleSharp, 5))
        #expect(parsePitch("^B,") == (.b, .sharp, 3))
        #expect(parsePitch("^d") == (.d, .sharp, 5))
        #expect(parsePitch("^f'''") == (.f, .sharp, 8))
        #expect(parsePitch("=A") == (.a, .natural, 4))
        #expect(parsePitch("=c''") == (.c, .natural, 7))
        #expect(parsePitch("A") == (.a, .omitted, 4))
        #expect(parsePitch("a") == (.a, .omitted, 5))
        #expect(parsePitch("B") == (.b, .omitted, 4))
        #expect(parsePitch("b") == (.b, .omitted, 5))
        #expect(parsePitch("C") == (.c, .omitted, 4))
        #expect(parsePitch("c") == (.c, .omitted, 5))
        #expect(parsePitch("D") == (.d, .omitted, 4))
        #expect(parsePitch("d") == (.d, .omitted, 5))
        #expect(parsePitch("E") == (.e, .omitted, 4))
        #expect(parsePitch("e") == (.e, .omitted, 5))
        #expect(parsePitch("F") == (.f, .omitted, 4))
        #expect(parsePitch("f") == (.f, .omitted, 5))
        #expect(parsePitch("G") == (.g, .omitted, 4))
        #expect(parsePitch("g") == (.g, .omitted, 5))
    }

    @Test
    func parseRest_failure() {
        #expect(parseRest("") == nil)
        #expect(parseRest("X3/2") == nil)
        #expect(parseRest("y") == nil)
        #expect(parseRest("Y4") == nil)
    }

    @Test
    func parseRest_success() {
        #expect(parseRest("x") == ("x", nil))
        #expect(parseRest("x//") == ("x", makeLength(1, 4)))
        #expect(parseRest("X2") == ("X", makeLength(2, 1)))
        #expect(parseRest("z") == ("z", nil))
        #expect(parseRest("z3/2") == ("z", makeLength(3, 2)))
        #expect(parseRest("Z4") == ("Z", makeLength(4, 1)))
    }
}
