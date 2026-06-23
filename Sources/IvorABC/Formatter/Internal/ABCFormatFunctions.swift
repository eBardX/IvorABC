// © 2026 John Gary Pusey (see LICENSE.md)

// swiftlint:disable file_length

internal import Foundation

private import XestiTools

// MARK: Internal Functions

internal func formatField(_ field: ABCField) throws -> (String, String) {
    switch field {
    case let .wordsAligned(alignedLyrics):
        ("w", _formatAlignedWords(alignedLyrics))

    case let .area(text):
        ("A", _formatText(text))

    case let .book(text):
        ("B", _formatText(text))

    case let .composer(text):
        ("C", _formatText(text))

    case let .discography(text):
        ("D", _formatText(text))

    case let .fileURL(text):
        ("F", _formatText(text))

    case let .group(text):
        ("G", _formatText(text))

    case let .history(text):
        ("H", _formatText(text))

    case let .elemskip(elemskip):
        ("E", _formatElemskip(elemskip))

    case let .information(text):
        ("I", _formatText(text))

    case let .instruction(directive):
        ("I", _formatInstructionDirective(directive))

    case let .key(ABCKeySignature):
        ("K", _formatKeySignature(ABCKeySignature))

    case let .words(text):
        ("W", _formatText(text))

    case let .macro(macro):
        ("m", _formatMacro(macro))

    case let .meter(timeSignature):
        ("M", _formatTimeSignature(timeSignature))

    case let .notes(text):
        ("N", _formatText(text))

    case let .origin(text):
        ("O", _formatText(text))

    case let .part(part):
        ("P", formatPart(part))

    case let .parts(partSequence):
        ("P", _formatPartSequence(partSequence))

    case let .referenceNumber(referenceNumber):
        ("X", "\(referenceNumber.uintValue)")

    case let .remark(text):
        ("r", _formatText(text))

    case let .rhythm(text):
        ("R", _formatText(text))

    case let .source(text):
        ("S", _formatText(text))

    case let .symbolLine(symbolLine):
        ("s", _formatSymbolLine(symbolLine))

    case let .tempo(tempo):
        ("Q", _formatTempo(tempo))

    case let .tuneTitle(text):
        ("T", _formatText(text))

    case let .transcription(text):
        ("Z", _formatText(text))

    case let .unitNoteLength(duration):
        ("L", "\(duration.numerator)/\(duration.denominator)")

    case let .userDefined(userSymbol):
        ("U", _formatUserSymbol(userSymbol))

    case let .voice(voice):
        ("V", _formatVoice(voice))
    }
}

internal func formatPart(_ part: ABCPart) -> String {
    parts[part].require()
}

internal func formatSymbol(_ symbol: ABCSymbol,
                           _ unitNoteLength: ABCDuration?,
                           _ meter: ABCTimeSignature?) throws -> String {
    switch symbol {
    case let .annotation(annotation):
        _formatAnnotation(annotation)

    case let .barRepeat(barRepeat):
        _formatBarRepeat(barRepeat)

    case .beamBreak:
        preconditionFailure("beamBreak must be handled by the caller")

    case let .brokenRhythm(brokenRhythm):
        _formatBrokenRhythm(brokenRhythm)

    case let .chord(chord):
        _formatChord(chord, unitNoteLength, meter)

    case let .chordSymbol(chordSymbol):
        _formatChordSymbol(chordSymbol)

    case let .decoration(decoration):
        _formatDecoration(decoration)

    case let .graceNotes(graceNotes):
        _formatGraceNotes(graceNotes, unitNoteLength, meter)

    case let .inlineField(field):
        try _formatInlineField(field)

    case let .macroCall(macroCall):
        macroCall.trigger

    case let .note(note):
        _formatNote(note, unitNoteLength, meter)

    case .overlay:
        "&"

    case let .rest(rest):
        try _formatRest(rest, unitNoteLength, meter)

    case let .shorthand(shorthand):
        _formatShorthand(shorthand)

    case let .slur(slur):
        _formatSlur(slur)

    case let .spacer(duration):
        "y\(_formatDuration(duration, unitNoteLength, meter))"

    case let .tuplet(tuplet):
        _formatTuplet(tuplet)

    case let .variantEnding(variantEnding):
        _formatVariantEnding(variantEnding)
    }
}

// MARK: Private Constants

