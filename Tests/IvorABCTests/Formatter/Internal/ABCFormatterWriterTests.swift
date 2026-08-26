// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorABC
import Testing
import XestiTools

struct ABCFormatterWriterTests {
}

// MARK: -

extension ABCFormatterWriterTests {
    @Test
    func writeTunebook_beamBreakEmitsSpace() {
        let note1 = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let note2 = makeNote(makePitch(.d, .natural, 4), makeLength(1))
        let tunebook = minimalTunebook(symbols: [.note(note1), .beamBreak, .note(note2)])
        var writer = ABCFormatter.Writer(tunebook: tunebook)
        let output = String(data: writer.writeTunebook(), encoding: .utf8).require()

        #expect(output.contains("C D\n"))
    }

    @Test
    func writeTunebook_directiveWithBlockContent() {
        let directive = ABCDirective(name: "text", value: "justify", content: ["Line one", "Line two"])
        let tunebook = makeTunebook([.directive(directive)],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        var writer = ABCFormatter.Writer(tunebook: tunebook)
        let output = String(data: writer.writeTunebook(), encoding: .utf8).require()

        #expect(output.contains("%%begintext justify\nLine one\nLine two\n%%endtext\n"))
    }

    @Test
    func writeTunebook_directiveWithoutContent() {
        let directive = ABCDirective(name: "staffwidth", value: "170")
        let tunebook = makeTunebook([.directive(directive)],
                                    [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test")),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        var writer = ABCFormatter.Writer(tunebook: tunebook)
        let output = String(data: writer.writeTunebook(), encoding: .utf8).require()

        #expect(output.contains("%%staffwidth 170\n"))
    }

    @Test
    func writeTunebook_multipleTunesSeparatedByBlankLine() {
        let tune1 = makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                      .field(.tuneTitle("First")),
                                      .field(.key(makeKeySignature(.c, .major)))])
        let tune2 = makeTune(header: [.field(.referenceNumber(makeReferenceNumber(2))),
                                      .field(.tuneTitle("Second")),
                                      .field(.key(makeKeySignature(.c, .major)))])
        let tunebook = makeTunebook([tune1, tune2])
        var writer = ABCFormatter.Writer(tunebook: tunebook)
        let output = String(data: writer.writeTunebook(), encoding: .utf8).require()

        #expect(output.contains("T:First\nK:C major\n\nX:2\n"))
    }

    @Test
    func writeTunebook_versionHeaderLine() {
        let tunebook = minimalTunebook()
        var writer = ABCFormatter.Writer(tunebook: tunebook)
        let output = String(data: writer.writeTunebook(), encoding: .utf8).require()

        #expect(output.hasPrefix("%abc-2.1\n"))
    }
}
