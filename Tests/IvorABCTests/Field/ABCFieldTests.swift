// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCFieldTests {
}

// MARK: -

extension ABCFieldTests {
    @Test
    func isValidInFileHeader_invalidFields() {
        let invalidFields: [ABCField] = [.alignedLyrics(makeAlignedLyrics()),
                                         .key(.empty),
                                         .lyrics(""),
                                         .parts(makePartSequence([makePart("A")])),
                                         .referenceNumber(makeReferenceNumber(1)),
                                         .symbolLine(makeSymbolLine([])),
                                         .tempo(makeTempo([])),
                                         .title(""),
                                         .voice(makeVoice("1"))]

        for field in invalidFields {
            #expect(!field.isValidInFileHeader)
        }
    }

    @Test
    func isValidInFileHeader_validFields() {
        let validFields: [ABCField] = [.area(""),
                                       .book(""),
                                       .composer(""),
                                       .discography(""),
                                       .fileURL(""),
                                       .group(""),
                                       .history(""),
                                       .macro(makeMacro("~G2", "{A}G{F}G")),
                                       .meter(.common),
                                       .notes(""),
                                       .origin(""),
                                       .remark(""),
                                       .rhythm(""),
                                       .source(""),
                                       .transcription(""),
                                       .unitNoteLength(makeDuration(1, 8)),
                                       .userSymbol(makeUserSymbol(.tilde, makeDecoration("roll")))]

        for field in validFields {
            #expect(field.isValidInFileHeader)
        }
    }

    @Test
    func isValidInTuneBody_invalidFields() {
        let invalidFields: [ABCField] = [.area(""),
                                         .book(""),
                                         .composer(""),
                                         .discography(""),
                                         .fileURL(""),
                                         .group(""),
                                         .history(""),
                                         .origin(""),
                                         .referenceNumber(makeReferenceNumber(1)),
                                         .source(""),
                                         .transcription("")]

        for field in invalidFields {
            #expect(!field.isValidInTuneBody)
        }
    }

    @Test
    func isValidInTuneBody_validFields() {
        let validFields: [ABCField] = [.alignedLyrics(makeAlignedLyrics()),
                                       .instruction(makeDirective("linebreak", "")),
                                       .key(.empty),
                                       .lyrics(""),
                                       .macro(makeMacro("~G2", "{A}G{F}G")),
                                       .meter(.common),
                                       .notes(""),
                                       .parts(makePartSequence([makePart("A")])),
                                       .remark(""),
                                       .rhythm(""),
                                       .symbolLine(makeSymbolLine([])),
                                       .tempo(makeTempo([])),
                                       .title(""),
                                       .unitNoteLength(makeDuration(1, 8)),
                                       .userSymbol(makeUserSymbol(.tilde, makeDecoration("roll"))),
                                       .voice(makeVoice("1"))]

        for field in validFields {
            #expect(field.isValidInTuneBody)
        }
    }

    @Test
    func isValidInTuneHeader_invalidFields() {
        let invalidFields: [ABCField] = [.alignedLyrics(makeAlignedLyrics()),
                                         .symbolLine(makeSymbolLine([]))]

        for field in invalidFields {
            #expect(!field.isValidInTuneHeader)
        }
    }

    @Test
    func isValidInTuneHeader_validFields() {
        let validFields: [ABCField] = [.area(""),
                                       .book(""),
                                       .composer(""),
                                       .discography(""),
                                       .fileURL(""),
                                       .group(""),
                                       .history(""),
                                       .key(.empty),
                                       .lyrics(""),
                                       .macro(makeMacro("~G2", "{A}G{F}G")),
                                       .meter(.common),
                                       .notes(""),
                                       .origin(""),
                                       .parts(makePartSequence([makePart("A")])),
                                       .referenceNumber(makeReferenceNumber(1)),
                                       .remark(""),
                                       .rhythm(""),
                                       .source(""),
                                       .tempo(makeTempo([])),
                                       .title(""),
                                       .transcription(""),
                                       .unitNoteLength(makeDuration(1, 8)),
                                       .userSymbol(makeUserSymbol(.tilde, makeDecoration("roll"))),
                                       .voice(makeVoice("1"))]

        for field in validFields {
            #expect(field.isValidInTuneHeader)
        }
    }
}