private let annotationPlacements: [ABCAnnotation.Placement: String] = [.above: "^",
                                                                       .auto: "@",
                                                                       .below: "_",
                                                                       .left: "<",
                                                                       .right: ">"]

private let barRepeatBarLines: [ABCBarRepeat.BarLine: String] = [.double: "||",
                                                                 .end: "|]",
                                                                 .invisible: "[|]",
                                                                 .standard: "|"]

private let brokenRhythms: [ABCBrokenRhythm: String] = [.dotted: ">",
                                                        .doubleDotted: ">>",
                                                        .reverseDotted: "<",
                                                        .reverseDoubleDotted: "<<",
                                                        .reverseTripleDotted: "<<<",
                                                        .tripleDotted: ">>>"]

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

private let parts: [ABCPart: String] = [.a: "A",
                                        .b: "B",
                                        .c: "C",
                                        .d: "D",
                                        .e: "E",
                                        .f: "F",
                                        .g: "G",
                                        .h: "H",
                                        .i: "I",
                                        .j: "J",
                                        .k: "K",
                                        .l: "L",
                                        .m: "M",
                                        .n: "N",
                                        .o: "O",
                                        .p: "P",
                                        .q: "Q",
                                        .r: "R",
                                        .s: "S",
                                        .t: "T",
                                        .u: "U",
                                        .v: "V",
                                        .w: "W",
                                        .x: "X",
                                        .y: "Y",
                                        .z: "Z"]

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

private let pitchNames: [ABCPitchName: String] = [.a: "A",
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

private let shorthands: [ABCShorthand: String] = [.dot: ".",
                                                  .hLower: "h",
                                                  .hUpper: "H",
                                                  .iLower: "i",
                                                  .iUpper: "I",
                                                  .jLower: "j",
                                                  .jUpper: "J",
                                                  .kLower: "k",
                                                  .kUpper: "K",
                                                  .lLower: "l",
                                                  .lUpper: "L",
                                                  .mLower: "m",
                                                  .mUpper: "M",
                                                  .nLower: "n",
                                                  .nUpper: "N",
                                                  .oLower: "o",
                                                  .oUpper: "O",
                                                  .pLower: "p",
                                                  .pUpper: "P",
                                                  .qLower: "q",
                                                  .qUpper: "Q",
                                                  .rLower: "r",
                                                  .rUpper: "R",
                                                  .sLower: "s",
                                                  .sUpper: "S",
                                                  .tilde: "~",
                                                  .tLower: "t",
                                                  .tUpper: "T",
                                                  .uLower: "u",
                                                  .uUpper: "U",
                                                  .vLower: "v",
                                                  .vUpper: "V",
                                                  .wLower: "w",
                                                  .wUpper: "W"]

private let slurs: [ABCSlur: String] = [.endDotted: ".)",
                                        .endRegular: ")",
                                        .startDotted: ".(",
                                        .startRegular: "("]

private let ties: [ABCTie: String] = [.dotted: ".-",
                                      .regular: "-"]

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

private func _formatAlignedWords(_ alignedLyrics: ABCAlignedWords) -> String {
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

        case .continuation:
            result.append("-")

            prevIsConnector = true

        case .hold:
            if needsSpace {
                result.append(" ")
            }

            result.append("_")

            prevIsConnector = false

        case .skip:
            if needsSpace {
                result.append(" ")
            }

            result.append("*")

            prevIsConnector = false

        case let .syllable(syllable):
            if needsSpace {
                result.append(" ")
            }

            result.append(escapeLyricsSyllable(syllable.stringValue))

            prevIsConnector = false
        }
    }

    return result
}

private func _formatAnnotation(_ annotation: ABCAnnotation) -> String {
    var result = "\""

    result += annotationPlacements[annotation.placement].require()

    result += escapeAnnotationText(annotation.text)

    result += "\""

    return result
}

