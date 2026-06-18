// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// swiftlint:disable file_length

// MARK: Internal Types

internal typealias ParseNoteResult = (pitch: ParsePitchResult, duration: ABCDuration?, tie: ABCTie?)
internal typealias ParsePitchResult = (letter: ABCPitch.Letter, accidental: ABCPitch.Accidental, octave: ABCPitch.Octave)
internal typealias ParseRestResult = (kind: String, duration: ABCDuration?)
internal typealias ParseTupletResult = (pcount: UInt, qcount: UInt?, rcount: UInt?)

// MARK: Internal Functions

internal func normalize(_ input: Substring) -> String {
    unescape(String(input).normalizedABCWhitespace())
}

internal func parseAlignedLyrics(_ tidyInput: Substring) -> ABCAlignedLyrics {
    var segments: [ABCAlignedLyrics.Segment] = []
    var input = tidyInput
    var currentText = ""

    func appendSegment(_ segment: ABCAlignedLyrics.Segment) {
        flushText()

        segments.append(segment)
    }

    func flushText() {
        guard !currentText.isEmpty
        else { return }

        segments.append(.syllable(ABCAlignedLyrics.Segment.Syllable(currentText)))

        currentText = ""
    }

    while let char = input.first {
        input = input.dropFirst()

        switch char {
        case "\\":
            if input.first == "-" {
                input = input.dropFirst()
                currentText.append("-")
            } else {
                currentText += decodeBackslashInLyrics(&input)
            }

        case "&":
            currentText += decodeHTMLEntityInLyrics(&input)

        case " ",
             "\t":
            flushText()

        case "-":
            appendSegment(.continuation)

        case "~":
            currentText.append(" ")

        case "_":
            appendSegment(.hold)

        case "*":
            appendSegment(.skip)

        case "|":
            appendSegment(.barAlign)

        default:
            currentText.append(char)
        }
    }

    flushText()

    return ABCAlignedLyrics(segments: segments)
}

internal func parseAnnotation(_ tidyInput: Substring) -> ABCAnnotation? {
    guard tidyInput.first == "\"",
          tidyInput.last == "\""
    else { return nil }

    let content = tidyInput.dropFirst().dropLast()

    guard !tidyInput.isEmpty,
          let placement = _parseAnnotationPlacement(content[...content.startIndex])
    else { return nil }

    return ABCAnnotation(placement: placement,
                         text: String(content.dropFirst()))
}

internal func parseBarRepeat(_ tidyInput: Substring) -> ABCBarRepeat? {
    var rest = tidyInput

    let isEditorial = rest.hasPrefix(".")

    if isEditorial {
        rest = rest.dropFirst()
    }

    let markStrings = [":||:", ":|:", "[|]", "::", ":|", "[|", "|:", "|]", "||", "|"]

    guard let markString = markStrings.first(where: { rest.hasPrefix($0) }),
          let mark = ABCBarRepeat.Mark(stringValue: String(markString))
    else { return nil }

    rest = rest.dropFirst(markString.count)

    var endings: [ClosedRange<UInt>] = []

    for part in rest.split(separator: ",") {
        if let dashIdx = part.firstIndex(of: "-") {
            guard let lo = UInt(part[..<dashIdx]),
                  let hi = UInt(part[part.index(after: dashIdx)...])
            else { return nil }

            endings.append(lo...hi)
        } else {
            guard let n = UInt(part)
            else { return nil }

            endings.append(n...n)
        }
    }

    return ABCBarRepeat(isEditorial: isEditorial, mark: mark, endings: endings)
}

internal func parseBrokenRhythm(_ tidyInput: Substring) -> ABCBrokenRhythm? {
    brokenRhythms[tidyInput]
}

internal func parseDirectiveName(_ tidyInput: Substring) -> String? {
    guard let head = tidyInput.first,
          head.isABCDirectiveNameHead,
          tidyInput.dropFirst().allSatisfy({ $0.isABCDirectiveNameTail })
    else { return nil }

    return String(tidyInput)
}

