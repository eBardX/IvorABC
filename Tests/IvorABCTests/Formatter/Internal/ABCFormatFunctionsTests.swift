// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCFormatFunctionsTests {
}

// MARK: -

extension ABCFormatFunctionsTests {
    @Test
    func formatField_elemskip() {
        let (letter, value) = formatField(.elemskip(.integer(3)))

        #expect(letter == "E")
        #expect(value == "3")
    }

    @Test
    func formatField_key() {
        let (letter, value) = formatField(.key(makeKeySignature(.c, .major)))

        #expect(letter == "K")
        #expect(value == "C major")
    }

    @Test
    func formatField_part() {
        let (letter, value) = formatField(.part(.a))

        #expect(letter == "P")
        #expect(value == "A")
    }

    @Test
    func formatField_referenceNumber() {
        let (letter, value) = formatField(.referenceNumber(makeReferenceNumber(7)))

        #expect(letter == "X")
        #expect(value == "7")
    }

    @Test
    func formatField_tuneTitle() {
        let (letter, value) = formatField(.tuneTitle(ABCText(stringValue: "Test Tune").require()))

        #expect(letter == "T")
        #expect(value == "Test Tune")
    }

    @Test
    func formatField_unitNoteLength() {
        let (letter, value) = formatField(.unitNoteLength(makeLength(1, 8)))

        #expect(letter == "L")
        #expect(value == "1/8")
    }

    @Test
    func formatField_voice() {
        let (letter, value) = formatField(.voice(makeVoice("T1")))

        #expect(letter == "V")
        #expect(value == "T1")
    }

    @Test
    func formatPart_returnsLetterForEachPart() {
        #expect(formatPart(.a) == "A")
        #expect(formatPart(.m) == "M")
        #expect(formatPart(.z) == "Z")
    }

    @Test
    func formatSymbol_barLine() {
        #expect(formatSymbol(.barLine(makeBarLine(.double))) == "||")
    }

    @Test
    func formatSymbol_note() {
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1))

        #expect(formatSymbol(.note(note)) == "C")
    }

    @Test
    func formatSymbol_overlay() {
        #expect(formatSymbol(.overlay) == "&")
    }

    @Test
    func formatSymbol_spacer() {
        #expect(formatSymbol(.spacer(makeLength(1))) == "y")
    }
}
