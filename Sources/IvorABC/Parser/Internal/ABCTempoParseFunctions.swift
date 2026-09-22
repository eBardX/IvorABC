// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Functions

// Parses an explicit fraction (e.g. `1/8`) as used by `L:` (unit note length)
// and `Q:` (tempo beat lengths). Unlike ``parseLength(_:)``, this does not
// accept the note/rest/chord shorthand forms (`/`, `//`, …).
internal func parseExplicitLength(_ tidyInput: Substring) -> ABCLength? {
    let result = tidyInput.splitBeforeFirst("/")

    guard let numerator = UInt(result.head)
    else { return nil }

    let denominator: UInt

    if let tail = result.tail {
        guard let denom = UInt(tail.dropFirst()),
              denom > 0
        else { return nil }

        denominator = denom
    } else {
        denominator = 1
    }

    return ABCLength(numerator: numerator,
                     denominator: denominator)
}

// Parses the deprecated `Q:C=rate` and `Q:Cn=rate` tempo forms (optionally
// surrounded by a quoted text label).
//
// The result is left *unresolved*: ``ABCTempo/lengths`` is empty and the
// multiplier `n` is recorded in ``ABCTempo/beatMultiplier``. ``ABCNormalizer``
// resolves the beat against the active unit note length (`L:`).
//
// Returns `nil` if the input does not match the C-form.
internal func parseLegacyBeatTempo(_ tidyInput: Substring) -> ABCTempo? {
    var input = tidyInput
    var text: String?

    // Leading optional "text"
    if let (t, rest) = _consumeTempoText(input) {
        text = t
        input = rest
    }

    // Must start with 'C'
    guard input.first == "C"
    else { return nil }

    input = input.dropFirst()

    // Optional integer multiplier (e.g. the 3 in Q:C3=40)
    guard let (multiplier, afterMultiplier) = _consumePositiveUInt(input, defaultValue: 1)
    else { return nil }

    input = afterMultiplier

    // Must have '=' followed by rate
    guard input.first == "="
    else { return nil }

    input = trimPrefix(input.dropFirst())

    // Rate integer
    guard let (rate, afterRate) = _consumePositiveUInt(input, defaultValue: nil)
    else { return nil }

    input = trimPrefix(afterRate)

    // Trailing optional "text"
    if let (t, rest) = _consumeTempoText(input) {
        text = t
        input = rest
    }

    guard input.isEmpty
    else { return nil }

    return ABCTempo(lengths: [],
                    rate: rate,
                    text: text,
                    beatMultiplier: multiplier)
}

internal func parseTempo(_ tidyInput: Substring) -> ABCTempo? {
    guard !tidyInput.isEmpty
    else { return nil }

    var lengths: [ABCLength] = []
    var text: String?
    var rate: UInt?

    var input = tidyInput

    if input.first == "\"" {
        guard let idx = input.dropFirst().firstIndex(of: "\""),
              let tmpText = _parseTempoText(input[...idx])
        else { return nil }

        text = tmpText

        input = trimPrefix(input[input.index(after: idx)...])
    }

    if !input.isEmpty {
        let idx = input.dropFirst().firstIndex(of: "\"") ?? input.endIndex

        guard let result = _parseTempoLengthsRate(trimSuffix(input[..<idx]))
        else { return nil }

        lengths = result.lengths
        rate = result.rate

        input = input[idx...]
    }

    if input.first == "\"" {
        guard let idx = input.dropFirst().firstIndex(of: "\""),
              let tmpText = _parseTempoText(input[...idx])
        else { return nil }

        text = tmpText

        input = trimPrefix(input[input.index(after: idx)...])
    }

    if !input.isEmpty {
        return nil
    }

    return ABCTempo(lengths: lengths,
                    rate: rate,
                    text: text)
}

internal func parseTimeSignature(_ tidyInput: Substring) -> ABCTimeSignature? {
    switch tidyInput {
    case "C":
        return .common

    case "C|":
        return .cut

    case "none":
        return .empty

    default:
        break
    }

    if tidyInput.contains("+") {
        return _parseComplexTimeSignature(tidyInput)
    }

    guard let meter = _parseStandardMeter(tidyInput),
          [1, 2, 4, 8, 16, 32, 64].contains(meter.denominator)
    else { return nil }

    return .standard(meter)
}