internal func parseDuration(_ tidyInput: Substring) -> ABCDuration? {
    guard !tidyInput.isEmpty
    else { return nil }

    //
    // <decUInteger>? "/" ( <decUInteger>? | "/"{2,6} )
    //
    let result = tidyInput.splitBeforeFirst("/")

    var denominator: UInt = 1
    var numerator: UInt = 1

    if !result.head.isEmpty {
        guard let numer = UInt(result.head)
        else { return nil }

        numerator = numer
    }

    if var tail = result.tail {
        while tail.hasPrefix("/") {
            denominator *= 2
            tail = tail.dropFirst()
        }

        if !tail.isEmpty {
            guard denominator == 2,         // i.e. only one "/" seen
                  let denom = UInt(tail)
            else { return nil }

            denominator = denom
        }
    }

    return ABCDuration(numerator: numerator,
                       denominator: denominator)
}

internal func parseElemskip(_ tidyInput: Substring) -> ABCElemskip? {
    let stringValue = normalize(tidyInput)

    // Try Int first — Double("3") also succeeds, which would misclassify
    // whole numbers as decimal.
    if let intValue = Int(stringValue) {
        return .integer(intValue)
    }

    if let doubleValue = Double(stringValue) {
        return .decimal(doubleValue)
    }

    return nil
}

// swiftlint:disable:next cyclomatic_complexity
internal func parseField(_ tidyInput: Substring) throws -> ABCField {
    let (ntext, vtext, isInline) = try _splitField(tidyInput)

    switch ntext {
    case "A" where !isInline:
        return try .area(parseText(vtext))

    case "B" where !isInline:
        return try .book(parseText(vtext))

    case "C" where !isInline:
        return try .composer(parseText(vtext))

    case "D" where !isInline:
        return try .discography(parseText(vtext))

    case "F" where !isInline:
        return try .fileURL(parseText(vtext))

    case "G" where !isInline:
        return try .group(parseText(vtext))

    case "H" where !isInline:
        return try .history(parseText(vtext))

    case "I":
        guard let dir = _parseInstruction(vtext)
        else { throw ABCParser.Error.invalidField(isInline, tidyInput) }

        return .instruction(dir)

    case "K":
        guard let ks = parseKeySignature(vtext)
        else { throw ABCParser.Error.invalidKeySignature(vtext) }

        return .key(ks)

    case "L":
        guard let unl = parseUnitNoteLength(vtext)
        else { throw ABCParser.Error.invalidUnitNoteLength(vtext) }

        return .unitNoteLength(unl)

    case "M":
        guard let ts = parseTimeSignature(vtext)
        else { throw ABCParser.Error.invalidTimeSignature(vtext) }

        return .meter(ts)

    case "m":
        guard let macro = parseMacro(vtext)
        else { throw ABCParser.Error.invalidMacro(vtext) }

        return .macro(macro)

    case "N":
        return try .notes(parseText(vtext))

    case "O" where !isInline:
        return try .origin(parseText(vtext))

    case "P":
        guard let ps = parsePartSequence(vtext)
        else { throw ABCParser.Error.invalidPartSequence(vtext) }

        return .parts(ps)

    case "Q":
        guard let tempo = parseTempo(vtext)
        else { throw ABCParser.Error.invalidTempo(vtext) }

        return .tempo(tempo)

    case "R":
        return try .rhythm(parseText(vtext))

    case "r":
        return try .remark(parseText(vtext))

    case "S" where !isInline:
        return try .source(parseText(vtext))

    case "s" where !isInline:
        guard let sl = parseSymbolLine(vtext)
        else { throw ABCParser.Error.invalidSymbolLine(vtext) }

        return .symbolLine(sl)

    case "T" where !isInline:
        return try .title(parseText(vtext))

    case "U":
        guard let uds = parseUserSymbol(vtext)
        else { throw ABCParser.Error.invalidUserSymbol(vtext) }

        return .userSymbol(uds)

    case "V":
        guard let voice = parseVoice(vtext)
        else { throw ABCParser.Error.invalidVoice(vtext) }

        return .voice(voice)

    case "W" where !isInline:
        return try .lyrics(parseText(vtext))

    case "w" where !isInline:
        return .alignedLyrics(parseAlignedLyrics(vtext))

    case "X" where !isInline:
        guard let rn = parseReferenceNumber(vtext)
        else { throw ABCParser.Error.invalidRefNumber(vtext) }

        return .referenceNumber(rn)

    case "Z" where !isInline:
        return try .transcription(parseText(vtext))

    default:
        break
    }

    throw ABCParser.Error.invalidField(isInline, tidyInput)
}

