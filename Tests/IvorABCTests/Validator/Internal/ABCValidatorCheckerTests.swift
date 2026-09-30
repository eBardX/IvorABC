// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCValidatorCheckerTests {
}

// MARK: -

extension ABCValidatorCheckerTests {
    @Test
    func checkTunebook_cleanTunebookReturnsNoIssues() {
        let tunebook = minimalTunebook()
        var checker = ABCValidator.Checker(tunebook: tunebook)

        #expect(checker.checkTunebook().isEmpty)
    }

    @Test
    func checkTunebook_dottedShorthandIsAlwaysValid() {
        let tunebook = minimalTunebook(symbols: [.shorthand(.dot)])
        var checker = ABCValidator.Checker(tunebook: tunebook)

        #expect(checker.checkTunebook().isEmpty)
    }

    @Test
    func checkTunebook_missingKeyIsReported() {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                       .field(.tuneTitle("Test"))])])
        var checker = ABCValidator.Checker(tunebook: tunebook)

        #expect(checker.checkTunebook() == [.missingKey(0)])
    }

    @Test
    func checkTunebook_multipleChordSymbolsAreReported() {
        let tunebook = minimalTunebook(symbols: [.chordSymbol(ABCChordSymbol(name: .init(root: .c))),
                                                 .chordSymbol(ABCChordSymbol(name: .init(root: .g))),
                                                 .note(makeNote(makePitch(.c, .natural, 4), makeLength(1)))])
        var checker = ABCValidator.Checker(tunebook: tunebook)

        #expect(checker.checkTunebook() == [.multipleChordSymbols(0)])
    }

    @Test
    func checkTunebook_pendingCountsResetPerTune() {
        let tune1 = makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                      .field(.tuneTitle("First")),
                                      .field(.key(makeKeySignature(.c, .major)))],
                             body: [.symbols([.chordSymbol(ABCChordSymbol(name: .init(root: .c))),
                                              .note(makeNote(makePitch(.c, .natural, 4), makeLength(1)))])])
        let tune2 = makeTune(header: [.field(.referenceNumber(makeReferenceNumber(2))),
                                      .field(.tuneTitle("Second")),
                                      .field(.key(makeKeySignature(.c, .major)))],
                             body: [.symbols([.chordSymbol(ABCChordSymbol(name: .init(root: .c))),
                                              .note(makeNote(makePitch(.c, .natural, 4), makeLength(1)))])])
        let tunebook = makeTunebook([tune1, tune2])
        var checker = ABCValidator.Checker(tunebook: tunebook)

        #expect(checker.checkTunebook().isEmpty)
    }

    @Test
    func checkTunebook_undefinedShorthandIsReported() {
        let tunebook = minimalTunebook(symbols: [.shorthand(.nUpper)])
        var checker = ABCValidator.Checker(tunebook: tunebook)

        #expect(checker.checkTunebook() == [.undefinedUserSymbol(0)])
    }
}