private func _formatBarRepeat(_ barRepeat: ABCBarRepeat) -> String {
    var result = ""

    if barRepeat.isDotted {
        result += "."
    }

    switch barRepeat.barLine {
    case .repeat:
        switch (barRepeat.precedingPlayCount, barRepeat.followingPlayCount) {
        case let (1, fpCount):
            result += "|"
            result += String(repeating: ":",
                             count: Int(fpCount.uintValue) - 1)

        case let (ppCount, 1):
            result += String(repeating: ":",
                             count: Int(ppCount.uintValue) - 1)
            result += "|"

        case (2, 2):
            // Standard 2x/2x uses the compact `::` form.
            result += "::"

        case let (ppCount, fpCount):
            // Asymmetric or n-fold counts use explicit form so colon counts are
            // unambiguous.
            result += String(repeating: ":",
                             count:
                                Int(ppCount.uintValue) - 1)
            result += "|"
            result += String(repeating: ":",
                             count:
                                Int(fpCount.uintValue) - 1)
        }

    default:
        result += barRepeatBarLines[barRepeat.barLine].require()
    }

    return result
}

private func _formatBrokenRhythm(_ brokenRhythm: ABCBrokenRhythm) -> String {
    brokenRhythms[brokenRhythm].require()
}

private func _formatChord(_ chord: ABCChord,
                          _ unitNoteLength: ABCDuration?,
                          _ meter: ABCTimeSignature?) -> String {
    var result = "["

    result += chord.notes.map { _formatNote($0, unitNoteLength, meter) }.joined()

    result += "]"

    result += _formatDuration(chord.duration,
                              unitNoteLength,
                              meter)
    if let tie = chord.tie {
        result += ties[tie].require()
    }

    return result
}

private func _formatChordSymbol(_ chordSymbol: ABCChordSymbol) -> String {
    var result = "\""

    result += pitchNames[chordSymbol.name.root].require()

    if let kind = chordSymbol.name.kind {
        result += kind
    }

    if let bass = chordSymbol.bass {
        result += "/" + pitchNames[bass].require()
    }

    if let parenthesized = chordSymbol.parenthesized {
        result += "(" + pitchNames[parenthesized.root].require()

        if let kind = parenthesized.kind {
            result += kind
        }

        result += ")"
    }

    result += "\""

    return result
}

private func _formatClef(_ clef: ABCClef) -> String {
    var segments: [String] = []

    if let name = clef.name {
        var segment = "clef=\(name)"

        if clef.line != ABCClef.defaultLine(for: clef.name) {
            segment += "\(clef.line)"
        }

        if let ottava = clef.ottava {
            segment += ottava == .alta ? "+8" : "-8"
        }

        segments.append(segment)
    }

    if let middle = clef.middle {
        segments.append("middle=\(_formatPitchLetterOctave(middle.letter, middle.octave))")
    }

    if clef.transpose != 0 {
        segments.append("transpose=\(clef.transpose)")
    }

    if clef.octave != 0 {
        segments.append("octave=\(clef.octave)")
    }

    if clef.stafflines != 5 {
        segments.append("stafflines=\(clef.stafflines)")
    }

    return segments.joined(separator: " ")
}

private func _formatDecoration(_ decoration: ABCDecoration) -> String {
    if decoration.dialect == .plus {
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
                          count: _uintLog2(rd))
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
                               _ meter: ABCTimeSignature?) -> String {
    var result = "{"

    if graceNotes.isSlashed {
        result += "/"
    }

    result += graceNotes.notes.map { _formatNote($0, unitNoteLength, meter) }.joined()

    result += "}"

    return result
}

private func _formatInlineField(_ field: ABCField) throws -> String {
    let (letter, value) = try formatField(field)

    return "[\(letter):\(value)]"
}

private func _formatInstructionDirective(_ directive: ABCDirective) -> String {
    var result = directive.name.stringValue

    if !directive.value.isEmpty {
        result += " "
        result += directive.value
    }

    return result
}

private func _formatKeySignature(_ keySignature: ABCKeySignature) -> String {
    switch keySignature {
    case let .clefOnly(clef):
        return _formatClef(clef)

    case .empty:
        return "none"

    case .highlandPipes:
        return "HP"

    case .highlandPipesPreset:
        return "Hp"

    case let .standard(standard):
        var result = pitchNames[standard.tonic].require()

        if let modeSuffix = keySignatureModes[standard.mode] {
            result.append(" ")
            result.append(modeSuffix)
        }

        for pitch in standard.extraAccidentals {
            result.append(" ")

            if let keyAccidental = pitchAccidentals[pitch.accidental]?.key {
                result.append(keyAccidental)
            }

            result.append(_formatPitchLetterOctave(pitch.letter, pitch.octave))
        }

        if let clef = standard.clef {
            let clefStr = _formatClef(clef)

            if !clefStr.isEmpty {
                result.append(" ")
                result.append(clefStr)
            }
        }

        return result
    }
}

