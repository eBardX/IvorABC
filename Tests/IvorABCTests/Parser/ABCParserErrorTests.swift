// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCParserErrorTests {
}

// MARK: -

extension ABCParserErrorTests {
    @Test
    func category_isIvorABC() {
        let error = ABCParser.Error.dataConversionFailed

        #expect(error.category?.description == "IvorABC")
    }

    @Test
    func message_dataConversionFailed() {
        let error = ABCParser.Error.dataConversionFailed

        #expect(error.message == "Failed to convert UTF-8 data to string")
    }

    @Test
    func message_invalidDirective() {
        let error = ABCParser.Error.invalidDirective("%%bogus")

        #expect(error.message.contains("%%bogus"))
    }

    @Test
    func message_invalidFieldInline() {
        let error = ABCParser.Error.invalidField(true, "[Q:bogus]")

        #expect(error.message.contains("inline"))
    }

    @Test
    func message_invalidFieldNotInline() {
        let error = ABCParser.Error.invalidField(false, "Q:bogus")

        #expect(!error.message.contains("inline"))
        #expect(error.message.contains("Q:bogus"))
    }

    @Test
    func message_invalidFileID() {
        let error = ABCParser.Error.invalidFileID("%abc-3.0")

        #expect(error.message.contains("%abc-3.0"))
    }

    @Test
    func message_invalidKeySignature() {
        let error = ABCParser.Error.invalidKeySignature("B##")

        #expect(error.message.contains("B##"))
    }

    @Test
    func message_invalidMacro() {
        let error = ABCParser.Error.invalidMacro("~G3")

        #expect(error.message.contains("~G3"))
    }

    @Test
    func message_invalidNote() {
        let error = ABCParser.Error.invalidNote("xyz")

        #expect(error.message.contains("xyz"))
    }

    @Test
    func message_invalidPitch() {
        let error = ABCParser.Error.invalidPitch("^^^C")

        #expect(error.message.contains("^^^C"))
    }

    @Test
    func message_invalidRefNumber() {
        let error = ABCParser.Error.invalidRefNumber("0")

        #expect(error.message.contains("0"))
    }

    @Test
    func message_invalidRest() {
        let error = ABCParser.Error.invalidRest("y")

        #expect(error.message.contains("y"))
    }

    @Test
    func message_invalidSymbolLine() {
        let error = ABCParser.Error.invalidSymbolLine("bogus")

        #expect(error.message.contains("bogus"))
    }

    @Test
    func message_invalidSymbols() {
        let error = ABCParser.Error.invalidSymbols("@@@")

        #expect(error.message.contains("@@@"))
    }

    @Test
    func message_invalidTempo() {
        let error = ABCParser.Error.invalidTempo("bogus")

        #expect(error.message.contains("bogus"))
    }

    @Test
    func message_invalidTimeSignature() {
        let error = ABCParser.Error.invalidTimeSignature("4/3")

        #expect(error.message.contains("4/3"))
    }

    @Test
    func message_invalidTuplet() {
        let error = ABCParser.Error.invalidTuplet("(10")

        #expect(error.message.contains("(10"))
    }

    @Test
    func message_invalidUnitNoteLength() {
        let error = ABCParser.Error.invalidUnitNoteLength("1/3")

        #expect(error.message.contains("1/3"))
    }

    @Test
    func message_invalidUserSymbol() {
        let error = ABCParser.Error.invalidUserSymbol("~")

        #expect(error.message.contains("~"))
    }

    @Test
    func message_invalidVersion() {
        let error = ABCParser.Error.invalidVersion("abc")

        #expect(error.message.contains("abc"))
    }

    @Test
    func message_invalidVoice() {
        let error = ABCParser.Error.invalidVoice("")

        #expect(error.message.contains("voice"))
    }

    @Test
    func message_misplacedField() {
        let error = ABCParser.Error.misplacedField(.area("test"))

        #expect(error.message.contains("Misplaced"))
    }

    @Test
    func message_missingFileID() {
        let error = ABCParser.Error.missingFileID

        #expect(error.message.contains("Missing"))
    }

    @Test
    func message_missingKeyField() {
        let error = ABCParser.Error.missingKeyField

        #expect(error.message.contains("K:"))
    }

    @Test
    func message_missingReferenceNumber() {
        let error = ABCParser.Error.missingReferenceNumber

        #expect(error.message.contains("X:"))
    }

    @Test
    func message_missingTunes() {
        let error = ABCParser.Error.missingTunes

        #expect(error.message.contains("tunes"))
    }

    @Test
    func message_orphanedContinuation() {
        let error = ABCParser.Error.orphanedContinuation

        #expect(error.message.contains("+:"))
    }

    @Test
    func message_unmatchedBeginDirective() {
        let error = ABCParser.Error.unmatchedBeginDirective("text")

        #expect(error.message.contains("%%begintext"))
        #expect(error.message.contains("%%endtext"))
    }

    @Test
    func message_unsupportedVersion() {
        let version = makeVersion(3, 0)
        let error = ABCParser.Error.unsupportedVersion(version)

        #expect(error.message.contains("3.0"))
    }
}
