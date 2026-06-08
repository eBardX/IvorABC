// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// swiftlint:disable file_length

// MARK: Internal Types

internal typealias ParseNoteResult = (pitch: ParsePitchResult, duration: ABCDuration?, isTied: Bool)
internal typealias ParsePitchResult = (letter: ABCPitch.Letter, accidental: ABCPitch.Accidental?, octave: ABCPitch.Octave)
internal typealias ParseRestResult = (kind: String, duration: ABCDuration?)
internal typealias ParseTupletResult = (pcount: UInt, qcount: UInt?, rcount: UInt?)

// MARK: Internal Functions

internal func normalize(_ input: Substring) -> String {
    unescape(String(input).normalizedABCWhitespace())
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
                       denominator: denominator,
                       reduce: true)
}

internal func parseAlignedLyrics(_ tidyInput: Substring) -> ABCAlignedLyrics {
    var segments: [ABCAlignedLyrics.Segment] = []
    var input = tidyInput
    var currentText = ""
    var hasText = false
    var precedingHyphen = false

    func flush() {
        guard hasText
        else { return }

        segments.append(precedingHyphen
                        ? .continuation(currentText)
                        : .syllable(currentText))

        currentText = ""
        hasText = false
        precedingHyphen = false
    }

    while let ch = input.first {
        input = input.dropFirst()

        switch ch {
        case "\\":
            if let next = input.first {
                currentText.append(next)

                input = input.dropFirst()
                hasText = true
            }

        case " ",
             "\t":
            flush()

            precedingHyphen = false

        case "-":
            flush()

            precedingHyphen = true

        case "_":
            flush()

            segments.append(.hold)

            precedingHyphen = false

        case "*":
            flush()

            segments.append(.skip)

            precedingHyphen = false

        case "|":
            flush()

            segments.append(.barAlign)

            precedingHyphen = false

        case "~":
            currentText.append(" ")

            hasText = true

        default:
            currentText.append(ch)

            hasText = true
        }
    }

    flush()

    return ABCAlignedLyrics(segments: segments)
}

internal func parseDirectiveName(_ tidyInput: Substring) -> String? {
    guard let head = tidyInput.first,
          head.isABCDirectiveNameHead,
          tidyInput.dropFirst().allSatisfy({ $0.isABCDirectiveNameTail })
    else { return nil }

    return String(tidyInput)
}

