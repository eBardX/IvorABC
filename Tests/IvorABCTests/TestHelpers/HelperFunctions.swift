// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorABC
import Testing
import XestiTools

// MARK: - ABCField Expectations

func expectFieldIsAlignedLyrics(_ field: ABCField,
                                _ expected: ABCAlignedLyrics,
                                sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .alignedLyrics(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .alignedLyrics", sourceLocation: sourceLocation)
    }
}

func expectFieldIsArea(_ field: ABCField,
                       _ expected: String,
                       sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .area(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .area", sourceLocation: sourceLocation)
    }
}

func expectFieldIsBook(_ field: ABCField,
                       _ expected: String,
                       sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .book(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .book", sourceLocation: sourceLocation)
    }
}

func expectFieldIsComposer(_ field: ABCField,
                           _ expected: String,
                           sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .composer(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .composer", sourceLocation: sourceLocation)
    }
}

func expectFieldIsDiscography(_ field: ABCField,
                              _ expected: String,
                              sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .discography(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .discography", sourceLocation: sourceLocation)
    }
}

func expectFieldIsFileURL(_ field: ABCField,
                          _ expected: String,
                          sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .fileURL(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .fileURL", sourceLocation: sourceLocation)
    }
}

func expectFieldIsGroup(_ field: ABCField,
                        _ expected: String,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .group(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .group", sourceLocation: sourceLocation)
    }
}

func expectFieldIsHistory(_ field: ABCField,
                          _ expected: String,
                          sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .history(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .history", sourceLocation: sourceLocation)
    }
}

func expectFieldIsInstruction(_ field: ABCField,
                              _ expected: ABCDirective,
                              sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .instruction(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .instruction", sourceLocation: sourceLocation)
    }
}

func expectFieldIsKey(_ field: ABCField,
                      sourceLocation: SourceLocation = #_sourceLocation) {
    if case .key = field { } else {
        Issue.record("Expected .key", sourceLocation: sourceLocation)
    }
}

func expectFieldIsLyrics(_ field: ABCField,
                         _ expected: String,
                         sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .lyrics(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .lyrics", sourceLocation: sourceLocation)
    }
}

func expectFieldIsMacro(_ field: ABCField,
                        _ expected: ABCMacro,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .macro(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .macro", sourceLocation: sourceLocation)
    }
}

func expectFieldIsMeter(_ field: ABCField,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case .meter = field { } else {
        Issue.record("Expected .meter", sourceLocation: sourceLocation)
    }
}

func expectFieldIsNotes(_ field: ABCField,
                        _ expected: String,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .notes(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .notes", sourceLocation: sourceLocation)
    }
}

func expectFieldIsOrigin(_ field: ABCField,
                         _ expected: String,
                         sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .origin(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .origin", sourceLocation: sourceLocation)
    }
}

func expectFieldIsParts(_ field: ABCField,
                        _ expected: ABCPartSequence,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .parts(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .parts", sourceLocation: sourceLocation)
    }
}

func expectFieldIsRefNumber(_ field: ABCField,
                            sourceLocation: SourceLocation = #_sourceLocation) {
    if case .refNumber = field { } else {
        Issue.record("Expected .refNumber", sourceLocation: sourceLocation)
    }
}

func expectFieldIsRemark(_ field: ABCField,
                         _ expected: String,
                         sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .remark(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .remark", sourceLocation: sourceLocation)
    }
}

func expectFieldIsRhythm(_ field: ABCField,
                         _ expected: String,
                         sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .rhythm(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .rhythm", sourceLocation: sourceLocation)
    }
}

func expectFieldIsSource(_ field: ABCField,
                         _ expected: String,
                         sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .source(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .source", sourceLocation: sourceLocation)
    }
}

func expectFieldIsSymbolLine(_ field: ABCField,
                             _ expected: ABCSymbolLine,
                             sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .symbolLine(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .symbolLine", sourceLocation: sourceLocation)
    }
}

func expectFieldIsTempo(_ field: ABCField,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case .tempo = field { } else {
        Issue.record("Expected .tempo", sourceLocation: sourceLocation)
    }
}

