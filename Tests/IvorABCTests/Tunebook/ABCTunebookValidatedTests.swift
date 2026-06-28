// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorABC
import Testing
import XestiTools

struct ABCTunebookValidatedTests {
}

// MARK: -

extension ABCTunebookValidatedTests {
    @Test
    func validated_notNormalized_throwsNotNormalized() {
        let tunebook = makeTunebook([makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(throws: ABCValidationError.notNormalized) {
            try tunebook.validated()
        }
    }

    @Test
    func validated_cleanNormalized_returnsNoIssues() throws {
        let (_, issues) = try minimalTunebook().normalized().validated()

        #expect(issues.isEmpty)
    }

    @Test
    func validated_alreadyValidated_shortCircuits() throws {
        let normalized = minimalTunebook().normalized()
        let (validated, _) = try normalized.validated()

        #expect(validated.isValidated)

        let (again, issues) = try validated.validated()

        #expect(again.isValidated)
        #expect(issues.isEmpty)
    }

    @Test
    func validated_setsIsValidated_whenNoErrors() throws {
        let (validated, _) = try minimalTunebook().normalized().validated()

        #expect(validated.isValidated)
    }

    @Test
    func validated_doesNotSetIsValidated_whenErrors() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
            .normalized()
        let (returned, issues) = try tunebook.validated()

        #expect(!issues.isEmpty)
        #expect(!returned.isValidated)
    }

    @Test
    func validated_undefinedShorthand_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validated_predefinedShorthand_noExplicitDefinition_returnsNoError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.tUpper),
                                                               .shorthand(.tilde),
                                                               .shorthand(.hUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues.isEmpty)
    }

    @Test
    func validated_definedShorthand_returnsNoError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.nUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues.isEmpty)
    }

    @Test
    func validated_annotationDefinedShorthand_returnsNoError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.nUpper, makeAnnotation(.above, "pizz"))))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues.isEmpty)
    }

    @Test
    func validated_deassignedPredefinedShorthand_withoutExplicitDefinition_returnsError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tilde)))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.tilde)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 0)])
    }

    @Test
    func validated_tuneScope_override_revertsForSubsequentTune() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Tune1")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("mordent"))))],
                                              body: []),
                                     makeTune(header: [.field(.referenceNumber(makeReferenceNumber(2))),
                                                       .field(.tuneTitle("Tune2"))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues.isEmpty)
    }

    @Test
    func validated_deassignedShorthand_globalScope_returnsError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill")))),
                                     .field(.userDefined(makeUserSymbol(.tUpper)))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 0)])
    }

    @Test
    func validated_deassignedShorthand_tuneScope_returnsError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper)))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 0)])
    }

    @Test
    func validated_deassignedShorthand_tuneScope_doesNotAffectSubsequentTune() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Tune1")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper)))],
                                              body: []),
                                     makeTune(header: [.field(.referenceNumber(makeReferenceNumber(2))),
                                                       .field(.tuneTitle("Tune2"))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues.isEmpty)
    }

    @Test
    func validated_dotShorthand_alwaysValid() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.dot)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues.isEmpty)
    }

    @Test
    func validated_plusDecorationInBody_afterNormalization_returnsNoIssues() throws {
        let (_, issues) = try minimalTunebook(symbols: [.decoration(makeDecoration("trill", .plus))])
            .normalized()
            .validated()

        #expect(issues.isEmpty)
    }

    @Test
    func validated_tuneIndex_isCorrect() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("First Tune"))]),
                                     makeTune(header: [.field(.referenceNumber(makeReferenceNumber(2))),
                                                       .field(.tuneTitle("Second Tune"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 1)])
    }

    @Test
    func validated_preservesIsNormalized() throws {
        let normalized = minimalTunebook().normalized()
        let (validated, _) = try normalized.validated()

        #expect(validated.isNormalized)
        #expect(validated.isValidated)
    }

    @Test
    func validated_canonicalPipeline_parse_normalized_validated_yieldsTT() throws {
        // parse → normalized() → validated() must reach (T,T) for a clean input
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n"
        let parsed = try ABCParser().parse(Data(input.utf8))
        let (validated, issues) = try parsed.normalized().validated()

        #expect(validated.isNormalized)
        #expect(validated.isValidated)
        #expect(issues.isEmpty)
    }

    // MARK: - Field placement and reference number checks

    @Test
    func validated_misplacedFileHeaderField_returnsError() throws {
        let tunebook = makeTunebook([.field(.tuneTitle("Bad"))],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues == [.misplacedFileHeaderField(.tuneTitle("Bad"))])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validated_misplacedTuneField_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.wordsAligned(makeAlignedWords())),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues == [.misplacedTuneField(.wordsAligned(makeAlignedWords()), tuneIndex: 0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validated_missingReferenceNumber_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("No X")),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues == [.missingReferenceNumber(tuneIndex: 0)])
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validated_misplacedReferenceNumber_returnsError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Bad")),
                                                       .field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues == [.misplacedReferenceNumber(tuneIndex: 0)])
        #expect(!issues[0].message.isEmpty)
    }
}