internal func parseKeySignature(_ tidyInput: Substring) -> ABCKeySignature? {
    // Partition whitespace-split tokens into key=value property tokens (clef,
    // transpose, etc.) and everything else (tonic, mode, accidentals).
    // A property token contains '=' at any position other than index 0;
    // '=' at index 0 is the natural-sign accidental prefix (e.g. "=F").
    var propertyTokens: [Substring] = []
    var otherTokens: [Substring] = []

    for token in tidyInput.split(whereSeparator: \.isABCWhitespace) {
        if let eqIdx = token.firstIndex(of: "="), eqIdx != token.startIndex {
            propertyTokens.append(token)
        } else {
            otherTokens.append(token)
        }
    }

    let clef: ABCKeySignature.Clef?

    if propertyTokens.isEmpty {
        clef = nil
    } else {
        guard let c = _parseKeySignatureClef(propertyTokens)
        else { return nil }

        clef = c
    }

    let keyInput = Substring(otherTokens.joined(separator: " "))

    if let special = _parseKeySignatureSpecial(keyInput) {
        if let clef, case .empty = special {
            return .clefOnly(clef)
        }

        return special
    }

    let result = keyInput.splitBeforeFirst(accidentalCS)

    guard let (tonic, mode) = _parseKeySignatureTonicMode(trimSuffix(result.head))
    else { return nil }

    let extraAccidentals: [ABCKeySignature.ExtraAccidental]

    if let tail = result.tail {
        guard let xacc = _parseKeySignatureExtraAccidentals(trimPrefix(tail))
        else { return nil }

        extraAccidentals = xacc
    } else {
        extraAccidentals = []
    }

    guard let standard = ABCKeySignature.Standard(tonic: tonic,
                                                  mode: mode,
                                                  extraAccidentals: extraAccidentals,
                                                  clef: clef)
    else { return nil }

    return .standard(standard)
}

/// Parses the ABC 1.6 `Q:C=rate` and `Q:Cn=rate` tempo forms (optionally
/// surrounded by a quoted text label), resolving `C` against `baseDuration`.
///
/// Returns `nil` if the input does not match the 1.6 C-form.
internal func parseLegacyBeatTempo(_ tidyInput: Substring,
                                   baseDuration: ABCDuration) -> ABCTempo? {
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

    guard input.isEmpty,
          // Resolve C×n against the active base duration
          let beat = ABCDuration(numerator: baseDuration.numerator * multiplier,
                                 denominator: baseDuration.denominator)
    else { return nil }

    return ABCTempo(durations: [beat],
                    rate: rate,
                    text: text,
                    legacyBeatMultiple: multiplier)
}

internal func parseMacro(_ tidyInput: Substring) -> ABCMacro? {
    guard let eqIdx = tidyInput.firstIndex(of: "=")
    else { return nil }

    let trigger = String(trim(tidyInput[..<eqIdx]))
    let replacement = String(trim(tidyInput[tidyInput.index(after: eqIdx)...]))

    guard !trigger.isEmpty,
          !replacement.isEmpty
    else { return nil }

    return ABCMacro(trigger: trigger,
                    replacement: replacement)
}

internal func parseNote(_ tidyInput: Substring) -> ParseNoteResult? {
    let isDottedTie = tidyInput.hasSuffix(".-")
    let isRegularTie = !isDottedTie && tidyInput.hasSuffix("-")
    let tie: ABCTie? = isDottedTie ? .dotted : (isRegularTie ? .regular : nil)
    let input = tidyInput.dropLast(isDottedTie ? 2 : (isRegularTie ? 1 : 0))

    let result = input.splitBeforeFirst(durationCS)

    guard let pitch = parsePitch(result.head)
    else { return nil }

    let duration: ABCDuration?

    if let tail = result.tail {
        guard let dur = parseDuration(tail)
        else { return nil }

        duration = dur
    } else {
        duration = nil
    }

    return (pitch, duration, tie)
}

internal func parsePartSequence(_ tidyInput: Substring) -> ABCPartSequence? {
    guard !tidyInput.isEmpty
    else { return nil }

    var input = tidyInput

    guard let items = _parsePartItems(&input,
                                      terminator: nil)
    else { return nil }

    return ABCPartSequence(items: items)
}