func expectFieldIsTitle(_ field: ABCField,
                        _ expected: String,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .title(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .title", sourceLocation: sourceLocation)
    }
}

func expectFieldIsTranscription(_ field: ABCField,
                                _ expected: String,
                                sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .transcription(v) = field {
        #expect(v.stringValue == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .transcription", sourceLocation: sourceLocation)
    }
}

func expectFieldIsUnitNoteLength(_ field: ABCField,
                                 sourceLocation: SourceLocation = #_sourceLocation) {
    if case .unitNoteLength = field { } else {
        Issue.record("Expected .unitNoteLength", sourceLocation: sourceLocation)
    }
}

func expectFieldIsUserSymbol(_ field: ABCField,
                             _ expected: ABCUserSymbol,
                             sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .userSymbol(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .userSymbol", sourceLocation: sourceLocation)
    }
}

func expectFieldIsVoice(_ field: ABCField,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case .voice = field { } else {
        Issue.record("Expected .voice", sourceLocation: sourceLocation)
    }
}

// MARK: - Parse Result Comparisons

// swiftlint:disable:next static_operator
func == (lhs: ParseNoteResult?,
         rhs: ParseNoteResult?) -> Bool {
    lhs?.duration == rhs?.duration
    && lhs?.isTied == rhs?.isTied
    && lhs?.pitch == rhs?.pitch
}

// swiftlint:disable:next static_operator
func == (lhs: ParsePitchResult?,
         rhs: ParsePitchResult?) -> Bool {
    lhs?.accidental == rhs?.accidental
    && lhs?.letter == rhs?.letter
    && lhs?.octave == rhs?.octave
}

// swiftlint:disable:next static_operator
func == (lhs: ParseRestResult?,
         rhs: ParseRestResult?) -> Bool {
    lhs?.kind == rhs?.kind
    && lhs?.duration == rhs?.duration
}

// swiftlint:disable:next static_operator
func == (lhs: ParseTupletResult?,
         rhs: ParseTupletResult?) -> Bool {
    lhs?.pcount == rhs?.pcount
    && lhs?.qcount == rhs?.qcount
    && lhs?.rcount == rhs?.rcount
}

// MARK: - Factory Functions

// swiftlint:disable:next identifier_name
func _alyrics(_ segments: [ABCAlignedLyrics.Segment] = []) -> ABCAlignedLyrics {
    ABCAlignedLyrics(segments: segments)
}

// swiftlint:disable:next identifier_name
func _dur(_ numerator: UInt,
          _ denominator: UInt) -> ABCDuration {
    ABCDuration(numerator, denominator)
}

// swiftlint:disable:next identifier_name
func _matchSymbols(_ input: String,
                   context: inout ABCParseContext) throws -> [ABCSymbol] {
    let tokenizer = ABCSymbolTokenizer(tracing: .silent)
    let tokens = try tokenizer.tokenize(input)
    var matcher = ABCSymbolMatcher(tokens: tokens)

    return try matcher.matchSymbols(&context)
}

// swiftlint:disable:next identifier_name
func _matchSymbols(_ input: String) throws -> [ABCSymbol] {
    var ctx = ABCParseContext()

    return try _matchSymbols(input,
                             context: &ctx)
}

// swiftlint:disable:next identifier_name
func _pit(_ letter: ABCPitch.Letter,
          _ accidental: ABCPitch.Accidental,
          _ octave: ABCPitch.Octave) -> ABCPitch {
    ABCPitch(letter: letter,
             accidental: accidental,
             octave: octave)
}

// swiftlint:disable:next identifier_name
func _pgroup(_ items: [ABCPartSequence.Item],
             _ count: UInt = 1) -> ABCPartSequence.Item {
    .group(items, count)
}

// swiftlint:disable:next identifier_name
func _ppart(_ letter: Character,
            _ count: UInt = 1) -> ABCPartSequence.Item {
    .part(letter, count)
}

