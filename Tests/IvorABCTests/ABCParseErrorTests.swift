// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCParseErrorTests {
}

// MARK: -

extension ABCParseErrorTests {
    @Test
    func test_categoryIsIvorABC() {
        let error = ABCParseError.dataConversionFailed

        #expect(error.category?.description == "IvorABC")
    }

    @Test
    func test_messageDataConversionFailed() {
        let error = ABCParseError.dataConversionFailed

        #expect(error.message == "Failed to convert UTF-8 data to string")
    }

    @Test
    func test_messageInvalidDirective() {
        let error = ABCParseError.invalidDirective("%%bogus")

        #expect(error.message.contains("%%bogus"))
    }

    @Test
    func test_messageInvalidFieldInline() {
        let error = ABCParseError.invalidField(true, "[Q:bogus]")

        #expect(error.message.contains("inline"))
    }

    @Test
    func test_messageInvalidFieldNotInline() {
        let error = ABCParseError.invalidField(false, "Q:bogus")

        #expect(!error.message.contains("inline"))
        #expect(error.message.contains("Q:bogus"))
    }

    @Test
    func test_messageInvalidFileID() {
        let error = ABCParseError.invalidFileID("%abc-3.0")

        #expect(error.message.contains("%abc-3.0"))
    }

    @Test
    func test_messageInvalidKeySignature() {
        let error = ABCParseError.invalidKeySignature("B##")

        #expect(error.message.contains("B##"))
    }

    @Test
    func test_messageInvalidNote() {
        let error = ABCParseError.invalidNote("xyz")

        #expect(error.message.contains("xyz"))
    }

    @Test
    func test_messageInvalidPitch() {
        let error = ABCParseError.invalidPitch("^^^C")

        #expect(error.message.contains("^^^C"))
    }

    @Test
    func test_messageInvalidRefNumber() {
        let error = ABCParseError.invalidRefNumber("0")

        #expect(error.message.contains("0"))
    }

    @Test
    func test_messageInvalidRest() {
        let error = ABCParseError.invalidRest("y")

        #expect(error.message.contains("y"))
    }

    @Test
    func test_messageInvalidSymbols() {
        let error = ABCParseError.invalidSymbols("@@@")

        #expect(error.message.contains("@@@"))
    }

    @Test
    func test_messageInvalidTempo() {
        let error = ABCParseError.invalidTempo("bogus")

        #expect(error.message.contains("bogus"))
    }

    @Test
    func test_messageInvalidTimeSignature() {
        let error = ABCParseError.invalidTimeSignature("4/3")

        #expect(error.message.contains("4/3"))
    }

    @Test
    func test_messageInvalidTuplet() {
        let error = ABCParseError.invalidTuplet("(10")

        #expect(error.message.contains("(10"))
    }

    @Test
    func test_messageInvalidUnitNoteLength() {
        let error = ABCParseError.invalidUnitNoteLength("1/3")

        #expect(error.message.contains("1/3"))
    }

    @Test
    func test_messageInvalidVersion() {
        let error = ABCParseError.invalidVersion("abc")

        #expect(error.message.contains("abc"))
    }

    @Test
    func test_messageInvalidVoice() {
        let error = ABCParseError.invalidVoice("")

        #expect(error.message.contains("voice"))
    }

    @Test
    func test_messageMisplacedField() {
        let error = ABCParseError.misplacedField(.area("test"))

        #expect(error.message.contains("Misplaced"))
    }

    @Test
    func test_messageMissingFileID() {
        let error = ABCParseError.missingFileID

        #expect(error.message.contains("Missing"))
    }

    @Test
    func test_messageUnsupportedVersion() {
        let version = ABCVersion(major: 3, minor: 0)
        let error = ABCParseError.unsupportedVersion(version)

        #expect(error.message.contains("3.0"))
    }
}
