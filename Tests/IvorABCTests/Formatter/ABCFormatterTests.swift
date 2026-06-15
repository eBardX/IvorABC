// © 2026 John Gary Pusey (see LICENSE.md)

// swiftlint:disable file_length

import Foundation
@testable import IvorABC
import Testing
import XestiTools

struct ABCFormatterTests {
}

// MARK: -

extension ABCFormatterTests {
    @Test
    func accidental_doubleFlat_emitsDoubleUnderscores() throws {
        let note = makeNote(makePitch(.a, .doubleFlat, 4),
                            makeDuration(1, 8),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("__A\n"))
    }

    @Test
    func accidental_doubleSharp_emitsDoubleCarets() throws {
        let note = makeNote(makePitch(.c, .doubleSharp, 4),
                            makeDuration(1, 8),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("^^C\n"))
    }

    @Test
    func accidental_flat_emitsUnderscore() throws {
        let note = makeNote(makePitch(.b, .flat, 4),
                            makeDuration(1, 8),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("_B\n"))
    }

    @Test
    func accidental_natural_emitsBareNote() throws {
        let note = makeNote(makePitch(.c, .natural, 4),
                            makeDuration(1, 8),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("C\n"))
        #expect(!output.contains("=C"))
    }

    @Test
    func accidental_sharp_emitsCaret() throws {
        let note = makeNote(makePitch(.f, .sharp, 4),
                            makeDuration(1, 8),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("^F\n"))
    }

