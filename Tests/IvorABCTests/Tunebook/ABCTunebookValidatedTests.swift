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
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 0)])
        #expect(issues[0].severity == .error)
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validated_predefinedShorthand_noExplicitDefinition_returnsNoError() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.tUpper),
                                                               .shorthand(.tilde),
                                                               .shorthand(.hUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues.isEmpty)
    }

    @Test
    func validated_definedShorthand_returnsNoError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.nUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues.isEmpty)
    }

    @Test
    func validated_annotationDefinedShorthand_returnsNoError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.nUpper, makeAnnotation(.above, "pizz"))))],
                                    [makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues.isEmpty)
    }

    @Test
    func validated_deassignedPredefinedShorthand_withoutExplicitDefinition_returnsError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tilde)))],
                                    [makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.tilde)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 0)])
    }

    @Test
    func validated_tuneScope_override_revertsForSubsequentTune() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Tune1")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("mordent"))))],
                                              body: []),
                                     makeTune(header: [.field(.tuneTitle("Tune2"))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues.isEmpty)
    }

    @Test
    func validated_deassignedShorthand_globalScope_returnsError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill")))),
                                     .field(.userDefined(makeUserSymbol(.tUpper)))],
                                    [makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 0)])
    }

    @Test
    func validated_deassignedShorthand_tuneScope_returnsError() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.tuneTitle("Test")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper)))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 0)])
    }

    @Test
    func validated_deassignedShorthand_tuneScope_doesNotAffectSubsequentTune() throws {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.tuneTitle("Tune1")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper)))],
                                              body: []),
                                     makeTune(header: [.field(.tuneTitle("Tune2"))],
                                              body: [.symbols([.shorthand(.tUpper)])])])
        let (_, issues) = try tunebook.normalized().validated()

        #expect(issues.isEmpty)
    }

    @Test
    func validated_dotShorthand_alwaysValid() throws {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Test"))],
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
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("First Tune"))]),
                                     makeTune(header: [.field(.tuneTitle("Second Tune"))],
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
        #expect(!issues.contains { $0.severity == .error })
    }

    // MARK: - Defensive legacy-construct re-check

    @Test
    func validated_legacyElemskipField_returnsError() throws {
        let tune = ABCTune(header: [.field(.elemskip(.integer(3)))],
                           body: []).require()
        let tunebook = ABCTunebook(version: .current,
                                   fileHeader: [],
                                   tunes: [tune],
                                   isNormalized: true,
                                   isValidated: false)
        let (_, issues) = try tunebook.validated()

        #expect(issues == [.legacyElemskipField(tuneIndex: 0)])
        #expect(issues[0].severity == .error)
    }

    @Test
    func validated_legacyInformationField_returnsError() throws {
        let tune = ABCTune(header: [.field(.information("some info"))],
                           body: []).require()
        let tunebook = ABCTunebook(version: .current,
                                   fileHeader: [],
                                   tunes: [tune],
                                   isNormalized: true,
                                   isValidated: false)
        let (_, issues) = try tunebook.validated()

        #expect(issues == [.legacyInformationField(tuneIndex: 0)])
    }

    @Test
    func validated_legacyTempoForm_returnsError() throws {
        let legacyTempo = ABCTempo(durations: [makeDuration(1, 4)],
                                   rate: 120,
                                   text: nil,
                                   legacyBeatMultiple: 1).require()
        let tune = ABCTune(header: [.field(.tempo(legacyTempo))],
                           body: []).require()
        let tunebook = ABCTunebook(version: .current,
                                   fileHeader: [],
                                   tunes: [tune],
                                   isNormalized: true,
                                   isValidated: false)
        let (_, issues) = try tunebook.validated()

        #expect(issues == [.legacyTempoForm(tuneIndex: 0)])
    }

    @Test
    func validated_legacyCharsetDirective_returnsError() throws {
        let directive = makeDirective("abc-charset", "utf-8")
        let tune = ABCTune(header: [.field(.key(makeKeySignature(.c, .major)))],
                           body: []).require()
        let tunebook = ABCTunebook(version: .current,
                                   fileHeader: [.directive(directive)],
                                   tunes: [tune],
                                   isNormalized: true,
                                   isValidated: false)
        let (_, issues) = try tunebook.validated()

        #expect(issues == [.legacyCharsetDirective(tuneIndex: nil)])
    }

    @Test
    func validated_legacyVersionDirective_returnsError() throws {
        let directive = makeDirective("abc-version", "2.1")
        let tune = ABCTune(header: [.field(.key(makeKeySignature(.c, .major)))],
                           body: []).require()
        let tunebook = ABCTunebook(version: .current,
                                   fileHeader: [.directive(directive)],
                                   tunes: [tune],
                                   isNormalized: true,
                                   isValidated: false)
        let (_, issues) = try tunebook.validated()

        #expect(issues == [.legacyVersionDirective(tuneIndex: nil)])
    }

    @Test
    func validated_legacyDecorationDirective_returnsError() throws {
        let directive = makeDirective("decoration", "+")
        let tune = ABCTune(header: [.directive(directive),
                                    .field(.key(makeKeySignature(.c, .major)))],
                           body: []).require()
        let tunebook = ABCTunebook(version: .current,
                                   fileHeader: [],
                                   tunes: [tune],
                                   isNormalized: true,
                                   isValidated: false)
        let (_, issues) = try tunebook.validated()

        #expect(issues == [.legacyDecorationDirective(tuneIndex: 0)])
    }
}