private func _formatMacro(_ macro: ABCMacro) -> String {
    "\(macro.trigger)=\(macro.replacement)"
}

private func _formatNote(_ note: ABCNote,
                         _ unitNoteLength: ABCDuration?,
                         _ meter: ABCTimeSignature?) -> String {
    var result = pitchAccidentals[note.pitch.accidental]?.note ?? ""

    result += _formatPitchLetterOctave(note.pitch.letter,
                                       note.pitch.octave)

    result += _formatDuration(note.duration,
                              unitNoteLength,
                              meter)

    if let tie = note.tie {
        result += ties[tie].require()
    }

    return result
}

private func _formatPartItems(_ items: [ABCPartSequence.Item]) -> String {
    items.map { item in
        switch item {
        case let .group(children, count):
            var result = "("

            result += _formatPartItems(children)
            result += ")"

            if count > 1 {
                result += String(count.uintValue)
            }

            return result

        case let .part(part, count):
            var result = formatPart(part)

            if count > 1 {
                result += String(count.uintValue)
            }

            return result
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

    let octaveInt = Int(octave.uintValue)

    if octaveInt <= 4 {
        return upper + String(repeating: ",",
                              count: 4 - octaveInt)
    } else {
        return lower + String(repeating: "'",
                              count: octaveInt - 5)
    }
}

private func _formatRest(_ rest: ABCRest,
                         _ unitNoteLength: ABCDuration?,
                         _ meter: ABCTimeSignature?) throws -> String {
    switch rest {
    case let .multiMeasure(invisible, measureCount):
        let letter = invisible ? "X" : "Z"

        return measureCount == 1 ? letter : "\(letter)\(measureCount)"

    case let .regular(invisible, duration):
        let letter = invisible ? "x" : "z"

        return "\(letter)\(_formatDuration(duration, unitNoteLength, meter))"
    }
}

private func _formatShorthand(_ shorthand: ABCShorthand) -> String {
    shorthands[shorthand].require()
}

private func _formatSlur(_ slur: ABCSlur) -> String {
    slurs[slur].require()
}

private func _formatSymbolLine(_ symbolLine: ABCSymbolLine) -> String {
    symbolLine.elements.map { token in
        switch token {
        case let .annotation(annotation):
            _formatAnnotation(annotation)

        case let .chordSymbol(chordSymbol):
            _formatChordSymbol(chordSymbol)

        case let .decoration(decoration):
            _formatDecoration(decoration)

        case .skip:
            "*"
        }
    }.joined(separator: " ")
}

private func _formatTempo(_ tempo: ABCTempo) -> String {
    var segments: [String] = []

    if let text = tempo.text {
        segments.append("\"\(text)\"")
    }

    if !tempo.durations.isEmpty {
        let durStr = tempo.durations.map { "\($0.numerator)/\($0.denominator)" }.joined(separator: " ")

        if let rate = tempo.rate {
            segments.append("\(durStr)=\(rate)")
        } else {
            segments.append(durStr)
        }
    } else if let rate = tempo.rate {
        segments.append("\(rate)")
    }

    return segments.joined(separator: " ")
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

private func _formatUserSymbol(_ userSymbol: ABCUserSymbol) -> String {
    var result = _formatShorthand(userSymbol.shorthand)

    result += "="

    switch userSymbol.definition {
    case let .annotation(annotation):
        result += _formatAnnotation(annotation)

    case let .decoration(decoration):
        result += _formatDecoration(decoration)
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
    var segments = [voice.id.stringValue]

    if let clef = voice.clef {
        let clefStr = _formatClef(clef)

        if !clefStr.isEmpty {
            segments.append(clefStr)
        }
    }

    for key in voice.properties.keys.sorted() {
        guard let value = voice.properties[key]
        else { continue }

        if value.contains(where: { $0.isWhitespace }) {
            segments.append("\(key)=\"\(value)\"")
        } else {
            segments.append("\(key)=\(value)")
        }
    }

    return segments.joined(separator: " ")
}

private func _uintLog2(_ uintValue: UInt) -> Int {
    var value = uintValue
    var result = 0

    while value > 1 {
        value >>= 1
        result += 1
    }

    return result
}
