// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCFieldTests {
}

// MARK: -

extension ABCFieldTests {
    @Test
    func test_isValidInFileHeader_invalidFields() {
        let invalidFields: [ABCField] = [.alignedLyrics(""),
                                         .key(.empty),
                                         .lyrics(""),
                                         .parts(""),
                                         .refNumber(ABCRefNumber(uintValue: 1)),
                                         .symbolLine(""),
                                         .tempo(ABCTempo(duration: nil,
                                                         rate: nil,
                                                         text: nil)),
                                         .title(""),
                                         .voice(ABCVoice(id: "1",
                                                         properties: [:]))]

        for field in invalidFields {
            #expect(!field.isValidInFileHeader)
        }
    }

    @Test
    func test_isValidInFileHeader_validFields() {
        let validFields: [ABCField] = [.area(""),
                                       .book(""),
                                       .composer(""),
                                       .discography(""),
                                       .fileURL(""),
                                       .group(""),
                                       .history(""),
                                       .instruction(""),
                                       .macro(""),
                                       .meter(.common),
                                       .notes(""),
                                       .origin(""),
                                       .remark(""),
                                       .rhythm(""),
                                       .source(""),
                                       .transcription(""),
                                       .unitNoteLength(ABCDuration(numerator: 1,
                                                                   denominator: 8,
                                                                   reduce: false)),
                                       .userDefined("")]

        for field in validFields {
            #expect(field.isValidInFileHeader)
        }
    }

    @Test
    func test_isValidInTuneBody_invalidFields() {
        let invalidFields: [ABCField] = [.area(""),
                                         .book(""),
                                         .composer(""),
                                         .discography(""),
                                         .fileURL(""),
                                         .group(""),
                                         .history(""),
                                         .origin(""),
                                         .refNumber(ABCRefNumber(uintValue: 1)),
                                         .source(""),
                                         .transcription("")]

        for field in invalidFields {
            #expect(!field.isValidInTuneBody)
        }
    }

    @Test
    func test_isValidInTuneBody_validFields() {
        let validFields: [ABCField] = [.alignedLyrics(""),
                                       .instruction(""),
                                       .key(.empty),
                                       .lyrics(""),
                                       .macro(""),
                                       .meter(.common),
                                       .notes(""),
                                       .parts(""),
                                       .remark(""),
                                       .rhythm(""),
                                       .symbolLine(""),
                                       .tempo(ABCTempo(duration: nil,
                                                       rate: nil,
                                                       text: nil)),
                                       .title(""),
                                       .unitNoteLength(ABCDuration(numerator: 1,
                                                                   denominator: 8,
                                                                   reduce: false)),
                                       .userDefined(""),
                                       .voice(ABCVoice(id: "1",
                                                       properties: [:]))]

        for field in validFields {
            #expect(field.isValidInTuneBody)
        }
    }

    @Test
    func test_isValidInTuneHeader_invalidFields() {
        let invalidFields: [ABCField] = [.alignedLyrics(""),
                                         .symbolLine("")]

        for field in invalidFields {
            #expect(!field.isValidInTuneHeader)
        }
    }

    @Test
    func test_isValidInTuneHeader_validFields() {
        let validFields: [ABCField] = [.area(""),
                                       .book(""),
                                       .composer(""),
                                       .discography(""),
                                       .fileURL(""),
                                       .group(""),
                                       .history(""),
                                       .instruction(""),
                                       .key(.empty),
                                       .lyrics(""),
                                       .macro(""),
                                       .meter(.common),
                                       .notes(""),
                                       .origin(""),
                                       .parts(""),
                                       .refNumber(ABCRefNumber(uintValue: 1)),
                                       .remark(""),
                                       .rhythm(""),
                                       .source(""),
                                       .tempo(ABCTempo(duration: nil,
                                                       rate: nil,
                                                       text: nil)),
                                       .title(""),
                                       .transcription(""),
                                       .unitNoteLength(ABCDuration(numerator: 1,
                                                                   denominator: 8,
                                                                   reduce: false)),
                                       .userDefined(""),
                                       .voice(ABCVoice(id: "1",
                                                       properties: [:]))]

        for field in validFields {
            #expect(field.isValidInTuneHeader)
        }
    }
}
