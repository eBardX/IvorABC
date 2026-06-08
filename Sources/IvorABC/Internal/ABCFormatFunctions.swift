// © 2026 John Gary Pusey (see LICENSE.md)

// swiftlint:disable file_length

internal import Foundation

// MARK: Internal Functions

internal func formatAccidental(_ acc: ABCPitch.Accidental) -> String {
    pitchAccidentals[acc]?.note ?? ""
}

internal func formatFieldContent(_ field: ABCField) throws -> (String, String) {
    switch field {
    case let .alignedLyrics(al):
        return ("w", _formatAlignedLyrics(al))

    case let .area(s):
        return try ("A", _validateString(s))

    case let .book(s):
        return try ("B", _validateString(s))

    case let .composer(s):
        return try ("C", _validateString(s))

    case let .discography(s):
        return try ("D", _validateString(s))

    case let .fileURL(s):
        return try ("F", _validateString(s))

    case let .group(s):
        return try ("G", _validateString(s))

    case let .history(s):
        return try ("H", _validateString(s))

    case let .instruction(dir):
        let value = dir.value.isEmpty ? dir.name : "\(dir.name) \(dir.value)"

        return try ("I", _validateString(value))

    case let .key(ks):
        return ("K", _formatKey(ks))

    case let .lyrics(s):
        return try ("W", _validateString(s))

    case let .macro(m):
        return try ("m", _validateString("\(m.trigger)=\(m.replacement)"))

    case let .meter(ts):
        switch ts {
        case let .explicit(fraction):
            guard isPowerOfTwo(fraction.denominator)
            else { throw ABCFormatError.invalidTimeSignature(ts) }

        case let .complex(nums, den):
            guard !nums.isEmpty,
                  isPowerOfTwo(den)
            else { throw ABCFormatError.invalidTimeSignature(ts) }

        default:
            break
        }

        return ("M", _formatMeter(ts))

    case let .notes(s):
        return try ("N", _validateString(s))

    case let .origin(s):
        return try ("O", _validateString(s))

    case let .parts(ps):
        return ("P", _formatPartSequence(ps))

    case let .refNumber(rn):
        return ("X", "\(rn.uintValue)")

    case let .remark(s):
        return try ("r", _validateString(s))

    case let .rhythm(s):
        return try ("R", _validateString(s))

    case let .source(s):
        return try ("S", _validateString(s))

    case let .symbolLine(sl):
        return ("s", _formatSymbolLine(sl))

    case let .tempo(t):
        return ("Q", _formatTempo(t))

    case let .title(s):
        return try ("T", _validateString(s))

    case let .transcription(s):
        return try ("Z", _validateString(s))

    case let .unitNoteLength(dur):
        guard isPowerOfTwo(dur.denominator)
        else { throw ABCFormatError.invalidUnitNoteLength(dur) }

        return ("L", "\(dur.numerator)/\(dur.denominator)")

    case let .userSymbol(us):
        return ("U", "\(us.symbol)=\(us.decoration)")

    case let .voice(v):
        guard !v.id.isEmpty
        else { throw ABCFormatError.emptyVoiceID }

        return ("V", _formatVoice(v))
    }
}

