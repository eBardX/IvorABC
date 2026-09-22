// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCMacroParseFunctionsTests {
}

// MARK: -

extension ABCMacroParseFunctionsTests {
    @Test
    func parseMacroReplacementSymbols_parsesLiteralSymbols() {
        let symbols = parseMacroReplacementSymbols("C2")
        let note = makeNote(makePitch(.c, .omitted, 4), makeLength(2))

        #expect(symbols == [.note(note)])
    }

    @Test
    func parseMacroReplacementSymbols_unparseableYieldsEmpty() {
        #expect(parseMacroReplacementSymbols("###").isEmpty)
    }

    @Test
    func parseMacroReplacementTemplate_literalSymbolPassesThrough() throws {
        let template = try #require(parseMacroReplacementTemplate("C"))
        let note = makeNote(makePitch(.c, .omitted, 4), makeLength(1))

        #expect(template == [.symbol(.note(note))])
    }

    @Test
    func parseMacroReplacementTemplate_placeholderNResolvesToZeroOffset() throws {
        let template = try #require(parseMacroReplacementTemplate("n"))

        #expect(template == [.placeholder(diatonicOffset: 0, length: makeLength(1))])
    }

    @Test
    func parseMacroReplacementTemplate_placeholderWithUpperOffset() throws {
        let template = try #require(parseMacroReplacementTemplate("o"))

        #expect(template == [.placeholder(diatonicOffset: 1, length: makeLength(1))])
    }

    @Test
    func parseMacroTarget_staticTarget() {
        let result = parseMacroTarget("gc")

        #expect(result.kind == .static)
        #expect(result.noteLength == nil)
    }

    @Test
    func parseMacroTarget_transposingTargetWithBareN() {
        let result = parseMacroTarget("Bn")

        #expect(result.kind == .transposing)
        #expect(result.noteLength == makeLength(1))
    }

    @Test
    func parseMacroTarget_transposingTargetWithExplicitLength() {
        let result = parseMacroTarget("Bn2")

        #expect(result.kind == .transposing)
        #expect(result.noteLength == makeLength(2))
    }
}
