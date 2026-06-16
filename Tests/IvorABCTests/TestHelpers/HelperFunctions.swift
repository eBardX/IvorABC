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

func makeAlignedLyrics(_ segments: [ABCAlignedLyrics.Segment] = []) -> ABCAlignedLyrics {
    ABCAlignedLyrics(segments: segments)
}

func makeAnnotation(_ position: ABCAnnotation.Position,
                    _ text: String) -> ABCAnnotation {
    ABCAnnotation(position: position,
                  text: text)
}

func makeChord(_ notes: [ABCNote],
               _ duration: ABCDuration,
               _ isTied: Bool) -> ABCChord {
    ABCChord(notes: notes,
             duration: duration,
             isTied: isTied)!   // swiftlint:disable:this force_unwrapping
}

func makeDecoration(_ name: String,
                    _ dialect: ABCDecoration.Dialect = .bang) -> ABCDecoration {
    ABCDecoration(name: name,
                  dialect: dialect)!    // swiftlint:disable:this force_unwrapping
}

func makeDirective(_ name: String,
                   _ value: String,
                   _ content: [String]? = nil) -> ABCDirective {
    ABCDirective(name: name,
                 value: value,
                 content: content)
}

func makeDuration(_ numerator: UInt,
                  _ denominator: UInt = 1) -> ABCDuration {
    ABCDuration(numerator: numerator,
                denominator: denominator)!  // swiftlint:disable:this force_unwrapping
}

func makeFileID(_ version: ABCVersion) -> ABCFileID {
    ABCFileID(version: version)
}

func makeGraceNotes(_ notes: [ABCNote],
                    _ isSlashed: Bool) -> ABCGraceNotes {
    ABCGraceNotes(notes: notes,
                  isSlashed: isSlashed)!    // swiftlint:disable:this force_unwrapping
}

func makeKeySignature(_ tonic: ABCKeySignature.Tonic,
                      _ mode: ABCKeySignature.Mode) -> ABCKeySignature {
    .standard(ABCKeySignature.Standard(tonic: tonic,
                                       mode: mode)!)    // swiftlint:disable:this force_unwrapping
}

func makeKeySignature(_ tonic: ABCKeySignature.Tonic,
                      _ mode: ABCKeySignature.Mode,
                      _ extraAccidentals: [ABCKeySignature.ExtraAccidental]) -> ABCKeySignature {
    .standard(ABCKeySignature.Standard(tonic: tonic,
                                       mode: mode,
                                       extraAccidentals: extraAccidentals)!)    // swiftlint:disable:this force_unwrapping
}

func makeKeySignature(_ tonic: ABCKeySignature.Tonic,
                      _ mode: ABCKeySignature.Mode,
                      _ clef: ABCKeySignature.Clef) -> ABCKeySignature {
    .standard(ABCKeySignature.Standard(tonic: tonic,
                                       mode: mode,
                                       clef: clef)!)    // swiftlint:disable:this force_unwrapping
}

func makeMacro(_ trigger: String,
               _ replacement: String) -> ABCMacro {
    ABCMacro(trigger: trigger,
             replacement: replacement)
}

func makeMacroCall(_ trigger: String,
                   _ expansion: [ABCSymbol]) -> ABCMacroCall {
    ABCMacroCall(trigger: trigger,
                 expansion: expansion)
}

func makeNote(_ pitch: ABCPitch,
              _ duration: ABCDuration,
              _ isTied: Bool) -> ABCNote {
    ABCNote(pitch: pitch,
            duration: duration,
            isTied: isTied)
}

func makePart(_ letter: Character,
              _ count: UInt = 1) -> ABCPartSequence.Item {
    .part(letter, count)
}

func makePartGroup(_ items: [ABCPartSequence.Item],
                   _ count: UInt = 1) -> ABCPartSequence.Item {
    .group(items, count)
}

func makePartSequence(_ items: [ABCPartSequence.Item]) -> ABCPartSequence {
    ABCPartSequence(items: items)
}

func makePitch(_ letter: ABCPitch.Letter,
               _ accidental: ABCPitch.Accidental,
               _ octave: ABCPitch.Octave) -> ABCPitch {
    ABCPitch(letter: letter,
             accidental: accidental,
             octave: octave)
}

