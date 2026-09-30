// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Functions

// Determines whether `token` is a bare clef name (e.g. `treble`, `perc`, `bass-8`)
// rather than voice metadata. Shared by `K:` (key signature) and `V:` (voice) fields.
internal func isBareClefNameToken(_ token: Substring) -> Bool {
    var t = token

    if t.hasSuffix("+8") || t.hasSuffix("-8") {
        t = t.dropLast(2)
    }

    let lineCount = t.reversed().prefix { $0.isNumber }.count

    t = t.dropLast(lineCount)

    return clefNamePrefixes.contains(String(t))
}

// Parses a bare clef name/property specifier shared by `K:` (key signature) and
// `V:` (voice) fields.
internal func parseClef(bareClefToken: Substring?,
                        propertyTokens: [Substring]) -> ABCClef? {
    var name: ABCClef.Name?
    var line: Int?
    var middle: ABCClef.Middle?
    var octave: Int?
    var ottava: ABCClef.Ottava?
    var stafflines: Int?
    var transpose: Int?

    if let token = bareClefToken {
        (name, line, ottava) = _parseClefNameLineAndOttava(token)
    }

    for token in propertyTokens {
        guard let eqIdx = token.firstIndex(of: "=")
        else { return nil }

        let key = String(token[token.startIndex..<eqIdx]).lowercased()
        let value = Substring(token[token.index(after: eqIdx)...])

        switch key {
        case "clef":
            (name, line, ottava) = _parseClefNameLineAndOttava(value)

        case "m",
            "middle":
            guard let m = _parseClefMiddle(value)
            else { return nil }

            middle = m

        case "octave":
            guard let n = Int(value)
            else { return nil }

            octave = n

        case "stafflines":
            guard let n = Int(value)
            else { return nil }

            stafflines = n

        case "t",
            "transpose":
            guard let n = Int(value)
            else { return nil }

            transpose = n

        default:
            return nil
        }
    }

    return ABCClef(name: name,
                   line: line,
                   ottava: ottava,
                   middle: middle,
                   transpose: transpose ?? 0,
                   octave: octave ?? 0,
                   stafflines: stafflines ?? 5)
}

internal func parseKeySignature(_ tidyInput: Substring) -> ABCKeySignature? {
    let (propertyTokens, bareClefToken, otherTokens) = _partitionKeySignatureTokens(tidyInput)

    let clef: ABCClef?

    if propertyTokens.isEmpty, bareClefToken == nil {
        clef = nil
    } else {
        guard let c = parseClef(bareClefToken: bareClefToken,
                                propertyTokens: propertyTokens)
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

// MARK: Private Constants

private let accidentalCS: Set<Character> = ["_", "^", "="]

// Known bare clef name prefixes (excludes "none" which is handled as the empty key special case).
private let clefNamePrefixes: [String] = ["treble", "alto", "tenor", "bass", "perc"]

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

// MARK: Private Functions

private func _parseClefMiddle(_ value: Substring) -> ABCClef.Middle? {
    guard !value.isEmpty,
          let plResult = pitchLetterOctaves[value.prefix(1)]
    else { return nil }

    var octave = plResult.octave

    for chr in value.dropFirst() {
        switch chr {
        case "'":
            octave += 1

        case ",":
            octave -= 1

        default:
            return nil
        }
    }

    guard octave >= 0,
          let octaveValue = ABCPitch.Octave(uintValue: UInt(octave))
    else { return nil }

    return ABCClef.Middle(letter: plResult.letter, octave: octaveValue)
}

private func _parseClefNameLineAndOttava(_ value: Substring) -> (ABCClef.Name?, Int?, ABCClef.Ottava?) {
    var v = value
    var ottava: ABCClef.Ottava?

    if v.hasSuffix("+8") {
        ottava = .alta

        v = v.dropLast(2)
    } else if v.hasSuffix("-8") {
        ottava = .bassa

        v = v.dropLast(2)
    }

    let lineCount = v.reversed().prefix { $0.isNumber }.count
    let line: Int? = lineCount == 0 ? nil : Int(v.suffix(lineCount))

    v = v.dropLast(lineCount)

    return (ABCClef.Name(stringValue: String(v)), line, ottava)
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

// Partitions whitespace-split tokens from a K: field value into:
//   propertyTokens – contain '=' not at position 0 (e.g. "clef=treble", "t=-2")
//   bareClefToken  – a single bare clef name token (e.g. "perc", "treble+8")
//   otherTokens    – tonic, mode, and extra-accidental tokens
//
// '=' at position 0 is the natural-sign accidental prefix (e.g. "=F"), so those
// always go to otherTokens.
private func _partitionKeySignatureTokens(_ tidyInput: Substring)
    -> (propertyTokens: [Substring], bareClefToken: Substring?, otherTokens: [Substring]) {
    var propertyTokens: [Substring] = []
    var bareClefToken: Substring?
    var otherTokens: [Substring] = []

    for token in tidyInput.split(whereSeparator: \.isABCWhitespace) {
        if let eqIdx = token.firstIndex(of: "="), eqIdx != token.startIndex {
            propertyTokens.append(token)
        } else if isBareClefNameToken(token) {
            bareClefToken = token
        } else {
            otherTokens.append(token)
        }
    }

    return (propertyTokens, bareClefToken, otherTokens)
}