// swiftlint:disable:next cyclomatic_complexity
internal func parseField(_ tidyInput: Substring) throws -> ABCField {
    let (ntext, vtext, isInline) = try _splitField(tidyInput)

    switch ntext {
    case "A" where !isInline:
        return .area(normalize(vtext))

    case "B" where !isInline:
        return .book(normalize(vtext))

    case "C" where !isInline:
        return .composer(normalize(vtext))

    case "D" where !isInline:
        return .discography(normalize(vtext))

    case "F" where !isInline:
        return .fileURL(normalize(vtext))

    case "G" where !isInline:
        return .group(normalize(vtext))

    case "H" where !isInline:
        return .history(normalize(vtext))

    case "I":
        guard let dir = _parseInstruction(vtext)
        else { throw ABCParseError.invalidField(isInline, tidyInput) }

        return .instruction(dir)

    case "K":
        guard let ks = parseKeySignature(vtext)
        else { throw ABCParseError.invalidKeySignature(vtext) }

        return .key(ks)

    case "L":
        guard let unl = parseUnitNoteLength(vtext)
        else { throw ABCParseError.invalidUnitNoteLength(vtext) }

        return .unitNoteLength(unl)

    case "M":
        guard let ts = parseTimeSignature(vtext)
        else { throw ABCParseError.invalidTimeSignature(vtext) }

        return .meter(ts)

    case "m":
        guard let macro = parseMacro(vtext)
        else { throw ABCParseError.invalidMacro(vtext) }

        return .macro(macro)

    case "N":
        return .notes(normalize(vtext))

    case "O" where !isInline:
        return .origin(normalize(vtext))

    case "P":
        guard let ps = parsePartSequence(vtext)
        else { throw ABCParseError.invalidPartSequence(vtext) }

        return .parts(ps)

    case "Q":
        guard let tempo = parseTempo(vtext)
        else { throw ABCParseError.invalidTempo(vtext) }

        return .tempo(tempo)

    case "R":
        return .rhythm(normalize(vtext))

    case "r":
        return .remark(normalize(vtext))

    case "S" where !isInline:
        return .source(normalize(vtext))

    case "s" where !isInline:
        guard let sl = parseSymbolLine(vtext)
        else { throw ABCParseError.invalidSymbolLine(vtext) }

        return .symbolLine(sl)

    case "T" where !isInline:
        return .title(normalize(vtext))

    case "U":
        guard let uds = parseUserSymbol(vtext)
        else { throw ABCParseError.invalidUserSymbol(vtext) }

        return .userSymbol(uds)

    case "V":
        guard let voice = parseVoice(vtext)
        else { throw ABCParseError.invalidVoice(vtext) }

        return .voice(voice)

    case "W" where !isInline:
        return .lyrics(normalize(vtext))

    case "w" where !isInline:
        return .alignedLyrics(parseAlignedLyrics(Substring(unescape(String(vtext)))))

    case "X" where !isInline:
        guard let rn = parseRefNumber(vtext)
        else { throw ABCParseError.invalidRefNumber(vtext) }

        return .refNumber(rn)

    case "Z" where !isInline:
        return .transcription(normalize(vtext))

    default:
        break
    }

    throw ABCParseError.invalidField(isInline, tidyInput)
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

    let clef: ABCClef?

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

    let accidentals: [ABCKeySignature.Accidental]

    if let tail = result.tail {
        guard let acc = _parseKeySignatureAccidentals(trimPrefix(tail))
        else { return nil }

        accidentals = acc
    } else {
        accidentals = []
    }

    return .standard(tonic, mode, accidentals, clef)
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
    let isTied = tidyInput.hasSuffix("-")
    let input = isTied ? tidyInput.dropLast() : tidyInput

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

    return (pitch, duration, isTied)
}

