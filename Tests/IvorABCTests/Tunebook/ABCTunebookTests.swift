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
        let version = ABCVersion(major: 2, minor: 1)
        let a = ABCTunebook(version: version, headers: [], tunes: [])
        let b = ABCTunebook(version: version, headers: [], tunes: [])

        #expect(a == b)
    }

    @Test
    func inequality() {
        let v21 = ABCVersion(major: 2, minor: 1)
        let v20 = ABCVersion(major: 2, minor: 0)

        #expect(ABCTunebook(version: v21, headers: [], tunes: []) !=
                ABCTunebook(version: v20, headers: [], tunes: []))

        let header = ABCHeader.field(.composer("Bach"))

        #expect(ABCTunebook(version: v21, headers: [], tunes: []) !=
                ABCTunebook(version: v21, headers: [header], tunes: []))
    }

    @Test
    func migrated_fromV20_returnsCurrentVersion() {
        let v20 = ABCVersion(major: 2, minor: 0)
        let current = ABCVersion.current
        let tunebook = ABCTunebook(version: v20, headers: [], tunes: [])

        #expect(tunebook.migrated().version == current)
    }

    @Test
    func migrated_preservesHeadersAndTunes() {
        let v20 = ABCVersion(major: 2, minor: 0)
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
        let v16 = ABCVersion(major: 1, minor: 6)
        let tunebook = ABCTunebook(version: v16, headers: [], tunes: [])

        #expect(tunebook.migrated().version == ABCVersion.current)
    }

    @Test
    func migrated_fromV16_legacyFieldBecomesRemark() {
        let v16 = ABCVersion(major: 1, minor: 6)
        let tune = ABCTune(entries: [.field(.legacy("E", "skip value"))])
        let tunebook = ABCTunebook(version: v16, headers: [], tunes: [tune])
        let migrated = tunebook.migrated()

        #expect(migrated.tunes.first?.entries.contains(.field(.remark("skip value"))) == true)
        #expect(migrated.tunes.first?.entries.contains(.field(.legacy("E", "skip value"))) == false)
    }

    @Test
    func migrated_fromV16_headerLegacyFieldBecomesRemark() {
        let v16 = ABCVersion(major: 1, minor: 6)
        let tunebook = ABCTunebook(version: v16,
                                   headers: [.field(.legacy("I", "some info"))],
                                   tunes: [])
        let migrated = tunebook.migrated()

        #expect(migrated.headers.contains(.field(.remark("some info"))) == true)
        #expect(migrated.headers.contains(.field(.legacy("I", "some info"))) == false)
    }

    @Test
    func migrated_fromV16_tempoLegacyFlagCleared() {
        let v16 = ABCVersion(major: 1, minor: 6)
        let dottedQuarter = ABCDuration(3, 8)
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
        let tunebook = minimalTunebook(symbols: [.decoration(_deco("trill", .plus))])
        let issues = tunebook.validate()

        #expect(issues == [.plusDialectDecorationWithoutDirective(tuneIndex: 0)])
        #expect(issues[0].severity == .error)
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_plusDecorationInBody_withDirective_returnsNoIssues() {
        let directive = ABCDirective(name: "decoration", value: "+")
        let tunebook = ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.field(.instruction(directive)),
                                                             .symbols([.decoration(_deco("trill", .plus))])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_bangDecorationInBody_inPlusMode_returnsError() {
        let directive = ABCDirective(name: "decoration", value: "+")
        let tunebook = ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.field(.instruction(directive)),
                                                             .symbols([.decoration(_deco("trill", .bang))])])])
        let issues = tunebook.validate()

        #expect(issues == [.bangDialectDecorationInPlusMode(tuneIndex: 0)])
        #expect(issues[0].severity == .error)
    }

    @Test
    func validate_shorthandDecoration_returnsNoIssues() {
        let shorthand = ABCDecoration("roll", "~", .plus)
        let tunebook = minimalTunebook(symbols: [.decoration(shorthand)])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_plusDecorationInUserSymbol_withoutDirective_returnsError() {
        let tunebook = ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.field(.userSymbol(_usym("T", _deco("trill", .plus))))])])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: 0)])
    }

    @Test
    func validate_plusDecorationInSymbolLine_withoutDirective_returnsError() {
        let tunebook = ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.field(.symbolLine(_sline([.decoration(_deco("trill", .plus))])))])])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: 0)])
    }

    @Test
    func validate_fileHeaderDirective_setsDialectForTune() {
        let directive = ABCDirective(name: "decoration", value: "+")
        let tunebook = ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                                   headers: [.directive(directive)],
                                   tunes: [ABCTune(entries: [.symbols([.decoration(_deco("trill", .plus))])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_inlineDirective_affectsSubsequentSymbols() {
        let directive = ABCDirective(name: "decoration", value: "+")
        let tunebook = ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.symbols([.inlineField(.instruction(directive)),
                                                                       .decoration(_deco("trill", .plus))])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_plusDecorationInFileHeader_withoutDirective_returnsError() {
        let tunebook = ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                                   headers: [.field(.userSymbol(_usym("T", _deco("trill", .plus))))],
                                   tunes: [])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: nil)])
    }

    @Test
    func validate_tuneIndex_isCorrect() {
        let tunebook = ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: []),
                                           ABCTune(entries: [.symbols([.decoration(_deco("trill", .plus))])])])

        #expect(tunebook.validate() == [.plusDialectDecorationWithoutDirective(tuneIndex: 1)])
    }

    @Test
    func validate_undefinedUserSymbol_returnsError() {
        let custom = ABCDecoration("trill", "W", .bang)
        let tunebook = minimalTunebook(symbols: [.decoration(custom)])
        let issues = tunebook.validate()

        #expect(issues == [.undefinedUserSymbol(tuneIndex: 0)])
        #expect(issues[0].severity == .error)
        #expect(!issues[0].message.isEmpty)
    }

    @Test
    func validate_definedUserSymbol_returnsNoIssues() {
        let custom = ABCDecoration("trill", "W", .bang)
        let tunebook = ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.field(.userSymbol(_usym("W", _deco("trill")))),
                                                             .symbols([.decoration(custom)])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_builtinShorthand_returnsNoIssues() {
        let tilde = ABCDecoration("roll", "~", .bang)
        let tunebook = minimalTunebook(symbols: [.decoration(tilde)])

        #expect(tunebook.validate().isEmpty)
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
        let macro = ABCMacro(trigger: "~G2", replacement: "{A}G{F}G")
        let call = ABCMacroCall(trigger: "~G2", expansion: [])
        let tunebook = ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.field(.macro(macro)),
                                                             .symbols([.macroCall(call)])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func validate_transposingMacro_returnsNoIssues() {
        let macro = ABCMacro(trigger: "~n2", replacement: "{A}n{B}n")
        let call = ABCMacroCall(trigger: "~G2", expansion: [])
        let tunebook = ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                                   headers: [],
                                   tunes: [ABCTune(entries: [.field(.macro(macro)),
                                                             .symbols([.macroCall(call)])])])

        #expect(tunebook.validate().isEmpty)
    }

    @Test
    func init_storesValues() {
        let version = ABCVersion(major: 2, minor: 1)
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
