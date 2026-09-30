// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCMacroTests {
}

// MARK: -

extension ABCMacroTests {
    @Test
    func equality() {
        let macro1 = makeMacro("~G2", "{A}G{F}G")
        let macro2 = makeMacro("~G2", "{A}G{F}G")

        #expect(macro1 == macro2)
    }

    @Test
    func inequality_differentReplacement() {
        let macro1 = makeMacro("~n", "!n!")
        let macro2 = makeMacro("~n", "!m!")

        #expect(macro1 != macro2)
    }

    @Test
    func inequality_differentTarget() {
        let macro1 = makeMacro("~G2", "{A}G{F}G")
        let macro2 = makeMacro("~A2", "{A}G{F}G")

        #expect(macro1 != macro2)
    }

    @Test
    func init_nilOnEmptyReplacement() {
        #expect(ABCMacro(target: "~G2", replacement: "") == nil)
    }

    @Test
    func init_nilOnEmptyTarget() {
        #expect(ABCMacro(target: "", replacement: "{A}G{F}G") == nil)
    }

    @Test
    func init_nilOnOverlongReplacement() {
        #expect(ABCMacro(target: "~G2", replacement: String(repeating: "G", count: 201)) == nil)
    }

    @Test
    func init_nilOnOverlongTarget() {
        #expect(ABCMacro(target: String(repeating: "~", count: 32), replacement: "{A}G{F}G") == nil)
    }

    @Test
    func init_nilOnUnparseableTransposingReplacement() {
        // An unclosed chord bracket cannot be tokenized/matched.
        #expect(ABCMacro(target: "~n", replacement: "[Gn") == nil)
    }

    @Test
    func init_static_toleratesUnparseableReplacement() {
        // Static macros are lenient: an unparseable replacement yields no
        // symbols rather than failing macro construction.
        let macro = ABCMacro(target: "~G", replacement: "[G")

        #expect(macro != nil)
        #expect(macro?.replacementSymbols?.isEmpty == true)
    }

    @Test
    func init_storesProperties() {
        let macro = makeMacro("~G2", "{A}G{F}G")

        #expect(macro.target == "~G2")
        #expect(macro.replacement == "{A}G{F}G")
    }

    @Test
    func init_succeedsAtReplacementBoundaries() {
        #expect(ABCMacro(target: "~G2", replacement: "G") != nil)
        #expect(ABCMacro(target: "~G2", replacement: String(repeating: "G", count: 200)) != nil)
    }

    @Test
    func init_succeedsAtTargetBoundaries() {
        #expect(ABCMacro(target: "~", replacement: "G") != nil)
        #expect(ABCMacro(target: String(repeating: "~", count: 31), replacement: "G") != nil)
    }

    @Test
    func kind_isStatic_whenTargetHasNoWildcard() {
        let macro = makeMacro("~G2", "{A}G{F}G")

        #expect(macro.kind == .static)
    }

    @Test
    func kind_isStatic_whenWildcardLetterIsNotTrailing() {
        // The target ends in "urn!" (from the decoration name), not a bare
        // wildcard, so this is not a transposing macro.
        let macro = makeMacro("!turn!", "G")

        #expect(macro.kind == .static)
    }

    @Test
    func kind_isTransposing_whenTargetEndsWithBareWildcard() {
        let macro = makeMacro("~n", "!trill!n")

        #expect(macro.kind == .transposing)
    }

    @Test
    func kind_isTransposing_whenTargetEndsWithWildcardAndLength() {
        let macro = makeMacro("!turn!n2", "n2")

        #expect(macro.kind == .transposing)
    }

    @Test
    func replacementSymbols_static_parsesLiteralSequence() {
        let macro = makeMacro("~G2", "{A}G{F}G")

        #expect(macro.replacementSymbols == [.graceNotes(makeGraceNotes([makeNote(makePitch(.a, .omitted, 4), makeLength(1, 1))], false)),
                                             .note(makeNote(makePitch(.g, .omitted, 4), makeLength(1, 1))),
                                             .graceNotes(makeGraceNotes([makeNote(makePitch(.f, .omitted, 4), makeLength(1, 1))], false)),
                                             .note(makeNote(makePitch(.g, .omitted, 4), makeLength(1, 1)))])
    }

    @Test
    func replacementSymbols_transposing_isNil() {
        let macro = makeMacro("~n", "n")

        #expect(macro.replacementSymbols == nil)
    }

    @Test
    func replacementTemplate_placeholderLettersInsideDecorationName_areNotSubstituted() {
        // "turn" contains 'u', 'r', and 'n' — none of which are wildcards
        // here, since they're inside the `!...!` decoration delimiters.
        let macro = makeMacro("~n", "!turn!n")

        #expect(macro.replacementTemplate == [.symbol(.decoration(makeDecoration("turn"))),
                                              .placeholder(diatonicOffset: 0, length: makeLength(1, 1))])
    }

    @Test
    func replacementTemplate_static_isNil() {
        let macro = makeMacro("~G2", "G")

        #expect(macro.replacementTemplate == nil)
    }

    @Test
    func replacementTemplate_transposing_bareWildcard_referencesMatchedNote() {
        let macro = makeMacro("~n", "!trill!n")

        #expect(macro.replacementTemplate == [.symbol(.decoration(makeDecoration("trill"))),
                                              .placeholder(diatonicOffset: 0, length: makeLength(1, 1))])
    }

    @Test
    func replacementTemplate_transposing_diatonicPlaceholders() {
        // h = -6, o = +1, m = -1 (relative to n).
        let macro = makeMacro("~n2", "honm2")

        #expect(macro.replacementTemplate == [.placeholder(diatonicOffset: -6, length: makeLength(1, 1)),
                                              .placeholder(diatonicOffset: 1, length: makeLength(1, 1)),
                                              .placeholder(diatonicOffset: 0, length: makeLength(1, 1)),
                                              .placeholder(diatonicOffset: -1, length: makeLength(2, 1))])
    }

    @Test
    func targetNoteLength_static_isNil() {
        let macro = makeMacro("~G2", "G")

        #expect(macro.targetNoteLength == nil)
    }

    @Test
    func targetNoteLength_transposing_bareWildcard_defaultsToOne() {
        let macro = makeMacro("~n", "n")

        #expect(macro.targetNoteLength == makeLength(1, 1))
    }

    @Test
    func targetNoteLength_transposing_explicitLength() {
        let macro = makeMacro("~n2", "n2")

        #expect(macro.targetNoteLength == makeLength(2, 1))
    }

    @Test
    func targetSymbols_static_isFullLiteralSequence() {
        let macro = makeMacro("~G2", "G")

        #expect(macro.targetSymbols == [.shorthand(.tilde),
                                        .note(makeNote(makePitch(.g, .omitted, 4), makeLength(2, 1)))])
    }

    @Test
    func targetSymbols_transposing_bareWildcard_isEmpty() {
        let macro = makeMacro("n", "n")

        #expect(macro.targetSymbols.isEmpty)
    }

    @Test
    func targetSymbols_transposing_isLiteralPrefixOnly() {
        let macro = makeMacro("!turn!n2", "G")

        #expect(macro.targetSymbols == [.decoration(makeDecoration("turn"))])
    }
}
