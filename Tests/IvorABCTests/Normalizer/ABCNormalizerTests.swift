// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorABC
import Testing
import XestiTools

struct ABCNormalizerTests {
}

// MARK: -

extension ABCNormalizerTests {
    @Test
    func normalize_alreadyNormalized_isIdempotent() {
        let normalizer = ABCNormalizer()
        let (once, _) = normalizer.normalize(makeTunebook(.current,
                                                          [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])]))
        let (twice, _) = normalizer.normalize(once)

        #expect(twice == once)
        #expect(twice.isNormalized)
    }

    @Test
    func normalize_setsIsNormalized() {
        let tunebook = makeTunebook(.v1_6,
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(!tunebook.isNormalized)
        #expect(ABCNormalizer().normalize(tunebook).0.isNormalized)
    }

    @Test
    func normalize_clearsIsValidated() {
        let tunebook = makeTunebook(.v2_0,
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(!ABCNormalizer().normalize(tunebook).0.isValidated)
    }

    @Test
    func normalize_fromV16_elemskipBecomesRemark() {
        let tune = makeTune(header: [.field(.elemskip(.integer(3)))])
        let tunebook = makeTunebook(.v1_6, [tune])
        let (normalized, _) = ABCNormalizer().normalize(tunebook)

        #expect(normalized.tunes.first?.header.contains(.field(.remark("3"))) == true)
        #expect(normalized.tunes.first?.header.contains(.field(.elemskip(.integer(3)))) == false)
    }

    @Test
    func normalize_fromV16_headerInformationBecomesRemark() {
        let tunebook = makeTunebook(.v1_6,
                                    [.field(.information("some info"))],
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])
        let (normalized, _) = ABCNormalizer().normalize(tunebook)

        #expect(normalized.fileHeader.contains(.field(.remark("some info"))) == true)
        #expect(normalized.fileHeader.contains(.field(.information("some info"))) == false)
    }

    @Test
    func normalize_fromV16_returnsCurrentVersion() {
        let tunebook = makeTunebook(.v1_6,
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(ABCNormalizer().normalize(tunebook).0.version == .current)
    }

    @Test
    func normalize_fromV16_tempoLegacyFlagCleared() {
        let dottedQuarter = makeDuration(3, 8)
        let legacyTempo = ABCTempo(durations: [dottedQuarter], rate: 40, text: nil, beatMultiplier: 3).require()
        let tune = makeTune(header: [.field(.tempo(legacyTempo))])
        let tunebook = makeTunebook(.v1_6, [tune])
        let (normalized, _) = ABCNormalizer().normalize(tunebook)

        let normalizedTempo = normalized.tunes.first?.header.compactMap { entry -> ABCTempo? in
            guard case let .field(f) = entry,
                  case let .tempo(t) = f
            else { return nil }

            return t
        }.first

        #expect(normalizedTempo?.beatMultiplier == nil)
        #expect(normalizedTempo?.durations == [dottedQuarter])
        #expect(normalizedTempo?.rate == 40)
    }

    @Test
    func normalize_fromV20_returnsCurrentVersion() {
        let tunebook = makeTunebook(.v2_0,
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(ABCNormalizer().normalize(tunebook).0.version == .current)
    }

    @Test
    func normalize_preservesFileHeaderAndTunes() {
        let fileHeader = ABCHeaderEntry.field(.composer("J.S. Bach"))
        let tune = makeTune(header: [.field(.tuneTitle("Test"))])
        let tunebook = makeTunebook(.v2_0, [fileHeader], [tune])
        let (normalized, _) = ABCNormalizer().normalize(tunebook)

        #expect(normalized.fileHeader == [fileHeader])
        #expect(normalized.tunes == [tune])
    }

    @Test
    func normalize_plusDecoration_convertsToBang() {
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(ABCReferenceNumber(1)))],
                                              body: [.symbols([.decoration(makeDecoration("trill", .plus))])])])
        let (normalized, _) = ABCNormalizer().normalize(tunebook)

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
    func normalize_fileHeaderDecorationPlusDirective_isDropped() {
        let directive = makeDirective("decoration", "+")
        let tunebook = makeTunebook([.directive(directive)],
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(ABCNormalizer().normalize(tunebook).0.fileHeader.isEmpty)
    }

    @Test
    func normalize_tuneHeaderDecorationPlusDirective_isDropped() {
        let directive = makeDirective("decoration", "+")
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(ABCReferenceNumber(1))),
                                                       .directive(directive),
                                                       .field(.key(makeKeySignature(.c, .major)))])])
        let (normalized, _) = ABCNormalizer().normalize(tunebook)

        #expect(!normalized.tunes[0].header.contains(.directive(directive)))
    }

    @Test
    func normalize_inlineDecorationPlusDirective_isDropped() {
        let directive = makeDirective("decoration", "+")
        let tunebook = makeTunebook([makeTune(header: [.field(.referenceNumber(ABCReferenceNumber(1))),
                                                       .field(.key(makeKeySignature(.c, .major)))],
                                              body: [.symbols([.inlineField(.instruction(directive)),
                                                               .decoration(makeDecoration("trill", .plus))])])])
        let (normalized, _) = ABCNormalizer().normalize(tunebook)
        var symbols: [ABCSymbol] = []

        if case let .symbols(s) = normalized.tunes.first?.body.first {
            symbols = s
        }

        #expect(!symbols.contains(.inlineField(.instruction(directive))))
    }

    @Test
    func normalize_abcCharsetDirective_isDropped() {
        let directive = makeDirective("abc-charset", "utf-8")
        let tunebook = makeTunebook([.directive(directive)],
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(ABCNormalizer().normalize(tunebook).0.fileHeader.isEmpty)
    }

    @Test
    func normalize_abcVersionDirective_isDropped() {
        let directive = makeDirective("abc-version", "2.1")
        let tunebook = makeTunebook([.directive(directive)],
                                    [makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(ABCNormalizer().normalize(tunebook).0.fileHeader.isEmpty)
    }

    @Test
    func normalize_deprecatedTempo_v21_thenValidated_returnsNoIssues() throws {
        let input = "%abc-2.1\nX:1\nT:Test\nQ:120\nK:C\nCDEF|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))

        #expect(!tunebook.isNormalized)

        let (normalized, _) = ABCNormalizer().normalize(tunebook)

        #expect(normalized.isNormalized)

        let (_, issues) = try ABCValidator().validate(normalized)

        #expect(issues.isEmpty)
    }
}
