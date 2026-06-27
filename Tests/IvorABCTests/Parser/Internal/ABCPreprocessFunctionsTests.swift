// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorABC
import Testing

struct ABCPreprocessFunctionsTests {
}

// MARK: -

extension ABCPreprocessFunctionsTests {

    // MARK: - BOM handling

    @Test
    func preprocess_utf8BOM_decodesAsUTF8() throws {
        // "T:Générale" encoded as UTF-8 with a leading BOM
        var bytes: [UInt8] = [0xef, 0xbb, 0xbf]   // UTF-8 BOM
        bytes += "%abc-2.1\nX:1\nT:G\u{00E9}n\u{00E9}rale\nK:C\nCDEF|\n".utf8

        let data = Data(bytes)
        let (lines, version, diagnostics) = try preprocess(data)

        #expect(version == ABCVersion(major: 2, minor: 1))
        #expect(diagnostics.isEmpty)

        let titleLine = lines.first { $0.hasPrefix("T:") }
        #expect(titleLine == "T:Générale")
    }

    @Test
    func preprocess_nosBOM_latin1Title_decodesAsLatin1() throws {
        // No %abc line → version nil → encoding ISO-8859-1
        // "T:Générale" where é = 0xE9 in ISO-8859-1
        var bytes: [UInt8] = []
        bytes += [0x58, 0x3a, 0x31, 0x0a]              // "X:1\n"
        bytes += [0x54,
                  0x3a,
                  0x47,
                  0xe9,
                  0x6e,
                  0xe9,
                  0x72,
                  0x61,
                  0x6c,
                  0x65,
                  0x0a]        // "T:Générale\n" (Latin-1)
        bytes += [0x4b, 0x3a, 0x43, 0x0a]              // "K:C\n"
        bytes += [0x43, 0x44, 0x45, 0x46, 0x7c, 0x0a] // "CDEF|\n"

        let data = Data(bytes)
        let (lines, version, diagnostics) = try preprocess(data)

        #expect(version == nil)
        #expect(diagnostics.isEmpty)

        let titleLine = lines.first { $0.hasPrefix("T:") }
        #expect(titleLine == "T:G\u{00E9}n\u{00E9}rale")
    }

    @Test
    func preprocess_nonUTF8BOM_emitsIgnoredByteOrderMarkDiagnostic() throws {
        // UTF-16 BE BOM followed by some ASCII content
        var bytes: [UInt8] = [0xfe, 0xff]  // UTF-16 BE BOM
        bytes += "X:1\nK:C\nCDEF|\n".utf8

        let data = Data(bytes)
        let (_, _, diagnostics) = try preprocess(data)

        #expect(diagnostics.contains(.ignoredByteOrderMark))
    }

    @Test
    func preprocess_utf8BOMOnly_returnsEmptyLines() throws {
        let data = Data([0xef, 0xbb, 0xbf])
        let (lines, version, diagnostics) = try preprocess(data)

        #expect(lines.isEmpty)
        #expect(version == nil)
        #expect(diagnostics.isEmpty)
    }

    // MARK: - Empty data

    @Test
    func preprocess_emptyData_returnsEmpty() throws {
        let (lines, version, diagnostics) = try preprocess(Data())

        #expect(lines.isEmpty)
        #expect(version == nil)
        #expect(diagnostics.isEmpty)
    }

    // MARK: - Charset directives

    @Test
    func preprocess_v21_explicitLatin1Charset_decodesAsLatin1() throws {
        // %abc-2.1 would default to UTF-8, but explicit I:abc-charset overrides to Latin-1
        var bytes: [UInt8] = []
        bytes += "%abc-2.1\n".utf8
        bytes += "I:abc-charset iso-8859-1\n".utf8
        bytes += [0x58, 0x3a, 0x31, 0x0a]
        bytes += [0x54, 0x3a, 0x47, 0xe9, 0x6e, 0xe9, 0x72, 0x61, 0x6c, 0x65, 0x0a]
        bytes += [0x4b, 0x3a, 0x43, 0x0a]
        bytes += [0x43, 0x44, 0x45, 0x46, 0x7c, 0x0a]

        let data = Data(bytes)
        let (lines, version, diagnostics) = try preprocess(data)

        #expect(version == ABCVersion(major: 2, minor: 1))
        #expect(diagnostics.isEmpty)

        let titleLine = lines.first { $0.hasPrefix("T:") }
        #expect(titleLine == "T:G\u{00E9}n\u{00E9}rale")
    }

    @Test
    func preprocess_doublePercentCharset_decodesWithDeclaredEncoding() throws {
        // ABC 2.0 with %%abc-charset iso-8859-1
        var bytes: [UInt8] = []
        bytes += "%%abc-charset iso-8859-1\n".utf8
        bytes += [0x58, 0x3a, 0x31, 0x0a]
        bytes += [0x54, 0x3a, 0x47, 0xe9, 0x6e, 0xe9, 0x72, 0x61, 0x6c, 0x65, 0x0a]
        bytes += [0x4b, 0x3a, 0x43, 0x0a]
        bytes += [0x43, 0x44, 0x45, 0x46, 0x7c, 0x0a]

        let data = Data(bytes)
        let (lines, version, diagnostics) = try preprocess(data)

        #expect(version == nil)
        #expect(diagnostics.isEmpty)

        let titleLine = lines.first { $0.hasPrefix("T:") }
        #expect(titleLine == "T:G\u{00E9}n\u{00E9}rale")
    }

