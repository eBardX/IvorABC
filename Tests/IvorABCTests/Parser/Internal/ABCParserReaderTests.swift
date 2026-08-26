// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorABC
import Testing

struct ABCParserReaderTests {
}

// MARK: -

extension ABCParserReaderTests {
    @Test
    func readTunebook_beginEndDirectiveBlockCollectsContent() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\n%%begintext justify\nLine one\nLine two\n%%endtext\nCDEF|\n"
        var reader = ABCParser.Reader(data: Data(input.utf8))
        let (tunebook, _) = try reader.readTunebook()
        let directive = tunebook.tunes[0].body.compactMap { entry -> ABCDirective? in
            guard case let .directive(directive) = entry
            else { return nil }

            return directive
        }.first

        #expect(directive?.name.stringValue == "text")
        #expect(directive?.value == "justify")
        #expect(directive?.content == ["Line one", "Line two"])
    }

    @Test
    func readTunebook_leadingBlankLineBeforeFirstTuneIsSkipped() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nK:C\nCDEF|\n"
        var reader = ABCParser.Reader(data: Data(input.utf8))
        let (tunebook, _) = try reader.readTunebook()

        #expect(tunebook.tunes.count == 1)
        #expect(tunebook.fileHeader.isEmpty)
        #expect(tunebook.tunes[0].body.count == 1)
    }

    @Test
    func readTunebook_unmatchedBeginDirectiveThrows() {
        let input = "%abc-2.1\nX:1\nT:Test\nK:C\n%%begintext justify\nLine one\n"
        var reader = ABCParser.Reader(data: Data(input.utf8))

        #expect(throws: ABCParser.Error.unmatchedBeginDirective("text")) {
            try reader.readTunebook()
        }
    }

    @Test
    func readTunebook_unrecognizedLineInLooseModeIsDiagnosedNotThrown() throws {
        let input = "%abc-2.0\nX:1\nT:Test\nK:C\nCDEF|\n\nThis is free text?\n\nX:2\nT:Another\nK:G\nGABc|\n"
        var reader = ABCParser.Reader(data: Data(input.utf8))
        let (_, diagnostics) = try reader.readTunebook()

        #expect(diagnostics.contains(.unrecognizedLine("This is free text?")))
    }
}
