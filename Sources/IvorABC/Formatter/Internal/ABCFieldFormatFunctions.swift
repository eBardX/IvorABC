// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Functions

internal func formatAlignedWords(_ alignedLyrics: ABCAlignedWords) -> String {
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

internal func formatElemskip(_ elemskip: ABCElemskip) -> String {
    switch elemskip {
    case let .decimal(doubleValue):
        String(doubleValue)

    case let .integer(intValue):
        String(intValue)
    }
}

internal func formatInstructionDirective(_ directive: ABCDirective) -> String {
    var result = directive.name.stringValue

    if !directive.value.isEmpty {
        result += " "
        result += directive.value
    }

    return result
}

internal func formatKeySignature(_ keySignature: ABCKeySignature) -> String {
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
        var result = formatPitchName(standard.tonic)

        result.append(" ")
        result.append(_formatKeySignatureMode(standard.mode))

        for pitch in standard.extraAccidentals {
            result.append(" ")

            if let keyAccidental = formatPitchAccidentalKeyGlyph(pitch.accidental) {
                result.append(keyAccidental)
            }

            result.append(formatPitchLetterOctave(pitch.letter, pitch.octave))
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

internal func formatMacro(_ macro: ABCMacro) -> String {
    "\(macro.target)=\(macro.replacement)"
}

internal func formatPartSequence(_ partSequence: ABCPartSequence) -> String {
    _formatPartItems(partSequence.items)
}

internal func formatTempo(_ tempo: ABCTempo) -> String {
    var segments: [String] = []

    if let text = tempo.text {
        segments.append("\"\(text)\"")
    }

    if !tempo.lengths.isEmpty {
        let durStr = tempo.lengths.map { "\($0.numerator)/\($0.denominator)" }.joined(separator: " ")

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

internal func formatText(_ text: ABCText) -> String {
    escape(text.stringValue)
}

internal func formatTimeSignature(_ timeSignature: ABCTimeSignature) -> String {
    switch timeSignature {
    case .common:
        "C"

    case let .complex(meter):
        "(\(meter.numerators.map { "\($0)" }.joined(separator: "+")))/\(meter.denominator)"

    case .cut:
        "C|"

    case .empty:
        "none"

    case let .standard(meter):
        "\(meter.numerator)/\(meter.denominator)"
    }
}

internal func formatUserSymbol(_ userSymbol: ABCUserSymbol) -> String {
    var result = formatShorthand(userSymbol.shorthand)

    result += "="

    switch userSymbol.definition {
    case nil:
        result += "!nil!"

    case let .annotation(annotation)?:
        result += formatAnnotation(annotation)

    case let .decoration(decoration)?:
        result += formatDecoration(decoration)
    }

    return result
}

internal func formatVoice(_ voice: ABCVoice) -> String {
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

// MARK: Private Functions

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
        segments.append("middle=\(formatPitchLetterOctave(middle.letter, middle.octave))")
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

private func _formatKeySignatureMode(_ mode: ABCKeySignature.Mode) -> String {
    switch mode {
    case .aeolian:
        "aeolian"

    case .dorian:
        "dorian"

    case .explicit:
        "explicit"

    case .ionian:
        "ionian"

    case .locrian:
        "locrian"

    case .lydian:
        "lydian"

    case .major:
        "major"

    case .minor:
        "minor"

    case .mixolydian:
        "mixolydian"

    case .phrygian:
        "phrygian"
    }
}

private func _formatPartItems(_ items: [ABCPartSequence.Item]) -> String {
    items.map { item in
        switch item {
        case let .group(children, repeatCount):
            var result = "("

            result += _formatPartItems(children)
            result += ")"

            if repeatCount > 1 {
                result += String(repeatCount.uintValue)
            }

            return result

        case let .part(part, repeatCount):
            var result = formatPart(part)

            if repeatCount > 1 {
                result += String(repeatCount.uintValue)
            }

            return result
        }
    }.joined()
}
