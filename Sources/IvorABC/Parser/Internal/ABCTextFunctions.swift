// © 2025–2026 John Gary Pusey (see LICENSE.md)

// MARK: Internal Functions

internal func escape(_ input: String) -> String {
    guard input.contains(where: { !$0.isABCVisible || $0 == "\\" || $0 == "%" || $0 == "&" })
    else { return input }

    var result = ""

    result.reserveCapacity(input.count)

    for ch in input {
        switch ch {
        case "\\":
            result += "\\\\"

        case "%":
            result += "\\%"

        case "&":
            result += "\\&"

        default:
            if ch.isABCVisible {
                result.append(ch)
            } else {
                result += _unicodeEscape(ch)
            }
        }
    }

    return result
}

internal func unescape(_ input: String) -> String {
    guard input.contains("\\") || input.contains("&")
    else { return input }

    let chars = Array(input)

    var result: [Character] = []

    result.reserveCapacity(chars.count)

    var index = 0

    while index < chars.count {
        switch chars[index] {
        case "&":
            index = _decodeHTMLEntity(chars,
                                      at: index,
                                      into: &result)

        case "\\":
            index = _decodeBackslashEscape(chars,
                                           at: index,
                                           into: &result)

        default:
            result.append(chars[index])

            index += 1
        }
    }

    return String(result)
}

// MARK: Private Functions

private func _decodeBackslashEscape(_ chars: [Character],
                                    at index: Int,
                                    into result: inout [Character]) -> Int {
    let n = chars.count

    guard index + 1 < n
    else {
        result.append("\\")

        return index + 1
    }

    let next = chars[index + 1]

    // \uXXXX — Unicode codepoint (4 hex digits; takes priority over breve modifier \uc)
    if next == "u", index + 6 <= n {
        let hex = String(chars[(index + 2)..<(index + 6)])

        if hex.allSatisfy(\.isHexDigit),
           let codepoint = UInt32(hex, radix: 16),
           let scalar = Unicode.Scalar(codepoint) {
            result.append(Character(scalar))

            return index + 6
        }
    }

    // Two-character TeX-style escape: \Xc
    if index + 2 < n {
        let key = String([next, chars[index + 2]])

        if let ch = _texEscapeMap[key] {
            result.append(ch)

            return index + 3
        }
    }

    // One-character escape: \X
    if let ch = _texSingleMap[String(next)] {
        result.append(ch)

        return index + 2
    }

    // Unrecognized — preserve the backslash and move past it only
    result.append("\\")

    return index + 1
}

private func _decodeHTMLEntity(_ chars: [Character],
                               at index: Int,
                               into result: inout [Character]) -> Int {
    let n = chars.count

    // Scan for closing ';' within a reasonable window
    var index2 = index + 1

    while index2 < n, chars[index2] != ";",
          index2 - index <= 20 {
        index2 += 1
    }

    guard index2 < n, chars[index2] == ";",
          index2 > index + 1
    else {
        result.append("&")

        return index + 1
    }

    let body = String(chars[(index + 1)..<index2])

    // Numeric entity: &#ddd; or &#xhhhh;
    if body.hasPrefix("#") {
        let value = body.dropFirst()

        if value.hasPrefix("x") || value.hasPrefix("X") {
            let hex = String(value.dropFirst())

            if !hex.isEmpty,
               hex.allSatisfy(\.isHexDigit),
               let cp = UInt32(hex, radix: 16),
               let scalar = Unicode.Scalar(cp) {
                result.append(Character(scalar))

                return index2 + 1
            }
        } else if !value.isEmpty,
                  value.allSatisfy(\.isNumber),
                  let cp = UInt32(value),
                  let scalar = Unicode.Scalar(cp) {
            result.append(Character(scalar))

            return index2 + 1
        }
    }

    // Named entity
    if let ch = _htmlEntityMap[body] {
        result.append(ch)

        return index2 + 1
    }

    // Unrecognized — preserve '&'
    result.append("&")

    return index + 1
}

private func _unicodeEscape(_ ch: Character) -> String {
    guard let scalar = ch.unicodeScalars.first
    else { return "" }

    let hex = String(scalar.value,
                     radix: 16)

    return "\\u" + String(repeating: "0",
                          count: max(0, 4 - hex.count)) + hex
}

// MARK: Private Data

