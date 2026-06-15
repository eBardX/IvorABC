// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCTextFunctionsTests {
}

// MARK: - escape

extension ABCTextFunctionsTests {
    @Test
    func encodeTextEscapes_ampersand() {
        #expect(escape("gin & tonic") == "gin \\& tonic")
        #expect(escape("a&b") == "a\\&b")
        #expect(escape("&") == "\\&")
    }

    @Test
    func encodeTextEscapes_backslash() {
        #expect(escape("foo\\bar") == "foo\\\\bar")
        #expect(escape("\\") == "\\\\")
        #expect(escape("a\\b\\c") == "a\\\\b\\\\c")
    }

    @Test
    func encodeTextEscapes_mixed() {
        #expect(escape("100% & \\cost") == "100\\% \\& \\\\cost")
    }

    @Test
    func encodeTextEscapes_noSpecialChars_returnsInput() {
        #expect(escape("Cafe au lait") == "Cafe au lait")
        #expect(escape("").isEmpty)
    }

    @Test
    func encodeTextEscapes_percent() {
        #expect(escape("100%") == "100\\%")
        #expect(escape("%") == "\\%")
    }

    @Test
    func encodeTextEscapes_invisibleChars() {
        #expect(escape("\t") == "\\u0009")
        #expect(escape("\n") == "\\u000a")
        #expect(escape("\r") == "\\u000d")
        #expect(escape("\u{00a0}") == "\\u00a0")
        #expect(escape("\u{034f}") == "\\u034f")
        #expect(escape("\u{200b}") == "\\u200b")
        #expect(escape("\u{200c}") == "\\u200c")
        #expect(escape("\u{200d}") == "\\u200d")
        #expect(escape("\u{feff}") == "\\ufeff")
        #expect(escape("foo\tbar") == "foo\\u0009bar")
    }

    @Test
    func encodeTextEscapes_roundTrip_withUnescape() {
        let originals = ["hello",
                         "foo\\bar",
                         "gin & tonic",
                         "100%",
                         "a\\b%c&d",
                         "\\&%",
                         "\t",
                         "\n",
                         "foo\tbar",
                         "line1\nline2",
                         "\u{00a0}",
                         "\u{034f}"]

        for original in originals {
            #expect(unescape(escape(original)) == original,
                    "round-trip failed for \(original.debugDescription)")
        }
    }
}

// MARK: - unescape

extension ABCTextFunctionsTests {
    @Test
    func decodeTextEscapes_html_decimal() {
        #expect(unescape("&#228;") == "ä")
        #expect(unescape("&#233;") == "é")
    }

    @Test
    func decodeTextEscapes_html_hex_lowercase() {
        #expect(unescape("&#x00e4;") == "ä")
    }

    @Test
    func decodeTextEscapes_html_hex_uppercase_prefix() {
        #expect(unescape("&#X00E4;") == "ä")
    }

    @Test
    func decodeTextEscapes_html_named_lowercase() {
        #expect(unescape("&auml;") == "ä")
        #expect(unescape("&eacute;") == "é")
        #expect(unescape("&ntilde;") == "ñ")
    }

    @Test
    func decodeTextEscapes_html_named_uppercase() {
        #expect(unescape("&Auml;") == "Ä")
        #expect(unescape("&Eacute;") == "É")
    }

    @Test
    func decodeTextEscapes_html_named_xml_predefined() {
        #expect(unescape("&amp;") == "&")
        #expect(unescape("&lt;") == "<")
        #expect(unescape("&gt;") == ">")
        #expect(unescape("&quot;") == "\"")
        #expect(unescape("&apos;") == "'")
    }

    @Test
    func decodeTextEscapes_incompleteEntity_preserved() {
        #expect(unescape("&auml") == "&auml")
    }

    @Test
    func decodeTextEscapes_mixed_escapesInString() {
        #expect(unescape("Caf\\'e &amp; Cr\\`eme") == "Café & Crème")
    }

    @Test
    func decodeTextEscapes_noEscapes_returnsInput() {
        let plain = "Cafe au lait"
        #expect(unescape(plain) == plain)
    }

