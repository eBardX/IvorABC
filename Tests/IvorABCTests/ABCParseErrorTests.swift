// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCParseErrorTests {
}

// MARK: -

extension ABCParseErrorTests {
    @Test
    func category_isIvorABC() {
        let error = ABCParseError.dataConversionFailed

        #expect(error.category?.description == "IvorABC")
    }

    @Test
    func message_dataConversionFailed() {
        let error = ABCParseError.dataConversionFailed

        #expect(error.message == "Failed to convert UTF-8 data to string")
    }

    @Test
    func message_invalidDirective() {
        let error = ABCParseError.invalidDirective("%%bogus")

        #expect(error.message.contains("%%bogus"))
    }

    @Test
    func message_invalidFieldInline() {
        let error = ABCParseError.invalidField(true, "[Q:bogus]")

        #expect(error.message.contains("inline"))
    }

    @Test
    func message_invalidFieldNotInline() {
        let error = ABCParseError.invalidField(false, "Q:bogus")

        #expect(!error.message.contains("inline"))
        #expect(error.message.contains("Q:bogus"))
    }

    @Test
    func message_invalidFileID() {
        let error = ABCParseError.invalidFileID("%abc-3.0")

        #expect(error.message.contains("%abc-3.0"))
    }

    @Test
    func message_invalidKeySignature() {
        let error = ABCParseError.invalidKeySignature("B##")

        #expect(error.message.contains("B##"))
    }

    @Test
    func message_invalidNote() {
        let error = ABCParseError.invalidNote("xyz")

        #expect(error.message.contains("xyz"))
    }

    @Test
    func message_invalidPitch() {
        let error = ABCParseError.invalidPitch("^^^C")

        #expect(error.message.contains("^^^C"))
    }

    @Test
    func message_invalidRefNumber() {
        let error = ABCParseError.invalidRefNumber("0")

        #expect(error.message.contains("0"))
    }

    @Test
    func message_invalidRest() {
        let error = ABCParseError.invalidRest("y")

        #expect(error.message.contains("y"))
    }

    @Test
    func message_invalidSymbols() {
        let error = ABCParseError.invalidSymbols("@@@")

        #expect(error.message.contains("@@@"))
    }

    @Test
    func message_invalidTempo() {
        let error = ABCParseError.invalidTempo("bogus")

        #expect(error.message.contains("bogus"))
    }

    @Test
    func message_invalidTimeSignature() {
        let error = ABCParseError.invalidTimeSignature("4/3")

        #expect(error.message.contains("4/3"))
    }

    @Test
    func message_invalidTuplet() {
        let error = ABCParseError.invalidTuplet("(10")

        #expect(error.message.contains("(10"))
    }

    @Test
    func message_invalidUnitNoteLength() {
        let error = ABCParseError.invalidUnitNoteLength("1/3")

        #expect(error.message.contains("1/3"))
    }

    @Test
    func message_invalidVersion() {
        let error = ABCParseError.invalidVersion("abc")

        #expect(error.message.contains("abc"))
    }

    @Test
    func message_invalidVoice() {
        let error = ABCParseError.invalidVoice("")

        #expect(error.message.contains("voice"))
    }

    @Test
    func message_misplacedField() {
        let error = ABCParseError.misplacedField(.area("test"))

        #expect(error.message.contains("Misplaced"))
    }

    @Test
    func message_missingFileID() {
        let error = ABCParseError.missingFileID

        #expect(error.message.contains("Missing"))
    }

    @Test
    func message_unsupportedVersion() {
        let version = ABCVersion(major: 3, minor: 0)
        let error = ABCParseError.unsupportedVersion(version)

        #expect(error.message.contains("3.0"))
    }
}
