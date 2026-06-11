// © 2026 John Gary Pusey (see LICENSE.md)

// swiftlint:disable file_length

internal import Foundation

// MARK: Internal Functions

internal func formatAccidental(_ accidental: ABCPitch.Accidental) -> String {
    pitchAccidentals[accidental]?.note ?? ""
}

internal func formatFieldContent(_ field: ABCField) throws -> (String, String) {
    switch field {
    case let .alignedLyrics(alignedLyrics):
        return ("w", _formatAlignedLyrics(alignedLyrics))

    case let .area(text):
        return try ("A", _validateText(text))

    case let .book(text):
        return try ("B", _validateText(text))

    case let .composer(text):
        return try ("C", _validateText(text))

    case let .discography(text):
        return try ("D", _validateText(text))

    case let .fileURL(text):
        return try ("F", _validateText(text))

    case let .group(text):
        return try ("G", _validateText(text))

    case let .history(text):
        return try ("H", _validateText(text))

    case let .instruction(directive):
        let value = directive.value.isEmpty
                    ? directive.name
                    : "\(directive.name) \(directive.value)"

        return try ("I", _validateText(value))

    case let .key(ABCKeySignature):
        return ("K", _formatKey(ABCKeySignature))

    case let .legacy(letter, text):
        return try (String(letter), _validateText(text))

    case let .lyrics(text):
        return try ("W", _validateText(text))

    case let .macro(macro):
        return try ("m", _validateText("\(macro.trigger)=\(macro.replacement)"))

    case let .meter(timeSignature):
        switch timeSignature {
        case let .explicit(fraction):
            guard isPowerOfTwo(fraction.denominator)
            else { throw ABCFormatter.Error.invalidTimeSignature(timeSignature) }

        case let .complex(nums, den):
            guard !nums.isEmpty,
                  isPowerOfTwo(den)
            else { throw ABCFormatter.Error.invalidTimeSignature(timeSignature) }

        default:
            break
        }

        return ("M", _formatMeter(timeSignature))

    case let .notes(text):
        return try ("N", _validateText(text))

    case let .origin(text):
        return try ("O", _validateText(text))

    case let .parts(partSequence):
        return ("P", _formatPartSequence(partSequence))

    case let .refNumber(refNumber):
        return ("X", "\(refNumber.uintValue)")

    case let .remark(text):
        return try ("r", _validateText(text))

    case let .rhythm(text):
        return try ("R", _validateText(text))

    case let .source(text):
        return try ("S", _validateText(text))

    case let .symbolLine(symbolLine):
        return ("s", _formatSymbolLine(symbolLine))

    case let .tempo(tempo):
        return ("Q", _formatTempo(tempo))

    case let .title(text):
        return try ("T", _validateText(text))

    case let .transcription(text):
        return try ("Z", _validateText(text))

    case let .unitNoteLength(duration):
        guard isPowerOfTwo(duration.denominator)
        else { throw ABCFormatter.Error.invalidUnitNoteLength(duration) }

        return ("L", "\(duration.numerator)/\(duration.denominator)")

    case let .userSymbol(userSymbol):
        return ("U", "\(userSymbol.symbol)=\(userSymbol.decoration.stringValue)")

    case let .voice(voice):
        guard !voice.id.isEmpty
        else { throw ABCFormatter.Error.emptyVoiceID }

        return ("V", _formatVoice(voice))
    }
}

internal func formatNote(_ note: ABCNote,
                         _ unitNoteLength: ABCDuration?,
                         _ meter: ABCTimeSignature?) -> String {
    var result = formatAccidental(note.pitch.accidental)

    result += formatPitchLetterOctave(note.pitch.letter,
                                      note.pitch.octave)

    result += _formatDuration(note.duration,
                              unitNoteLength,
                              meter)

    if note.isTied {
        result += "-"
    }

    return result
}

internal func formatPitchLetterOctave(_ letter: ABCPitch.Letter,
                                      _ octave: ABCPitch.Octave) -> String {
    guard let (upper, lower) = pitchLetters[letter]
    else { preconditionFailure("Unknown pitch letter: \(letter)") }

    if octave <= 4 {
        return upper + String(repeating: ",",
                              count: 4 - octave)
    } else {
        return lower + String(repeating: "'",
                              count: octave - 5)
    }
}

