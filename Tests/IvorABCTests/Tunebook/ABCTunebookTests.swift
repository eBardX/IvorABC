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
        let a = ABCTunebook(version: version, headers: [], tunes: [])
        let b = ABCTunebook(version: version, headers: [], tunes: [])

        #expect(a == b)
    }

    @Test
    func inequality() {
        let v21 = makeVersion(2, 1)
        let v20 = makeVersion(2, 0)

        #expect(ABCTunebook(version: v21, headers: [], tunes: []) !=
                ABCTunebook(version: v20, headers: [], tunes: []))

        let header = ABCHeader.field(.composer("Bach"))

        #expect(ABCTunebook(version: v21, headers: [], tunes: []) !=
                ABCTunebook(version: v21, headers: [header], tunes: []))
    }

    @Test
    func migrated_fromV20_returnsCurrentVersion() {
        let v20 = makeVersion(2, 0)
        let current = ABCVersion.current
        let tunebook = ABCTunebook(version: v20, headers: [], tunes: [])

        #expect(tunebook.migrated().version == current)
    }

    @Test
    func migrated_preservesHeadersAndTunes() {
        let v20 = makeVersion(2, 0)
        let header = ABCHeader.field(.composer("J.S. Bach"))
        let tune = ABCTune(entries: [.field(.title("Test"))])
        let tunebook = ABCTunebook(version: v20, headers: [header], tunes: [tune])
        let migrated = tunebook.migrated()

        #expect(migrated.headers == [header])
        #expect(migrated.tunes == [tune])
    }

    @Test
    func migrated_fromCurrentVersion_isNoOp() {
        let current = ABCVersion.current
        let tunebook = ABCTunebook(version: current, headers: [], tunes: [])

        #expect(tunebook.migrated() == tunebook)
    }

    @Test
    func migrated_fromV16_returnsCurrentVersion() {
        let v16 = makeVersion(1, 6)
        let tunebook = ABCTunebook(version: v16, headers: [], tunes: [])

        #expect(tunebook.migrated().version == ABCVersion.current)
    }

    @Test
    func migrated_fromV16_elemskipBecomesRemark() {
        let v16 = makeVersion(1, 6)
        let tune = ABCTune(entries: [.field(.elemskip(.integer(3)))])
        let tunebook = ABCTunebook(version: v16, headers: [], tunes: [tune])
        let migrated = tunebook.migrated()

        #expect(migrated.tunes.first?.entries.contains(.field(.remark("3"))) == true)
        #expect(migrated.tunes.first?.entries.contains(.field(.elemskip(.integer(3)))) == false)
    }

    @Test
    func migrated_fromV16_headerInformationBecomesRemark() {
        let v16 = makeVersion(1, 6)
        let tunebook = ABCTunebook(version: v16,
                                   headers: [.field(.information("some info"))],
                                   tunes: [])
        let migrated = tunebook.migrated()

        #expect(migrated.headers.contains(.field(.remark("some info"))) == true)
        #expect(migrated.headers.contains(.field(.information("some info"))) == false)
    }

    @Test
    func migrated_fromV16_tempoLegacyFlagCleared() {
        let v16 = makeVersion(1, 6)
        let dottedQuarter = makeDuration(3, 8)
        let legacyTempo = ABCTempo(durations: [dottedQuarter], rate: 40, text: nil, legacyBeatMultiple: 3)
        let tune = ABCTune(entries: [.field(.tempo(legacyTempo))])
        let tunebook = ABCTunebook(version: v16, headers: [], tunes: [tune])
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
        let tunebook = ABCTunebook(version: makeVersion(2, 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.field(.instruction(directive)),
                                                             .symbols([.decoration(makeDecoration("trill", .plus))])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_bangDecorationInBody_inPlusMode_returnsError() {
        let directive = makeDirective("decoration", "+")
        let tunebook = ABCTunebook(version: makeVersion(2, 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.field(.instruction(directive)),
                                                             .symbols([.decoration(makeDecoration("trill", .bang))])])])
        let issues = tunebook.validate()

        #expect(issues == [.bangDialectDecorationInPlusMode(tuneIndex: 0)])
        #expect(issues[0].severity == .error)
    }

    @Test
    func validate_plusDecorationInUserSymbol_withoutDirective_returnsError() {
        let tunebook = ABCTunebook(version: makeVersion(2, 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.field(.userSymbol(makeUserSymbol(.tUpper, makeDecoration("trill", .plus))))])])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: 0)])
    }

    @Test
    func validate_plusDecorationInSymbolLine_withoutDirective_returnsError() {
        let symbolLine = makeSymbolLine([.decoration(makeDecoration("trill", .plus))])
        let tunebook = ABCTunebook(version: makeVersion(2, 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.field(.symbolLine(symbolLine))])])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: 0)])
    }

    @Test
    func validate_fileHeaderDirective_setsDialectForTune() {
        let directive = makeDirective("decoration", "+")
        let tunebook = ABCTunebook(version: makeVersion(2, 1),
                                   headers: [.directive(directive)],
                                   tunes: [ABCTune(entries: [.symbols([.decoration(makeDecoration("trill", .plus))])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_inlineDirective_affectsSubsequentSymbols() {
        let directive = makeDirective("decoration", "+")
        let tunebook = ABCTunebook(version: makeVersion(2, 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.symbols([.inlineField(.instruction(directive)),
                                                                       .decoration(makeDecoration("trill", .plus))])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_plusDecorationInFileHeader_withoutDirective_returnsError() {
        let tunebook = ABCTunebook(version: makeVersion(2, 1),
                                   headers: [.field(.userSymbol(makeUserSymbol(.tUpper, makeDecoration("trill", .plus))))],
                                   tunes: [])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: nil)])
    }

    @Test
    func validate_tuneIndex_isCorrect() {
        let tunebook = ABCTunebook(version: makeVersion(2, 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: []),
                                           ABCTune(entries: [.symbols([.decoration(makeDecoration("trill", .plus))])])])

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
        let tunebook = ABCTunebook(version: makeVersion(2, 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.field(.macro(macro)),
                                                             .symbols([.macroCall(call)])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_transposingMacro_returnsNoIssues() {
        let macro = makeMacro("~n2", "{A}n{B}n")
        let call = ABCMacroCall(trigger: "~G2", expansion: [])
        let tunebook = ABCTunebook(version: makeVersion(2, 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.field(.macro(macro)),
                                                             .symbols([.macroCall(call)])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func init_storesValues() {
        let version = makeVersion(2, 1)
        let header = ABCHeader.field(.composer("J.S. Bach"))
        let tune = ABCTune(entries: [.field(.title("Test"))])
        let tunebook = ABCTunebook(version: version,
                                   headers: [header],
                                   tunes: [tune])

        #expect(tunebook.version == version)
        #expect(tunebook.headers == [header])
        #expect(tunebook.tunes == [tune])
    }
}