internal func formatNote(_ note: ABCNote,
                         _ unitNoteLength: ABCDuration?,
                         _ meter: ABCTimeSignature?) -> String {
    var result = formatAccidental(note.pitch.accidental)

    result += formatPitchLetterOctave(note.pitch.letter,
                                      note.pitch.octave)

    result += _formatDurationSuffix(note.duration,
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
    case let .annotation(ann):
        return "\"\(ann.stringValue)\""

    case let .barRepeat(br):
        let validChars: Set<Character> = ["|", ":", "[", "]"]

        guard !br.isEmpty,
              br.allSatisfy({ validChars.contains($0) })
        else { throw ABCFormatError.invalidBarRepeat(br) }

        return br

    case .beamBreak:
        preconditionFailure("beamBreak must be handled by the caller")

    case let .brokenRhythm(br):
        guard !br.isEmpty,
              br.count <= 3,
              let first = br.first,
              first == ">" || first == "<",
              br.allSatisfy({ $0 == first })
        else { throw ABCFormatError.invalidBrokenRhythm(br) }

        return br

    case let .chord(notes, dur, isTied):
        return try _formatChord(notes, dur, isTied, unitNoteLength, meter)

    case let .chordSymbol(cs):
        return "\"\(cs)\""

    case let .decoration(dec):
        guard !dec.name.isEmpty,
              !dec.name.contains("!")
        else { throw ABCFormatError.invalidDecorationName(dec.name) }

        return dec.shorthand.map { String($0) } ?? "!\(dec.name)!"

    case let .graceNotes(slash, notes):
        return try _formatGraceNotes(slash, notes, unitNoteLength, meter)

    case let .inlineField(ifld):
        let (letter, value) = try formatFieldContent(ifld)

        return "[\(letter):\(value)]"

    case let .macroCall(mc):
        return mc.trigger

    case let .note(nt):
        guard nt.duration.numerator > 0
        else { throw ABCFormatError.invalidDuration(nt.duration) }

        return formatNote(nt, unitNoteLength, meter)

    case .overlay:
        return "&"

    case let .rest(rst):
        switch rst {
        case let .multiMeasure(inv, measureCount):
            guard measureCount > 0
            else { throw ABCFormatError.invalidMultiMeasureRestCount }

            let letter = inv ? "X" : "Z"

            return measureCount == 1 ? letter : "\(letter)\(measureCount)"

        case let .regular(inv, dur):
            guard dur.numerator > 0
            else { throw ABCFormatError.invalidDuration(dur) }

            let letter = inv ? "x" : "z"

            return "\(letter)\(_formatDurationSuffix(dur, unitNoteLength, meter))"
        }

    case let .slur(sl):
        guard sl == "(" || sl == ")"
        else { throw ABCFormatError.invalidSlur(sl) }

        return sl

    case let .spacer(dur):
        guard dur.numerator > 0
        else { throw ABCFormatError.invalidDuration(dur) }

        return "y\(_formatDurationSuffix(dur, unitNoteLength, meter))"

    case let .tuplet(tup):
        guard tup.noteCount > 0
        else { throw ABCFormatError.invalidTupletNoteCount }

        return tup.stringValue

    case let .variantEnding(ve):
        guard !ve.endings.isEmpty
        else { throw ABCFormatError.emptyVariantEnding }

        return ve.stringValue
    }
}

// MARK: Private Functions

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

internal func isPowerOfTwo(_ n: UInt) -> Bool {
    n > 0 && (n & (n - 1)) == 0
}

internal func log2Integer(_ n: UInt) -> Int {
    var result = 0
    var value = n

    while value > 1 {
        value >>= 1
        result += 1
    }

    return result
}

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
    if let dur = unitNoteLength {
        return dur
    }

    if let ts = meter {
        return _durationFromMeter(ts)
    }

    return ABCDuration(numerator: 1,
                       denominator: 8,
                       reduce: false)
}

private func _formatAlignedLyrics(_ al: ABCAlignedLyrics) -> String {
    var result = ""

    for segment in al.segments {
        switch segment {
        case let .syllable(text):
            if !result.isEmpty {
                result.append(" ")
            }

            result.append(text.replacingOccurrences(of: "%",
                                                    with: "\\%")
                             .replacingOccurrences(of: " ",
                                                   with: "~"))

        case let .continuation(text):
            result.append("-")
            result.append(text.replacingOccurrences(of: "%",
                                                    with: "\\%")
                             .replacingOccurrences(of: " ",
                                                   with: "~"))

        case .hold:
            if !result.isEmpty {
                result.append(" ")
            }

            result.append("_")

        case .skip:
            if !result.isEmpty {
                result.append(" ")
            }

            result.append("*")

        case .barAlign:
            if !result.isEmpty {
                result.append(" ")
            }

            result.append("|")
        }
    }

    return result
}