// swiftlint:disable:next identifier_name
func _pseq(_ items: [ABCPartSequence.Item] = []) -> ABCPartSequence {
    ABCPartSequence(items: items)
}

// swiftlint:disable:next identifier_name
func _rnum(_ uintValue: UInt) -> ABCRefNumber {
    ABCRefNumber(uintValue: uintValue)
}

// swiftlint:disable:next identifier_name
func _sline(_ elements: [ABCSymbolLine.Element] = []) -> ABCSymbolLine {
    ABCSymbolLine(elements: elements)
}

// swiftlint:disable:next identifier_name
func _tempo(_ numerator: UInt,
            _ denominator: UInt,
            _ rate: UInt) -> ABCTempo {
    ABCTempo(durations: [_dur(numerator, denominator)],
             rate: rate,
             text: nil)
}

// swiftlint:disable:next identifier_name
func _tempo(_ numerator: UInt,
            _ denominator: UInt,
            _ rate: UInt,
            _ text: String) -> ABCTempo {
    ABCTempo(durations: [_dur(numerator, denominator)],
             rate: rate,
             text: text)
}

// swiftlint:disable:next identifier_name
func _tempo(_ durations: [ABCDuration],
            _ rate: UInt) -> ABCTempo {
    ABCTempo(durations: durations,
             rate: rate,
             text: nil)
}

// swiftlint:disable:next identifier_name
func _tempo(_ text: String) -> ABCTempo {
    ABCTempo(durations: [],
             rate: nil,
             text: text)
}

// swiftlint:disable:next identifier_name
func _tsig(_ numerator: UInt,
           _ denominator: UInt) throws -> ABCTimeSignature {
    try .standard(#require(ABCTimeSignature.StandardMeter(numerator: numerator, denominator: denominator)))
}

// swiftlint:disable:next identifier_name
func _tsig(_ numerators: [UInt],
           _ denominator: UInt) throws -> ABCTimeSignature {
    try .complex(#require(ABCTimeSignature.AdditiveMeter(numerators: numerators, denominator: denominator)))
}

// swiftlint:disable:next identifier_name
func _deco(_ name: String,
           _ dialect: ABCDecoration.Dialect = .bang) -> ABCDecoration {
    ABCDecoration(name, nil, dialect)
}

// swiftlint:disable:next identifier_name
func _usym(_ symbol: Character,
           _ decoration: ABCDecoration) -> ABCUserSymbol {
    ABCUserSymbol(symbol: symbol,
                  decoration: decoration)
}

// swiftlint:disable:next identifier_name
func _voice(_ id: String,
            _ properties: [String: String] = [:]) -> ABCVoice {
    ABCVoice(id: id,
             properties: properties)
}

// MARK: - ABCFormatter Helpers

func format(_ tunebook: ABCTunebook) throws -> String {
    let formatter = ABCFormatter()
    let data = try formatter.format(tunebook)

    return String(bytes: data, encoding: .utf8) ?? ""
}

func minimalTunebook(key: ABCKeySignature = .standard(.c, .major, [], nil),
                     symbols: [ABCSymbol] = []) -> ABCTunebook {
    ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                headers: [],
                tunes: [ABCTune(entries: [.field(.refNumber(ABCRefNumber(uintValue: 1))),
                                          .field(.title("Test")),
                                          .field(.key(key)),
                                          .symbols(symbols)])])
}

func minimalTunebookWithL4(symbols: [ABCSymbol]) -> ABCTunebook {
    ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                headers: [],
                tunes: [ABCTune(entries: [.field(.refNumber(ABCRefNumber(uintValue: 1))),
                                          .field(.unitNoteLength(_dur(1, 4))),
                                          .field(.key(.standard(.c, .major, [], nil))),
                                          .symbols(symbols)])])
}

func minimalTunebookWithTempo(_ tempo: ABCTempo) -> ABCTunebook {
    ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                headers: [],
                tunes: [ABCTune(entries: [.field(.refNumber(ABCRefNumber(uintValue: 1))),
                                          .field(.tempo(tempo)),
                                          .field(.key(.standard(.c, .major, [], nil))),
                                          .symbols([])])])
}