    @Test
    func decodeTextEscapes_tex_acute() {
        #expect(unescape("\\'e") == "é")
        #expect(unescape("\\'A") == "Á")
    }

    @Test
    func decodeTextEscapes_tex_cedilla() {
        #expect(unescape("\\cc") == "ç")
        #expect(unescape("\\cC") == "Ç")
    }

    @Test
    func decodeTextEscapes_tex_circumflex() {
        #expect(unescape("\\^o") == "ô")
        #expect(unescape("\\^U") == "Û")
    }

    @Test
    func decodeTextEscapes_tex_grave() {
        #expect(unescape("\\`a") == "à")
        #expect(unescape("\\`E") == "È")
    }

    @Test
    func decodeTextEscapes_tex_ligature() {
        #expect(unescape("\\ae") == "æ")
        #expect(unescape("\\AE") == "Æ")
        #expect(unescape("\\oe") == "œ")
        #expect(unescape("\\ss") == "ß")
    }

    @Test
    func decodeTextEscapes_tex_single_flat() {
        #expect(unescape("\\b") == "♭")
    }

    @Test
    func decodeTextEscapes_tex_single_natural() {
        #expect(unescape("\\=") == "♮")
    }

    @Test
    func decodeTextEscapes_tex_single_ampersand() {
        #expect(unescape("\\&") == "&")
        #expect(unescape("gin \\& tonic") == "gin & tonic")
    }

    @Test
    func decodeTextEscapes_tex_single_backslash() {
        #expect(unescape("\\\\") == "\\")
        #expect(unescape("foo\\\\bar") == "foo\\bar")
        #expect(unescape("a\\\\b\\\\c") == "a\\b\\c")
    }

    @Test
    func decodeTextEscapes_tex_single_percent() {
        #expect(unescape("\\%") == "%")
    }

    @Test
    func decodeTextEscapes_tex_single_sharp() {
        #expect(unescape("\\#") == "♯")
    }

    @Test
    func decodeTextEscapes_tex_stroke() {
        #expect(unescape("\\/o") == "ø")
        #expect(unescape("\\/O") == "Ø")
    }

    @Test
    func decodeTextEscapes_tex_tilde() {
        #expect(unescape("\\~n") == "ñ")
        #expect(unescape("\\~N") == "Ñ")
    }

    @Test
    func decodeTextEscapes_tex_umlaut() {
        #expect(unescape("\\\"a") == "ä")
        #expect(unescape("\\\"U") == "Ü")
    }

    @Test
    func decodeTextEscapes_unicode_basic_ascii() {
        #expect(unescape("\\u0041") == "A")
    }

    @Test
    func decodeTextEscapes_unicode_breve_fallthrough() {
        // \ua (not 4 hex digits) falls through to breve map: ă
        #expect(unescape("\\ua") == "ă")
    }

    @Test
    func decodeTextEscapes_unicode_lowercase() {
        #expect(unescape("\\u00e4") == "ä")
    }

    @Test
    func decodeTextEscapes_unicode_uppercase() {
        #expect(unescape("\\u00E4") == "ä")
    }

    @Test
    func decodeTextEscapes_unrecognizedBackslash_preserved() {
        #expect(unescape("\\q") == "\\q")
    }

    @Test
    func decodeTextEscapes_unrecognizedEntity_preserved() {
        #expect(unescape("&xyzzy;") == "&xyzzy;")
    }

    @Test
    func parseField_stringField_decodesEscapes() throws {
        try expectFieldIsHistory(parseField("H:Caf\\'e"), "Café")
        try expectFieldIsComposer(parseField("C:J\\\"urgen M\\\"uller"), "Jürgen Müller")
        try expectFieldIsTitle(parseField("T:&Eacute;tude"), "Étude")
        try expectFieldIsHistory(parseField("H:\\u00e9"), "é")
        try expectFieldIsNotes(parseField("N:&#228;"), "ä")
        try expectFieldIsComposer(parseField("C:foo\\\\bar"), "foo\\bar")
        try expectFieldIsSource(parseField("S:gin \\& tonic"), "gin & tonic")
    }
}
