// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCFormatterErrorTests {
}

// MARK: -

extension ABCFormatterErrorTests {
    @Test
    func category_isIvorABC() {
        let error = ABCFormatter.Error.missingKeySignature

        #expect(error.category?.description == "IvorABC")
    }

    @Test
    func equality() {
        let a = ABCFormatter.Error.missingKeySignature
        let b = ABCFormatter.Error.missingKeySignature

        #expect(a == b)
    }

    @Test
    func message_emptyChord() {
        #expect(ABCFormatter.Error.emptyChord.message.contains("Chord"))
    }

    @Test
    func message_emptyGraceNotes() {
        #expect(ABCFormatter.Error.emptyGraceNotes.message.contains("Grace"))
    }

    @Test
    func message_emptyVariantEnding() {
        #expect(ABCFormatter.Error.emptyVariantEnding.message.contains("Variant"))
    }

    @Test
    func message_emptyVoiceID() {
        #expect(ABCFormatter.Error.emptyVoiceID.message.contains("Voice"))
    }

    @Test
    func message_invalidBarRepeat() {
        let error = ABCFormatter.Error.invalidBarRepeat("||:")

        #expect(error.message.contains("||:"))
    }

    @Test
    func message_invalidBrokenRhythm() {
        let error = ABCFormatter.Error.invalidBrokenRhythm(">>>")

        #expect(error.message.contains(">>>"))
    }

    @Test
    func message_invalidMultiMeasureRestCount() {
        #expect(ABCFormatter.Error.invalidMultiMeasureRestCount.message.contains("zero"))
    }

    @Test
    func message_invalidSlur() {
        let error = ABCFormatter.Error.invalidSlur("bad")

        #expect(error.message.contains("bad"))
    }

    @Test
    func message_invalidStringArgument() {
        let error = ABCFormatter.Error.invalidTextValue("invalid characters")

        #expect(error.message.contains("invalid characters"))
    }

    @Test
    func message_invalidTimeSignature() throws {
        let ts = try ABCTimeSignature.standard(#require(ABCTimeSignature.StandardMeter(numerator: 3, denominator: 4)))
        let error = ABCFormatter.Error.invalidTimeSignature(ts)

        #expect(error.message.contains("structurally invalid"))
    }

    @Test
    func message_invalidTupletNoteCount() {
        #expect(ABCFormatter.Error.invalidTupletNoteCount.message.contains("zero"))
    }

    @Test
    func message_invalidUnitNoteLength() {
        let dur = ABCDuration(1, 3)
        let error = ABCFormatter.Error.invalidUnitNoteLength(dur)

        #expect(error.message.contains("1/3"))
    }

    @Test
    func message_misplacedFileHeaderField() {
        let error = ABCFormatter.Error.misplacedFileHeaderField(.area("test"))

        #expect(error.message.contains("file header"))
    }

    @Test
    func message_misplacedTuneField() {
        let error = ABCFormatter.Error.misplacedTuneField(.area("test"))

        #expect(error.message.contains("tune"))
    }

    @Test
    func message_missingKeySignature() {
        #expect(ABCFormatter.Error.missingKeySignature.message.contains("K:"))
    }

    @Test
    func message_missingReferenceNumber() {
        #expect(ABCFormatter.Error.missingReferenceNumber.message.contains("X:"))
    }

    @Test
    func message_stringConversionFailed() {
        #expect(ABCFormatter.Error.stringConversionFailed.message.contains("UTF-8"))
    }

    @Test
    func message_unsupportedVersion() {
        let error = ABCFormatter.Error.unsupportedVersion(ABCVersion(major: 1, minor: 6))

        #expect(error.message.contains("1.6"))
    }
}