// Two-character TeX-style backslash escapes: \Xc where X is the modifier and c is the base character.
// Derived from the ABC 2.1 standard appendix and the abcjs reference implementation.
// Note: \u followed by exactly 4 hex digits is handled separately as a Unicode codepoint;
// \uc (and similar) falls through to this map (breve/caron modifier + base character).
private let _texEscapeMap: [String: Character] = ["`a": "à",  // Grave accent
                                                  "`A": "À",
                                                  "`e": "è",
                                                  "`E": "È",
                                                  "`i": "ì",
                                                  "`I": "Ì",
                                                  "`o": "ò",
                                                  "`O": "Ò",
                                                  "`u": "ù",
                                                  "`U": "Ù",
                                                  "'C": "Ć",  // Acute accent
                                                  "'I": "Í",
                                                  "'O": "Ó",
                                                  "'U": "Ú",
                                                  "'Y": "Ý",
                                                  "'a": "á",
                                                  "'A": "Á",
                                                  "'c": "ć",
                                                  "'e": "é",
                                                  "'E": "É",
                                                  "'i": "í",
                                                  "'o": "ó",
                                                  "'u": "ú",
                                                  "'y": "ý",
                                                  "^A": "Â",  // Circumflex
                                                  "^C": "Ĉ",
                                                  "^E": "Ê",
                                                  "^I": "Î",
                                                  "^O": "Ô",
                                                  "^U": "Û",
                                                  "^Y": "Ŷ",
                                                  "^a": "â",
                                                  "^c": "ĉ",
                                                  "^e": "ê",
                                                  "^i": "î",
                                                  "^o": "ô",
                                                  "^u": "û",
                                                  "^y": "ŷ",
                                                  "~A": "Ã",  // Tilde
                                                  "~I": "Ĩ",
                                                  "~N": "Ñ",
                                                  "~O": "Õ",
                                                  "~U": "Ũ",
                                                  "~a": "ã",
                                                  "~i": "ĩ",
                                                  "~n": "ñ",
                                                  "~o": "õ",
                                                  "~u": "ũ",
                                                  "\"A": "Ä", // Umlaut / diaeresis
                                                  "\"E": "Ë",
                                                  "\"I": "Ï",
                                                  "\"O": "Ö",
                                                  "\"U": "Ü",
                                                  "\"Y": "Ÿ",
                                                  "\"a": "ä",
                                                  "\"e": "ë",
                                                  "\"i": "ï",
                                                  "\"o": "ö",
                                                  "\"u": "ü",
                                                  "\"y": "ÿ",
                                                  "AA": "Å",  // Ring above
                                                  "oA": "Å",
                                                  "oU": "Ů",
                                                  "aa": "å",
                                                  "oa": "å",
                                                  "ou": "ů",
                                                  "=A": "Ā",  // Macron
                                                  "=E": "Ē",
                                                  "=I": "Ī",
                                                  "=O": "Ō",
                                                  "=U": "Ū",
                                                  "=a": "ā",
                                                  "=e": "ē",
                                                  "=i": "ī",
                                                  "=o": "ō",
                                                  "=s": "š",
                                                  "=u": "ū",
                                                  "uA": "Ă",  // Breve / caron (modifier 'u')
                                                  "uC": "Č",
                                                  "uE": "Ĕ",
                                                  "uI": "Ĭ",
                                                  "uO": "Ŏ",
                                                  "uU": "Ŭ",
                                                  "ua": "ă",
                                                  "uc": "č",
                                                  "ue": "ĕ",
                                                  "ui": "ĭ",
                                                  "uo": "ŏ",
                                                  "uu": "ŭ",
                                                  ";A": "Ą",  // Ogonek
                                                  ";E": "Ę",
                                                  ";I": "Į",
                                                  ";U": "Ų",
                                                  ";a": "ą",
                                                  ";e": "ę",
                                                  ";i": "į",
                                                  ";u": "ų",
                                                  ".C": "Ċ",  // Dot above
                                                  ".E": "Ė",
                                                  ".I": "İ",
                                                  ".c": "ċ",
                                                  ".e": "ė",
                                                  "cC": "Ç",  // Cedilla
                                                  "cc": "ç",
                                                  "/O": "Ø",  // Stroke
                                                  "/o": "ø",
                                                  "HO": "Ő",  // Double acute (Hungarian umlaut)
                                                  "HU": "Ű",
                                                  "Ho": "ő",
                                                  "Hu": "ű",
                                                  "vS": "Š",  // Caron
                                                  "vZ": "Ž",
                                                  "vs": "š",
                                                  "vz": "ž",
                                                  "DH": "Ð",  // Eth
                                                  "dh": "ð",
                                                  "AE": "Æ",  // Ligatures and digraphs
                                                  "OE": "Œ",
                                                  "ae": "æ",
                                                  "oe": "œ",
                                                  "ss": "ß"]