internal func formatSymbol(_ symbol: ABCSymbol,
                           _ unitNoteLength: ABCDuration?,
                           _ meter: ABCTimeSignature?) throws -> String {
    switch symbol {
    case let .annotation(annotation):
        return "\"\(annotation.stringValue)\""

    case let .barRepeat(text):
        let validChars: Set<Character> = ["|", ":", "[", "]"]

        guard !text.isEmpty,
              text.allSatisfy({ validChars.contains($0) })
        else { throw ABCFormatter.Error.invalidBarRepeat(text) }

        return text

    case .beamBreak:
        preconditionFailure("beamBreak must be handled by the caller")

    case let .brokenRhythm(text):
        guard !text.isEmpty,
              text.count <= 3,
              let first = text.first,
              first == ">" || first == "<",
              text.allSatisfy({ $0 == first })
        else { throw ABCFormatter.Error.invalidBrokenRhythm(text) }

        return text

    case let .chord(chord):
        return try _formatChord(chord,
                                unitNoteLength,
                                meter)

    case let .chordSymbol(text):
        return "\"\(text)\""

    case let .decoration(decoration):
        return decoration.stringValue

    case let .graceNotes(graceNotes):
        return try _formatGraceNotes(graceNotes,
                                     unitNoteLength,
                                     meter)

    case let .inlineField(field):
        let (letter, value) = try formatFieldContent(field)

        return "[\(letter):\(value)]"

    case let .macroCall(macroCall):
        return macroCall.trigger

    case let .note(note):
        guard note.duration.numerator > 0
        else { throw ABCFormatter.Error.invalidDuration(note.duration) }

        return formatNote(note,
                          unitNoteLength,
                          meter)

    case .overlay:
        return "&"

    case let .rest(rest):
        switch rest {
        case let .multiMeasure(invisible, measureCount):
            guard measureCount > 0
            else { throw ABCFormatter.Error.invalidMultiMeasureRestCount }

            let letter = invisible ? "X" : "Z"

            return measureCount == 1 ? letter : "\(letter)\(measureCount)"

        case let .regular(invisible, duration):
            guard duration.numerator > 0
            else { throw ABCFormatter.Error.invalidDuration(duration) }

            let letter = invisible ? "x" : "z"

            return "\(letter)\(_formatDuration(duration, unitNoteLength, meter))"
        }

    case let .slur(text):
        guard text == "(" || text == ")"
        else { throw ABCFormatter.Error.invalidSlur(text) }

        return text

    case let .spacer(duration):
        guard duration.numerator > 0
        else { throw ABCFormatter.Error.invalidDuration(duration) }

        return "y\(_formatDuration(duration, unitNoteLength, meter))"

    case let .tuplet(tuplet):
        guard tuplet.noteCount > 0
        else { throw ABCFormatter.Error.invalidTupletNoteCount }

        return tuplet.stringValue

    case let .variantEnding(variantEnding):
        guard !variantEnding.endings.isEmpty
        else { throw ABCFormatter.Error.emptyVariantEnding }

        return variantEnding.stringValue
    }
}

internal func isPowerOfTwo(_ value: UInt) -> Bool {
    value > 0 && (value & (value - 1)) == 0
}

internal func log2Integer(_ inValue: UInt) -> Int {
    var value = inValue
    var result = 0

    while value > 1 {
        value >>= 1
        result += 1
    }

    return result
}

// MARK: Private Constants

private let modes: [ABCKeySignature.Mode: String] = [.aeolian: "aeolian",
                                                     .dorian: "dorian",
                                                     .explicit: "explicit",
                                                     .ionian: "ionian",
                                                     .locrian: "locrian",
                                                     .lydian: "lydian",
                                                     .major: "major",
                                                     .minor: "minor",
                                                     .mixolydian: "mixolydian",
                                                     .phrygian: "phrygian"]

private let pitchAccidentals: [ABCPitch.Accidental: (key: String, note: String)] = [.doubleFlat: ("__", "__"),
                                                                                    .flat: ("_", "_"),
                                                                                    .natural: ("=", ""),
                                                                                    .sharp: ("^", "^"),
                                                                                    .doubleSharp: ("^^", "^^")]

private let pitchLetters: [ABCPitch.Letter: (upper: String, lower: String)] = [.a: ("A", "a"),
                                                                               .b: ("B", "b"),
                                                                               .c: ("C", "c"),
                                                                               .d: ("D", "d"),
                                                                               .e: ("E", "e"),
                                                                               .f: ("F", "f"),
                                                                               .g: ("G", "g")]

private let tonics: [ABCKeySignature.Tonic: String] = [.a: "A",
                                                       .aFlat: "Ab",
                                                       .aSharp: "A#",
                                                       .b: "B",
                                                       .bFlat: "Bb",
                                                       .bSharp: "B#",
                                                       .c: "C",
                                                       .cFlat: "Cb",
                                                       .cSharp: "C#",
                                                       .d: "D",
                                                       .dFlat: "Db",
                                                       .dSharp: "D#",
                                                       .e: "E",
                                                       .eFlat: "Eb",
                                                       .eSharp: "E#",
                                                       .f: "F",
                                                       .fFlat: "Fb",
                                                       .fSharp: "F#",
                                                       .g: "G",
                                                       .gFlat: "Gb",
                                                       .gSharp: "G#"]