// MARK: Private Type Aliases

private typealias ParseTempoLengthsRateResult = (lengths: [ABCLength], rate: UInt)

// MARK: Private Functions

// Consumes a run of decimal digits and returns `(value, remainingInput)`.
//
// - If the input starts with no digits, returns `(defaultValue, input)` when
//   `defaultValue` is non-nil, otherwise returns `nil`.
// - Returns `nil` when the parsed integer is zero.
private func _consumePositiveUInt(_ input: Substring,
                                  defaultValue: UInt?) -> (UInt, Substring)? {
    var digits = ""
    var rest = input

    while let ch = rest.first, ch.isNumber {
        digits.append(ch)
        rest = rest.dropFirst()
    }

    if digits.isEmpty {
        guard let d = defaultValue
        else { return nil }

        return (d, input)
    }

    guard let value = UInt(digits),
          value > 0
    else { return nil }

    return (value, rest)
}

private func _consumeTempoText(_ input: Substring) -> (String, Substring)? {
    // Consumes a leading `"text"` token and returns `(text, remainingInput)`, or
    // `nil` if the input does not start with a closing-quotable segment.
    guard input.first == "\""
    else { return nil }

    guard let closeIdx = input.dropFirst().firstIndex(of: "\""),
          let t = _parseTempoText(input[...closeIdx])
    else { return nil }

    let rest = trimPrefix(input[input.index(after: closeIdx)...])

    return (t, rest)
}

private func _parseComplexTimeSignature(_ tidyInput: Substring) -> ABCTimeSignature? {
    let numeratorText: Substring
    let denominatorText: Substring

    if tidyInput.first == "(" {
        guard let closeIdx = tidyInput.firstIndex(of: ")")
        else { return nil }

        numeratorText = tidyInput[tidyInput.index(after: tidyInput.startIndex)..<closeIdx]

        let afterClose = tidyInput[tidyInput.index(after: closeIdx)...]

        guard afterClose.first == "/"
        else { return nil }

        denominatorText = afterClose.dropFirst()
    } else {
        let parts = tidyInput.splitBeforeFirst("/")

        guard let dtail = parts.tail
        else { return nil }

        numeratorText = parts.head
        denominatorText = dtail.dropFirst()
    }

    guard let denominator = UInt(denominatorText),
          [1, 2, 4, 8, 16, 32, 64].contains(denominator)
    else { return nil }

    let numParts = numeratorText.split(separator: "+",
                                       omittingEmptySubsequences: false)

    guard numParts.count >= 2
    else { return nil }

    var numerators: [UInt] = []

    for part in numParts {
        guard let num = UInt(part), num > 0
        else { return nil }

        numerators.append(num)
    }

    return ABCTimeSignature.AdditiveMeter(numerators: numerators, denominator: denominator)
                           .map { .complex($0) }
}

private func _parseStandardMeter(_ tidyInput: Substring) -> ABCTimeSignature.StandardMeter? {
    let result = tidyInput.splitBeforeFirst("/")

    guard let numerator = UInt(result.head),
          let dtext = result.tail?.dropFirst(),
          let denominator = UInt(dtext),
          numerator > 0,
          denominator > 0
    else { return nil }

    return ABCTimeSignature.StandardMeter(numerator: numerator, denominator: denominator)
}

private func _parseTempoLengthsRate(_ tidyInput: Substring) -> ParseTempoLengthsRateResult? {
    let result = tidyInput.splitBeforeFirst("=")
    let dtext = trimSuffix(result.head)
    let pieces = dtext.split { $0.isABCWhitespace }

    guard !pieces.isEmpty
    else { return nil }

    var lengths: [ABCLength] = []

    for piece in pieces {
        guard let len = parseExplicitLength(piece)
        else { return nil }

        lengths.append(len)
    }

    guard let rtext = result.tail?.dropFirst(),
          let rate = UInt(trimPrefix(rtext)),
          rate > 0
    else { return nil }

    return (lengths, rate)
}

private func _parseTempoText(_ tidyInput: Substring) -> String? {
    guard tidyInput.first == "\"",
          tidyInput.last == "\""
    else { return nil }

    return normalize(tidyInput.dropFirst().dropLast())
}