func makeRefNumber(_ uintValue: UInt) -> ABCRefNumber {
    ABCRefNumber(uintValue: uintValue)
}

func makeSymbolLine(_ elements: [ABCSymbolLine.Element]) -> ABCSymbolLine {
    ABCSymbolLine(elements: elements)
}

func makeTempo(_ numerator: UInt,
               _ denominator: UInt,
               _ rate: UInt? = nil,
               _ text: String? = nil) -> ABCTempo {
    ABCTempo(durations: [makeDuration(numerator, denominator)],
             rate: rate,
             text: text)
}

func makeTempo(_ durations: [ABCDuration],
               _ rate: UInt? = nil,
               _ text: String? = nil) -> ABCTempo {
    ABCTempo(durations: durations,
             rate: rate,
             text: text)
}

func makeTempo(_ text: String) -> ABCTempo {
    ABCTempo(durations: [],
             rate: nil,
             text: text)
}

func makeTimeSignature(_ numerator: UInt,
                       _ denominator: UInt) -> ABCTimeSignature {
    .standard(ABCTimeSignature.StandardMeter(numerator: numerator,
                                             denominator: denominator)!) // swiftlint:disable:this force_unwrapping
}

func makeTimeSignature(_ numerators: [UInt],
                       _ denominator: UInt) -> ABCTimeSignature {
    .complex(ABCTimeSignature.AdditiveMeter(numerators: numerators,
                                            denominator: denominator)!) // swiftlint:disable:this force_unwrapping
}

func makeTuplet(_ noteCount: UInt,
                _ beatCount: UInt? = nil,
                _ affectedCount: UInt? = nil) -> ABCTuplet {
    ABCTuplet(noteCount: noteCount,
              beatCount: beatCount,
              affectedCount: affectedCount)!    // swiftlint:disable:this force_unwrapping
}

func makeUserSymbol(_ symbol: Character,
                    _ decoration: ABCDecoration) -> ABCUserSymbol {
    ABCUserSymbol(symbol: symbol,
                  decoration: decoration)
}

func makeVariantEnding(_ endings: [ClosedRange<UInt>]) -> ABCVariantEnding {
    ABCVariantEnding(endings: endings)! // swiftlint:disable:this force_unwrapping
}

func makeVersion(_ major: UInt,
                 _ minor: UInt) -> ABCVersion {
    ABCVersion(major: major,
               minor: minor)
}

func makeVoice(_ id: String,
               _ properties: [String: String] = [:]) -> ABCVoice {
    ABCVoice(id: id,
             properties: properties)
}

func matchSymbols(_ input: String) throws -> [ABCSymbol] {
    var ctx = ABCParseContext()

    return try matchSymbols(input,
                            context: &ctx)
}

func matchSymbols(_ input: String,
                  context: inout ABCParseContext) throws -> [ABCSymbol] {
    let tokenizer = ABCSymbolTokenizer(tracing: .silent)
    let tokens = try tokenizer.tokenize(input)
    var matcher = ABCSymbolMatcher(tokens: tokens)

    return try matcher.matchSymbols(&context)
}

// MARK: - ABCFormatter Helpers

func format(_ tunebook: ABCTunebook) throws -> String {
    let formatter = ABCFormatter()
    let data = try formatter.format(tunebook)

    return String(bytes: data, encoding: .utf8) ?? ""
}

func minimalTunebook(key: ABCKeySignature = .standard(.init(tonic: .c, mode: .major)!),    // swiftlint:disable:this force_unwrapping
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
                                          .field(.unitNoteLength(makeDuration(1, 4))),
                                          .field(.key(makeKeySignature(.c, .major))),
                                          .symbols(symbols)])])
}

func minimalTunebookWithTempo(_ tempo: ABCTempo) -> ABCTunebook {
    ABCTunebook(version: ABCVersion(major: 2, minor: 1),
                headers: [],
                tunes: [ABCTune(entries: [.field(.refNumber(ABCRefNumber(uintValue: 1))),
                                          .field(.tempo(tempo)),
                                          .field(.key(makeKeySignature(.c, .major))),
                                          .symbols([])])])
}