// MARK: Private Functions

private func _durationFromMeter(_ meter: ABCTimeSignature) -> ABCDuration {
    switch meter {
    case let .explicit(fraction):
        let ratio = Double(fraction.numerator) / Double(fraction.denominator)

        return ratio < 0.75
        ? ABCDuration(numerator: 1,
                      denominator: 16,
                      reduce: false)
        : ABCDuration(numerator: 1,
                      denominator: 8,
                      reduce: false)

    default:
        return ABCDuration(numerator: 1,
                           denominator: 8,
                           reduce: false)
    }
}

private func _effectiveBase(_ unitNoteLength: ABCDuration?,
                            _ meter: ABCTimeSignature?) -> ABCDuration {
    if let unitNoteLength {
        return unitNoteLength
    }

    if let meter {
        return _durationFromMeter(meter)
    }

    return ABCDuration(numerator: 1,
                       denominator: 8,
                       reduce: false)
}

private func _formatAlignedLyrics(_ alignedLyrics: ABCAlignedLyrics) -> String {
    var prevIsConnector = false
    var result = ""

    for segment in alignedLyrics.segments {
        let needsSpace = !result.isEmpty && !prevIsConnector

        switch segment {
        case .barAlign:
            if needsSpace {
                result.append(" ")
            }

            result.append("|")

            prevIsConnector = false

        case .escapedHyphen:
            result.append("\\-")

            prevIsConnector = true

        case .hold:
            if needsSpace {
                result.append(" ")
            }

            result.append("_")

            prevIsConnector = false

        case .hyphen:
            result.append("-")

            prevIsConnector = true

        case .skip:
            if needsSpace {
                result.append(" ")
            }

            result.append("*")

            prevIsConnector = false

        case let .text(string):
            if needsSpace {
                result.append(" ")
            }

            result.append(string.replacingOccurrences(of: "%",
                                                      with: "\\%"))

            prevIsConnector = false

        case .tilde:
            result.append("~")

            prevIsConnector = true
        }
    }

    return result
}

private func _formatChord(_ chord: ABCChord,
                          _ unitNoteLength: ABCDuration?,
                          _ meter: ABCTimeSignature?) throws -> String {
    guard !chord.notes.isEmpty
    else { throw ABCFormatter.Error.emptyChord }

    guard chord.duration.numerator > 0
    else { throw ABCFormatter.Error.invalidDuration(chord.duration) }

    for note in chord.notes {
        guard note.duration.numerator > 0
        else { throw ABCFormatter.Error.invalidDuration(note.duration) }
    }

    var result = "["

    result += chord.notes.map { formatNote($0, unitNoteLength, meter) }.joined()

    result += "]"

    result += _formatDuration(chord.duration,
                              unitNoteLength,
                              meter)
    if chord.isTied {
        result += "-"
    }

    return result
}

private func _formatClef(_ clef: ABCClef) -> String {
    var parts: [String] = []

    if let name = clef.name {
        parts.append("clef=\(name)")
    }

    if let middle = clef.middle {
        parts.append("middle=\(middle)")
    }

    if let transpose = clef.transpose {
        parts.append("transpose=\(transpose)")
    }

    if let octave = clef.octave {
        parts.append("octave=\(octave)")
    }

    if let stafflines = clef.stafflines {
        parts.append("stafflines=\(stafflines)")
    }

    return parts.joined(separator: " ")
}

private func _formatDuration(_ duration: ABCDuration,
                             _ unitNoteLength: ABCDuration?,
                             _ meter: ABCTimeSignature?) -> String {
    let base = _effectiveBase(unitNoteLength, meter)
    let mn = duration.numerator * base.denominator
    let md = duration.denominator * base.numerator
    let reduced = ABCFraction(numerator: mn,
                              denominator: md,
                              reduce: true)
    let rn = reduced.numerator
    let rd = reduced.denominator

    if rn == 1, rd == 1 {
        return ""
    }

    if rd == 1 {
        return "\(rn)"
    }

    if rn == 1 {
        if isPowerOfTwo(rd) {
            return String(repeating: "/",
                          count: log2Integer(rd))
        } else {
            return "/\(rd)"
        }
    }

    return "\(rn)/\(rd)"
}

