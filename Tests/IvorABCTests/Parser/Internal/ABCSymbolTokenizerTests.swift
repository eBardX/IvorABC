// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTokens
import XestiTools

struct ABCSymbolTokenizerTests {
}

// MARK: -

extension ABCSymbolTokenizerTests {
    @Test
    func init_tracingIsPreserved() {
        let tokenizer = ABCSymbolTokenizer(tracing: .verbose)

        #expect(tokenizer.tracing == .verbose)
    }

    @Test
    func tokenize_barRepeat_doubleBar() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("||")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .barRepeat)
    }

    @Test
    func tokenize_barRepeat_singleBar() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("|")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .barRepeat)
    }

    @Test
    func tokenize_brokenRhythm_left() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("<")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .brokenRhythm)
    }

    @Test
    func tokenize_brokenRhythm_right() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize(">")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .brokenRhythm)
    }

    @Test
    func tokenize_chordBeginEnd() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("[CE]")

        #expect(tokens.count == 4)
        #expect(tokens[0].kind == .chordBegin)
        #expect(tokens[1].kind == .note)
        #expect(tokens[2].kind == .note)
        #expect(tokens[3].kind == .chordEnd)
    }

    @Test
    func tokenize_chordBeginEnd_withSuffix() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("[CE]2")

        #expect(tokens.count == 5)
        #expect(tokens[0].kind == .chordBegin)
        #expect(tokens[1].kind == .note)
        #expect(tokens[2].kind == .note)
        #expect(tokens[3].kind == .chordEnd)
        #expect(tokens[4].kind == .chordSuffix)
        #expect(tokens[4].value == "2")
    }

    @Test
    func tokenize_chordSuffix_fractionDuration() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("[CE]/2")

        #expect(tokens.count == 5)
        #expect(tokens[4].kind == .chordSuffix)
        #expect(tokens[4].value == "/2")
    }

    @Test
    func tokenize_chordSuffix_tie() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("[CE]-")

        #expect(tokens.count == 5)
        #expect(tokens[4].kind == .chordSuffix)
        #expect(tokens[4].value == "-")
    }

    @Test
    func tokenize_chordSymbol() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("\"Am\"")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .chordSymbol)
    }

    @Test
    func tokenize_commentSkipped() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("C % comment")

        #expect(tokens.count == 2)
        #expect(tokens[0].kind == .note)
        #expect(tokens[1].kind == .whitespace)
    }

    @Test
    func tokenize_decoration_legacyPlusSyntax() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("+trill+")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .decoration)
        #expect(tokens[0].value == "+trill+")
    }

    @Test
    func tokenize_decoration_longform() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("!p!")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .decoration)
    }

    @Test
    func tokenize_shorthand() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("~")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .shorthand)
    }

    @Test
    func tokenize_shorthand_fullRedefinableRange() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)
        let letters = "HIJKLMNOPQRSTUVWhijklmnopqrstuvw"

        for letter in letters {
            let tokens = try tokenizer.tokenize(String(letter))

            #expect(tokens.count == 1, "Expected 1 token for '\(letter)'")
            #expect(tokens[0].kind == .shorthand, "Expected .shorthand for '\(letter)'")
        }
    }

    @Test
    func tokenize_empty() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("")

        #expect(tokens.isEmpty)
    }

    @Test
    func tokenize_graceNotesBeginEnd() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("{C}")

        #expect(tokens.count == 3)
        #expect(tokens[0].kind == .graceNotesBegin)
        #expect(tokens[1].kind == .note)
        #expect(tokens[2].kind == .graceNotesEnd)
    }

    @Test
    func tokenize_graceNotesBegin_slash() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("{/C}")

        #expect(tokens.count == 3)
        #expect(tokens[0].kind == .graceNotesBegin)
        #expect(tokens[0].value.hasSuffix("/"))
    }

    @Test
    func tokenize_inlineField() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("[K:G]")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .inlineField)
    }

    @Test
    func tokenize_multipleNotes() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("CDEF")

        #expect(tokens.count == 4)
        #expect(tokens.allSatisfy { $0.kind == .note })
    }

    @Test
    func tokenize_note_lowercase() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("c")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .note)
    }

    @Test
    func tokenize_note_uppercase() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("C")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .note)
    }

    @Test
    func tokenize_note_withAccidentalAndOctave() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("^c'")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .note)
        #expect(tokens[0].value == "^c'")
    }

    @Test
    func tokenize_overlay() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("&")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .overlay)
    }

    @Test
    func tokenize_rest_multiMeasure() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("Z")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .rest)
    }

    @Test
    func tokenize_rest_regular() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("z")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .rest)
    }

    @Test
    func tokenize_slurBeginEnd() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("(C)")

        #expect(tokens.count == 3)
        #expect(tokens[0].kind == .slurBegin)
        #expect(tokens[1].kind == .note)
        #expect(tokens[2].kind == .slurEnd)
    }

    @Test
    func tokenize_spacer() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("y")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .spacer)
    }

    @Test
    func tokenize_spacer_withDuration() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("y2")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .spacer)
        #expect(tokens[0].value == "y2")
    }

    @Test
    func tokenize_tuplet() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("(3")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .tuplet)
    }

    @Test
    func tokenize_variantEnding() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("[1")

        #expect(tokens.count == 1)
        #expect(tokens[0].kind == .variantEnding)
    }

    @Test
    func tokenize_whitespaceEmitted() throws {
        let tokenizer = ABCSymbolTokenizer(tracing: .silent)

        let tokens = try tokenizer.tokenize("C D E")

        #expect(tokens.count == 5)
        #expect(tokens[0].kind == .note)
        #expect(tokens[1].kind == .whitespace)
        #expect(tokens[2].kind == .note)
        #expect(tokens[3].kind == .whitespace)
        #expect(tokens[4].kind == .note)
    }
}
