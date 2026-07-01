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
        let a = ABCParser.Diagnostic.malformedVersion("2.x")
        let b = ABCParser.Diagnostic.malformedVersion("2.x")

        #expect(a == b)
    }

    @Test
    func inequality() {
        let tempo = ABCTempo(lengths: [], rate: 120, text: nil).require()

        #expect(ABCParser.Diagnostic.malformedVersion("2.x") != ABCParser.Diagnostic.deprecatedTempo(tempo))
    }

    @Test
    func message_deprecatedTempo() {
        let tempo = ABCTempo(lengths: [], rate: 120, text: nil).require()
        let diagnostic = ABCParser.Diagnostic.deprecatedTempo(tempo)

        #expect(diagnostic.message.contains("120"))
    }

    @Test
    func message_deprecatedField() {
        let diagnostic = ABCParser.Diagnostic.deprecatedField(.area("test"))

        #expect(diagnostic.message.lowercased().contains("deprecated"))
    }

    @Test
    func message_malformedVersion() {
        let diagnostic = ABCParser.Diagnostic.malformedVersion("2.x")

        #expect(diagnostic.message.contains("2.x"))
    }

    @Test
    func message_unrecognizedLine() {
        let diagnostic = ABCParser.Diagnostic.unrecognizedLine("%%%bogus")

        #expect(diagnostic.message.contains("%%%bogus"))
    }

    @Test
    func message_unrecognizedVersion() {
        let version = ABCVersion(major: 3, minor: 0)
        let diagnostic = ABCParser.Diagnostic.unrecognizedVersion(version)

        #expect(diagnostic.message.contains("3.0"))
    }
}
