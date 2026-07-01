// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorABC
import Testing
import XestiTools

struct ABCParserParsePolicyTests {
}

// MARK: -

extension ABCParserParsePolicyTests {

    // MARK: - Deprecated tempo

    @Test
    func parse_deprecatedTempo_bareInteger_v21_emitsDiagnostic() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nQ:120\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (_, diagnostics) = try ABCParser().parse(data)

        #expect(diagnostics.contains { if case .deprecatedTempo = $0 { true } else { false } })
    }

    @Test
    func parse_deprecatedTempo_bareInteger_v21_succeeds() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nQ:120\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)
        let tempo = tunebook.tunes.first?.header.compactMap { entry -> ABCTempo? in
            guard case let .field(field) = entry,
                  case let .tempo(t) = field
            else { return nil }

            return t
        }.first

        #expect(tempo?.rate == 120)
        #expect(tempo?.beatMultiplier == 1)
        #expect(tempo?.lengths.isEmpty == true)
    }

    @Test
    func parse_deprecatedTempo_bareInteger_v20_succeeds() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nQ:120\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)
        let tempo = tunebook.tunes.first?.header.compactMap { entry -> ABCTempo? in
            guard case let .field(field) = entry,
                  case let .tempo(t) = field
            else { return nil }

            return t
        }.first

        #expect(tempo?.rate == 120)
        #expect(tempo?.beatMultiplier == 1)
    }

    @Test
    func parse_deprecatedTempo_cForm_v21_succeeds() throws {
        // Q:C=rate (previously 1.6-only) now accepted in all versions
        let input = "%abc-2.1\nX:1\nT:Test\nL:1/8\nQ:C=120\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)
        let tempo = tunebook.tunes.first?.header.compactMap { entry -> ABCTempo? in
            guard case let .field(field) = entry,
                  case let .tempo(t) = field
            else { return nil }

            return t
        }.first

        #expect(tempo?.rate == 120)
        #expect(tempo?.beatMultiplier == 1)
        #expect(tempo?.lengths.isEmpty == true)
    }

    @Test
    func parse_deprecatedTempo_cForm_v21_emitsDiagnostic() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nL:1/8\nQ:C=120\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (_, diagnostics) = try ABCParser().parse(data)

        #expect(diagnostics.contains { if case .deprecatedTempo = $0 { true } else { false } })
    }

    @Test
    func parse_deprecatedTempo_leftUnresolvedRegardlessOfL() throws {
        // The parser does not resolve the beat; it records the multiplier and
        // leaves lengths empty for the normalizer to resolve against L:.
        let input = "%abc-2.1\nX:1\nT:Test\nL:1/4\nQ:120\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)
        let tempo = tunebook.tunes.first?.header.compactMap { entry -> ABCTempo? in
            guard case let .field(field) = entry,
                  case let .tempo(t) = field
            else { return nil }

            return t
        }.first

        #expect(tempo?.rate == 120)
        #expect(tempo?.beatMultiplier == 1)
        #expect(tempo?.lengths.isEmpty == true)
    }

    // MARK: - E: elemskip

    @Test
    func parse_elemskip_v16_producesElemskipField() throws {
        let input = "%abc-1.6\nX:1\nT:Test\nE:3\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)
        let fields = tunebook.tunes.first?.header.compactMap { entry -> ABCField? in
            guard case let .field(f) = entry
            else { return nil }

            return f
        }

        #expect(fields?.contains(.elemskip(.integer(3))) == true)
    }

    @Test
    func parse_elemskip_v20_producesElemskipField() throws {
        // E: accepted in loose mode (2.0 → loose)
        let input = "%abc-2.0\nX:1\nT:Test\nE:3\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)
        let fields = tunebook.tunes.first?.header.compactMap { entry -> ABCField? in
            guard case let .field(f) = entry
            else { return nil }

            return f
        }

        #expect(fields?.contains(.elemskip(.integer(3))) == true)
    }

    @Test
    func parse_elemskip_nilVersion_producesElemskipField() throws {
        // E: accepted in loose mode (nil version → loose)
        let input = "X:1\nT:Test\nE:3\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)
        let fields = tunebook.tunes.first?.header.compactMap { entry -> ABCField? in
            guard case let .field(f) = entry
            else { return nil }

            return f
        }

        #expect(fields?.contains(.elemskip(.integer(3))) == true)
    }

    @Test
    func parse_elemskip_loose_emitsDeprecatedFieldDiagnostic() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nE:3\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (_, diagnostics) = try ABCParser().parse(data)

        #expect(diagnostics.contains { if case .deprecatedField(.elemskip) = $0 { true } else { false } })
    }

    @Test
    func parse_elemskip_v21_throws() {
        // E: in strict mode (2.1 → strict) is invalid
        let input = "%abc-2.1\nX:1\nT:Test\nE:3\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        #expect(throws: ABCParser.Error.self) {
            try ABCParser().parse(data)
        }
    }

    // MARK: - I: field mode

    @Test
    func parse_iField_v16_isInformation() throws {
        let input = "%abc-1.6\nX:1\nT:Test\nI:some info\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)
        let fields = tunebook.tunes.first?.header.compactMap { entry -> ABCField? in
            guard case let .field(f) = entry
            else { return nil }

            return f
        }

        #expect(fields?.contains(.information("some info")) == true)
    }

    @Test
    func parse_iField_nilVersion_isInstruction() throws {
        // Unversioned files treat I: as a directive instruction (not free-text)
        let input = "X:1\nT:Test\nI:linebreak !\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        #expect(throws: Never.self) {
            try ABCParser().parse(data)
        }
    }

    @Test
    func parse_iField_v21_isInstruction() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nI:linebreak !\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        #expect(throws: Never.self) {
            try ABCParser().parse(data)
        }
    }

    // MARK: - ABC 1.6

    @Test
    func parse_v16_succeedsWithDeclaredVersion() throws {
        let input = "%abc-1.6\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)

        #expect(tunebook.version == .v1_6)
        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_v16_tempoC_producesUnresolvedBeatWithFlag() throws {
        // Q:C=120 → multiplier 1 recorded, lengths left empty (unresolved).
        let input = "%abc-1.6\nX:1\nT:Test\nL:1/8\nQ:C=120\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)
        let tempo = tunebook.tunes.first?.header.compactMap { entry -> ABCTempo? in
            guard case let .field(f) = entry,
                  case let .tempo(t) = f
            else { return nil }

            return t
        }.first

        #expect(tempo?.rate == 120)
        #expect(tempo?.beatMultiplier == 1)
        #expect(tempo?.lengths.isEmpty == true)
    }

    @Test
    func parse_v16_tempoCn_producesUnresolvedBeatWithFlag() throws {
        // Q:C3=40 → multiplier 3 recorded, lengths left empty (unresolved).
        let input = "%abc-1.6\nX:1\nT:Test\nL:1/8\nQ:C3=40\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)
        let tempo = tunebook.tunes.first?.header.compactMap { entry -> ABCTempo? in
            guard case let .field(f) = entry,
                  case let .tempo(t) = f
            else { return nil }

            return t
        }.first

        #expect(tempo?.rate == 40)
        #expect(tempo?.beatMultiplier == 3)
        #expect(tempo?.lengths.isEmpty == true)
    }

    @Test
    func parse_v16_postV16FieldAccepted() throws {
        // V: (voice) was added after 1.6 but we accept it anyway
        let input = "%abc-1.6\nX:1\nT:Test\nK:C\n[V:V1]CDEF|\n"
        let data = Data(input.utf8)

        #expect(throws: Never.self) {
            try ABCParser().parse(data)
        }
    }

    @Test
    func parse_v16_noUnrecognizedVersionDiagnostic() throws {
        let input = "%abc-1.6\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (_, diagnostics) = try ABCParser().parse(data)

        #expect(!diagnostics.contains(.unrecognizedVersion(.v1_6)))
    }

    // MARK: - Version and mode

    @Test
    func parse_noDiagnosticsOnValidV21Input() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (_, diagnostics) = try ABCParser().parse(data)

        #expect(diagnostics.isEmpty)
    }

    @Test
    func parse_freeText_v20_emitsUnrecognizedLineDiagnostic() throws {
        // 2.0 → loose mode; free text between tunes is recovered with diagnostic
        let input = "%abc-2.0\nX:1\nT:Test\nK:C\nCDEF|\n\nThis is free text?\n\nX:2\nT:Another\nK:G\nGABc|\n"
        let data = Data(input.utf8)

        let (_, diagnostics) = try ABCParser().parse(data)

        #expect(diagnostics.contains(.unrecognizedLine("This is free text?")))
    }

    @Test
    func parse_freeTextBetweenTunes_v20_skipsLineAndParsesAllTunes() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nK:C\nCDEF|\n\nThis is free text?\n\nX:2\nT:Another\nK:G\nGABc|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)

        #expect(tunebook.tunes.count == 2)
    }

    @Test
    func parse_freeTextBetweenTunes_v21_throws() {
        // 2.1 → strict mode; free text throws
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n\nThis is free text?\n\nX:2\nT:Another\nK:G\nGABc|\n"
        let data = Data(input.utf8)

        #expect(throws: ABCParser.Error.self) {
            try ABCParser().parse(data)
        }
    }

    @Test
    func parse_missingFileID_nilVersion() throws {
        let input = "X:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, diagnostics) = try ABCParser().parse(data)

        #expect(tunebook.version == nil)
        #expect(!diagnostics.contains { if case .malformedVersion = $0 { true } else { false } })
        #expect(!diagnostics.contains { if case .unrecognizedVersion = $0 { true } else { false } })
    }

    @Test
    func parse_missingFileID_succeeds() throws {
        let input = "X:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)

        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_presentFileID_setsVersion() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)

        #expect(tunebook.version == .v2_1)
    }

    @Test
    func parse_unrecognizedVersion_emitsUnrecognizedVersionDiagnostic() throws {
        let input = "%abc-3.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (_, diagnostics) = try ABCParser().parse(data)

        #expect(diagnostics.contains(.unrecognizedVersion(makeVersion(3, 0))))
    }

    @Test
    func parse_v20_noUnrecognizedVersionDiagnostic() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (_, diagnostics) = try ABCParser().parse(data)

        #expect(!diagnostics.contains(.unrecognizedVersion(.v2_0)))
    }

    @Test
    func parse_v20_succeedsWithDeclaredVersion() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)

        #expect(tunebook.version == .v2_0)
        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_unknownVersion_succeeds() throws {
        // Unrecognized version is retained; unrecognizedVersion diagnostic emitted
        let input = "%abc-3.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)

        let (tunebook, _) = try ABCParser().parse(data)

        #expect(tunebook.version == makeVersion(3, 0))
        #expect(tunebook.tunes.count == 1)
    }

    // MARK: - Header/body structure

    @Test
    func parse_headerBodySplit_keyFieldInHeader_symbolsInBody() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n"
        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let keyInHeader = tune.header.contains { if case .field(.key) = $0 { true } else { false } }
        let keyInBody = tune.body.contains { if case .field(.key) = $0 { true } else { false } }
        let symbolsInBody = tune.body.contains { if case .symbols = $0 { true } else { false } }
        let symbolsInHeader = tune.header.contains { if case .field = $0 { false } else { true } }

        #expect(keyInHeader)
        #expect(!keyInBody)
        #expect(symbolsInBody)
        #expect(!symbolsInHeader)
    }

    @Test
    func parse_missingKeyField_v20_emitsNoDiagnostics() throws {
        // A missing K: is a semantic concern handled by the validator; the
        // parser no longer emits any diagnostic for it.
        let input = "%abc-2.0\nX:1\nT:Test\nCDEF|\n"

        let (_, diagnostics) = try ABCParser().parse(Data(input.utf8))

        #expect(diagnostics.isEmpty)
    }

    @Test
    func parse_missingKeyField_v20_symbolsGoToBody() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nCDEF|\n"
        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbolsInBody = tune.body.contains { if case .symbols = $0 { true } else { false } }

        #expect(symbolsInBody)
    }

    @Test
    func parse_missingKeyField_v21_succeeds() throws {
        // A missing K: is a semantic concern handled by the validator; the
        // parser accepts the tune and routes the music code to the body.
        let input = "%abc-2.1\nX:1\nT:Test\nCDEF|\n"

        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbolsInBody = tune.body.contains { if case .symbols = $0 { true } else { false } }

        #expect(symbolsInBody)
    }

    @Test
    func parse_missingReferenceNumber_v21_succeeds() throws {
        // A missing X: is a semantic concern handled by the validator; the
        // parser accepts the tune.
        let input = "%abc-2.1\nT:Test\nK:C\nCDEF|\n"

        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))

        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_multipleTitlesConsecutive_valid() throws {
        let input = "%abc-2.1\nX:1\nT:Main Title\nT:Subtitle\nK:C\nCDEF|\n"

        #expect(throws: Never.self) {
            try ABCParser().parse(Data(input.utf8))
        }
    }

    @Test
    func parse_multipleTitlesNonConsecutive_v21_succeeds() throws {
        // Title placement is a semantic concern handled by the validator; the
        // parser accepts the tune.
        let input = "%abc-2.1\nX:1\nT:First Title\nC:Bach\nT:Second Title\nK:C\nCDEF|\n"

        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))

        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_tuneTitleAfterOtherField_v21_succeeds() throws {
        // Title placement is a semantic concern handled by the validator; the
        // parser accepts the tune.
        let input = "%abc-2.1\nX:1\nC:Bach\nT:Test\nK:C\nCDEF|\n"

        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))

        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_orphanedContinuationInHeader_v21_throws() {
        let input = "%abc-2.1\nX:1\n+:ignored\nT:Test\nK:C\nCDEF|\n"

        #expect(throws: ABCParser.Error.orphanedContinuation) {
            try ABCParser().parse(Data(input.utf8))
        }
    }

    @Test
    func parse_orphanedContinuationInHeader_v20_succeeds() throws {
        // 2.0 → loose mode; orphaned continuation is skipped
        let input = "%abc-2.0\nX:1\n+:ignored\nT:Test\nK:C\nCDEF|\n"

        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))

        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_orphanedContinuationInBody_v21_throws() {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\n+:orphaned\nCDEF|\n"

        #expect(throws: ABCParser.Error.orphanedContinuation) {
            try ABCParser().parse(Data(input.utf8))
        }
    }

    @Test
    func parse_orphanedContinuationInBody_v20_succeeds() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nK:C\n+:orphaned\nCDEF|\n"

        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))

        #expect(tunebook.tunes.count == 1)
    }

    // MARK: - isNormalized optimization

    @Test
    func parse_cleanV21_isNormalized() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n"
        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))

        #expect(tunebook.isNormalized)
    }

    @Test
    func parse_cleanV20_isNotNormalized() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))

        #expect(!tunebook.isNormalized)
    }

    @Test
    func parse_nilVersion_isNotNormalized() throws {
        let input = "X:1\nT:Test\nK:C\nCDEF|\n"
        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))

        #expect(!tunebook.isNormalized)
    }

    @Test
    func parse_v21_withDeprecatedTempo_isNotNormalized() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nQ:120\nK:C\nCDEF|\n"
        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))

        #expect(!tunebook.isNormalized)
    }

    @Test
    func parse_v21_withAbcCharsetDirective_isNotNormalized() throws {
        let input = "%abc-2.1\n%%abc-charset utf-8\nX:1\nT:Test\nK:C\nCDEF|\n"
        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))

        #expect(!tunebook.isNormalized)
    }

    @Test
    func parse_v21_withAbcVersionDirective_isNotNormalized() throws {
        let input = "%abc-2.1\n%%abc-version 2.1\nX:1\nT:Test\nK:C\nCDEF|\n"
        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))

        #expect(!tunebook.isNormalized)
    }

    @Test
    func parse_v21_withDecorationPlusDirective_isNotNormalized() throws {
        let input = "%abc-2.1\n%%decoration +\nX:1\nT:Test\nK:C\nCDEF|\n"
        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))

        #expect(!tunebook.isNormalized)
    }
}
