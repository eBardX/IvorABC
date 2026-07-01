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
        let invalidFields: [ABCField] = [.wordsAligned(makeAlignedWords()),
                                         .key(.empty),
                                         .part(.a),
                                         .words(""),
                                         .parts(makePartSequence([makePart(.a)])),
                                         .referenceNumber(makeReferenceNumber(1)),
                                         .symbolLine(makeSymbolLine([])),
                                         .tempo(makeTempo([])),
                                         .tuneTitle(""),
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
                                       .unitNoteLength(makeLength(1, 8)),
                                       .userDefined(makeUserSymbol(.tilde, makeDecoration("roll"))),
                                       .userDefined(makeUserSymbol(.hUpper, makeAnnotation(.above, "fermata")))]

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
                                         .parts(makePartSequence([makePart(.a)])),
                                         .referenceNumber(makeReferenceNumber(1)),
                                         .source(""),
                                         .transcription("")]

        for field in invalidFields {
            #expect(!field.isValidInTuneBody)
        }
    }

    @Test
    func isValidInTuneBody_validFields() {
        let validFields: [ABCField] = [.wordsAligned(makeAlignedWords()),
                                       .instruction(makeDirective("linebreak", "")),
                                       .key(.empty),
                                       .part(.a),
                                       .words(""),
                                       .macro(makeMacro("~G2", "{A}G{F}G")),
                                       .meter(.common),
                                       .notes(""),
                                       .remark(""),
                                       .rhythm(""),
                                       .symbolLine(makeSymbolLine([])),
                                       .tempo(makeTempo([])),
                                       .tuneTitle(""),
                                       .unitNoteLength(makeLength(1, 8)),
                                       .userDefined(makeUserSymbol(.tilde, makeDecoration("roll"))),
                                       .userDefined(makeUserSymbol(.hUpper, makeAnnotation(.above, "fermata"))),
                                       .voice(makeVoice("1"))]

        for field in validFields {
            #expect(field.isValidInTuneBody)
        }
    }

    @Test
    func isValidInTuneHeader_invalidFields() {
        let invalidFields: [ABCField] = [.part(.a),
                                         .wordsAligned(makeAlignedWords()),
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
                                       .words(""),
                                       .macro(makeMacro("~G2", "{A}G{F}G")),
                                       .meter(.common),
                                       .notes(""),
                                       .origin(""),
                                       .parts(makePartSequence([makePart(.a)])),
                                       .referenceNumber(makeReferenceNumber(1)),
                                       .remark(""),
                                       .rhythm(""),
                                       .source(""),
                                       .tempo(makeTempo([])),
                                       .tuneTitle(""),
                                       .transcription(""),
                                       .unitNoteLength(makeLength(1, 8)),
                                       .userDefined(makeUserSymbol(.tilde, makeDecoration("roll"))),
                                       .userDefined(makeUserSymbol(.hUpper, makeAnnotation(.above, "fermata"))),
                                       .voice(makeVoice("1"))]

        for field in validFields {
            #expect(field.isValidInTuneHeader)
        }
    }
}
