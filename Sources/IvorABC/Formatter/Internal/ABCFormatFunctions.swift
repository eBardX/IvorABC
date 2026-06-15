// © 2026 John Gary Pusey (see LICENSE.md)

// swiftlint:disable file_length

internal import Foundation

private import XestiTools

// MARK: Internal Functions

internal func formatAccidental(_ accidental: ABCPitch.Accidental) -> String {
    pitchAccidentals[accidental]?.note ?? ""
}

internal func formatFieldContent(_ field: ABCField) throws -> (String, String) {
    switch field {
    case let .alignedLyrics(alignedLyrics):
        return ("w", _formatAlignedLyrics(alignedLyrics))

    case let .area(text):
        return ("A", _formatText(text))

    case let .book(text):
        return ("B", _formatText(text))

    case let .composer(text):
        return ("C", _formatText(text))

    case let .discography(text):
        return ("D", _formatText(text))

    case let .fileURL(text):
        return ("F", _formatText(text))

    case let .group(text):
        return ("G", _formatText(text))

    case let .history(text):
        return ("H", _formatText(text))

    case let .elemskip(elemskip):
        return ("E", _formatElemskip(elemskip))

    case let .information(text):
        return ("I", _formatText(text))

    case let .instruction(directive):
        return ("I", _formatInstructionDirective(directive))

    case let .key(ABCKeySignature):
        return ("K", _formatKeySignature(ABCKeySignature))

    case let .lyrics(text):
        return ("W", _formatText(text))

    case let .macro(macro):
        return ("m", _formatMacro(macro))

    case let .meter(timeSignature):
        return ("M", _formatTimeSignature(timeSignature))

    case let .notes(text):
        return ("N", _formatText(text))

    case let .origin(text):
        return ("O", _formatText(text))

    case let .parts(partSequence):
        return ("P", _formatPartSequence(partSequence))

    case let .refNumber(refNumber):
        return ("X", "\(refNumber.uintValue)")

    case let .remark(text):
        return ("r", _formatText(text))

    case let .rhythm(text):
        return ("R", _formatText(text))

    case let .source(text):
        return ("S", _formatText(text))

    case let .symbolLine(symbolLine):
        return ("s", _formatSymbolLine(symbolLine))

    case let .tempo(tempo):
        return ("Q", _formatTempo(tempo))

    case let .title(text):
        return ("T", _formatText(text))

    case let .transcription(text):
        return ("Z", _formatText(text))

    case let .unitNoteLength(duration):
        return ("L", "\(duration.numerator)/\(duration.denominator)")

    case let .userSymbol(userSymbol):
        return ("U", "\(userSymbol.symbol)=\(_formatDecoration(userSymbol.decoration, false))")

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

    result += _formatPitchLetterOctave(note.pitch.letter,
                                       note.pitch.octave)

    result += _formatDuration(note.duration,
                              unitNoteLength,
                              meter)

    if note.isTied {
        result += "-"
    }

    return result
}

internal func formatSymbol(_ symbol: ABCSymbol,
                           _ unitNoteLength: ABCDuration?,
                           _ meter: ABCTimeSignature?) throws -> String {
    switch symbol {
    case let .annotation(annotation):
        return _formatAnnotation(annotation)

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
        return _formatDecoration(decoration, true)

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
            let letter = invisible ? "x" : "z"

            return "\(letter)\(_formatDuration(duration, unitNoteLength, meter))"
        }

    case let .slur(text):
        guard text == "(" || text == ")"
        else { throw ABCFormatter.Error.invalidSlur(text) }

        return text

    case let .spacer(duration):
        return "y\(_formatDuration(duration, unitNoteLength, meter))"

    case let .tuplet(tuplet):
        return _formatTuplet(tuplet)

    case let .variantEnding(variantEnding):
        return _formatVariantEnding(variantEnding)
    }
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

private let annotationPositions: [ABCAnnotation.Position: String] = [.above: "^",
                                                                     .auto: "@",
                                                                     .below: "_",
                                                                     .left: "<",
                                                                     .right: ">"]

private let keySignatureModes: [ABCKeySignature.Mode: String] = [.aeolian: "aeolian",
                                                                 .dorian: "dorian",
                                                                 .explicit: "explicit",
                                                                 .ionian: "ionian",
                                                                 .locrian: "locrian",
                                                                 .lydian: "lydian",
                                                                 .major: "major",
                                                                 .minor: "minor",
                                                                 .mixolydian: "mixolydian",
                                                                 .phrygian: "phrygian"]

private let keySignatureTonics: [ABCKeySignature.Tonic: String] = [.a: "A",
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

// MARK: Private Functions

private func _durationFromTimeSignature(_ timeSignature: ABCTimeSignature) -> ABCDuration? {
    switch timeSignature {
    case let .standard(meter):
        let ratio = Double(meter.numerator) / Double(meter.denominator)

        return ratio < 0.75
               ? ABCDuration(numerator: 1,
                             denominator: 16)
               : ABCDuration(numerator: 1,
                             denominator: 8)

    default:
        return ABCDuration(numerator: 1,
                           denominator: 8)
    }
}

private func _effectiveBaseDuration(_ unitNoteLength: ABCDuration?,
                                    _ timeSignature: ABCTimeSignature?) -> ABCDuration? {
    if let unitNoteLength {
        return unitNoteLength
    }

    if let timeSignature {
        return _durationFromTimeSignature(timeSignature)
    }

    return ABCDuration(numerator: 1,
                       denominator: 8)
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

            result.append(escape(string))

            prevIsConnector = false

        case .tilde:
            result.append("~")

            prevIsConnector = true
        }
    }

    return result
}

