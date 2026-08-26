// © 2025–2026 John Gary Pusey (see LICENSE.md)

// MARK: Internal Functions

// Decodes a backslash escape sequence within an aligned lyrics line.
//
// The caller has already consumed the leading `\`. On return, `input` is
// advanced past all characters that were part of the escape sequence.
// Returns the decoded string to append to the current syllable.
internal func decodeBackslashInLyrics(_ input: inout Substring) -> String {
    guard let next = input.first
    else { return "" }

    // \uXXXX — Unicode codepoint (4 hex digits; takes priority over \uc breve)
    if next == "u" {
        let hexSlice = input.dropFirst().prefix(4)

        if hexSlice.count == 4 {
            let hex = String(hexSlice)

            if hex.allSatisfy(\.isHexDigit),
               let codepoint = UInt32(hex, radix: 16),
               let scalar = Unicode.Scalar(codepoint) {
                input = input.dropFirst(5)

                return String(Character(scalar))
            }
        }
    }

    // Two-character TeX-style escape: \Xc
    if let next2 = input.dropFirst().first {
        let key = String([next, next2])

        if let ch = texEscapeMap[key] {
            input = input.dropFirst(2)

            return String(ch)
        }
    }

    // One-character escape: \X
    input = input.dropFirst()

    if let ch = texSingleMap[String(next)] {
        return String(ch)
    }

    // Unrecognized — pass through the character after the backslash
    return String(next)
}

// Decodes an HTML entity within an aligned lyrics line.
//
// The caller has already consumed the leading `&`. On return, `input` is
// advanced past all characters that were part of the entity (including the
// closing `;`). Returns the decoded string, or `"&"` if the entity is
// unrecognized or malformed.
internal func decodeHTMLEntityInLyrics(_ input: inout Substring) -> String {
    var scan = input
    var count = 0

    while let ch = scan.first, ch != ";", count <= 20 {
        scan = scan.dropFirst()
        count += 1
    }

    let body = String(input.prefix(count))

    guard scan.first == ";", !body.isEmpty
    else { return "&" }

    // Numeric entity: &#ddd; or &#xhhhh;
    if body.hasPrefix("#") {
        let value = body.dropFirst()

        if value.hasPrefix("x") || value.hasPrefix("X") {
            let hex = String(value.dropFirst())

            if !hex.isEmpty,
               hex.allSatisfy(\.isHexDigit),
               let cp = UInt32(hex, radix: 16),
               let scalar = Unicode.Scalar(cp) {
                input = scan.dropFirst()

                return String(Character(scalar))
            }
        } else if !value.isEmpty,
                  value.allSatisfy(\.isNumber),
                  let cp = UInt32(value),
                  let scalar = Unicode.Scalar(cp) {
            input = scan.dropFirst()

            return String(Character(scalar))
        }
    }

    // Named entity
    if let ch = htmlEntityMap[body] {
        input = scan.dropFirst()

        return String(ch)
    }

    return "&"
}

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

// Encodes annotation display text for output inside an ABC `"..."` annotation.
//
// Like `escape(_:)` but only escapes characters that are unsafe within a
// double-quoted annotation. `%` is left as-is since it has no special
// meaning inside quotes, but `&` must still be escaped because `unescape`
// processes HTML entities on re-parse.
// Specifically:
// - `\` → `\\`
// - `"` → `\u0022` (`\"` is already the TeX umlaut modifier prefix)
// - `&` → `\&`
// - Non-ABC-visible characters → `\uXXXX`
internal func escapeAnnotationText(_ input: String) -> String {
    guard input.contains(where: { !$0.isABCVisible || $0 == "\\" || $0 == "\"" || $0 == "&" })
    else { return input }

    var result = ""

    result.reserveCapacity(input.count)

    for ch in input {
        switch ch {
        case "\\":
            result += "\\\\"

        case "\"":
            result += "\\u0022"

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

// Encodes syllable display text for output in an ABC `w:` field.
//
// Characters that are structural in ABC lyrics source are escaped so the
// result is safe to emit verbatim. Specifically:
// - space → `~`
// - `-` → `\-`
// - `~` → `\~`
// - `_`, `*`, `|` → `\_`, `\*`, `\|`
// - `\` → `\\`
// - `%` → `\%`
// - `&` → `\&`
// - Non-ABC-visible characters → `\uXXXX`
internal func escapeLyricsSyllable(_ input: String) -> String {
    guard !input.isEmpty
    else { return input }

    var result = ""

    for ch in input {
        switch ch {
        case " ":
            result += "~"

        case "-":
            result += "\\-"

        case "~":
            result += "\\~"

        case "_":
            result += "\\_"

        case "*":
            result += "\\*"

        case "|":
            result += "\\|"

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
    else { result.append("\\"); return index + 1 }

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

        if let ch = texEscapeMap[key] {
            result.append(ch)

            return index + 3
        }
    }

    // One-character escape: \X
    if let ch = texSingleMap[String(next)] {
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
    else { result.append("&"); return index + 1 }

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
    if let ch = htmlEntityMap[body] {
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
