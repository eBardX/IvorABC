// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Functions

internal func parseVoice(_ tidyInput: Substring) -> ABCVoice? {
    guard !tidyInput.isEmpty
    else { return nil }

    let idResult = tidyInput.splitBeforeFirst { $0.isABCWhitespace }

    var properties: [String: String] = [:]
    var clefProperties: [ClefPropertyPair] = []
    var bareClefToken: Substring?

    if var rest = idResult.tail {
        while !rest.isEmpty {
            rest = trimPrefix(rest)

            guard !rest.isEmpty
            else { break }

            let peek = rest.splitBeforeFirst { $0.isABCWhitespace }

            if isBareClefNameToken(peek.head) {
                bareClefToken = peek.head
                rest = trimPrefix(peek.tail ?? "")
                continue
            }

            guard let propResult = _parseVoiceProperty(rest)
            else { return nil }

            if clefPropertyKeys.contains(propResult.key.lowercased()) {
                clefProperties.append((propResult.key, propResult.value))
            } else {
                properties[propResult.key] = propResult.value
            }

            rest = propResult.rest
        }
    }

    let clef: ABCClef?

    if clefProperties.isEmpty,
       bareClefToken == nil {
        clef = nil
    } else {
        guard let c = parseClef(bareClefToken: bareClefToken,
                                propertyTokens: clefProperties.map { Substring("\($0.key)=\($0.value)") })
        else { return nil }

        clef = c
    }

    guard let id = ABCVoice.ID(stringValue: String(idResult.head))
    else { return nil }

    return ABCVoice(id: id,
                    clef: clef,
                    properties: properties)
}

// MARK: Private Type Aliases

private typealias ClefPropertyPair = (key: String, value: String)
private typealias ParseVoicePropertyResult = (key: String, value: String, rest: Substring)

// MARK: Private Constants

// Property keys that belong to the clef specifier rather than voice metadata.
private let clefPropertyKeys: Set<String> = ["clef", "middle", "m", "transpose", "t", "octave", "stafflines"]

// MARK: Private Functions

private func _parseVoiceProperty(_ tidyInput: Substring) -> ParseVoicePropertyResult? {
    let result = tidyInput.splitBeforeFirst("=")
    let key = trim(result.head)

    guard !key.isEmpty,
          var vtext = result.tail
    else { return nil }

    vtext = trimPrefix(vtext.dropFirst())

    guard !vtext.isEmpty
    else { return nil }

    let value: Substring
    let rest: Substring

    if vtext.first == "\"" {
        let result2 = vtext.dropFirst().splitBeforeFirst("\"")

        value = result2.head
        rest = result2.tail?.dropFirst() ?? ""
    } else {
        let result2 = vtext.splitBeforeFirst { $0.isABCWhitespace }

        value = result2.head
        rest = result2.tail ?? ""
    }

    return (String(key), String(value), trimPrefix(rest))
}
