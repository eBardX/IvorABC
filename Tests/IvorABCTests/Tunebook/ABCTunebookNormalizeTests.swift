// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorABC
import Testing
import XestiTools

struct ABCTunebookNormalizeTests {
}

// MARK: -

extension ABCTunebookNormalizeTests {
    @Test
    func normalized_alreadyNormalized_isIdempotent() {
        let once = makeTunebook(.current,
                                [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])
            .normalized()
        let twice = once.normalized()

        #expect(twice == once)
        #expect(twice.isNormalized)
    }

    @Test
    func normalized_setsIsNormalized() {
        let tunebook = makeTunebook(.v1_6,
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(!tunebook.isNormalized)
        #expect(tunebook.normalized().isNormalized)
    }

    @Test
    func normalized_clearsIsValidated() {
        // normalized() always produces isValidated: false
        let tunebook = makeTunebook(.v2_0,
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(!tunebook.normalized().isValidated)
    }

    @Test
    func normalized_fromV16_elemskipBecomesRemark() {
        let tune = makeTune(header: [.field(.elemskip(.integer(3)))])
        let tunebook = makeTunebook(.v1_6, [tune])
        let normalized = tunebook.normalized()

        #expect(normalized.tunes.first?.header.contains(.field(.remark("3"))) == true)
        #expect(normalized.tunes.first?.header.contains(.field(.elemskip(.integer(3)))) == false)
    }

    @Test
    func normalized_fromV16_headerInformationBecomesRemark() {
        let tunebook = makeTunebook(.v1_6,
                                    [.field(.information("some info"))],
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])
        let normalized = tunebook.normalized()

        #expect(normalized.fileHeader.contains(.field(.remark("some info"))) == true)
        #expect(normalized.fileHeader.contains(.field(.information("some info"))) == false)
    }

    @Test
    func normalized_fromV16_returnsCurrentVersion() {
        let tunebook = makeTunebook(.v1_6,
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.normalized().version == .current)
    }

    @Test
    func normalized_fromV16_tempoLegacyFlagCleared() {
        let dottedQuarter = makeDuration(3, 8)
        let legacyTempo = ABCTempo(durations: [dottedQuarter], rate: 40, text: nil, legacyBeatMultiple: 3).require()
        let tune = makeTune(header: [.field(.tempo(legacyTempo))])
        let tunebook = makeTunebook(.v1_6, [tune])
        let normalized = tunebook.normalized()

        let normalizedTempo = normalized.tunes.first?.header.compactMap { entry -> ABCTempo? in
            guard case let .field(f) = entry,
                  case let .tempo(t) = f
            else { return nil }

            return t
        }.first

        #expect(normalizedTempo?.legacyBeatMultiple == nil)
        #expect(normalizedTempo?.durations == [dottedQuarter])
        #expect(normalizedTempo?.rate == 40)
    }

    @Test
    func normalized_fromV20_returnsCurrentVersion() {
        let tunebook = makeTunebook(.v2_0,
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.normalized().version == .current)
    }

    @Test
    func normalized_preservesFileHeaderAndTunes() {
        let fileHeader = ABCHeaderEntry.field(.composer("J.S. Bach"))
        let tune = makeTune(header: [.field(.tuneTitle("Test"))])
        let tunebook = makeTunebook(.v2_0, [fileHeader], [tune])
        let normalized = tunebook.normalized()

        #expect(normalized.fileHeader == [fileHeader])
        #expect(normalized.tunes == [tune])
    }

    @Test
    func normalized_plusDecoration_convertsToBasng() {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(ABCReferenceNumber(1)))],
                                              body: [.symbols([.decoration(makeDecoration("trill", .plus))])])])
        let normalized = tunebook.normalized()

        let decoration = normalized.tunes.first?.body.compactMap { entry -> ABCDecoration? in
            guard case let .symbols(symbols) = entry,
                  case let .decoration(d) = symbols.first
            else { return nil }

            return d
        }.first

        #expect(decoration?.name == ABCDecoration.Name("trill"))
        #expect(decoration?.dialect == .bang)
    }

    @Test
    func normalized_fileHeaderDecorationPlusDirective_isDropped() {
        let directive = makeDirective("decoration", "+")
        let tunebook = makeTunebook([.directive(directive)],
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.normalized().fileHeader.isEmpty)
    }

    @Test
    func normalized_tuneHeaderDecorationPlusDirective_isDropped() {
        let directive = makeDirective("decoration", "+")
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(ABCReferenceNumber(1))),
                                                       .directive(directive),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let normalized = tunebook.normalized()

        #expect(!normalized.tunes[0].header.contains(.directive(directive)))
    }

    @Test
    func normalized_inlineDecorationPlusDirective_isDropped() {
        let directive = makeDirective("decoration", "+")
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(ABCReferenceNumber(1))),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.inlineField(.instruction(directive)),
                                                               .decoration(makeDecoration("trill", .plus))])])])
        let normalized = tunebook.normalized()
        var symbols: [ABCSymbol] = []

        if case let .symbols(s) = normalized.tunes.first?.body.first {
            symbols = s
        }

        #expect(!symbols.contains(.inlineField(.instruction(directive))))
    }

    @Test
    func normalized_abcCharsetDirective_isDropped() {
        let directive = makeDirective("abc-charset", "utf-8")
        let tunebook = makeTunebook([.directive(directive)],
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.normalized().fileHeader.isEmpty)
    }

    @Test
    func normalized_abcVersionDirective_isDropped() {
        let directive = makeDirective("abc-version", "2.1")
        let tunebook = makeTunebook([.directive(directive)],
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(tunebook.normalized().fileHeader.isEmpty)
    }

    @Test
    func normalized_deprecatedTempo_v21_thenValidated_returnsNoErrors() throws {
        // Q:120 in 2.1 → deprecated tempo (legacyBeatMultiple=1), normalized away,
        // then validated → no issues
        let input = "%abc-2.1\nX:1\nT:Test\nQ:120\nK:C\nCDEF|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))

        #expect(!tunebook.isNormalized)

        let normalized = tunebook.normalized()

        #expect(normalized.isNormalized)

        let (_, issues) = try ABCValidator().validate(normalized)

        #expect(issues.isEmpty)
    }
}