internal func parsePitch(_ tidyInput: Substring) -> ParsePitchResult? {
    guard !tidyInput.isEmpty
    else { return nil }

    let result1 = tidyInput.splitBeforeFirst(octaveCS)
    let result2 = result1.head.splitBeforeFirst(pitchLetterCS)

    guard let plLetter = result2.tail,
          let plResult = pitchLetters[plLetter]
    else { return nil }

    let accidental: ABCPitch.Accidental

    if !result2.head.isEmpty {
        guard let acc = pitchAccidentals[result2.head]
        else { return nil }

        accidental = acc
    } else {
        accidental = .omitted
    }

    var octave = plResult.octave

    for chr in result1.tail ?? "" {
        switch chr {
        case "'":
            octave += 1

        case ",":
            octave -= 1

        default:
            return nil
        }
    }

    return (plResult.letter, accidental, octave)
}

internal func parseReferenceNumber(_ tidyInput: Substring) -> ABCReferenceNumber? {
    guard let uintValue = UInt(tidyInput)
    else { return nil }

    return ABCReferenceNumber(uintValue: uintValue)
}

internal func parseRest(_ tidyInput: Substring) -> ParseRestResult? {
    let result = tidyInput.splitBeforeFirst(durationCS)

    guard result.head.count == 1,
          let restLetter = result.head.first,
          restLetterCS.contains(restLetter)
    else { return nil }

    let duration: ABCDuration?

    if let tail = result.tail {
        if restLetter.isUppercase {
            guard let cnt = UInt(tail)
            else { return nil }

            duration = ABCDuration(numerator: cnt,
                                   denominator: 1)
        } else {
            guard let dur = parseDuration(tail)
            else { return nil }

            duration = dur
        }
    } else {
        duration = nil
    }

    return (String(restLetter), duration)
}

internal func parseShorthand(_ tidyInput: Substring) -> ABCShorthand? {
    shorthands[tidyInput]
}

internal func parseSymbolLine(_ tidyInput: Substring) -> ABCSymbolLine? {
    var elements: [ABCSymbolLine.Element] = []
    var input = tidyInput

    while !input.isEmpty {
        input = trimPrefix(input)

        guard !input.isEmpty
        else { break }

        switch input.first {
        case "*":
            elements.append(.skip)

            input = input.dropFirst()

        case "!":
            let rest = input.dropFirst()

            guard let closeIdx = rest.firstIndex(of: "!"),
                  !rest[..<closeIdx].isEmpty,
                  rest[..<closeIdx].allSatisfy({ $0.isABCAlphanumeric || ".()+<>".contains($0) }),
                  let name = ABCDecoration.Name(stringValue: String(rest[..<closeIdx])),
                  let decoration = ABCDecoration(name: name, dialect: .bang)
            else { return nil }

            elements.append(.decoration(decoration))

            input = rest[rest.index(after: closeIdx)...]

        case "+":
            let rest = input.dropFirst()

            guard let closeIdx = rest.firstIndex(of: "+"),
                  !rest[..<closeIdx].isEmpty,
                  rest[..<closeIdx].allSatisfy({ $0.isABCAlphanumeric || ".()<>".contains($0) }),
                  let name = ABCDecoration.Name(stringValue: String(rest[..<closeIdx])),
                  let decoration = ABCDecoration(name: name, dialect: .plus)
            else { return nil }

            elements.append(.decoration(decoration))

            input = rest[rest.index(after: closeIdx)...]

        case "\"":
            let rest = input.dropFirst()

            guard let closeIdx = rest.firstIndex(of: "\"")
            else { return nil }

            if let annotation = parseAnnotation(input[...closeIdx]) {
                elements.append(.annotation(annotation))
            } else {
                let content = String(rest[..<closeIdx])

                elements.append(.chordSymbol(content))
            }

            input = rest[rest.index(after: closeIdx)...]

        default:        // what about decoration shorthands?
            return nil
        }
    }

    return ABCSymbolLine(elements: elements)
}

internal func parseTempo(_ tidyInput: Substring) -> ABCTempo? {
    guard !tidyInput.isEmpty
    else { return nil }

    var durations: [ABCDuration] = []
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

        guard let result = _parseTempoDurationsRate(trimSuffix(input[..<idx]))
        else { return nil }

        durations = result.durations
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

    return ABCTempo(durations: durations,
                    rate: rate,
                    text: text)
}