private func _formatChord(_ notes: [ABCNote],
                          _ dur: ABCDuration,
                          _ isTied: Bool,
                          _ unitNoteLength: ABCDuration?,
                          _ meter: ABCTimeSignature?) throws -> String {
    guard !notes.isEmpty
    else { throw ABCFormatError.emptyChord }

    guard dur.numerator > 0
    else { throw ABCFormatError.invalidDuration(dur) }

    for note in notes {
        guard note.duration.numerator > 0
        else { throw ABCFormatError.invalidDuration(note.duration) }
    }

    var result = "["

    result += notes.map { formatNote($0, unitNoteLength, meter) }.joined()

    result += "]"

    result += _formatDurationSuffix(dur,
                                    unitNoteLength,
                                    meter)
    if isTied {
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

private func _formatDurationSuffix(_ stored: ABCDuration,
                                   _ unitNoteLength: ABCDuration?,
                                   _ meter: ABCTimeSignature?) -> String {
    let base = _effectiveBase(unitNoteLength, meter)
    let mn = stored.numerator * base.denominator
    let md = stored.denominator * base.numerator
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

private func _formatGraceNotes(_ slash: Bool,
                               _ notes: [ABCNote],
                               _ unitNoteLength: ABCDuration?,
                               _ meter: ABCTimeSignature?) throws -> String {
    guard !notes.isEmpty
    else { throw ABCFormatError.emptyGraceNotes }

    for note in notes {
        guard note.duration.numerator > 0
        else { throw ABCFormatError.invalidDuration(note.duration) }
    }

    var result = "{"

    if slash {
        result += "/"
    }

    result += notes.map { formatNote($0, unitNoteLength, meter) }.joined()

    result += "}"

    return result
}

private func _formatKey(_ ks: ABCKeySignature) -> String {
    switch ks {
    case .empty:
        return "none"

    case .highlandPipes:
        return "HP"

    case .highlandPipesPreset:
        return "Hp"

    case let .clefOnly(clef):
        return _formatClef(clef)

    case let .standard(tonic, mode, accs, clef):
        var result = _formatTonic(tonic)

        let modeSuffix = _formatMode(mode)

        if !modeSuffix.isEmpty {
            result.append(" ")
            result.append(modeSuffix)
        }

        for acc in accs {
            result.append(" ")
            result.append(_formatKeyAccidental(acc.accidental))
            result.append(formatPitchLetterOctave(acc.letter, acc.octave))
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

private func _formatKeyAccidental(_ acc: ABCPitch.Accidental) -> String {
    pitchAccidentals[acc]?.key ?? ""
}

private func _formatMeter(_ ts: ABCTimeSignature) -> String {
    switch ts {
    case .common:
        "C"

    case .cut:
        "C|"

    case .empty:
        "none"

    case let .explicit(fraction):
        "\(fraction.numerator)/\(fraction.denominator)"

    case let .complex(nums, den):
        "(\(nums.map { "\($0)" }.joined(separator: "+")))/\(den)"
    }
}

private func _formatMode(_ mode: ABCKeySignature.Mode) -> String {
    modes[mode] ?? ""
}

private func _formatPartItems(_ items: [ABCPartSequence.Item]) -> String {
    items.map { item -> String in
        switch item {
        case let .part(ch, count):
            return count == 1 ? String(ch) : "\(ch)\(count)"

        case let .group(children, count):
            let inner = _formatPartItems(children)

            return count == 1 ? "(\(inner))" : "(\(inner))\(count)"
        }
    }.joined()
}

private func _formatPartSequence(_ ps: ABCPartSequence) -> String {
    _formatPartItems(ps.items)
}

private func _formatSymbolLine(_ sl: ABCSymbolLine) -> String {
    sl.tokens.map { token -> String in
        switch token {
        case let .annotation(ann):
            return "\"\(ann.stringValue)\""

        case let .chordSymbol(cs):
            return "\"\(cs)\""

        case let .decoration(dec):
            return dec.shorthand.map { String($0) } ?? "!\(dec.name)!"

        case .skip:
            return "*"
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

private func _validateString(_ string: String) throws -> String {
    guard !string.contains(where: { $0.isNewline })
    else { throw ABCFormatError.invalidStringArgument(string) }

    return string.contains("%")
           ? string.replacingOccurrences(of: "%",
                                         with: "\\%")
           : string
}
