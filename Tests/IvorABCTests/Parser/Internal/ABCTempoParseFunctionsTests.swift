// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCTempoParseFunctionsTests {
}

// MARK: -

extension ABCTempoParseFunctionsTests {
    @Test
    func parseTempo_compoundBeat_failure() {
        #expect(parseTempo("3/8+1/4=44") == nil)
        #expect(parseTempo("1/4+1/4+1/4=120") == nil)
        #expect(parseTempo("1/4 +3/8+ 1/4 + 3/8=40") == nil)
    }

    @Test
    func parseTempo_compoundBeat_success() {
        let d38 = makeLength(3, 8)
        let d14 = makeLength(1, 4)
        let d12 = makeLength(1, 2)

        #expect(parseTempo("3/8 1/4=44") == makeTempo([d38, d14], 44))
        #expect(parseTempo("3/8 1/4 = 44") == makeTempo([d38, d14], 44))
        #expect(parseTempo("1/4 1/4 1/4=120") == makeTempo([d14, d14, d14], 120))
        #expect(parseTempo("1/2 1/4=60") == makeTempo([d12, d14], 60))
        #expect(parseTempo("1/4 3/8 1/4 3/8=40") == makeTempo([d14, d38, d14, d38], 40))
    }

    @Test
    func parseTempo_failure() {
        #expect(parseTempo("") == nil)
        #expect(parseTempo("120") == nil)
        #expect(parseTempo("C = 120") == nil)
    }

    @Test
    func parseTempo_success() {
        #expect(parseTempo("\"Allegro\" 1/4=120") == makeTempo(1, 4, 120, "Allegro"))
        #expect(parseTempo("\"Andante\"") == makeTempo("Andante"))
        #expect(parseTempo("\"Andante mosso\" 1/4 = 110") == makeTempo(1, 4, 110, "Andante mosso"))
        #expect(parseTempo("1/2=120") == makeTempo(1, 2, 120))
        #expect(parseTempo("1/4 = 110 \"Andante mosso\"") == makeTempo(1, 4, 110, "Andante mosso"))
        #expect(parseTempo("3/8=50 \"Slowly\"") == makeTempo(3, 8, 50, "Slowly"))
    }

    @Test
    func parseTimeSignature_complex_failure() {
        #expect(parseTimeSignature("(2+3+2)/3") == nil)     // bad denominator
        #expect(parseTimeSignature("(2+3+2)") == nil)       // missing denominator
        #expect(parseTimeSignature("+3/8") == nil)          // leading +
        #expect(parseTimeSignature("2+/8") == nil)          // trailing +
        #expect(parseTimeSignature("2+0/8") == nil)         // zero numerator part
    }

    @Test
    func parseTimeSignature_complex_success() {
        #expect(parseTimeSignature("(2+3+2)/8") == makeTimeSignature([2, 3, 2], 8))
        #expect(parseTimeSignature("2+3+2/8") == makeTimeSignature([2, 3, 2], 8))
        #expect(parseTimeSignature("(3+3)/8") == makeTimeSignature([3, 3], 8))
        #expect(parseTimeSignature("3+3/8") == makeTimeSignature([3, 3], 8))
        #expect(parseTimeSignature("(2+3)/4") == makeTimeSignature([2, 3], 4))
        #expect(parseTimeSignature("3+3+2/8") == makeTimeSignature([3, 3, 2], 8))
    }

    @Test
    func parseTimeSignature_failure() {
        #expect(parseTimeSignature("") == nil)
        #expect(parseTimeSignature("4/3") == nil)
    }

    @Test
    func parseTimeSignature_success() {
        #expect(parseTimeSignature("C") == .common)
        #expect(parseTimeSignature("C|") == .cut)
        #expect(parseTimeSignature("12/8") == makeTimeSignature(12, 8))
        #expect(parseTimeSignature("3/4") == makeTimeSignature(3, 4))
        #expect(parseTimeSignature("4/4") == makeTimeSignature(4, 4))
        #expect(parseTimeSignature("6/8") == makeTimeSignature(6, 8))
        #expect(parseTimeSignature("9/8") == makeTimeSignature(9, 8))
    }
}
