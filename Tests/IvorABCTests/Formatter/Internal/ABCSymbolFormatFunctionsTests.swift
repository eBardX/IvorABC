// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCSymbolFormatFunctionsTests {
}

// MARK: -

extension ABCSymbolFormatFunctionsTests {
    @Test
    func formatAnnotation_wrapsTextInQuotesWithPlacementPrefix() {
        let annotation = makeAnnotation(.above, "dim.")

        #expect(formatAnnotation(annotation) == "\"^dim.\"")
    }

    @Test
    func formatBarLine_asymmetricRepeatCounts() {
        let barLine = makeBarLine(.repeat, precedingPlayCount: 2, followingPlayCount: 3)

        #expect(formatBarLine(barLine) == ":|::")
    }

    @Test
    func formatBarLine_dottedStandard() {
        let barLine = makeBarLine(isDotted: true)

        #expect(formatBarLine(barLine) == ".|")
    }

    @Test
    func formatBarLine_end() {
        #expect(formatBarLine(makeBarLine(.end)) == "|]")
    }

    @Test
    func formatBarLine_repeatEndOnly() {
        let barLine = makeBarLine(.repeat, precedingPlayCount: 3, followingPlayCount: 1)

        #expect(formatBarLine(barLine) == "::|")
    }

    @Test
    func formatBarLine_repeatStandardCollapsesToDoubleColon() {
        let barLine = makeBarLine(.repeat, precedingPlayCount: 2, followingPlayCount: 2)

        #expect(formatBarLine(barLine) == "::")
    }

    @Test
    func formatBarLine_repeatStartOnly() {
        let barLine = makeBarLine(.repeat, precedingPlayCount: 1, followingPlayCount: 3)

        #expect(formatBarLine(barLine) == "|::")
    }

    @Test
    func formatBrokenRhythm_returnsGlyphForEachCase() {
        #expect(formatBrokenRhythm(.dotted) == ">")
        #expect(formatBrokenRhythm(.tripleDotted) == ">>>")
        #expect(formatBrokenRhythm(.reverseDotted) == "<")
    }

    @Test
    func formatChord_withTie() {
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let chord = makeChord([note], makeLength(1), .regular)

        #expect(formatChord(chord) == "[C]-")
    }

    @Test
    func formatChordSymbol_withBassAndParenthesized() {
        let chordSymbol = ABCChordSymbol(name: .init(root: .g, kind: "m"),
                                         bass: .b,
                                         parenthesized: .init(root: .e))

        #expect(formatChordSymbol(chordSymbol) == "\"Gm/B(E)\"")
    }

    @Test
    func formatDecoration_bangDialect() {
        #expect(formatDecoration(makeDecoration("roll")) == "!roll!")
    }

    @Test
    func formatDecoration_plusDialect() {
        #expect(formatDecoration(makeDecoration("roll", .plus)) == "+roll+")
    }

    @Test
    func formatGraceNotes_slashed() {
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let graceNotes = makeGraceNotes([note], true)

        #expect(formatGraceNotes(graceNotes) == "{/C}")
    }

    @Test
    func formatInlineField_wrapsInBrackets() {
        #expect(formatInlineField(.part(.a)) == "[P:A]")
    }

    @Test
    func formatLength_powerOf2DenominatorUsesSlashes() {
        #expect(formatLength(makeLength(1, 4)) == "//")
    }

    @Test
    func formatLength_unitLengthIsEmpty() {
        #expect(formatLength(makeLength(1, 1)).isEmpty)
    }

    @Test
    func formatNote_withAccidentalAndTie() {
        let note = makeNote(makePitch(.f, .sharp, 4), makeLength(1), .dotted)

        #expect(formatNote(note) == "^F.-")
    }

    @Test
    func formatPitchLetterOctave_aboveMiddleUsesApostrophes() {
        #expect(formatPitchLetterOctave(.c, ABCPitch.Octave(uintValue: 6).require()) == "c'")
    }

    @Test
    func formatPitchLetterOctave_belowMiddleUsesCommas() {
        #expect(formatPitchLetterOctave(.c, ABCPitch.Octave(uintValue: 2).require()) == "C,,")
    }

    @Test
    func formatPitchLetterOctave_middleOctaveIsUppercase() {
        #expect(formatPitchLetterOctave(.c, ABCPitch.Octave(uintValue: 4).require()) == "C")
    }

    @Test
    func formatRest_multiMeasureOmitsCountWhenOne() {
        let rest = ABCRest.multiMeasure(false, 1)

        #expect(formatRest(rest) == "Z")
    }

    @Test
    func formatRest_multiMeasureWithCount() {
        let rest = ABCRest.multiMeasure(true, 3)

        #expect(formatRest(rest) == "X3")
    }

    @Test
    func formatRest_regular() {
        let rest = ABCRest.regular(false, makeLength(1, 2))

        #expect(formatRest(rest) == "z/")
    }

    @Test
    func formatShorthand_returnsGlyphForEachCase() {
        #expect(formatShorthand(.dot) == ".")
        #expect(formatShorthand(.tilde) == "~")
    }

    @Test
    func formatSlur_returnsGlyphForEachCase() {
        #expect(formatSlur(.startRegular) == "(")
        #expect(formatSlur(.endDotted) == ".)")
    }

    @Test
    func formatSymbolLine_joinsElementsWithSpace() {
        let symbolLine = makeSymbolLine([.skip, .decoration(makeDecoration("roll"))])

        #expect(formatSymbolLine(symbolLine) == "* !roll!")
    }

    @Test
    func formatTuplet_noteCountOnly() {
        let tuplet = makeTuplet(3)

        #expect(formatTuplet(tuplet) == "(3")
    }

    @Test
    func formatTuplet_withAllCounts() {
        let tuplet = makeTuplet(3, 2, 3)

        #expect(formatTuplet(tuplet) == "(3:2:3")
    }

    @Test
    func formatVariantEnding_singleAndRangeEndings() {
        let variantEnding = makeVariantEnding([1...1, 3...4])

        #expect(formatVariantEnding(variantEnding) == "[1,3-4")
    }
}
