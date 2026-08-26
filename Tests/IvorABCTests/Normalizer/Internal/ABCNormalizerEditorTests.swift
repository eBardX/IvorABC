// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCNormalizerEditorTests {
}

// MARK: -

extension ABCNormalizerEditorTests {
    @Test
    func editTunebook_bodyDecorationConvertedInSymbolLine() {
        let legacyDecoration = ABCDecoration(name: ABCDecoration.Name("roll"),
                                             dialect: .plus).require()
        let symbolLine = makeSymbolLine([.decoration(legacyDecoration)])
        let tunebook = makeTunebook([makeTune(header: [.field(.key(makeKeySignature(.c, .major)))],
                                              body: [.field(.symbolLine(symbolLine))])])
        var editor = ABCNormalizer.Editor(tunebook: tunebook)
        let (_, changes) = editor.editTunebook()

        #expect(changes.contains { if case .convertedDecoration = $0 { true } else { false } })
    }

    @Test
    func editTunebook_bodyDirectiveChangeHasNonNilTuneIndex() {
        let directive = makeDirective("abc-charset", "utf-8")
        let tunebook = makeTunebook([makeTune(header: [.field(.key(makeKeySignature(.c, .major)))],
                                              body: [.directive(directive)])])
        var editor = ABCNormalizer.Editor(tunebook: tunebook)
        let (normalized, changes) = editor.editTunebook()

        #expect(changes.first?.tuneIndex == 0)
        #expect(normalized.tunes[0].body.isEmpty)
    }

    @Test
    func editTunebook_fileHeaderDirectiveChangeHasNilTuneIndex() {
        let directive = makeDirective("abc-charset", "utf-8")
        let tunebook = makeTunebook([.directive(directive)],
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])
        var editor = ABCNormalizer.Editor(tunebook: tunebook)
        let (_, changes) = editor.editTunebook()

        #expect(changes.first?.tuneIndex == nil)
    }

    @Test
    func editTunebook_inlineInstructionDirectiveIsRemovedFromSymbols() {
        let directive = makeDirective("abc-charset", "utf-8")
        let tunebook = makeTunebook([makeTune(header: [.field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.inlineField(.instruction(directive))])])])
        var editor = ABCNormalizer.Editor(tunebook: tunebook)
        let (normalized, _) = editor.editTunebook()

        #expect(normalized.tunes[0].body.isEmpty)
    }

    @Test
    func editTunebook_multipleTunesReportDistinctTuneIndices() {
        let directive = makeDirective("abc-charset", "utf-8")
        let tune0 = makeTune(header: [.field(.key(makeKeySignature(.c, .major)))],
                             body: [.directive(directive)])
        let tune1 = makeTune(header: [.field(.key(makeKeySignature(.c, .major)))],
                             body: [.directive(directive)])
        let tunebook = makeTunebook([tune0, tune1])
        var editor = ABCNormalizer.Editor(tunebook: tunebook)
        let (_, changes) = editor.editTunebook()

        #expect(changes.map(\.tuneIndex) == [0, 1])
    }

    @Test
    func editTunebook_returnsNormalizedTunebook() {
        let tunebook = minimalTunebook()
        var editor = ABCNormalizer.Editor(tunebook: tunebook)
        let (normalized, _) = editor.editTunebook()

        #expect(normalized.isNormalized)
        #expect(normalized.version == .current)
    }

    @Test
    func editTunebook_userDefinedSymbolDecorationIsConverted() {
        let legacyDecoration = ABCDecoration(name: ABCDecoration.Name("roll"),
                                             dialect: .plus).require()
        let userSymbol = makeUserSymbol(.tilde, legacyDecoration)
        let tunebook = makeTunebook([makeTune(header: [.field(.key(makeKeySignature(.c, .major)))],
                                              body: [.field(.userDefined(userSymbol))])])
        var editor = ABCNormalizer.Editor(tunebook: tunebook)
        let (_, changes) = editor.editTunebook()

        #expect(changes.contains { if case .convertedDecoration = $0 { true } else { false } })
    }
}