private func _formatAnnotation(_ annotation: ABCAnnotation) -> String {
    var result = "\""

    result += annotationPositions[annotation.position] ?? ""
    result += annotation.text

    result += "\""

    return result
}

private func _formatChord(_ chord: ABCChord,
                          _ unitNoteLength: ABCDuration?,
                          _ meter: ABCTimeSignature?) throws -> String {
    guard !chord.notes.isEmpty
    else { throw ABCFormatter.Error.emptyChord }

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

private func _formatDecoration(_ decoration: ABCDecoration,
                               _ shorthandAllowed: Bool) -> String {
    if shorthandAllowed,
       let shorthand = decoration.shorthand {
        String(shorthand)
    } else if decoration.dialect == .plus {
        "+\(decoration.name)+"
    } else {
        "!\(decoration.name)!"
    }
}

private func _formatDuration(_ duration: ABCDuration,
                             _ unitNoteLength: ABCDuration?,
                             _ meter: ABCTimeSignature?) -> String {
    guard let base = _effectiveBaseDuration(unitNoteLength, meter)
    else { return "" }

    let mn = duration.numerator * base.denominator
    let md = duration.denominator * base.numerator

    guard let reduced = ABCDuration(numerator: mn,
                                    denominator: md)
    else { return "" }

    let rn = reduced.numerator
    let rd = reduced.denominator

    if rn == 1,
       rd == 1 {
        return ""
    }

    if rd == 1 {
        return "\(rn)"
    }

    if rn == 1 {
        if rd.isPowerOf2 {
            return String(repeating: "/",
                          count: log2Integer(rd))
        } else {
            return "/\(rd)"
        }
    }

    return "\(rn)/\(rd)"
}

private func _formatElemskip(_ elemskip: ABCElemskip) -> String {
    switch elemskip {
    case let .decimal(doubleValue):
        String(doubleValue)

    case let .integer(intValue):
        String(intValue)
    }
}

private func _formatGraceNotes(_ graceNotes: ABCGraceNotes,
                               _ unitNoteLength: ABCDuration?,
                               _ meter: ABCTimeSignature?) throws -> String {
    guard !graceNotes.notes.isEmpty
    else { throw ABCFormatter.Error.emptyGraceNotes }

    var result = "{"

    if graceNotes.isSlashed {
        result += "/"
    }

    result += graceNotes.notes.map { formatNote($0, unitNoteLength, meter) }.joined()

    result += "}"

    return result
}

private func _formatInstructionDirective(_ directive: ABCDirective) -> String {
    var result = directive.name

    if !directive.value.isEmpty {
        result += " "
        result += directive.value
    }

    return result
}

private func _formatKeySignature(_ keySignature: ABCKeySignature) -> String {
    switch keySignature {
    case let .clefOnly(clef):
        return _formatKeySignatureClef(clef)

    case .empty:
        return "none"

    case .highlandPipes:
        return "HP"

    case .highlandPipesPreset:
        return "Hp"

    case let .standard(std):
        var result = _formatKeySignatureTonic(std.tonic)

        let modeSuffix = _formatKeySignatureMode(std.mode)

        if !modeSuffix.isEmpty {
            result.append(" ")
            result.append(modeSuffix)
        }

        for pitch in std.extraAccidentals {
            result.append(" ")
            result.append(_formatKeySignatureAccidental(pitch.accidental))
            result.append(_formatPitchLetterOctave(pitch.letter, pitch.octave))
        }

        if let clef = std.clef {
            let clefStr = _formatKeySignatureClef(clef)

            if !clefStr.isEmpty {
                result.append(" ")
                result.append(clefStr)
            }
        }

        return result
    }
}

private func _formatKeySignatureAccidental(_ accidental: ABCPitch.Accidental) -> String {
    pitchAccidentals[accidental]?.key ?? ""
}

private func _formatKeySignatureClef(_ clef: ABCKeySignature.Clef) -> String {
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

private func _formatKeySignatureMode(_ mode: ABCKeySignature.Mode) -> String {
    keySignatureModes[mode] ?? ""
}

private func _formatKeySignatureTonic(_ tonic: ABCKeySignature.Tonic) -> String {
    keySignatureTonics[tonic] ?? ""
}

private func _formatMacro(_ macro: ABCMacro) -> String {
    "\(macro.trigger)=\(macro.replacement)"
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

private func _formatPitchLetterOctave(_ letter: ABCPitch.Letter,
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

private func _formatSymbolLine(_ symbolLine: ABCSymbolLine) -> String {
    symbolLine.elements.map { token in
        switch token {
        case let .annotation(annotation):
            _formatAnnotation(annotation)

        case let .chordSymbol(text):
            "\"\(text)\""

        case let .decoration(decoration):
            _formatDecoration(decoration, true)

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

private func _formatText(_ text: ABCText) -> String {
    escape(text.stringValue)
}

private func _formatTimeSignature(_ timeSignature: ABCTimeSignature) -> String {
    switch timeSignature {
    case .common:
        "C"

    case .cut:
        "C|"

    case .empty:
        "none"

    case let .standard(meter):
        "\(meter.numerator)/\(meter.denominator)"

    case let .complex(meter):
        "(\(meter.numerators.map { "\($0)" }.joined(separator: "+")))/\(meter.denominator)"
    }
}

private func _formatTuplet(_ tuplet: ABCTuplet) -> String {
    var result = "("

    result += "\(tuplet.noteCount)"

    if let qCount = tuplet.beatCount {
        result += ":"
        result += "\(qCount)"

        if let rCount = tuplet.affectedCount {
            result += ":"
            result += "\(rCount)"
        }
    }

    return result
}

private func _formatVariantEnding(_ variantEnding: ABCVariantEnding) -> String {
    var result = "["

    result += variantEnding.endings.map { range in
        range.lowerBound == range.upperBound
        ? "\(range.lowerBound)"
        : "\(range.lowerBound)-\(range.upperBound)"
    }.joined(separator: ",")

    return result
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
