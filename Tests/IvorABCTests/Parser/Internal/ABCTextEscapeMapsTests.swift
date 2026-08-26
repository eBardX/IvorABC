// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCTextEscapeMapsTests {
}

// MARK: -

extension ABCTextEscapeMapsTests {
    @Test
    func htmlEntityMap_containsLatin1Supplement() {
        #expect(htmlEntityMap["Aacute"] == "Á")
        #expect(htmlEntityMap["ouml"] == "ö")
        #expect(htmlEntityMap["szlig"] == "ß")
    }

    @Test
    func htmlEntityMap_containsXMLPredefinedEntities() {
        #expect(htmlEntityMap["amp"] == "&")
        #expect(htmlEntityMap["apos"] == "'")
        #expect(htmlEntityMap["gt"] == ">")
        #expect(htmlEntityMap["lt"] == "<")
        #expect(htmlEntityMap["quot"] == "\"")
    }

    @Test
    func htmlEntityMap_isCaseSensitive() {
        #expect(htmlEntityMap["AElig"] == "Æ")
        #expect(htmlEntityMap["aelig"] == "æ")
        #expect(htmlEntityMap["AElig"] != htmlEntityMap["aelig"])
    }

    @Test
    func texEscapeMap_containsAccentedLetters() {
        #expect(texEscapeMap["'e"] == "é")
        #expect(texEscapeMap["`a"] == "à")
        #expect(texEscapeMap["^o"] == "ô")
        #expect(texEscapeMap["~n"] == "ñ")
        #expect(texEscapeMap["\"u"] == "ü")
    }

    @Test
    func texEscapeMap_containsLigaturesAndSpecialForms() {
        #expect(texEscapeMap["ss"] == "ß")
        #expect(texEscapeMap["ae"] == "æ")
        #expect(texEscapeMap["oe"] == "œ")
        #expect(texEscapeMap["/o"] == "ø")
    }

    @Test
    func texSingleMap_containsLiteralEscapes() {
        #expect(texSingleMap["%"] == "%")
        #expect(texSingleMap["&"] == "&")
        #expect(texSingleMap["\\"] == "\\")
    }

    @Test
    func texSingleMap_containsMusicSymbols() {
        #expect(texSingleMap["#"] == "♯")
        #expect(texSingleMap["="] == "♮")
        #expect(texSingleMap["b"] == "♭")
    }
}