    @Test
    func alignedLyrics_continuation_emitsHyphen() throws {
        let lyrics = makeAlignedLyrics([.text("hel"), .hyphen, .text("lo")])
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .field(.alignedLyrics(lyrics))])])

        #expect(try format(book).contains("w:hel-lo\n"))
    }

    @Test
    func alignedLyrics_hold_emitsUnderscore() throws {
        let lyrics = makeAlignedLyrics([.text("long"), .hold])
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .field(.alignedLyrics(lyrics))])])

        #expect(try format(book).contains("w:long _\n"))
    }

    @Test
    func alignedLyrics_syllableWithPercent_escapesPercentSign() throws {
        let lyrics = makeAlignedLyrics([.text("100%"), .text("done")])
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .field(.alignedLyrics(lyrics))])])

        #expect(try format(book).contains("w:100\\% done\n"))
    }

    @Test
    func alignedLyrics_syllables_emitsSpaceSeparated() throws {
        let lyrics = makeAlignedLyrics([.text("hel"), .text("lo")])
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .field(.alignedLyrics(lyrics))])])

        #expect(try format(book).contains("w:hel lo\n"))
    }

    @Test
    func barRepeat_emitsVerbatim() throws {
        let note = makeNote(makePitch(.c, .natural, 4), makeDuration(1, 8), false)
        let output = try format(minimalTunebook(symbols: [.barRepeat("|:"), .note(note)]))

        #expect(output.contains("|:"))
    }

    @Test
    func barRepeat_emptyString_throws() throws {
        #expect(throws: ABCFormatter.Error.invalidBarRepeat("")) {
            try ABCFormatter().format(minimalTunebook(symbols: [.barRepeat("")]))
        }
    }

    @Test
    func barRepeat_invalidCharacter_throws() throws {
        #expect(throws: ABCFormatter.Error.invalidBarRepeat("X")) {
            try ABCFormatter().format(minimalTunebook(symbols: [.barRepeat("X")]))
        }
    }

    @Test
    func brokenRhythm_doubleRight_emitsVerbatim() throws {
        let c = makeNote(makePitch(.c, .natural, 4), makeDuration(1, 8), false)
        let d = makeNote(makePitch(.d, .natural, 4), makeDuration(1, 8), false)
        let output = try format(minimalTunebook(symbols: [.note(c), .brokenRhythm(">>"), .note(d)]))

        #expect(output.contains(">>"))
    }

    @Test
    func brokenRhythm_emitsVerbatim() throws {
        let c = makeNote(makePitch(.c, .natural, 4), makeDuration(1, 8), false)
        let d = makeNote(makePitch(.d, .natural, 4), makeDuration(1, 8), false)
        let output = try format(minimalTunebook(symbols: [.note(c), .brokenRhythm(">"), .note(d)]))

        #expect(output.contains(">"))
    }

    @Test
    func brokenRhythm_emptyString_throws() throws {
        #expect(throws: ABCFormatter.Error.invalidBrokenRhythm("")) {
            try ABCFormatter().format(minimalTunebook(symbols: [.brokenRhythm("")]))
        }
    }

    @Test
    func brokenRhythm_invalidCharacter_throws() throws {
        #expect(throws: ABCFormatter.Error.invalidBrokenRhythm("x")) {
            try ABCFormatter().format(minimalTunebook(symbols: [.brokenRhythm("x")]))
        }
    }

    @Test
    func brokenRhythm_left_emitsVerbatim() throws {
        let c = makeNote(makePitch(.c, .natural, 4), makeDuration(1, 8), false)
        let d = makeNote(makePitch(.d, .natural, 4), makeDuration(1, 8), false)
        let output = try format(minimalTunebook(symbols: [.note(c), .brokenRhythm("<"), .note(d)]))

        #expect(output.contains("<"))
    }

    @Test
    func brokenRhythm_mixedDirections_throws() throws {
        #expect(throws: ABCFormatter.Error.invalidBrokenRhythm("><")) {
            try ABCFormatter().format(minimalTunebook(symbols: [.brokenRhythm("><")]))
        }
    }

    @Test
    func brokenRhythm_tooLong_throws() throws {
        #expect(throws: ABCFormatter.Error.invalidBrokenRhythm(">>>>")) {
            try ABCFormatter().format(minimalTunebook(symbols: [.brokenRhythm(">>>>")]))
        }
    }

    @Test
    func chord_basic_emitsBracketedNotes() throws {
        let notes: [ABCNote] = [makeNote(makePitch(.c, .natural, 4), makeDuration(1, 8), false),
                                makeNote(makePitch(.e, .natural, 4), makeDuration(1, 8), false),
                                makeNote(makePitch(.g, .natural, 4), makeDuration(1, 8), false)]
        let output = try format(minimalTunebook(symbols: [.chord(makeChord(notes, makeDuration(1, 8), false))]))

        #expect(output.contains("[CEG]\n"))
    }

    @Test
    func chord_withDurationSuffix_emitsChordSuffix() throws {
        let notes: [ABCNote] = [makeNote(makePitch(.c, .natural, 4), makeDuration(1, 8), false),
                                makeNote(makePitch(.e, .natural, 4), makeDuration(1, 8), false)]
        let output = try format(minimalTunebook(symbols: [.chord(makeChord(notes, makeDuration(1, 4), false))]))

        #expect(output.contains("[CE]2\n"))
    }

    @Test
    func chord_withTie_emitsDash() throws {
        let notes: [ABCNote] = [makeNote(makePitch(.c, .natural, 4), makeDuration(1, 8), false),
                                makeNote(makePitch(.e, .natural, 4), makeDuration(1, 8), false)]
        let output = try format(minimalTunebook(symbols: [.chord(makeChord(notes, makeDuration(1, 8), true))]))

        #expect(output.contains("[CE]-\n"))
    }

    @Test
    func crossTuneDurationState_L1_4_leaksIntoSecondTune() throws {
        // Tune 1 sets L:1/4. Tune 2 has no L:. The formatter must carry
        // unitNoteLength forward, so notes in tune 2 are divided by 1/4.
        let noteDur = makeDuration(1, 4)  // stored duration = 1/4 (one unit of L:1/4)
        let note = makeNote(makePitch(.c, .natural, 4), noteDur, false)
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.unitNoteLength(makeDuration(1, 4))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .symbols([.note(note)])]),
                                       ABCTune(entries: [.field(.refNumber(makeRefNumber(2))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .symbols([.note(note)])])])
        let output = try format(book)
        let lines = output.components(separatedBy: "\n")

        // Both tunes should emit "C" (no suffix) because both use L:1/4 as base.
        let symbolLines = lines.filter { $0 == "C" }

        #expect(symbolLines.count == 2)
    }

    @Test
    func crossTuneDurationState_M3_8_leaksIntoSecondTune() throws {
        // Tune 1 sets M:3/8 (ratio < 0.75, so default L: is 1/16) with no explicit L:.
        // Tune 2 has no M: and no L:. M: state carries forward, so the effective
        // base in tune 2 is still 1/16.
        let noteDur = makeDuration(1, 16)  // stored duration = 1/16 (one unit under M:3/8 default)
        let note = makeNote(makePitch(.c, .natural, 4), noteDur, false)
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.meter(makeTimeSignature(3, 8))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .symbols([.note(note)])]),
                                       ABCTune(entries: [.field(.refNumber(makeRefNumber(2))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .symbols([.note(note)])])])
        let output = try format(book)
        let lines = output.components(separatedBy: "\n")

        // Both tunes should emit "C" (no suffix) because both use 1/16 as effective base.
        let symbolLines = lines.filter { $0 == "C" }

        #expect(symbolLines.count == 2)
    }

    @Test
    func duration_default_emitsEmpty() throws {
        // With L:1/8 (the default), a stored duration of 1/8 emits no suffix.
        let note = makeNote(makePitch(.c, .natural, 4),
                            makeDuration(1, 8),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("C\n"))
    }

    @Test
    func duration_double_emits2() throws {
        let note = makeNote(makePitch(.c, .natural, 4),
                            makeDuration(1, 4),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("C2\n"))
    }

    @Test
    func duration_half_emitsSlash() throws {
        let note = makeNote(makePitch(.c, .natural, 4),
                            makeDuration(1, 16),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("C/\n"))
    }

    @Test
    func duration_quarter_emitsDoubleSlash() throws {
        let note = makeNote(makePitch(.c, .natural, 4),
                            makeDuration(1, 32),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("C//\n"))
    }

    @Test
    func duration_threeHalves_emits3over2() throws {
        let note = makeNote(makePitch(.c, .natural, 4),
                            makeDuration(3, 16),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("C3/2\n"))
    }

    @Test
    func duration_underL4_eighth_emitsSlash() throws {
        let note = makeNote(makePitch(.c, .natural, 4),
                            makeDuration(1, 8),
                            false)
        let output = try format(minimalTunebookWithL4(symbols: [.note(note)]))

        #expect(output.contains("C/\n"))
    }

    @Test
    func duration_underL4_quarter_emitsEmpty() throws {
        let note = makeNote(makePitch(.c, .natural, 4),
                            makeDuration(1, 4),
                            false)
        let output = try format(minimalTunebookWithL4(symbols: [.note(note)]))

        #expect(output.contains("C\n"))
    }

    @Test
    func duration_underL4_whole_emits4() throws {
        let note = makeNote(makePitch(.c, .natural, 4),
                            makeDuration(1, 1),
                            false)
        let output = try format(minimalTunebookWithL4(symbols: [.note(note)]))

        #expect(output.contains("C4\n"))
    }

    @Test
    func field_area_emitsAField() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.field(.area("Ireland"))],
                               tunes: [])

        #expect(try format(book).contains("A:Ireland\n"))
    }

    @Test
    func field_book_emitsBField() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.field(.book("My Book"))],
                               tunes: [])

        #expect(try format(book).contains("B:My Book\n"))
    }

    @Test
    func field_composer_emitsCField() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.field(.composer("Bach"))],
                               tunes: [])

        #expect(try format(book).contains("C:Bach\n"))
    }

    @Test
    func field_key_emitsKField() throws {
        let output = try format(minimalTunebook())

        #expect(output.contains("K:C major\n"))
    }

    @Test
    func field_macro_emitsMacroField() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.field(.macro(makeMacro("~G2", "{A}G{F}G")))],
                               tunes: [])

        #expect(try format(book).contains("m:~G2={A}G{F}G\n"))
    }

    @Test
    func field_refNumber_emitsXField() throws {
        let output = try format(minimalTunebook())

        #expect(output.contains("X:1\n"))
    }

    @Test
    func field_stringField_escapesPercentSign() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.title("Foo % Bar")),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .symbols([])])])

        #expect(try format(book).contains("T:Foo \\% Bar\n"))
    }

    @Test
    func field_title_emitsTField() throws {
        let output = try format(minimalTunebook())

        #expect(output.contains("T:Test\n"))
    }

    @Test
    func field_unitNoteLength_emitsLField() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.field(.unitNoteLength(makeDuration(1, 8)))],
                               tunes: [])

        #expect(try format(book).contains("L:1/8\n"))
    }

    @Test
    func field_userSymbol_emitsUField() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.field(.userSymbol(makeUserSymbol("~", makeDecoration("roll"))))],
                               tunes: [])

        #expect(try format(book).contains("U:~=!roll!\n"))
    }

    @Test
    func fileHeader_beginEndDirective_emitsBlockForm() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.directive(makeDirective("text",
                                                                  "",
                                                                  ["Line one", "Line two"]))],
                               tunes: [])
        let output = try format(book)

        #expect(output.contains("%%begintext\nLine one\nLine two\n%%endtext\n"))
    }

    @Test
    func fileHeader_beginEndDirective_withValue_emitsBlockFormWithValue() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.directive(makeDirective("text",
                                                                  "justify",
                                                                  ["Some text"]))],
                               tunes: [])
        let output = try format(book)

        #expect(output.contains("%%begintext justify\nSome text\n%%endtext\n"))
    }

    @Test
    func fileHeader_directive_emitsPercentPercent() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.directive(makeDirective("midi",
                                                                  "program 40"))],
                               tunes: [])
        let output = try format(book)

        #expect(output.contains("%%midi program 40\n"))
    }

    @Test
    func fileHeader_meterField_emitsMField() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.field(.meter(makeTimeSignature(4, 4)))],
                               tunes: [])
        let output = try format(book)

        #expect(output.contains("M:4/4\n"))
    }

    @Test
    func fileHeader_misplacedField_throws() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.field(.title("Bad"))],
                               tunes: [])

        #expect(throws: ABCFormatter.Error.misplacedFileHeaderField(.title("Bad"))) {
            try ABCFormatter().format(book)
        }
    }

    @Test
    func fileIDLine_customVersion_throws() {
        let book = ABCTunebook(version: makeVersion(3, 0),
                               headers: [],
                               tunes: [])

        #expect(throws: ABCFormatter.Error.unsupportedVersion(makeVersion(3, 0))) {
            try format(book)
        }
    }

    @Test
    func fileIDLine_version21_emitsCorrectHeader() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [])
        let output = try format(book)

        #expect(output.hasPrefix("%abc-2.1\n"))
    }

    @Test
    func graceNotes_noSlash_emitsCurlyBraces() throws {
        let notes: [ABCNote] = [makeNote(makePitch(.a, .natural, 4), makeDuration(1, 8), false)]
        let following = makeNote(makePitch(.g, .natural, 4), makeDuration(1, 8), false)
        let output = try format(minimalTunebook(symbols: [.graceNotes(makeGraceNotes(notes, false)), .note(following)]))

        #expect(output.contains("{A}G\n"))
    }

    @Test
    func graceNotes_withSlash_emitsSlashInBraces() throws {
        let notes: [ABCNote] = [makeNote(makePitch(.a, .natural, 4), makeDuration(1, 8), false)]
        let following = makeNote(makePitch(.g, .natural, 4), makeDuration(1, 8), false)
        let output = try format(minimalTunebook(symbols: [.graceNotes(makeGraceNotes(notes, true)), .note(following)]))

        #expect(output.contains("{/A}G\n"))
    }

    @Test
    func idempotence_simpleTune_formatsIdentically() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nM:4/4\nL:1/8\nK:G\nGABc defe|\n"
        let book1 = try ABCParser().parse(Data(input.utf8))
        let formatted1 = try ABCFormatter().format(book1)
        let book2 = try ABCParser().parse(formatted1)
        let formatted2 = try ABCFormatter().format(book2)

        #expect(formatted1 == formatted2)
    }

    @Test
    func inlineField_key_emitsBracketed() throws {
        let output = try format(minimalTunebook(symbols: [.inlineField(.key(makeKeySignature(.g, .major))),
                                                          .note(makeNote(makePitch(.g, .natural, 4),
                                                                         makeDuration(1, 8),
                                                                         false))]))

        #expect(output.contains("[K:G major]"))
    }

    @Test
    func inlineField_meter_emitsBracketed() throws {
        let output = try format(minimalTunebook(symbols: [.inlineField(.meter(makeTimeSignature(3, 4))),
                                                          .note(makeNote(makePitch(.c, .natural, 4),
                                                                         makeDuration(1, 8),
                                                                         false))]))

        #expect(output.contains("[M:3/4]"))
    }

    @Test
    func key_bFlatMajor_emitsBb() throws {
        let output = try format(minimalTunebook(key: makeKeySignature(.bFlat, .major)))

        #expect(output.contains("K:Bb major\n"))
    }

    @Test
    func key_cMajor_emitsC() throws {
        let output = try format(minimalTunebook(key: makeKeySignature(.c, .major)))

        #expect(output.contains("K:C major\n"))
    }

    @Test
    func key_clefOnly_emitsClefProperty() throws {
        let clef = ABCKeySignature.Clef(name: "treble")
        let output = try format(minimalTunebook(key: .clefOnly(clef)))

        #expect(output.contains("K:clef=treble\n"))
    }

    @Test
    func key_dMinor_emitsDmin() throws {
        let output = try format(minimalTunebook(key: makeKeySignature(.d, .minor)))

        #expect(output.contains("K:D minor\n"))
    }

    @Test
    func key_dorian_emitsModeSuffix() throws {
        let output = try format(minimalTunebook(key: makeKeySignature(.d, .dorian)))

        #expect(output.contains("K:D dorian\n"))
    }

    @Test
    func key_empty_emitsNone() throws {
        let output = try format(minimalTunebook(key: .empty))

        #expect(output.contains("K:none\n"))
    }

    @Test
    func key_fSharpMajor_emitsFSharp() throws {
        let output = try format(minimalTunebook(key: makeKeySignature(.fSharp, .major)))

        #expect(output.contains("K:F# major\n"))
    }

    @Test
    func key_highlandPipesPreset_emitsHp() throws {
        let output = try format(minimalTunebook(key: .highlandPipesPreset))

        #expect(output.contains("K:Hp\n"))
    }

    @Test
    func key_highlandPipes_emitsHP() throws {
        let output = try format(minimalTunebook(key: .highlandPipes))

        #expect(output.contains("K:HP\n"))
    }

    @Test
    func key_withAccidental_emitsAccidental() throws {
        let acc = makePitch(.f, .sharp, 4)
        let output = try format(minimalTunebook(key: makeKeySignature(.c, .major, [acc])))

        #expect(output.contains("K:C major ^F\n"))
    }

    @Test
    func key_withClef_emitsClefAfterKey() throws {
        let clef = ABCKeySignature.Clef(name: "bass")
        let output = try format(minimalTunebook(key: makeKeySignature(.g, .major, clef)))

        #expect(output.contains("K:G major clef=bass\n"))
    }

    @Test
    func meter_common_emitsC() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.field(.meter(.common))],
                               tunes: [])

        #expect(try format(book).contains("M:C\n"))
    }

    @Test
    func meter_complex_emitsParenthesizedForm() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.field(.meter(makeTimeSignature([2, 3, 2], 8)))],
                               tunes: [])

        #expect(try format(book).contains("M:(2+3+2)/8\n"))
    }

    @Test
    func meter_cut_emitsCPipe() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.field(.meter(.cut))],
                               tunes: [])

        #expect(try format(book).contains("M:C|\n"))
    }

    @Test
    func meter_empty_emitsNone() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.field(.meter(.empty))],
                               tunes: [])

        #expect(try format(book).contains("M:none\n"))
    }

    @Test
    func meter_standard_emitsFraction() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [.field(.meter(makeTimeSignature(3, 4)))],
                               tunes: [])

        #expect(try format(book).contains("M:3/4\n"))
    }

    @Test
    func overlay_emitsAmpersand() throws {
        let output = try format(minimalTunebook(symbols: [.overlay]))

        #expect(output.contains("&\n"))
    }

    @Test
    func parts_simple_emitsLetters() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.parts(makePartSequence([makePart("A"), makePart("B")]))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .symbols([])])])

        #expect(try format(book).contains("P:AB\n"))
    }

    @Test
    func parts_withGroup_emitsParentheses() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.parts(makePartSequence([makePart("A"),
                                                                                         makePartGroup([makePart("B"),
                                                                                                        makePart("C")], 3)]))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .symbols([])])])

        #expect(try format(book).contains("P:A(BC)3\n"))
    }

    @Test
    func parts_withRepeats_emitsRepeatCounts() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.parts(makePartSequence([makePart("A", 2), makePart("B")]))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .symbols([])])])

        #expect(try format(book).contains("P:A2B\n"))
    }

    @Test
    func pitch_octave2_emitsUppercaseWithTwoCommas() throws {
        let note = ABCNote(pitch: makePitch(.c, .natural, 2),
                           duration: makeDuration(1, 8),
                           isTied: false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("C,,\n"))
    }

    @Test
    func pitch_octave3_emitsUppercaseWithComma() throws {
        let note = makeNote(makePitch(.c, .natural, 3),
                            makeDuration(1, 8),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("C,\n"))
    }

    @Test
    func pitch_octave4_emitsUppercase() throws {
        let note = makeNote(makePitch(.c, .natural, 4),
                            makeDuration(1, 8),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("C\n"))
    }

    @Test
    func pitch_octave5_emitsLowercase() throws {
        let note = makeNote(makePitch(.c, .natural, 5),
                            makeDuration(1, 8),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("c\n"))
    }

    @Test
    func pitch_octave6_emitsLowercaseWithApostrophe() throws {
        let note = makeNote(makePitch(.c, .natural, 6),
                            makeDuration(1, 8),
                            false)
        let output = try format(minimalTunebook(symbols: [.note(note)]))

        #expect(output.contains("c'\n"))
    }

    @Test
    func rest_multiMeasure1_emitsZ() throws {
        let output = try format(minimalTunebook(symbols: [.rest(.multiMeasure(false, 1))]))

        #expect(output.contains("Z\n"))
    }

    @Test
    func rest_multiMeasureZeroCount_throws() throws {
        #expect(throws: ABCFormatter.Error.invalidMultiMeasureRestCount) {
            try ABCFormatter().format(minimalTunebook(symbols: [.rest(.multiMeasure(false, 0))]))
        }
    }

    @Test
    func rest_multiMeasure_emitsZN() throws {
        let output = try format(minimalTunebook(symbols: [.rest(.multiMeasure(false, 4))]))

        #expect(output.contains("Z4\n"))
    }

    @Test
    func rest_regularInvisible_emitsX() throws {
        let output = try format(minimalTunebook(symbols: [.rest(.regular(true, makeDuration(1, 8)))]))

        #expect(output.contains("x\n"))
    }

    @Test
    func rest_regular_emitsZ() throws {
        let output = try format(minimalTunebook(symbols: [.rest(.regular(false, makeDuration(1, 8)))]))

        #expect(output.contains("z\n"))
    }

    @Test
    func roundTrip_beamBreak_beamedDistinctFromUnbeamed() throws {
        let beamed = "%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\nABcd|\n"
        let unbeamed = "%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\nA B c d|\n"
        let bookBeamed = try ABCParser().parse(Data(beamed.utf8))
        let bookUnbeamed = try ABCParser().parse(Data(unbeamed.utf8))

        #expect(bookBeamed != bookUnbeamed)
    }

    @Test
    func roundTrip_beamBreak_preservedAfterFormat() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\nA B c d|\n"
        let book1 = try ABCParser().parse(Data(input.utf8))
        let formatted = try ABCFormatter().format(book1)
        let book2 = try ABCParser().parse(formatted)

        #expect(book1 == book2)
    }

    @Test
    func roundTrip_beginEndBlock_producesEqualModel() throws {
        let input = "%abc-2.1\n%%begintext justify\nSome text\n%%endtext\nX:1\nT:Test\nK:C\nCDEF|\n"
        let book1 = try ABCParser().parse(Data(input.utf8))
        let formatted = try ABCFormatter().format(book1)
        let book2 = try ABCParser().parse(formatted)

        #expect(book1 == book2)
    }

    @Test
    func roundTrip_brokenRhythm_producesEqualModel() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\nC>>D<E|\n"
        let book1 = try ABCParser().parse(Data(input.utf8))
        let formatted = try ABCFormatter().format(book1)
        let book2 = try ABCParser().parse(formatted)

        #expect(book1 == book2)
    }

    @Test
    func roundTrip_fileHeaderDirective_producesEqualModel() throws {
        let input = "%abc-2.1\n%%midi program 40\nX:1\nT:Test\nK:C\nCDEF|\n"
        let book1 = try ABCParser().parse(Data(input.utf8))
        let formatted = try ABCFormatter().format(book1)
        let book2 = try ABCParser().parse(formatted)

        #expect(book1 == book2)
    }

    @Test
    func roundTrip_keyWithAccidentals_producesEqualModel() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:G ^F\nGABc|\n"
        let book1 = try ABCParser().parse(Data(input.utf8))
        let formatted = try ABCFormatter().format(book1)
        let book2 = try ABCParser().parse(formatted)

        #expect(book1 == book2)
    }

    @Test
    func roundTrip_multipleVoices_producesEqualModel() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nV:V1\nV:V2\nK:C\nV:V1\nCDEF|\nV:V2\nGABc|\n"
        let book1 = try ABCParser().parse(Data(input.utf8))
        let formatted = try ABCFormatter().format(book1)
        let book2 = try ABCParser().parse(formatted)

        #expect(book1 == book2)
    }

    @Test
    func roundTrip_overlay_producesEqualModel() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nL:1/4\nK:C\nCG&EG|\n"
        let book1 = try ABCParser().parse(Data(input.utf8))
        let formatted = try ABCFormatter().format(book1)
        let book2 = try ABCParser().parse(formatted)

        #expect(book1 == book2)
    }

    @Test
    func roundTrip_simpleTune_producesEqualModel() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nM:4/4\nL:1/8\nK:G\nGABc defe|\n"
        let book1 = try ABCParser().parse(Data(input.utf8))
        let formatted = try ABCFormatter().format(book1)
        let book2 = try ABCParser().parse(formatted)

        #expect(book1 == book2)
    }

    @Test
    func roundTrip_slur_producesEqualModel() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\n(C(DE)F)|\n"
        let book1 = try ABCParser().parse(Data(input.utf8))
        let formatted = try ABCFormatter().format(book1)
        let book2 = try ABCParser().parse(formatted)

        #expect(book1 == book2)
    }

    @Test
    func roundTrip_spacer_producesEqualModel() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\ny2C|\n"
        let book1 = try ABCParser().parse(Data(input.utf8))
        let formatted = try ABCFormatter().format(book1)
        let book2 = try ABCParser().parse(formatted)

        #expect(book1 == book2)
    }

    @Test
    func roundTrip_variantEnding_producesEqualModel() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\n|:CDEF|[1 GABc:|[2 cdef|]\n"
        let book1 = try ABCParser().parse(Data(input.utf8))
        let formatted = try ABCFormatter().format(book1)
        let book2 = try ABCParser().parse(formatted)

        #expect(book1 == book2)
    }

    @Test
    func slur_invalidString_throws() throws {
        #expect(throws: ABCFormatter.Error.invalidSlur("x")) {
            try ABCFormatter().format(minimalTunebook(symbols: [.slur("x")]))
        }
    }

    @Test
    func spacer_emitsY() throws {
        let output = try format(minimalTunebook(symbols: [.spacer(makeDuration(1, 8))]))

        #expect(output.contains("y\n"))
    }

    @Test
    func spacer_withDuration_emitsYWithSuffix() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.unitNoteLength(makeDuration(1, 8))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .symbols([.spacer(makeDuration(1, 4))])])])
        let output = try format(book)

        #expect(output.contains("y2\n"))
    }

    @Test
    func symbolLine_skip_emitsStar() throws {
        let sl = makeSymbolLine([.skip, .decoration(makeDecoration("trill", nil, .bang)), .skip])
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .field(.symbolLine(sl))])])

        #expect(try format(book).contains("s:* !trill! *\n"))
    }

    @Test
    func tempo_durationAndRate_emitsFullForm() throws {
        #expect(try format(minimalTunebookWithTempo(makeTempo(1, 4, 120))).contains("Q:1/4=120\n"))
    }

    @Test
    func tempo_durationTextAndRate_emitsFullForm() throws {
        #expect(try format(minimalTunebookWithTempo(makeTempo(1, 4, 80, "Andante"))).contains("Q:\"Andante\" 1/4=80\n"))
    }

    @Test
    func tempo_textAndRate_emitsTextWithBareRate() throws {
        let tempo = makeTempo([], 80, "Moderato")

        #expect(try format(minimalTunebookWithTempo(tempo)).contains("Q:\"Moderato\" 80\n"))
    }

    @Test
    func tempo_textOnly_emitsQuotedText() throws {
        #expect(try format(minimalTunebookWithTempo(makeTempo("Andante"))).contains("Q:\"Andante\"\n"))
    }

    @Test
    func tuneDirective_simple_emitsPercentPercent() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .directive(makeDirective("midi", "channel 1")),
                                                         .symbols([])])])
        let output = try format(book)

        #expect(output.contains("%%midi channel 1\n"))
    }

    @Test
    func tune_allMissingRefNumbers_assignedSequentially() throws {
        let tune = ABCTune(entries: [.field(.title("Test")),
                                     .field(.key(makeKeySignature(.c, .major))),
                                     .symbols([])])
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [tune, tune])
        let output = try format(book)

        #expect(output.contains("X:1\n"))
        #expect(output.contains("X:2\n"))
    }

    @Test
    func tune_misplacedBodyFieldInHeader_throws() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.alignedLyrics(makeAlignedLyrics())),
                                                         .field(.key(makeKeySignature(.c, .major)))])])

        #expect(throws: ABCFormatter.Error.misplacedTuneField(.alignedLyrics(makeAlignedLyrics()))) {
            try ABCFormatter().format(book)
        }
    }

    @Test
    func tune_missingKeySignature_throws() throws {
        let note = makeNote(makePitch(.c, .natural, 4), makeDuration(1, 8), false)
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.title("Test")),
                                                         .symbols([.note(note)])])])

        #expect(throws: ABCFormatter.Error.missingKeySignature) {
            try ABCFormatter().format(book)
        }
    }

    @Test
    func tune_missingRefNumber_throws() throws {
        // X: is present but misplaced (not first field) — still throws.
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.title("Bad")),
                                                         .field(.refNumber(makeRefNumber(1))),
                                                         .field(.key(makeKeySignature(.c, .major)))])])

        #expect(throws: ABCFormatter.Error.missingReferenceNumber) {
            try ABCFormatter().format(book)
        }
    }

    @Test
    func tune_noRefNumber_autoAssigns1() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.title("Test")),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .symbols([])])])

        #expect(try format(book).contains("X:1\n"))
    }

    @Test
    func tune_partialMissingRefNumbers_skipsExistingNumbers() throws {
        // Tunes with X:3 and X:5 intermixed with tunes missing X:.
        // Missing tunes should be assigned X:1 and X:2, skipping 3 and 5.
        let withKey = ABCTune(entries: [.field(.key(makeKeySignature(.c, .major))),
                                        .symbols([])])
        let withX3 = ABCTune(entries: [.field(.refNumber(makeRefNumber(3)))] + withKey.entries)
        let withX5 = ABCTune(entries: [.field(.refNumber(makeRefNumber(5)))] + withKey.entries)
        let noX = ABCTune(entries: [.field(.title("Test"))] + withKey.entries)
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [withX3, noX, withX5, noX])
        let output = try format(book)
        let xLines = output.components(separatedBy: "\n").filter { $0.hasPrefix("X:") }

        #expect(xLines == ["X:3", "X:1", "X:5", "X:2"])
    }

    @Test
    func tuplet_pAndQ_emitsPQ() throws {
        let output = try format(minimalTunebook(symbols: [.tuplet(makeTuplet(3, 2))]))

        #expect(output.contains("(3:2\n"))
    }

    @Test
    func tuplet_pOnly_emitsBareP() throws {
        let output = try format(minimalTunebook(symbols: [.tuplet(makeTuplet(3))]))

        #expect(output.contains("(3\n"))
    }

    @Test
    func tuplet_pQAndR_emitsFullForm() throws {
        let output = try format(minimalTunebook(symbols: [.tuplet(makeTuplet(3, 2, 3))]))

        #expect(output.contains("(3:2:3\n"))
    }

    @Test
    func variantEnding_emitsBracketForm() throws {
        let output = try format(minimalTunebook(symbols: [.variantEnding(makeVariantEnding([1...1]))]))

        #expect(output.contains("[1\n"))
    }

    @Test
    func variantEnding_list_emitsCommaForm() throws {
        let output = try format(minimalTunebook(symbols: [.variantEnding(makeVariantEnding([1...1, 3...3]))]))

        #expect(output.contains("[1,3\n"))
    }

    @Test
    func variantEnding_range_emitsDashForm() throws {
        let output = try format(minimalTunebook(symbols: [.variantEnding(makeVariantEnding([1...3]))]))

        #expect(output.contains("[1-3\n"))
    }

    @Test
    func voice_emptyID_throws() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.voice(makeVoice(""))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .symbols([])])])

        #expect(throws: ABCFormatter.Error.emptyVoiceID) {
            try ABCFormatter().format(book)
        }
    }

    @Test
    func voice_simple_emitsIDOnly() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.voice(makeVoice("V1"))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .symbols([])])])

        #expect(try format(book).contains("V:V1\n"))
    }

    @Test
    func unsupportedVersion_throws() {
        let book = ABCTunebook(version: makeVersion(1, 6),
                               headers: [],
                               tunes: [])

        #expect(throws: ABCFormatter.Error.unsupportedVersion(makeVersion(1, 6))) {
            try format(book)
        }
    }

    @Test
    func voice_withProperties_sortedAlphabetically() throws {
        let book = ABCTunebook(version: makeVersion(2, 1),
                               headers: [],
                               tunes: [ABCTune(entries: [.field(.refNumber(makeRefNumber(1))),
                                                         .field(.voice(makeVoice("V1", ["name": "Violin",
                                                                                        "clef": "treble"]))),
                                                         .field(.key(makeKeySignature(.c, .major))),
                                                         .symbols([])])])
        let output = try format(book)

        #expect(output.contains("V:V1 clef=treble name=Violin\n"))
    }
}
