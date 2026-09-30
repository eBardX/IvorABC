// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorABC
import Testing
import XestiTools

struct ABCValidatorTests {
}

// MARK: -

extension ABCValidatorTests {
    @Test
    func validate_alreadyValidated_shortCircuits() throws {
        let (normalized, _) = ABCNormalizer().normalize(minimalTunebook())
        let (validated, _) = try ABCValidator().validate(normalized)

        #expect(validated.isValidated)

        let (again, issues) = try ABCValidator().validate(validated)

        #expect(again.isValidated)
        #expect(issues.isEmpty)
    }

    @Test
    func validate_annotationDefinedShorthand_returnsNoError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.nUpper, makeAnnotation(.above, "pizz"))))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_canonicalPipeline_parse_normalize_validate_yieldsTT() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n"
        let (parsed, _) = try ABCParser().parse(Data(input.utf8))
        let (validated, issues) = try ABCValidator().validate(ABCNormalizer().normalize(parsed).0)

        #expect(validated.isNormalized)
        #expect(validated.isValidated)
        #expect(issues.isEmpty)
    }

    @Test
    func validate_chordSymbolPendingAcrossVoiceSwitch_thenDuplicated_returnsError() throws {
        let t1 = makeVoice("T1")
        let t2 = makeVoice("T2")
        let cs1 = ABCChordSymbol(name: .init(root: .a, kind: "m"))
        let cs2 = ABCChordSymbol(name: .init(root: .g))
        let note1 = makeNote(makePitch(.c, .natural, 4), makeLength(1, 4))
        let note2 = makeNote(makePitch(.d, .natural, 4), makeLength(1, 4))
        // T1 leaves a chord symbol pending (no note yet) before switching to
        // T2, whose own note drains only *its* count; back on T1, a second
        // chord symbol precedes T1's note, which should still be flagged.
        let body: [ABCBodyEntry] = [.field(.voice(t1)),
                                    .symbols([.chordSymbol(cs1)]),
                                    .field(.voice(t2)),
                                    .symbols([.note(note2)]),
                                    .field(.voice(t1)),
                                    .symbols([.chordSymbol(cs2), .note(note1)])]
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: body)])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.multipleChordSymbols(0)])
    }

    @Test
    func validate_chordSymbolsAcrossNotes_returnsNoError() throws {
        let cs1 = ABCChordSymbol(name: .init(root: .a, kind: "m"))
        let cs2 = ABCChordSymbol(name: .init(root: .g))
        let note1 = makeNote(makePitch(.c, .natural, 4), makeLength(1, 4))
        let note2 = makeNote(makePitch(.d, .natural, 4), makeLength(1, 4))
        let tunebook = minimalTunebook(symbols: [.chordSymbol(cs1), .note(note1), .chordSymbol(cs2), .note(note2)])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_chordSymbolsSeparatedByBarLine_returnsNoError() throws {
        let cs1 = ABCChordSymbol(name: .init(root: .a, kind: "m"))
        let cs2 = ABCChordSymbol(name: .init(root: .g))
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1, 4))
        let tunebook = minimalTunebook(symbols: [.chordSymbol(cs1), .barLine(makeBarLine()), .chordSymbol(cs2), .note(note)])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_cleanNormalized_returnsNoIssues() throws {
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(minimalTunebook()).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_consecutiveChordSymbols_returnsError() throws {
        let cs1 = ABCChordSymbol(name: .init(root: .a, kind: "m"))
        let cs2 = ABCChordSymbol(name: .init(root: .g))
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1, 4))
        let tunebook = minimalTunebook(symbols: [.chordSymbol(cs1), .chordSymbol(cs2), .note(note)])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.multipleChordSymbols(0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_consecutiveGraceNotes_returnsError() throws {
        let graceNotes1 = makeGraceNotes([makeNote(makePitch(.g, .natural, 4), makeLength(1, 8))], false)
        let graceNotes2 = makeGraceNotes([makeNote(makePitch(.a, .natural, 4), makeLength(1, 8))], false)
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1, 4))
        let tunebook = minimalTunebook(symbols: [.graceNotes(graceNotes1), .graceNotes(graceNotes2), .note(note)])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.multipleGraceNotes(0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_deassignedPredefinedShorthand_withoutExplicitDefinition_returnsError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tilde)))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.shorthand(.tilde)])])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.undefinedUserSymbol(0)])
    }

    @Test
    func validate_deassignedShorthand_globalScope_returnsError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill")))),
                                     .field(.userDefined(makeUserSymbol(.tUpper)))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.undefinedUserSymbol(0)])
    }

    @Test
    func validate_deassignedShorthand_tuneScope_doesNotAffectSubsequentTune() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Tune1")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper))),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: []),
                                     makeTune(header: [.field(.referenceNumber(makeReferenceNumber(2))),
                                                       .field(.tuneTitle("Tune2")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_deassignedShorthand_tuneScope_returnsError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper))),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.undefinedUserSymbol(0)])
    }

    @Test
    func validate_definedShorthand_returnsNoError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.nUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_doesNotSetIsValidated_whenErrors() throws {
        let (tunebook, _) = ABCNormalizer().normalize(makeTunebook([makeTune(header: [.field(.tuneTitle("Test")),
                                                                                      .field(.key(makeKeySignature(.c, .major)))],
                                                                             body: [.symbols([.shorthand(.nUpper)])])]))
        let (returned, issues) = try ABCValidator().validate(tunebook)

        #expect(!issues.isEmpty)
        #expect(!returned.isValidated)
    }

    @Test
    func validate_dotShorthand_alwaysValid() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.shorthand(.dot)])])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_invalidInlineField_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.inlineField(.words("la la la"))])])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.invalidInlineField(.words("la la la"), 0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_keyLast_returnsNoError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.composer("Composer")),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_misplacedFileHeaderField_returnsError() throws {
        let tunebook = makeTunebook([.field(.tuneTitle("Bad"))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.misplacedFileHeaderField(.tuneTitle("Bad"))])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_misplacedKey_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major))),
                                                       .field(.composer("Trailing"))])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.misplacedKey(0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_misplacedReferenceNumber_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Bad")),
                                                       .field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.misplacedReferenceNumber(0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_misplacedReferenceNumber_suppressesTuneTitleCheck() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Bad")),
                                                       .field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Also Bad")),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.misplacedReferenceNumber(0)])
    }

    @Test
    func validate_misplacedTuneBodyField_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.field(.composer("Bach"))])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.misplacedTuneBodyField(.composer("Bach"), 0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_misplacedTuneHeaderField_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.wordsAligned(makeAlignedWords())),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.misplacedTuneHeaderField(.wordsAligned(makeAlignedWords()), 0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_misplacedTuneTitle_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.composer("Composer")),
                                                       .field(.tuneTitle("Late")),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.misplacedTuneTitle(0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_missingKey_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.missingKey(0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_missingReferenceNumber_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("No X")),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.missingReferenceNumber(0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_missingTuneTitle_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.missingTuneTitle(0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_multipleChordSymbolsAndGraceNotes_returnsBothErrors() throws {
        let cs1 = ABCChordSymbol(name: .init(root: .a, kind: "m"))
        let cs2 = ABCChordSymbol(name: .init(root: .g))
        let graceNotes1 = makeGraceNotes([makeNote(makePitch(.g, .natural, 4), makeLength(1, 8))], false)
        let graceNotes2 = makeGraceNotes([makeNote(makePitch(.a, .natural, 4), makeLength(1, 8))], false)
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1, 4))
        let tunebook = minimalTunebook(symbols: [.chordSymbol(cs1),
                                                 .graceNotes(graceNotes1),
                                                 .chordSymbol(cs2),
                                                 .graceNotes(graceNotes2),
                                                 .note(note)])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.multipleChordSymbols(0), .multipleGraceNotes(0)])
    }

    @Test
    func validate_nonConsecutiveChordSymbols_returnsError() throws {
        let cs1 = ABCChordSymbol(name: .init(root: .a, kind: "m"))
        let cs2 = ABCChordSymbol(name: .init(root: .g))
        let decoration = makeDecoration("trill")
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1, 4))
        let tunebook = minimalTunebook(symbols: [.chordSymbol(cs1), .decoration(decoration), .chordSymbol(cs2), .note(note)])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.multipleChordSymbols(0)])
    }

    @Test
    func validate_nonConsecutiveGraceNotes_returnsError() throws {
        let graceNotes1 = makeGraceNotes([makeNote(makePitch(.g, .natural, 4), makeLength(1, 8))], false)
        let graceNotes2 = makeGraceNotes([makeNote(makePitch(.a, .natural, 4), makeLength(1, 8))], false)
        let cs = ABCChordSymbol(name: .init(root: .a, kind: "m"))
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1, 4))
        let tunebook = minimalTunebook(symbols: [.graceNotes(graceNotes1), .chordSymbol(cs), .graceNotes(graceNotes2), .note(note)])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.multipleGraceNotes(0)])
    }

    @Test
    func validate_notNormalized_throwsNotNormalized() {
        let tunebook = makeTunebook([makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(throws: ABCValidator.Error.notNormalized) {
            try ABCValidator().validate(tunebook)
        }
    }

    @Test
    func validate_oneChordSymbolPerVoice_interleaved_returnsNoError() throws {
        let t1 = makeVoice("T1")
        let t2 = makeVoice("T2")
        let cs1 = ABCChordSymbol(name: .init(root: .a, kind: "m"))
        let cs2 = ABCChordSymbol(name: .init(root: .g))
        let note1 = makeNote(makePitch(.c, .natural, 4), makeLength(1, 4))
        let note2 = makeNote(makePitch(.d, .natural, 4), makeLength(1, 4))
        let body: [ABCBodyEntry] = [.field(.voice(t1)),
                                    .symbols([.chordSymbol(cs1), .note(note1)]),
                                    .field(.voice(t2)),
                                    .symbols([.chordSymbol(cs2), .note(note2)])]
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: body)])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_plusDecorationInBody_afterNormalization_returnsNoIssues() throws {
        let (tunebook, _) = ABCNormalizer().normalize(minimalTunebook(symbols: [.decoration(makeDecoration("trill", .plus))]))
        let (_, issues) = try ABCValidator().validate(tunebook)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_predefinedShorthand_noExplicitDefinition_returnsNoError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.shorthand(.tUpper),
                                                               .shorthand(.tilde),
                                                               .shorthand(.hUpper)])])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_preservesIsNormalized() throws {
        let (normalized, _) = ABCNormalizer().normalize(minimalTunebook())
        let (validated, _) = try ABCValidator().validate(normalized)

        #expect(validated.isNormalized)
        #expect(validated.isValidated)
    }

    @Test
    func validate_setsIsValidated_whenNoErrors() throws {
        let (validated, _) = try ABCValidator().validate(ABCNormalizer().normalize(minimalTunebook()).0)

        #expect(validated.isValidated)
    }

    @Test
    func validate_singleChordSymbol_returnsNoError() throws {
        let cs = ABCChordSymbol(name: .init(root: .a, kind: "m"))
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1, 4))
        let tunebook = minimalTunebook(symbols: [.chordSymbol(cs), .note(note)])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_singleGraceNotes_returnsNoError() throws {
        let graceNotes = makeGraceNotes([makeNote(makePitch(.g, .natural, 4), makeLength(1, 8))], false)
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1, 4))
        let tunebook = minimalTunebook(symbols: [.graceNotes(graceNotes), .note(note)])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_tuneIndex_isCorrect() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("First Tune")),
                                                       .field(.key(makeKeySignature(.c, .major)))]),
                                     makeTune(header: [.field(.referenceNumber(makeReferenceNumber(2))),
                                                       .field(.tuneTitle("Second Tune")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.undefinedUserSymbol(1)])
    }

    @Test
    func validate_tuneScope_override_revertsForSubsequentTune() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Tune1")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("mordent")))),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: []),
                                     makeTune(header: [.field(.referenceNumber(makeReferenceNumber(2))),
                                                       .field(.tuneTitle("Tune2")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_tuneTitleSecond_returnsNoError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Good")),
                                                       .field(.composer("Composer")),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }

    @Test
    func validate_undefinedShorthand_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues == [.undefinedUserSymbol(0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_validInlineField_returnsNoError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.inlineField(.meter(makeTimeSignature(3, 4)))])])])
        let (_, issues) = try ABCValidator().validate(ABCNormalizer().normalize(tunebook).0)

        #expect(issues.isEmpty)
    }
}
