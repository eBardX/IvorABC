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
    func validate_notNormalized_throwsNotNormalized() {
        let tunebook = makeTunebook([makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(throws: ABCValidator.Error.notNormalized) {
            try ABCValidator().validate(tunebook)
        }
    }

    @Test
    func validate_cleanNormalized_returnsNoIssues() throws {
        let (_, issues) = try ABCValidator().validate(minimalTunebook().normalized())

        #expect(issues.isEmpty)
    }

    @Test
    func validate_alreadyValidated_shortCircuits() throws {
        let normalized = minimalTunebook().normalized()
        let (validated, _) = try ABCValidator().validate(normalized)

        #expect(validated.isValidated)

        let (again, issues) = try ABCValidator().validate(validated)

        #expect(again.isValidated)
        #expect(issues.isEmpty)
    }

    @Test
    func validate_setsIsValidated_whenNoErrors() throws {
        let (validated, _) = try ABCValidator().validate(minimalTunebook().normalized())

        #expect(validated.isValidated)
    }

    @Test
    func validate_doesNotSetIsValidated_whenErrors() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
            .normalized()
        let (returned, issues) = try ABCValidator().validate(tunebook)

        #expect(!issues.isEmpty)
        #expect(!returned.isValidated)
    }

    @Test
    func validate_undefinedShorthand_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_predefinedShorthand_noExplicitDefinition_returnsNoError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.tUpper),
                                                               .shorthand(.tilde),
                                                               .shorthand(.hUpper)])])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues.isEmpty)
    }

    @Test
    func validate_definedShorthand_returnsNoError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.nUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues.isEmpty)
    }

    @Test
    func validate_annotationDefinedShorthand_returnsNoError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.nUpper, makeAnnotation(.above, "pizz"))))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues.isEmpty)
    }

    @Test
    func validate_deassignedPredefinedShorthand_withoutExplicitDefinition_returnsError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tilde)))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.tilde)])])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 0)])
    }

    @Test
    func validate_tuneScope_override_revertsForSubsequentTune() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Tune1")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("mordent"))))],
                                              body: []),
                                     makeTune(header: [.field(.referenceNumber(makeReferenceNumber(2))),
                                                       .field(.tuneTitle("Tune2"))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues.isEmpty)
    }

    @Test
    func validate_deassignedShorthand_globalScope_returnsError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill")))),
                                     .field(.userDefined(makeUserSymbol(.tUpper)))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 0)])
    }

    @Test
    func validate_deassignedShorthand_tuneScope_returnsError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper)))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 0)])
    }

    @Test
    func validate_deassignedShorthand_tuneScope_doesNotAffectSubsequentTune() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Tune1")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper)))],
                                              body: []),
                                     makeTune(header: [.field(.referenceNumber(makeReferenceNumber(2))),
                                                       .field(.tuneTitle("Tune2"))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues.isEmpty)
    }

    @Test
    func validate_dotShorthand_alwaysValid() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.dot)])])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues.isEmpty)
    }

    @Test
    func validate_plusDecorationInBody_afterNormalization_returnsNoIssues() throws {
        let (_, issues) = try ABCValidator().validate(minimalTunebook(symbols: [.decoration(makeDecoration("trill", .plus))])
                .normalized())

        #expect(issues.isEmpty)
    }

    @Test
    func validate_tuneIndex_isCorrect() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("First Tune"))]),
                                     makeTune(header: [.field(.referenceNumber(makeReferenceNumber(2))),
                                                       .field(.tuneTitle("Second Tune"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 1)])
    }

    @Test
    func validate_preservesIsNormalized() throws {
        let normalized = minimalTunebook().normalized()
        let (validated, _) = try ABCValidator().validate(normalized)

        #expect(validated.isNormalized)
        #expect(validated.isValidated)
    }

    @Test
    func validate_canonicalPipeline_parse_normalized_validated_yieldsTT() throws {
        // parse → normalized() → ABCValidator().validate(_:) must reach (T,T) for clean input
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n"
        let parsed = try ABCParser().parse(Data(input.utf8))
        let (validated, issues) = try ABCValidator().validate(parsed.normalized())

        #expect(validated.isNormalized)
        #expect(validated.isValidated)
        #expect(issues.isEmpty)
    }

    // MARK: - Field placement and reference number checks

    @Test
    func validate_misplacedFileHeaderField_returnsError() throws {
        let tunebook = makeTunebook([.field(.tuneTitle("Bad"))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues == [.misplacedFileHeaderField(.tuneTitle("Bad"))])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_misplacedTuneField_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.wordsAligned(makeAlignedWords())),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues == [.misplacedTuneField(.wordsAligned(makeAlignedWords()), tuneIndex: 0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_missingReferenceNumber_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("No X")),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues == [.missingReferenceNumber(tuneIndex: 0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_misplacedReferenceNumber_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Bad")),
                                                       .field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try ABCValidator().validate(tunebook.normalized())

        #expect(issues == [.misplacedReferenceNumber(tuneIndex: 0)])
        #expect(!issues[0].message.isEmpty)
    }
}
