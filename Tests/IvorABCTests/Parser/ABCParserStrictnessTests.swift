// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorABC
import Testing

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
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n\nThis is free text.\n\nX:2\nT:Another\nK:G\nGABc|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let (_, diagnostics) = try parser.parseWithDiagnostics(data)

        #expect(diagnostics.contains(.unrecognizedLine("This is free text.")))
    }

    @Test
    func parseWithDiagnostics_missingFileID_emitsDiagnostic() throws {
        let input = "X:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let (_, diagnostics) = try parser.parseWithDiagnostics(data)

        #expect(diagnostics.contains(.missingFileID))
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
    func parseWithDiagnostics_unsupportedVersion_emitsDiagnostic() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let (_, diagnostics) = try parser.parseWithDiagnostics(data)

        #expect(diagnostics.contains(.unsupportedVersion(ABCVersion(major: 2, minor: 0))))
    }

    @Test
    func parse_bareTempoRate_lenient_succeedsWithRateAndNoBeats() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nQ:120\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let tunebook = try parser.parse(data)
        let tempo = tunebook.tunes.first?.entries.compactMap { entry -> ABCTempo? in
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
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n\nThis is free text.\n\nX:2\nT:Another\nK:G\nGABc|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let tunebook = try parser.parse(data)

        #expect(tunebook.tunes.count == 2)
    }

    @Test
    func parse_freeTextBetweenTunes_strict_throws() {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n\nThis is free text.\n\nX:2\nT:Another\nK:G\nGABc|\n"
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
    func parse_missingFileID_strict_throws() {
        let input = "X:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        #expect(throws: ABCParser.Error.self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_unsupportedVersion_lenient_succeedsWithDeclaredVersion() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser(strictness: .lenient)

        let tunebook = try parser.parse(data)

        #expect(tunebook.version == ABCVersion(major: 2, minor: 0))
        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_unsupportedVersion_strict_throws() {
        let input = "%abc-2.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        #expect(throws: ABCParser.Error.self) {
            try parser.parse(data)
        }
    }
}
