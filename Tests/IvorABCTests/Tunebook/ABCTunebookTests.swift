// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCTunebookTests {
}

// MARK: -

extension ABCTunebookTests {
    @Test
    func equality() {
        let version = makeVersion(2, 1)
        let tune = makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])
        let a = makeTunebook(version, [tune])
        let b = makeTunebook(version, [tune])

        #expect(a == b)
    }

    @Test
    func inequality() {
        let v21 = makeVersion(2, 1)
        let v20 = makeVersion(2, 0)
        let tune = makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])

        #expect(makeTunebook(v21, [tune]) !=
                makeTunebook(v20, [tune]))

        let header = ABCHeaderEntry.field(.composer("Bach"))

        #expect(makeTunebook(v21, [tune]) !=
                makeTunebook(v21, [header], [tune]))
    }

    @Test
    func validate_cleanTunebook_returnsNoIssues() {
        #expect(minimalTunebook().validate().isEmpty)
    }

    @Test
    func validate_plusDecorationInBody_withoutDirective_returnsError() {
        let tunebook = minimalTunebook(symbols: [.decoration(makeDecoration("trill", .plus))])
        let issues = tunebook.validate()

        #expect(issues == [.plusDialectDecorationWithoutDirective(tuneIndex: 0)])
        #expect(issues[0].severity == .error)
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_plusDecorationInBody_withDirective_returnsNoIssues() {
        let directive = makeDirective("decoration", "+")
        let tunebook = makeTunebook([makeTune(header: [.field(.instruction(directive))],
                                              body: [.symbols([.decoration(makeDecoration("trill", .plus))])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_bangDecorationInBody_inPlusMode_returnsError() {
        let directive = makeDirective("decoration", "+")
        let tunebook = makeTunebook([makeTune(header: [.field(.instruction(directive))],
                                              body: [.symbols([.decoration(makeDecoration("trill", .bang))])])])
        let issues = tunebook.validate()

        #expect(issues == [.bangDialectDecorationInPlusMode(tuneIndex: 0)])
        #expect(issues[0].severity == .error)
    }

    @Test
    func validate_plusDecorationInUserSymbol_withoutDirective_returnsError() {
        let tunebook = makeTunebook([makeTune(header: [.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill", .plus))))])])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: 0)])
    }

    @Test
    func validate_plusDecorationInSymbolLine_withoutDirective_returnsError() {
        let symbolLine = makeSymbolLine([.decoration(makeDecoration("trill", .plus))])
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(ABCReferenceNumber(1)))],
                                              body: [.field(.symbolLine(symbolLine))])])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: 0)])
    }

    @Test
    func validate_fileHeaderDirective_setsDialectForTune() {
        let directive = makeDirective("decoration", "+")
        let tunebook = makeTunebook([.directive(directive)],
                                    [makeTune(header: [.field(.referenceNumber(ABCReferenceNumber(1)))],
                                              body: [.symbols([.decoration(makeDecoration("trill", .plus))])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_inlineDirective_affectsSubsequentSymbols() {
        let directive = makeDirective("decoration", "+")
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(ABCReferenceNumber(1)))],
                                              body: [.symbols([.inlineField(.instruction(directive)),
                                                               .decoration(makeDecoration("trill", .plus))])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_plusDecorationInFileHeader_withoutDirective_returnsError() {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill", .plus))))],
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: nil)])
    }

    @Test
    func validate_tuneIndex_isCorrect() {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("First Tune"))]),
                                     makeTune(header: [.field(.referenceNumber(ABCReferenceNumber(1)))],
                                              body: [.symbols([.decoration(makeDecoration("trill", .plus))])])])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: 1)])
    }

    @Test
    func validate_undefinedShorthand_returnsError() {
        // N has no predefined meaning and no U: definition
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])

        #expect(tunebook.validate() == [.undefinedUserSymbol(tuneIndex: 0)])
    }

    @Test
    func validate_predefinedShorthand_noExplicitDefinition_returnsNoError() {
        // Standard shorthands (~, H, L, M, O, P, S, T, u, v) are valid without U:
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.tUpper),
                                                               .shorthand(.tilde),
                                                               .shorthand(.hUpper)])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_definedShorthand_returnsNoError() {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.nUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_annotationDefinedShorthand_returnsNoError() {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.nUpper, makeAnnotation(.above, "pizz"))))],
                                    [makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.nUpper)])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_deassignedPredefinedShorthand_withoutExplicitDefinition_returnsError() {
        // ~ is predefined as !roll!; de-assigning it at file-header level makes it undefined
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tilde)))],
                                    [makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.tilde)])])])

        #expect(tunebook.validate() == [.undefinedUserSymbol(tuneIndex: 0)])
    }

    @Test
    func validate_tuneScope_override_revertsForSubsequentTune() {
        // Tune 1 overrides T; Tune 2 sees the predefined default restored
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Tune1")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("mordent"))))],
                                              body: []),
                                     makeTune(header: [.field(.tuneTitle("Tune2"))],
                                              body: [.symbols([.shorthand(.tUpper)])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_deassignedShorthand_globalScope_returnsError() {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill")))),
                                     .field(.userDefined(makeUserSymbol(.tUpper)))],
                                    [makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.tUpper)])])])

        #expect(tunebook.validate() == [.undefinedUserSymbol(tuneIndex: 0)])
    }

    @Test
    func validate_deassignedShorthand_tuneScope_returnsError() {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.tuneTitle("Test")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper)))],
                                              body: [.symbols([.shorthand(.tUpper)])])])

        #expect(tunebook.validate() == [.undefinedUserSymbol(tuneIndex: 0)])
    }

    @Test
    func validate_deassignedShorthand_tuneScope_doesNotAffectSubsequentTune() {
        let tunebook = makeTunebook([.field(.userDefined(makeUserSymbol(.tUpper, makeDecoration("trill"))))],
                                    [makeTune(header: [.field(.tuneTitle("Tune1")),
                                                       .field(.userDefined(makeUserSymbol(.tUpper)))],
                                              body: []),
                                     makeTune(header: [.field(.tuneTitle("Tune2"))],
                                              body: [.symbols([.shorthand(.tUpper)])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_dotShorthand_alwaysValid() {
        let tunebook = makeTunebook([makeTune(header: [.field(.tuneTitle("Test"))],
                                              body: [.symbols([.shorthand(.dot)])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func init_withEmptyTunes_returnsNil() {
        #expect(ABCTunebook(version: makeVersion(2, 1), fileHeader: [], tunes: []) == nil)
    }

    @Test
    func init_storesValues() {
        let version = makeVersion(2, 1)
        let header = ABCHeaderEntry.field(.composer("J.S. Bach"))
        let tune = makeTune(header: [.field(.tuneTitle("Test"))])
        let tunebook = makeTunebook(version, [header], [tune])

        #expect(tunebook.version == version)
        #expect(tunebook.fileHeader == [header])
        #expect(tunebook.tunes == [tune])
    }
}