internal func parseText(_ tidyInput: Substring) throws -> ABCText {
    guard let text = ABCText(stringValue: normalize(tidyInput))
    else { throw ABCParser.Error.invalidText(tidyInput) }

    return text
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

internal func parseTuplet(_ tidyInput: Substring) -> ParseTupletResult? {
    guard tidyInput.hasPrefix("(")
    else { return nil }

    let presult = tidyInput.dropFirst().splitBeforeFirst(":")

    guard let pcount = UInt(presult.head),
          (2...9).contains(pcount)
    else { return nil }

    guard let ptail = presult.tail?.dropFirst()
    else { return (pcount, nil, nil) }

    let qresult = ptail.splitBeforeFirst(":")
    let qcount: UInt?

    if !qresult.head.isEmpty {
        guard let qcnt = UInt(qresult.head),
              (2...9).contains(qcnt)
        else { return nil }

        qcount = qcnt
    } else {
        qcount = nil
    }

    guard let qtail = qresult.tail?.dropFirst(),
          !qtail.isEmpty
    else { return (pcount, qcount, nil) }

    guard let rcount = UInt(qtail),
          (2...9).contains(rcount)
    else { return nil }

    return (pcount, qcount, rcount)
}

internal func parseUnitNoteLength(_ tidyInput: Substring) -> ABCDuration? {
    guard let duration = _parseDuration(tidyInput),
          duration.numerator > 0,
          [1, 2, 4, 8, 16, 32, 64, 128, 256, 512].contains(duration.denominator)
    else { return nil }

    return duration
}

internal func parseUserSymbol(_ tidyInput: Substring) -> ABCUserSymbol? {
    guard let first = tidyInput.first,
          let shorthand = parseShorthand(Substring(String(first)))
    else { return nil }

    let rest = trimPrefix(tidyInput.dropFirst())

    guard rest.hasPrefix("=")
    else { return nil }

    let raw = String(trim(rest.dropFirst()))

    guard !raw.isEmpty
    else { return nil }

    let definition: ABCUserSymbol.Definition? = if raw.first == "\"" {
        parseAnnotation(Substring(raw)).map { .annotation($0) }
    } else if raw.count >= 2, raw.first == "!", raw.last == "!" {
        ABCDecoration.Name(stringValue: String(raw.dropFirst().dropLast()))
            .flatMap { ABCDecoration(name: $0, dialect: .bang) }
            .map { .decoration($0) }
    } else if raw.count >= 2, raw.first == "+", raw.last == "+" {
        ABCDecoration.Name(stringValue: String(raw.dropFirst().dropLast()))
            .flatMap { ABCDecoration(name: $0, dialect: .plus) }
            .map { .decoration($0) }
    } else {
        ABCDecoration.Name(stringValue: raw)
            .flatMap { ABCDecoration(name: $0, dialect: .bang) }
            .map { .decoration($0) }
    }

    guard let definition
    else { return nil }

    return ABCUserSymbol(shorthand: shorthand,
                         definition: definition)
}

internal func parseVariantEnding(_ tidyInput: Substring) -> ABCVariantEnding? {
    // Parses a variant ending from the ABC token text (e.g. `[1` or
    // `[2,3` or `[1-3`).
    guard tidyInput.hasPrefix("[")
    else { return nil }

    var ranges: [ClosedRange<UInt>] = []

    for part in tidyInput.dropFirst().split(separator: ",") {
        if let dashIdx = part.firstIndex(of: "-") {
            guard let lo = UInt(part[..<dashIdx]),
                  let hi = UInt(part[part.index(after: dashIdx)...])
            else { return nil }

            ranges.append(lo...hi)
        } else {
            guard let n = UInt(part)
            else { return nil }

            ranges.append(n...n)
        }
    }

    return ABCVariantEnding(endings: ranges)
}

internal func parseVoice(_ tidyInput: Substring) -> ABCVoice? {
    guard !tidyInput.isEmpty
    else { return nil }

    let result = tidyInput.splitBeforeFirst { $0.isABCWhitespace }

    var properties: [String: String] = [:]

    if var rest = result.tail {
        while !rest.isEmpty {
            guard let result = _parseVoiceProperty(rest)
            else { return nil }

            properties[result.key] = result.value

            rest = result.rest
        }
    }

    return ABCVoice(id: String(result.head),
                    properties: properties)
}

internal func tidy(_ input: Substring) -> Substring {
    trim(uncomment(input))
}

internal func trim(_ input: Substring) -> Substring {
    trimPrefix(trimSuffix(input))
}

internal func trimPrefix(_ input: Substring) -> Substring {
    input.dropPrefix { $0.isABCWhitespace }
}

internal func trimSuffix(_ input: Substring) -> Substring {
    input.dropSuffix { $0.isABCWhitespace }
}

internal func uncomment(_ input: Substring) -> Substring {
    var idx = input.startIndex

loop:
    while idx < input.endIndex {
        switch input[idx] {
        case "\\":
            input.formIndex(after: &idx)

            guard idx < input.endIndex
            else { break loop }

        case "%":
            break loop

        default:
            break
        }

        input.formIndex(after: &idx)
    }

    guard idx < input.endIndex
    else { return input }

    return input[..<idx]
}

// MARK: Private Types

private typealias ParseTempoDurationsRateResult = (durations: [ABCDuration], rate: UInt)
private typealias ParseVoicePropertyResult      = (key: String, value: String, rest: Substring)
private typealias PitchLetterResult             = (letter: ABCPitch.Letter, octave: ABCPitch.Octave)

// MARK: Private Constants

private let accidentalCS: Set<Character>  = ["_", "^", "="]
private let durationCS: Set<Character>    = ["/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
private let octaveCS: Set<Character>      = [",", "'"]
private let pitchLetterCS: Set<Character> = ["A", "B", "C", "D", "E", "F", "G", "a", "b", "c", "d", "e", "f", "g"]
private let restLetterCS: Set<Character>  = ["X", "Z", "x", "z"]

private let annotationPlacements: [Substring: ABCAnnotation.Placement] = ["^": .above,
                                                                          "@": .auto,
                                                                          "_": .below,
                                                                          "<": .left,
                                                                          ">": .right]

private let brokenRhythms: [Substring: ABCBrokenRhythm] = ["<": .reverseDotted,
                                                           "<<": .reverseDoubleDotted,
                                                           "<<<": .reverseTripleDotted,
                                                           ">": .dotted,
                                                           ">>": .doubleDotted,
                                                           ">>>": .tripleDotted]

private let keySignatureModes: [Substring: ABCKeySignature.Mode] = ["": .major,
                                                                    "aeo": .aeolian,
                                                                    "dor": .dorian,
                                                                    "exp": .explicit,
                                                                    "ion": .ionian,
                                                                    "loc": .locrian,
                                                                    "lyd": .lydian,
                                                                    "m": .minor,
                                                                    "maj": .major,
                                                                    "min": .minor,
                                                                    "mix": .mixolydian,
                                                                    "phr": .phrygian]

private let pitchAccidentals: [Substring: ABCPitch.Accidental] = ["_": .flat,
                                                                  "__": .doubleFlat,
                                                                  "^": .sharp,
                                                                  "^^": .doubleSharp,
                                                                  "=": .natural]

private let pitchLetters: [Substring: PitchLetterResult] = ["A": (.a, 4),
                                                            "a": (.a, 5),
                                                            "B": (.b, 4),
                                                            "b": (.b, 5),
                                                            "C": (.c, 4),
                                                            "c": (.c, 5),
                                                            "D": (.d, 4),
                                                            "d": (.d, 5),
                                                            "E": (.e, 4),
                                                            "e": (.e, 5),
                                                            "F": (.f, 4),
                                                            "f": (.f, 5),
                                                            "G": (.g, 4),
                                                            "g": (.g, 5)]

private let keySignatureTonics: [Substring: ABCKeySignature.Tonic] = ["A": .a,
                                                                      "A#": .aSharp,
                                                                      "Ab": .aFlat,
                                                                      "B": .b,
                                                                      "B#": .bSharp,
                                                                      "Bb": .bFlat,
                                                                      "C": .c,
                                                                      "C#": .cSharp,
                                                                      "Cb": .cFlat,
                                                                      "D": .d,
                                                                      "D#": .dSharp,
                                                                      "Db": .dFlat,
                                                                      "E": .e,
                                                                      "E#": .eSharp,
                                                                      "Eb": .eFlat,
                                                                      "F": .f,
                                                                      "F#": .fSharp,
                                                                      "Fb": .fFlat,
                                                                      "G": .g,
                                                                      "G#": .gSharp,
                                                                      "Gb": .gFlat]

private let shorthands: [Substring: ABCShorthand] = [".": .dot,
                                                     "~": .tilde,
                                                     "h": .hLower,
                                                     "H": .hUpper,
                                                     "i": .iLower,
                                                     "I": .iUpper,
                                                     "j": .jLower,
                                                     "J": .jUpper,
                                                     "k": .kLower,
                                                     "K": .kUpper,
                                                     "l": .lLower,
                                                     "L": .lUpper,
                                                     "m": .mLower,
                                                     "M": .mUpper,
                                                     "n": .nLower,
                                                     "N": .nUpper,
                                                     "o": .oLower,
                                                     "O": .oUpper,
                                                     "p": .pLower,
                                                     "P": .pUpper,
                                                     "q": .qLower,
                                                     "Q": .qUpper,
                                                     "r": .rLower,
                                                     "R": .rUpper,
                                                     "s": .sLower,
                                                     "S": .sUpper,
                                                     "t": .tLower,
                                                     "T": .tUpper,
                                                     "u": .uLower,
                                                     "U": .uUpper,
                                                     "v": .vLower,
                                                     "V": .vUpper,
                                                     "w": .wLower,
                                                     "W": .wUpper]

// MARK: Private Functions

private func _parseAnnotationPlacement(_ tidyInput: Substring) -> ABCAnnotation.Placement? {
    annotationPlacements[tidyInput]
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

private func _parseDuration(_ tidyInput: Substring) -> ABCDuration? {
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

    return ABCDuration(numerator: numerator,
                       denominator: denominator)
}

private func _parseInstruction(_ tidyInput: Substring) -> ABCDirective? {
    let result = tidyInput.splitBeforeFirst { $0.isABCWhitespace }

    guard let name = parseDirectiveName(result.head)
    else { return nil }

    let value = String(trimPrefix(result.tail ?? ""))

    return ABCDirective(name: name,
                        value: value)!  // swiftlint:disable:this force_unwrapping
}

private func _parseKeySignatureClef(_ propertyTokens: [Substring]) -> ABCKeySignature.Clef? {
    var name: String?
    var middle: String?
    var octave: Int?
    var stafflines: Int?
    var transpose: Int?

    for token in propertyTokens {
        guard let eqIdx = token.firstIndex(of: "=")
        else { return nil }

        let key = String(token[token.startIndex..<eqIdx]).lowercased()
        let value = String(token[token.index(after: eqIdx)...])

        switch key {
        case "clef":
            name = value

        case "middle":
            middle = value

        case "octave":
            guard let n = Int(value)
            else { return nil }

            octave = n

        case "stafflines":
            guard let n = Int(value)
            else { return nil }

            stafflines = n

        case "transpose":
            guard let n = Int(value)
            else { return nil }

            transpose = n

        default:
            return nil
        }
    }

    return ABCKeySignature.Clef(name: name, middle: middle, octave: octave, stafflines: stafflines, transpose: transpose)
}

private func _parseKeySignatureExtraAccidentals(_ tidyInput: Substring) -> [ABCKeySignature.ExtraAccidental]? {
    var extraAccidentals: [ABCKeySignature.ExtraAccidental] = []

    var chunker = tidyInput.split { $0.isABCWhitespace }.makeIterator()

    while let chunk = chunker.next() {
        guard let result = parsePitch(chunk),
              result.accidental != .omitted
        else { return nil }

        let extraAccidental = ABCPitch(letter: result.letter,
                                       accidental: result.accidental,
                                       octave: result.octave)

        extraAccidentals.append(extraAccidental)
    }

    return extraAccidentals
}

private func _parseKeySignatureSpecial(_ tidyInput: Substring) -> ABCKeySignature? {
    switch tidyInput {
    case "HP":
        .highlandPipes

    case "Hp":
        .highlandPipesPreset

    default:
        switch tidyInput.lowercased() {
        case "",
             "none":
            .empty

        default:
            nil
        }
    }
}

private func _parseKeySignatureTonicMode(_ tidyInput: Substring) -> (ABCKeySignature.Tonic, ABCKeySignature.Mode)? {
    var tonicCount = 1

    if let second = tidyInput.dropFirst().first,
       ["#", "b"].contains(second) {
        tonicCount += 1
    }

    guard let tonic = keySignatureTonics[tidyInput.prefix(tonicCount)]
    else { return nil }

    let rest = trimPrefix(tidyInput.dropFirst(tonicCount))
    let mode: ABCKeySignature.Mode

    if !rest.isEmpty {
        guard let tmpMode = keySignatureModes[Substring(rest.prefix(3).lowercased())]
        else { return nil }

        mode = tmpMode
    } else {
        mode = .major
    }

    return (tonic, mode)
}

private func _parsePartCount(_ input: inout Substring) -> UInt {
    var digits = ""

    while let ch = input.first, ch.isABCDigit {
        digits.append(ch)
        input = input.dropFirst()
    }

    return UInt(digits) ?? 1
}

private func _parsePartItems(_ input: inout Substring,
                             terminator: Character?) -> [ABCPartSequence.Item]? {
    var items: [ABCPartSequence.Item] = []

    while true {
        while input.first?.isABCWhitespace == true {
            input = input.dropFirst()
        }

        if let term = terminator {
            guard let ch = input.first
            else { return nil }

     // unmatched "("

            if ch == term {
                input = input.dropFirst()

                return items
            }
        } else {
            if input.isEmpty {
                return items
            }
        }

        let ch = input[input.startIndex]

        input = input.dropFirst()

        switch ch {
        case "(":
            guard let groupItems = _parsePartItems(&input,
                                                   terminator: ")")
            else { return nil }

            let count = _parsePartCount(&input)

            items.append(.group(groupItems, count))

        case "A"..."Z":
            let count = _parsePartCount(&input)

            items.append(.part(ch, count))

        default:
            return nil
        }
    }
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

private func _parseTempoDurationsRate(_ tidyInput: Substring) -> ParseTempoDurationsRateResult? {
    let result = tidyInput.splitBeforeFirst("=")
    let dtext = trimSuffix(result.head)
    let pieces = dtext.split { $0.isABCWhitespace }

    guard !pieces.isEmpty
    else { return nil }

    var durations: [ABCDuration] = []

    for piece in pieces {
        guard let dur = _parseDuration(piece)
        else { return nil }

        durations.append(dur)
    }

    guard let rtext = result.tail?.dropFirst(),
          let rate = UInt(trimPrefix(rtext)),
          rate > 0
    else { return nil }

    return (durations, rate)
}

private func _parseTempoText(_ tidyInput: Substring) -> String? {
    guard tidyInput.first == "\"",
          tidyInput.last == "\""
    else { return nil }

    return normalize(tidyInput.dropFirst().dropLast())
}

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

private func _splitField(_ tidyInput: Substring) throws -> (Substring, Substring, Bool) {
    var input = tidyInput

    let isInline: Bool

    if input.first == "[" {
        isInline = true

        guard input.last == "]"
        else { throw ABCParser.Error.invalidField(isInline, tidyInput) }

        input = input.dropFirst().dropLast()
    } else {
        isInline = false
    }

    precondition(input.dropFirst().first == ":")

    let result = input.splitBeforeFirst([":"])

    guard let tail = result.tail
    else { throw ABCParser.Error.invalidField(isInline, tidyInput) }

    let name = result.head
    let value = trim(tail.dropFirst())

    return (name, value, isInline)
}

/// Consumes a leading `"text"` token and returns `(text, remainingInput)`, or
/// `nil` if the input does not start with a closing-quotable segment.
private func _consumeTempoText(_ input: Substring) -> (String, Substring)? {
    guard input.first == "\""
    else { return nil }

    guard let closeIdx = input.dropFirst().firstIndex(of: "\""),
          let t = _parseTempoText(input[...closeIdx])
    else { return nil }

    let rest = trimPrefix(input[input.index(after: closeIdx)...])

    return (t, rest)
}

/// Consumes a run of decimal digits and returns `(value, remainingInput)`.
///
/// - If the input starts with no digits, returns `(defaultValue, input)` when
///   `defaultValue` is non-nil, otherwise returns `nil`.
/// - Returns `nil` when the parsed integer is zero.
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

// swiftlint:enable file_length