// Single-character backslash escapes: \X
private let _texSingleMap: [String: Character] = ["%": "%",
                                                  "&": "&",
                                                  "\\": "\\",
                                                  "#": "♯",
                                                  "=": "♮",
                                                  "b": "♭"]

// HTML/SGML named entity map
private let _htmlEntityMap: [String: Character] = ["amp": "&",     // XML predefined
                                                   "apos": "'",
                                                   "gt": ">",
                                                   "lt": "<",
                                                   "quot": "\"",
                                                   "AElig": "Æ",   // Latin-1 supplement (U+00A0–U+00FF)
                                                   "Aacute": "Á",
                                                   "Acirc": "Â",
                                                   "Agrave": "À",
                                                   "Aring": "Å",
                                                   "Atilde": "Ã",
                                                   "Auml": "Ä",
                                                   "Ccedil": "Ç",
                                                   "ETH": "Ð",
                                                   "Eacute": "É",
                                                   "Ecirc": "Ê",
                                                   "Egrave": "È",
                                                   "Euml": "Ë",
                                                   "Iacute": "Í",
                                                   "Icirc": "Î",
                                                   "Igrave": "Ì",
                                                   "Iuml": "Ï",
                                                   "Ntilde": "Ñ",
                                                   "Oacute": "Ó",
                                                   "Ocirc": "Ô",
                                                   "Ograve": "Ò",
                                                   "Oslash": "Ø",
                                                   "Otilde": "Õ",
                                                   "Ouml": "Ö",
                                                   "THORN": "Þ",
                                                   "Uacute": "Ú",
                                                   "Ucirc": "Û",
                                                   "Ugrave": "Ù",
                                                   "Uuml": "Ü",
                                                   "Yacute": "Ý",
                                                   "aacute": "á",
                                                   "acirc": "â",
                                                   "acute": "\u{00B4}",
                                                   "aelig": "æ",
                                                   "agrave": "à",
                                                   "aring": "å",
                                                   "atilde": "ã",
                                                   "auml": "ä",
                                                   "brvbar": "\u{00A6}",
                                                   "ccedil": "ç",
                                                   "cedil": "\u{00B8}",
                                                   "cent": "\u{00A2}",
                                                   "copy": "\u{00A9}",
                                                   "curren": "\u{00A4}",
                                                   "deg": "\u{00B0}",
                                                   "divide": "\u{00F7}",
                                                   "eacute": "é",
                                                   "ecirc": "ê",
                                                   "egrave": "è",
                                                   "eth": "ð",
                                                   "euml": "ë",
                                                   "frac12": "\u{00BD}",
                                                   "frac14": "\u{00BC}",
                                                   "frac34": "\u{00BE}",
                                                   "iacute": "í",
                                                   "icirc": "î",
                                                   "iexcl": "\u{00A1}",
                                                   "igrave": "ì",
                                                   "iquest": "\u{00BF}",
                                                   "iuml": "ï",
                                                   "laquo": "\u{00AB}",
                                                   "macr": "\u{00AF}",
                                                   "micro": "\u{00B5}",
                                                   "middot": "\u{00B7}",
                                                   "nbsp": "\u{00A0}",
                                                   "not": "\u{00AC}",
                                                   "ntilde": "ñ",
                                                   "oacute": "ó",
                                                   "ocirc": "ô",
                                                   "ograve": "ò",
                                                   "ordf": "\u{00AA}",
                                                   "ordm": "\u{00BA}",
                                                   "oslash": "ø",
                                                   "otilde": "õ",
                                                   "ouml": "ö",
                                                   "para": "\u{00B6}",
                                                   "plusmn": "\u{00B1}",
                                                   "pound": "\u{00A3}",
                                                   "raquo": "\u{00BB}",
                                                   "reg": "\u{00AE}",
                                                   "sect": "\u{00A7}",
                                                   "shy": "\u{00AD}",
                                                   "sup1": "\u{00B9}",
                                                   "sup2": "\u{00B2}",
                                                   "sup3": "\u{00B3}",
                                                   "szlig": "ß",
                                                   "thorn": "þ",
                                                   "times": "\u{00D7}",
                                                   "uacute": "ú",
                                                   "ucirc": "û",
                                                   "ugrave": "ù",
                                                   "uml": "\u{00A8}",
                                                   "uuml": "ü",
                                                   "yacute": "ý",
                                                   "yen": "\u{00A5}",
                                                   "yuml": "ÿ",
                                                   "OElig": "Œ",   // Latin Extended-B / special (HTML 4 extras commonly used in music text)
                                                   "Scaron": "Š",
                                                   "Yuml": "Ÿ",
                                                   "oelig": "œ",
                                                   "scaron": "š"]
