// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCParserDiagnosticTests {
}

// MARK: -

extension ABCParserDiagnosticTests {
    @Test
    func equality() {
        let a = ABCParser.Diagnostic.missingFileID
        let b = ABCParser.Diagnostic.missingFileID

        #expect(a == b)
    }

    @Test
    func inequality() {
        #expect(ABCParser.Diagnostic.missingFileID != ABCParser.Diagnostic.bareTempoRate(120))
    }

    @Test
    func message_bareTempoRate() {
        let diagnostic = ABCParser.Diagnostic.bareTempoRate(120)

        #expect(diagnostic.message.contains("120"))
    }

    @Test
    func message_misplacedField() {
        let diagnostic = ABCParser.Diagnostic.misplacedField(.area("test"))

        #expect(diagnostic.message.contains("Misplaced"))
    }

    @Test
    func message_missingFileID() {
        let diagnostic = ABCParser.Diagnostic.missingFileID

        #expect(diagnostic.message.contains("Missing"))
    }

    @Test
    func message_unrecognizedLine() {
        let diagnostic = ABCParser.Diagnostic.unrecognizedLine("%%%bogus")

        #expect(diagnostic.message.contains("%%%bogus"))
    }

    @Test
    func message_unsupportedVersion() {
        let version = ABCVersion(major: 3, minor: 0)
        let diagnostic = ABCParser.Diagnostic.unsupportedVersion(version)

        #expect(diagnostic.message.contains("3.0"))
    }
}
