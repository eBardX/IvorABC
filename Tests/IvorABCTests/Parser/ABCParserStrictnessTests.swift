// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorABC
import Testing
import XestiTools

struct ABCParserStrictnessTests {
}

// MARK: -

extension ABCParserStrictnessTests {
    @Test
    func equality() {
        #expect(ABCParser.Strictness.lenient == .lenient)
        #expect(ABCParser.Strictness.strict == .strict)
    }

    @Test
    func inequality() {
        #expect(ABCParser.Strictness.lenient != .strict)
    }

    @Test
    func parseWithDiagnostics_bareTempoRate_emitsDiagnostic() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nQ:120\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let (_, diagnostics) = try parser.parseWithDiagnostics(data)

        #expect(diagnostics.contains(.bareTempoRate(120)))
    }

    @Test
    func parseWithDiagnostics_freeText_emitsUnrecognizedLineDiagnostic() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n\nThis is free text?\n\nX:2\nT:Another\nK:G\nGABc|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let (_, diagnostics) = try parser.parseWithDiagnostics(data)

        #expect(diagnostics.contains(.unrecognizedLine("This is free text?")))
    }

    @Test
    func parseWithDiagnostics_missingFileID_noMissingFileIDDiagnostic() throws {
        let input = "X:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let (_, diagnostics) = try parser.parseWithDiagnostics(data)

        #expect(!diagnostics.contains(.missingFileID))
    }

    @Test
    func parseWithDiagnostics_presentFileID_noMissingFileIDDiagnostic() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let (_, diagnostics) = try parser.parseWithDiagnostics(data)

        #expect(!diagnostics.contains(.missingFileID))
    }

    @Test
    func parseWithDiagnostics_strictMode_noDiagnosticsOnValidInput() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let (_, diagnostics) = try parser.parseWithDiagnostics(data)

        #expect(diagnostics.isEmpty)
    }

    @Test
    func parseWithDiagnostics_unsupportedVersion_noUnsupportedVersionDiagnostic() throws {
        let input = "%abc-3.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let (_, diagnostics) = try parser.parseWithDiagnostics(data)

        #expect(!diagnostics.contains(.unsupportedVersion(makeVersion(3, 0))))
    }

    @Test
    func parseWithDiagnostics_v20_lenient_noUnsupportedVersionDiagnostic() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let (_, diagnostics) = try parser.parseWithDiagnostics(data)

        #expect(!diagnostics.contains(.unsupportedVersion(makeVersion(2, 0))))
    }

    @Test
    func parse_bareTempoRate_lenient_succeedsWithRateAndNoBeats() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nQ:120\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let tunebook = try parser.parse(data)
        let tempo = tunebook.tunes.first?.header.compactMap { entry -> ABCTempo? in
            guard case let .field(field) = entry,
                  case let .tempo(t) = field
            else { return nil }

            return t
        }.first

        #expect(tempo?.rate == 120)
        #expect(tempo?.durations.isEmpty == true)
    }

    @Test
    func parse_bareTempoRate_strict_throws() {
        let input = "%abc-2.1\nX:1\nT:Test\nQ:120\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        #expect(throws: ABCParser.Error.self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_freeTextBetweenTunes_lenient_skipsLineAndParsesAllTunes() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n\nThis is free text?\n\nX:2\nT:Another\nK:G\nGABc|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let tunebook = try parser.parse(data)

        #expect(tunebook.tunes.count == 2)
    }

    @Test
    func parse_freeTextBetweenTunes_strict_throws() {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n\nThis is free text?\n\nX:2\nT:Another\nK:G\nGABc|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        #expect(throws: ABCParser.Error.self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_missingFileID_lenient_succeeds() throws {
        let input = "X:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let tunebook = try parser.parse(data)

        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_missingFileID_strict_succeeds() throws {
        let input = "X:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_v20_lenient_succeedsWithDeclaredVersion() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let tunebook = try parser.parse(data)

        #expect(tunebook.version == makeVersion(2, 0))
        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_v20_strict_succeedsWithDeclaredVersion() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.version == makeVersion(2, 0))
        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_unknownVersion_strict_succeeds() throws {
        let input = "%abc-3.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.version == makeVersion(3, 0))
        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_bareTempoRate_v20_strict_succeedsWithRateAndNoBeats() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nQ:120\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tempo = tunebook.tunes.first?.header.compactMap { entry -> ABCTempo? in
            guard case let .field(field) = entry,
                  case let .tempo(t) = field
            else { return nil }

            return t
        }.first

        #expect(tempo?.rate == 120)
        #expect(tempo?.durations.isEmpty == true)
    }

    // MARK: - ABC 1.6

    @Test
    func parse_v16_strict_succeedsWithDeclaredVersion() throws {
        let input = "%abc-1.6\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.version == makeVersion(1, 6))
        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_v16_strict_elemskipProducesElemskipField() throws {
        let input = "%abc-1.6\nX:1\nT:Test\nE:3\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let fields = tunebook.tunes.first?.header.compactMap { entry -> ABCField? in
            guard case let .field(f) = entry
            else { return nil }

            return f
        }

        #expect(fields?.contains(.elemskip(.integer(3))) == true)
    }

    @Test
    func parse_v16_strict_informationFieldProducesInformationField() throws {
        let input = "%abc-1.6\nX:1\nT:Test\nI:some info\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let fields = tunebook.tunes.first?.header.compactMap { entry -> ABCField? in
            guard case let .field(f) = entry
            else { return nil }

            return f
        }

        #expect(fields?.contains(.information("some info")) == true)
    }

    @Test
    func parse_v16_strict_tempoC_producesResolvedBeatWithFlag() throws {
        // L:1/8 active → Q:C=120 resolves to 1/8=120
        let input = "%abc-1.6\nX:1\nT:Test\nL:1/8\nQ:C=120\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tempo = tunebook.tunes.first?.header.compactMap { entry -> ABCTempo? in
            guard case let .field(f) = entry,
                  case let .tempo(t) = f
            else { return nil }

            return t
        }.first

        #expect(tempo?.rate == 120)
        #expect(tempo?.legacyBeatMultiple == 1)
        #expect(tempo?.durations == [makeDuration(1, 8)])
    }

    @Test
    func parse_v16_strict_tempoCn_producesResolvedDottedBeatWithFlag() throws {
        // L:1/8 active → Q:C3=40 resolves to 3/8=40
        let input = "%abc-1.6\nX:1\nT:Test\nL:1/8\nQ:C3=40\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tempo = tunebook.tunes.first?.header.compactMap { entry -> ABCTempo? in
            guard case let .field(f) = entry,
                  case let .tempo(t) = f
            else { return nil }

            return t
        }.first

        #expect(tempo?.rate == 40)
        #expect(tempo?.legacyBeatMultiple == 3)
        #expect(tempo?.durations == [makeDuration(3, 8)])
    }

    @Test
    func parse_v16_strict_postV16FieldAccepted() throws {
        // V: (voice) was added after 1.6 but we accept it anyway
        let input = "%abc-1.6\nX:1\nT:Test\nK:C\n[V:V1]CDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        #expect(throws: Never.self) {
            try parser.parse(data)
        }
    }

    @Test
    func parseWithDiagnostics_v16_noUnsupportedVersionDiagnostic() throws {
        let input = "%abc-1.6\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let (_, diagnostics) = try parser.parseWithDiagnostics(data)

        #expect(!diagnostics.contains(.unsupportedVersion(makeVersion(1, 6))))
    }

    // MARK: - Header/body structure

    @Test
    func parse_headerBodySplit_keyFieldInHeader_symbolsInBody() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))
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
    func parse_missingKeyField_lenient_emitsDiagnostic() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nCDEF|\n"
        let parser = ABCParser(strictness: .lenient)

        let (_, diagnostics) = try parser.parseWithDiagnostics(Data(input.utf8))

        #expect(diagnostics.contains(.missingKeyField))
    }

    @Test
    func parse_missingKeyField_lenient_symbolsGoToBody() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nCDEF|\n"
        let tunebook = try ABCParser(strictness: .lenient).parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbolsInBody = tune.body.contains { if case .symbols = $0 { true } else { false } }

        #expect(symbolsInBody)
    }

    @Test
    func parse_missingKeyField_strict_throws() {
        let input = "%abc-2.1\nX:1\nT:Test\nCDEF|\n"

        #expect(throws: ABCParser.Error.missingKeyField) {
            try ABCParser().parse(Data(input.utf8))
        }
    }

    @Test
    func parse_missingReferenceNumber_strict_throws() {
        let input = "%abc-2.1\nT:Test\nK:C\nCDEF|\n"

        #expect(throws: ABCParser.Error.missingReferenceNumber) {
            try ABCParser().parse(Data(input.utf8))
        }
    }

    @Test
    func parse_multipleTitlesConsecutive_valid() throws {
        let input = "%abc-2.1\nX:1\nT:Main Title\nT:Subtitle\nK:C\nCDEF|\n"

        #expect(throws: Never.self) {
            try ABCParser().parse(Data(input.utf8))
        }
    }

    @Test
    func parse_multipleTitlesNonConsecutive_strict_throws() {
        let input = "%abc-2.1\nX:1\nT:First Title\nC:Bach\nT:Second Title\nK:C\nCDEF|\n"

        #expect(throws: ABCParser.Error.self) {
            try ABCParser().parse(Data(input.utf8))
        }
    }

    @Test
    func parse_tuneTitleAfterOtherField_strict_throws() {
        let input = "%abc-2.1\nX:1\nC:Bach\nT:Test\nK:C\nCDEF|\n"

        #expect(throws: ABCParser.Error.self) {
            try ABCParser().parse(Data(input.utf8))
        }
    }

    @Test
    func parse_orphanedContinuationInHeader_strict_throws() {
        let input = "%abc-2.1\nX:1\n+:ignored\nT:Test\nK:C\nCDEF|\n"

        #expect(throws: ABCParser.Error.orphanedContinuation) {
            try ABCParser().parse(Data(input.utf8))
        }
    }

    @Test
    func parse_orphanedContinuationInHeader_lenient_succeeds() throws {
        let input = "%abc-2.1\nX:1\n+:ignored\nT:Test\nK:C\nCDEF|\n"
        let parser = ABCParser(strictness: .lenient)

        let tunebook = try parser.parse(Data(input.utf8))

        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_orphanedContinuationInBody_strict_throws() {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\n+:orphaned\nCDEF|\n"

        #expect(throws: ABCParser.Error.orphanedContinuation) {
            try ABCParser().parse(Data(input.utf8))
        }
    }

    @Test
    func parse_orphanedContinuationInBody_lenient_succeeds() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\n+:orphaned\nCDEF|\n"
        let parser = ABCParser(strictness: .lenient)

        let tunebook = try parser.parse(Data(input.utf8))

        #expect(tunebook.tunes.count == 1)
    }
}