private func _formatGraceNotes(_ graceNotes: ABCGraceNotes,
                               _ unitNoteLength: ABCDuration?,
                               _ meter: ABCTimeSignature?) throws -> String {
    guard !graceNotes.notes.isEmpty
    else { throw ABCFormatter.Error.emptyGraceNotes }

    for note in graceNotes.notes {
        guard note.duration.numerator > 0
        else { throw ABCFormatter.Error.invalidDuration(note.duration) }
    }

    var result = "{"

    if graceNotes.isSlashed {
        result += "/"
    }

    result += graceNotes.notes.map { formatNote($0, unitNoteLength, meter) }.joined()

    result += "}"

    return result
}

private func _formatKey(_ keySignature: ABCKeySignature) -> String {
    switch keySignature {
    case let .clefOnly(clef):
        return _formatClef(clef)

    case .empty:
        return "none"

    case .highlandPipes:
        return "HP"

    case .highlandPipesPreset:
        return "Hp"

    case let .standard(tonic, mode, accidentals, clef):
        var result = _formatTonic(tonic)

        let modeSuffix = _formatMode(mode)

        if !modeSuffix.isEmpty {
            result.append(" ")
            result.append(modeSuffix)
        }

        for pitch in accidentals {
            result.append(" ")
            result.append(_formatKeyAccidental(pitch.accidental))
            result.append(formatPitchLetterOctave(pitch.letter, pitch.octave))
        }

        if let clef {
            let clefStr = _formatClef(clef)

            if !clefStr.isEmpty {
                result.append(" ")
                result.append(clefStr)
            }
        }

        return result
    }
}

private func _formatKeyAccidental(_ accidental: ABCPitch.Accidental) -> String {
    pitchAccidentals[accidental]?.key ?? ""
}

private func _formatMeter(_ timeSignature: ABCTimeSignature) -> String {
    switch timeSignature {
    case .common:
        "C"

    case .cut:
        "C|"

    case .empty:
        "none"

    case let .explicit(fraction):
        "\(fraction.numerator)/\(fraction.denominator)"

    case let .complex(numerators, denominator):
        "(\(numerators.map { "\($0)" }.joined(separator: "+")))/\(denominator)"
    }
}

private func _formatMode(_ mode: ABCKeySignature.Mode) -> String {
    modes[mode] ?? ""
}

private func _formatPartItems(_ items: [ABCPartSequence.Item]) -> String {
    items.map { item in
        switch item {
        case let .group(children, count):
            let inner = _formatPartItems(children)

            return count == 1 ? "(\(inner))" : "(\(inner))\(count)"

        case let .part(char, count):
            return count == 1 ? String(char) : "\(char)\(count)"
        }
    }.joined()
}

private func _formatPartSequence(_ partSequence: ABCPartSequence) -> String {
    _formatPartItems(partSequence.items)
}

private func _formatSymbolLine(_ symbolLine: ABCSymbolLine) -> String {
    symbolLine.elements.map { token in
        switch token {
        case let .annotation(annotation):
            "\"\(annotation.stringValue)\""

        case let .chordSymbol(text):
            "\"\(text)\""

        case let .decoration(decoration):
            decoration.stringValue

        case .skip:
            "*"
        }
    }.joined(separator: " ")
}

private func _formatTempo(_ tempo: ABCTempo) -> String {
    var parts: [String] = []

    if let text = tempo.text {
        parts.append("\"\(text)\"")
    }

    if !tempo.durations.isEmpty {
        let durStr = tempo.durations.map { "\($0.numerator)/\($0.denominator)" }.joined(separator: " ")

        if let rate = tempo.rate {
            parts.append("\(durStr)=\(rate)")
        } else {
            parts.append(durStr)
        }
    } else if let rate = tempo.rate {
        parts.append("\(rate)")
    }

    return parts.joined(separator: " ")
}

private func _formatTonic(_ tonic: ABCKeySignature.Tonic) -> String {
    tonics[tonic] ?? ""
}

private func _formatVoice(_ voice: ABCVoice) -> String {
    var parts = [voice.id]

    for key in voice.properties.keys.sorted() {
        guard let value = voice.properties[key]
        else { continue }

        if value.contains(where: { $0.isWhitespace }) {
            parts.append("\(key)=\"\(value)\"")
        } else {
            parts.append("\(key)=\(value)")
        }
    }

    return parts.joined(separator: " ")
}

private func _validateText(_ text: String) throws -> String {
    guard !text.contains(where: { $0.isNewline })
    else { throw ABCFormatter.Error.invalidTextValue(text) }

    return text.contains("%")
           ? text.replacingOccurrences(of: "%",
                                       with: "\\%")
           : text
}
