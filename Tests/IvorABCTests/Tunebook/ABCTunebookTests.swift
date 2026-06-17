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
        let tune = makeTune([.field(.key(makeKeySignature(.c, .major)))])
        let a = makeTunebook(version, [tune])
        let b = makeTunebook(version, [tune])

        #expect(a == b)
    }

    @Test
    func inequality() {
        let v21 = makeVersion(2, 1)
        let v20 = makeVersion(2, 0)
        let tune = makeTune([.field(.key(makeKeySignature(.c, .major)))])

        #expect(makeTunebook(v21, [tune]) !=
                makeTunebook(v20, [tune]))

        let header = ABCHeader.field(.composer("Bach"))

        #expect(makeTunebook(v21, [tune]) !=
                makeTunebook(v21, [header], [tune]))
    }

    @Test
    func migrated_fromV20_returnsCurrentVersion() {
        let v20 = makeVersion(2, 0)
        let current = ABCVersion.current
        let tunebook = makeTunebook(v20,
                                    [makeTune([.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.migrated().version == current)
    }

    @Test
    func migrated_preservesHeadersAndTunes() {
        let v20 = makeVersion(2, 0)
        let header = ABCHeader.field(.composer("J.S. Bach"))
        let tune = makeTune([.field(.title("Test"))])
        let tunebook = makeTunebook(v20, [header], [tune])
        let migrated = tunebook.migrated()

        #expect(migrated.headers == [header])
        #expect(migrated.tunes == [tune])
    }

    @Test
    func migrated_fromCurrentVersion_isNoOp() {
        let current = ABCVersion.current
        let tunebook = makeTunebook(current,
                                    [makeTune([.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.migrated() == tunebook)
    }

    @Test
    func migrated_fromV16_returnsCurrentVersion() {
        let v16 = makeVersion(1, 6)
        let tunebook = makeTunebook(v16,
                                    [makeTune([.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.migrated().version == ABCVersion.current)
    }

    @Test
    func migrated_fromV16_elemskipBecomesRemark() {
        let v16 = makeVersion(1, 6)
        let tune = makeTune([.field(.elemskip(.integer(3)))])
        let tunebook = makeTunebook(v16, [tune])
        let migrated = tunebook.migrated()

        #expect(migrated.tunes.first?.entries.contains(.field(.remark("3"))) == true)
        #expect(migrated.tunes.first?.entries.contains(.field(.elemskip(.integer(3)))) == false)
    }

    @Test
    func migrated_fromV16_headerInformationBecomesRemark() {
        let v16 = makeVersion(1, 6)
        let tunebook = makeTunebook(v16,
                                    [.field(.information("some info"))],
                                    [makeTune([.field(.key(makeKeySignature(.c, .major)))])])
        let migrated = tunebook.migrated()

        #expect(migrated.headers.contains(.field(.remark("some info"))) == true)
        #expect(migrated.headers.contains(.field(.information("some info"))) == false)
    }

    @Test
    func migrated_fromV16_tempoLegacyFlagCleared() {
        let v16 = makeVersion(1, 6)
        let dottedQuarter = makeDuration(3, 8)
        let legacyTempo = ABCTempo(durations: [dottedQuarter], rate: 40, text: nil, legacyBeatMultiple: 3)
        let tune = makeTune([.field(.tempo(legacyTempo))])
        let tunebook = makeTunebook(v16, [tune])
        let migrated = tunebook.migrated()

        let migratedTempo = migrated.tunes.first?.entries.compactMap { entry -> ABCTempo? in
            guard case let .field(f) = entry, case let .tempo(t) = f
            else { return nil }

            return t
        }.first

        #expect(migratedTempo?.legacyBeatMultiple == nil)
        #expect(migratedTempo?.durations == [dottedQuarter])
        #expect(migratedTempo?.rate == 40)
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
        let tunebook = makeTunebook([makeTune([.field(.instruction(directive)),
                                               .symbols([.decoration(makeDecoration("trill", .plus))])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_bangDecorationInBody_inPlusMode_returnsError() {
        let directive = makeDirective("decoration", "+")
        let tunebook = makeTunebook([makeTune([.field(.instruction(directive)),
                                               .symbols([.decoration(makeDecoration("trill", .bang))])])])
        let issues = tunebook.validate()

        #expect(issues == [.bangDialectDecorationInPlusMode(tuneIndex: 0)])
        #expect(issues[0].severity == .error)
    }

    @Test
    func validate_plusDecorationInUserSymbol_withoutDirective_returnsError() {
        let tunebook = makeTunebook([makeTune([.field(.userSymbol(makeUserSymbol(.tUpper, makeDecoration("trill", .plus))))])])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: 0)])
    }

    @Test
    func validate_plusDecorationInSymbolLine_withoutDirective_returnsError() {
        let symbolLine = makeSymbolLine([.decoration(makeDecoration("trill", .plus))])
        let tunebook = makeTunebook([makeTune([.field(.symbolLine(symbolLine))])])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: 0)])
    }

    @Test
    func validate_fileHeaderDirective_setsDialectForTune() {
        let directive = makeDirective("decoration", "+")
        let tunebook = makeTunebook([.directive(directive)],
                                    [makeTune([.symbols([.decoration(makeDecoration("trill", .plus))])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_inlineDirective_affectsSubsequentSymbols() {
        let directive = makeDirective("decoration", "+")
        let tunebook = makeTunebook([makeTune([.symbols([.inlineField(.instruction(directive)),
                                                         .decoration(makeDecoration("trill", .plus))])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_plusDecorationInFileHeader_withoutDirective_returnsError() {
        let tunebook = makeTunebook([.field(.userSymbol(makeUserSymbol(.tUpper, makeDecoration("trill", .plus))))],
                                    [makeTune([.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: nil)])
    }

    @Test
    func validate_tuneIndex_isCorrect() {
        let tunebook = makeTunebook([makeTune([.field(.title("First Tune"))]),
                                     makeTune([.symbols([.decoration(makeDecoration("trill", .plus))])])])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: 1)])
    }

    @Test
    func validate_undefinedMacro_returnsError() {
        let call = ABCMacroCall(trigger: "~G2", expansion: [])
        let tunebook = minimalTunebook(symbols: [.macroCall(call)])
        let issues = tunebook.validate()

        #expect(issues == [.undefinedMacro(tuneIndex: 0)])
        #expect(issues[0].severity == .error)
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_definedMacro_returnsNoIssues() {
        let macro = makeMacro("~G2", "{A}G{F}G")
        let call = ABCMacroCall(trigger: "~G2", expansion: [])
        let tunebook = makeTunebook([makeTune([.field(.macro(macro)),
                                               .symbols([.macroCall(call)])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_transposingMacro_returnsNoIssues() {
        let macro = makeMacro("~n2", "{A}n{B}n")
        let call = ABCMacroCall(trigger: "~G2", expansion: [])
        let tunebook = makeTunebook([makeTune([.field(.macro(macro)),
                                               .symbols([.macroCall(call)])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func init_withEmptyTunes_returnsNil() {
        #expect(ABCTunebook(version: makeVersion(2, 1), headers: [], tunes: []) == nil)
    }

    @Test
    func init_storesValues() {
        let version = makeVersion(2, 1)
        let header = ABCHeader.field(.composer("J.S. Bach"))
        let tune = makeTune([.field(.title("Test"))])
        let tunebook = makeTunebook(version, [header], [tune])

        #expect(tunebook.version == version)
        #expect(tunebook.headers == [header])
        #expect(tunebook.tunes == [tune])
    }
}
