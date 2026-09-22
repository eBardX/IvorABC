// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCFieldFormatFunctionsTests {
}

// MARK: -

extension ABCFieldFormatFunctionsTests {
    @Test
    func formatAlignedWords_continuationJoinsWithoutSpace() {
        let alignedWords = makeAlignedWords([.syllable(.init(stringValue: "Ama").require()),
                                             .continuation,
                                             .syllable(.init(stringValue: "zing").require())])

        #expect(formatAlignedWords(alignedWords) == "Ama-zing")
    }

    @Test
    func formatAlignedWords_separatesSyllablesWithSpace() {
        let alignedWords = makeAlignedWords([.syllable(.init(stringValue: "Hark").require()),
                                             .syllable(.init(stringValue: "the").require())])

        #expect(formatAlignedWords(alignedWords) == "Hark the")
    }

    @Test
    func formatElemskip_decimal() {
        #expect(formatElemskip(.decimal(1.5)) == "1.5")
    }

    @Test
    func formatElemskip_integer() {
        #expect(formatElemskip(.integer(3)) == "3")
    }

    @Test
    func formatInstructionDirective_omitsValueWhenEmpty() {
        let directive = makeDirective("MIDI", "")

        #expect(formatInstructionDirective(directive) == "MIDI")
    }

    @Test
    func formatInstructionDirective_withValue() {
        let directive = makeDirective("MIDI", "program 1")

        #expect(formatInstructionDirective(directive) == "MIDI program 1")
    }

    @Test
    func formatKeySignature_empty() {
        #expect(formatKeySignature(.empty) == "none")
    }

    @Test
    func formatKeySignature_highlandPipes() {
        #expect(formatKeySignature(.highlandPipes) == "HP")
    }

    @Test
    func formatKeySignature_highlandPipesPreset() {
        #expect(formatKeySignature(.highlandPipesPreset) == "Hp")
    }

    @Test
    func formatKeySignature_standardIncludesModeSuffix() {
        let keySignature = makeKeySignature(.c, .major)

        #expect(formatKeySignature(keySignature) == "C major")
    }

    @Test
    func formatKeySignature_standardWithExtraAccidentals() {
        let keySignature = makeKeySignature(.d, .major, [makePitch(.f, .sharp, 4)])

        #expect(formatKeySignature(keySignature) == "D major ^F")
    }

    @Test
    func formatKeySignature_standardWithNonMajorMode() {
        let keySignature = makeKeySignature(.d, .dorian)

        #expect(formatKeySignature(keySignature) == "D dorian")
    }

    @Test
    func formatMacro_joinsTargetAndReplacement() {
        let macro = makeMacro("n", "C")

        #expect(formatMacro(macro) == "n=C")
    }

    @Test
    func formatPartSequence_nestedGroupsWithRepeatCounts() {
        let sequence = makePartSequence([makePartGroup([makePart(.a), makePart(.b)], 3)])

        #expect(formatPartSequence(sequence) == "(AB)3")
    }

    @Test
    func formatTempo_lengthsWithRate() {
        let tempo = makeTempo(1, 4, 120)

        #expect(formatTempo(tempo) == "1/4=120")
    }

    @Test
    func formatTempo_textOnly() {
        let tempo = makeTempo("Allegro")

        #expect(formatTempo(tempo) == "\"Allegro\"")
    }

    @Test
    func formatText_escapesSpecialCharacters() {
        let text = ABCText(stringValue: "50% off").require()

        #expect(formatText(text) == "50\\% off")
    }

    @Test
    func formatTimeSignature_common() {
        #expect(formatTimeSignature(.common) == "C")
    }

    @Test
    func formatTimeSignature_complex() {
        let timeSignature = makeTimeSignature([2, 3, 2], 8)

        #expect(formatTimeSignature(timeSignature) == "(2+3+2)/8")
    }

    @Test
    func formatTimeSignature_cut() {
        #expect(formatTimeSignature(.cut) == "C|")
    }

    @Test
    func formatTimeSignature_standard() {
        let timeSignature = makeTimeSignature(6, 8)

        #expect(formatTimeSignature(timeSignature) == "6/8")
    }

    @Test
    func formatUserSymbol_decoration() {
        let userSymbol = makeUserSymbol(.tilde, makeDecoration("roll"))

        #expect(formatUserSymbol(userSymbol) == "~=!roll!")
    }

    @Test
    func formatUserSymbol_nilDefinition() {
        let userSymbol = makeUserSymbol(.tilde)

        #expect(formatUserSymbol(userSymbol) == "~=!nil!")
    }

    @Test
    func formatVoice_withPropertiesSortedByKey() {
        let voice = makeVoice("T1", ["stem": "up", "name": "Tenor"])

        #expect(formatVoice(voice) == "T1 name=Tenor stem=up")
    }

    @Test
    func formatVoice_withQuotedPropertyValue() {
        let voice = makeVoice("T1", ["name": "First Tenor"])

        #expect(formatVoice(voice) == "T1 name=\"First Tenor\"")
    }
}