internal func parsePartSequence(_ tidyInput: Substring) -> ABCPartSequence? {
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

    let accidental: ABCPitch.Accidental?

    if !result2.head.isEmpty {
        guard let acc = pitchAccidentals[result2.head]
        else { return nil }

        accidental = acc
    } else {
        accidental = nil
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

internal func parseRefNumber(_ tidyInput: Substring) -> ABCRefNumber? {
    guard let uintValue = UInt(tidyInput),
          uintValue > 0
    else { return nil }

    return ABCRefNumber(uintValue: uintValue)
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
                                   denominator: 1,
                                   reduce: false)
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

internal func parseSymbolLine(_ tidyInput: Substring) -> ABCSymbolLine? {
    var tokens: [ABCSymbolLine.Token] = []
    var input = tidyInput

    while !input.isEmpty {
        input = trimPrefix(input)

        guard !input.isEmpty
        else { break }

        switch input.first {
        case "*":
            tokens.append(.skip)

            input = input.dropFirst()

        case "!":
            let rest = input.dropFirst()

            guard let closeIdx = rest.firstIndex(of: "!"),
                  !rest[..<closeIdx].isEmpty,
                  rest[..<closeIdx].allSatisfy({ $0.isABCAlphanumeric || ".()+<>".contains($0) })
            else { return nil }

            tokens.append(.decoration(ABCDecoration(name: String(rest[..<closeIdx]))))

            input = rest[rest.index(after: closeIdx)...]

        case "\"":
            let rest = input.dropFirst()

            guard let closeIdx = rest.firstIndex(of: "\"")
            else { return nil }

            let content = String(rest[..<closeIdx])

            if let first = content.first, "_@^<>".contains(first) {
                tokens.append(.annotation(content))
            } else {
                tokens.append(.chordSymbol(content))
            }

            input = rest[rest.index(after: closeIdx)...]

        default:
            return nil
        }
    }

    return ABCSymbolLine(tokens: tokens)
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

    guard let fraction = _parseFraction(tidyInput),
          [1, 2, 4, 8, 16, 32, 64].contains(fraction.denominator)
    else { return nil }

    return .explicit(fraction)
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
    guard let symbol = tidyInput.first
    else { return nil }

    let rest = trimPrefix(tidyInput.dropFirst())

    guard rest.hasPrefix("=")
    else { return nil }

    let decoration = String(trim(rest.dropFirst()))

    guard !decoration.isEmpty
    else { return nil }

    return ABCUserSymbol(symbol: symbol,
                         decoration: decoration)
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

private let modes: [String: ABCKeySignature.Mode] = ["": .major,
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

private let tonics: [Substring: ABCKeySignature.Tonic] = ["A": .a,
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

// MARK: Private Functions

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

    return .complex(numerators, denominator)
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

    return ABCFraction(numerator: numerator,
                       denominator: denominator,
                       reduce: true)
}

private func _parseFraction(_ tidyInput: Substring) -> ABCFraction? {
    let result = tidyInput.splitBeforeFirst("/")

    guard let numerator = UInt(result.head),
          let dtext = result.tail?.dropFirst(),
          let denominator = UInt(dtext),
          numerator > 0,
          denominator > 0
    else { return nil }

    return ABCFraction(numerator: numerator,
                       denominator: denominator,
                       reduce: false)
}

private func _parseInstruction(_ tidyInput: Substring) -> ABCDirective? {
    let result = tidyInput.splitBeforeFirst { $0.isABCWhitespace }

    guard let name = parseDirectiveName(result.head)
    else { return nil }

    let value = String(trimPrefix(result.tail ?? ""))

    return ABCDirective(name: name,
                        value: value)
}

private func _parseKeySignatureAccidentals(_ tidyInput: Substring) -> [ABCKeySignature.Accidental]? {
    var accidentals: [ABCKeySignature.Accidental] = []

    var chunker = tidyInput.split { $0.isABCWhitespace }.makeIterator()

    while let chunk = chunker.next() {
        guard let result = parsePitch(chunk)
        else { return nil }

        let accidental = ABCPitch(letter: result.letter,
                                  accidental: result.accidental ?? .natural,
                                  octave: result.octave)

        accidentals.append(accidental)
    }

    return accidentals
}

private func _parseKeySignatureClef(_ propertyTokens: [Substring]) -> ABCClef? {
    var clef = ABCClef()

    for token in propertyTokens {
        guard let eqIdx = token.firstIndex(of: "=")
        else { return nil }

        let key = String(token[token.startIndex..<eqIdx]).lowercased()
        let value = String(token[token.index(after: eqIdx)...])

        switch key {
        case "clef":
            clef.name = value

        case "middle":
            clef.middle = value

        case "octave":
            guard let n = Int(value)
            else { return nil }

            clef.octave = n

        case "stafflines":
            guard let n = Int(value)
            else { return nil }

            clef.stafflines = n

        case "transpose":
            guard let n = Int(value)
            else { return nil }

            clef.transpose = n

        default:
            return nil
        }
    }

    return clef
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

    guard let tonic = tonics[tidyInput.prefix(tonicCount)]
    else { return nil }

    let rest = trimPrefix(tidyInput.dropFirst(tonicCount))
    let mode: ABCKeySignature.Mode

    if !rest.isEmpty {
        guard let tmpMode = modes[rest.prefix(3).lowercased()]
        else { return nil }

        mode = tmpMode
    } else {
        mode = .major
    }

    return (tonic, mode)
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

private func _splitField(_ tidyInput: Substring) throws -> (Substring, Substring, Bool) {
    var input = tidyInput

    let isInline: Bool

    if input.first == "[" {
        isInline = true

        guard input.last == "]"
        else { throw ABCParseError.invalidField(isInline, tidyInput) }

        input = input.dropFirst().dropLast()
    } else {
        isInline = false
    }

    precondition(input.dropFirst().first == ":")

    let result = input.splitBeforeFirst([":"])

    guard let tail = result.tail
    else { throw ABCParseError.invalidField(isInline, tidyInput) }

    let name = result.head
    let value = trim(tail.dropFirst())

    return (name, value, isInline)
}

// swiftlint:enable file_length