    @Test
    func preprocess_unknownCharset_emitsUnrecognizedCharsetAndFallsBackToLatin1() throws {
        let input = "%%abc-charset klingon\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let (_, _, diagnostics) = try preprocess(data)

        #expect(diagnostics.contains(.unrecognizedCharset("klingon")))
    }

    @Test
    func preprocess_duplicateCharset_emitsDuplicateCharsetDiagnostic() throws {
        let input = "%%abc-charset utf-8\n%%abc-charset iso-8859-1\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let (_, _, diagnostics) = try preprocess(data)

        #expect(diagnostics.contains(.duplicateCharset("iso-8859-1")))
    }

    @Test
    func preprocess_charsetAliases_allRecognized() throws {
        let aliases = ["utf-8", "UTF-8", "utf8", "us-ascii", "ASCII"]

        for alias in aliases {
            let input = "%%abc-charset \(alias)\nX:1\nT:Test\nK:C\nCDEF|\n"
            let data = Data(input.utf8)
            let (_, _, diagnostics) = try preprocess(data)

            #expect(!diagnostics.contains { if case .unrecognizedCharset = $0 { true } else { false } },
                    "Expected alias '\(alias)' to be recognized")
        }
    }

    @Test
    func preprocess_iso8859_9_roundTrip() throws {
        // Turkish 'ş' is 0xFE in ISO-8859-9
        let input = "%%abc-charset iso-8859-9\nX:1\nT:"
        var bytes = [UInt8](input.utf8)

        bytes.append(0xfe)  // 'ş' in ISO-8859-9

        bytes += "\nK:C\nCDEF|\n".utf8

        let data = Data(bytes)
        let (lines, _, diagnostics) = try preprocess(data)

        #expect(!diagnostics.contains { if case .unrecognizedCharset = $0 { true } else { false } })

        let titleLine = lines.first { $0.hasPrefix("T:") }

        #expect(titleLine?.contains("ş") == true)
    }

    // MARK: - Decode failure

    @Test
    func preprocess_v21_invalidUTF8_strict_throwsDataConversionFailed() {
        var bytes = [UInt8]("%abc-2.1\nX:1\nT:".utf8)

        bytes.append(0xff)  // invalid UTF-8 byte

        bytes += "\nK:C\nCDEF|\n".utf8

        let data = Data(bytes)

        #expect(throws: ABCParser.Error.dataConversionFailed) {
            try preprocess(data, strictness: .strict)
        }
    }

    @Test
    func preprocess_v21_invalidUTF8_lenient_emitsInvalidUTF8DiagnosticAndFallsBack() throws {
        var bytes = [UInt8]("%abc-2.1\nX:1\nT:".utf8)

        bytes.append(0xff)  // invalid UTF-8 byte

        bytes += "\nK:C\nCDEF|\n".utf8

        let data = Data(bytes)
        let (_, _, diagnostics) = try preprocess(data, strictness: .lenient)

        #expect(diagnostics.contains(.invalidUTF8))
    }

    // MARK: - Version resolution

    @Test
    func preprocess_fileIDVersion_takesHighestPrecedence() throws {
        let input = "%abc-2.1\n%%abc-version 2.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let (_, version, _) = try preprocess(data)

        #expect(version == ABCVersion(major: 2, minor: 1))
    }

    @Test
    func preprocess_doublePercentVersion_noFileID_resolvedAsVersion() throws {
        let input = "%%abc-version 2.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let (_, version, _) = try preprocess(data)

        #expect(version == ABCVersion(major: 2, minor: 0))
    }

    @Test
    func preprocess_instructionVersion_noFileID_resolvedAsVersion() throws {
        let input = "I:abc-version 2.0\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let (_, version, _) = try preprocess(data)

        #expect(version == ABCVersion(major: 2, minor: 0))
    }

    // MARK: - File-ID line stripping

    @Test
    func preprocess_fileIDLine_isStrippedFromLines() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let (lines, _, _) = try preprocess(data)

        #expect(!lines.contains { $0.hasPrefix("%abc") })
    }

    // MARK: - Continuation line joining

    @Test
    func preprocess_continuationLines_areJoined() throws {
        // Music line with backslash continuation
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\nCDEF\\\nGABc|\n"
        let data = Data(input.utf8)
        let (lines, _, _) = try preprocess(data)

        let musicLines = lines.filter { !$0.hasPrefix("%") && !$0.hasPrefix("X:") && !$0.hasPrefix("T:") && !$0.hasPrefix("K:") && !$0.isEmpty }

        #expect(musicLines.count == 1)
    }

    @Test
    func preprocess_fieldContinuation_latin1_joinedCorrectly() throws {
        // Continuation in Latin-1 encoded file (no version line → Latin-1)
        // T:First line\n+:Second line
        var bytes: [UInt8] = []
        bytes += "X:1\n".utf8
        bytes += "T:First line\n".utf8
        bytes += "+:Second line\n".utf8
        bytes += "K:C\n".utf8
        bytes += "CDEF|\n".utf8

        let data = Data(bytes)
        let (lines, _, _) = try preprocess(data)

        let titleLine = lines.first { $0.hasPrefix("T:") }

        #expect(titleLine == "T:First line")

        let contLine = lines.first { $0.hasPrefix("+:") }

        #expect(contLine == "+:Second line")
    }
}
