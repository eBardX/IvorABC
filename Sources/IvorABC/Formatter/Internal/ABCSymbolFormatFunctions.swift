// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Functions

internal func formatAnnotation(_ annotation: ABCAnnotation) -> String {
    var result = "\""

    switch annotation.placement {
    case .above:
        result += "^"

    case .auto:
        result += "@"

    case .below:
        result += "_"

    case .left:
        result += "<"

    case .right:
        result += ">"
    }

    result += escapeAnnotationText(annotation.text)

    result += "\""

    return result
}

internal func formatBarLine(_ barLine: ABCBarLine) -> String {
    var result = ""

    if barLine.isDotted {
        result += "."
    }

    switch barLine.kind {
    case .double:
        result += "||"

    case .end:
        result += "|]"

    case .invisible:
        result += "[|]"

    case .repeat:
        switch (barLine.precedingPlayCount, barLine.followingPlayCount) {
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

    case .standard:
        result += "|"
    }

    return result
}

internal func formatBrokenRhythm(_ brokenRhythm: ABCBrokenRhythm) -> String {
    switch brokenRhythm {
    case .dotted:
        ">"

    case .doubleDotted:
        ">>"

    case .reverseDotted:
        "<"

    case .reverseDoubleDotted:
        "<<"

    case .reverseTripleDotted:
        "<<<"

    case .tripleDotted:
        ">>>"
    }
}

internal func formatChord(_ chord: ABCChord) -> String {
    var result = "["

    result += chord.notes.map { formatNote($0) }.joined()

    result += "]"

    result += formatLength(chord.length)

    if let tie = chord.tie {
        result += formatTie(tie)
    }

    return result
}

internal func formatChordSymbol(_ chordSymbol: ABCChordSymbol) -> String {
    var result = "\""

    result += formatPitchName(chordSymbol.name.root)

    if let kind = chordSymbol.name.kind {
        result += kind
    }

    if let bass = chordSymbol.bass {
        result += "/" + formatPitchName(bass)
    }

    if let parenthesized = chordSymbol.parenthesized {
        result += "(" + formatPitchName(parenthesized.root)

        if let kind = parenthesized.kind {
            result += kind
        }

        result += ")"
    }

    result += "\""

    return result
}

internal func formatDecoration(_ decoration: ABCDecoration) -> String {
    if decoration.dialect == .plus {
        "+\(decoration.name)+"
    } else {
        "!\(decoration.name)!"
    }
}

internal func formatGraceNotes(_ graceNotes: ABCGraceNotes) -> String {
    var result = "{"

    if graceNotes.isSlashed {
        result += "/"
    }

    result += graceNotes.notes.map { formatNote($0) }.joined()

    result += "}"

    return result
}

internal func formatInlineField(_ field: ABCField) -> String {
    let (letter, value) = formatField(field)

    return "[\(letter):\(value)]"
}

// Formats a written length (a multiplier of the unit note length) directly.
// The AST stores note/rest/chord/spacer lengths as written; resolution against
// `L:`/`M:` is the resolver's job. See ``ABCNote/length``.
internal func formatLength(_ length: ABCLength) -> String {
    _formatLengthComponents(length.numerator, length.denominator)
}

internal func formatNote(_ note: ABCNote) -> String {
    var result = formatPitchAccidentalNoteGlyph(note.pitch.accidental)

    result += formatPitchLetterOctave(note.pitch.letter,
                                      note.pitch.octave)

    result += formatLength(note.length)

    if let tie = note.tie {
        result += formatTie(tie)
    }

    return result
}

internal func formatPitchAccidentalKeyGlyph(_ accidental: ABCPitch.Accidental) -> String? {
    switch accidental {
    case .doubleFlat:
        "__"

    case .doubleSharp:
        "^^"

    case .flat:
        "_"

    case .natural:
        "="

    case .omitted:
        nil

    case .sharp:
        "^"
    }
}

internal func formatPitchAccidentalNoteGlyph(_ accidental: ABCPitch.Accidental) -> String {
    switch accidental {
    case .doubleFlat:
        "__"

    case .doubleSharp:
        "^^"

    case .flat:
        "_"

    case .natural:
        ""

    case .omitted:
        ""

    case .sharp:
        "^"
    }
}

internal func formatPitchLetterOctave(_ letter: ABCPitch.Letter,
                                      _ octave: ABCPitch.Octave) -> String {
    let (upper, lower) = switch letter {
    case .a:
        ("A", "a")

    case .b:
        ("B", "b")

    case .c:
        ("C", "c")

    case .d:
        ("D", "d")

    case .e:
        ("E", "e")

    case .f:
        ("F", "f")

    case .g:
        ("G", "g")
    }

    let octaveInt = Int(octave.uintValue)

    if octaveInt <= 4 {
        return upper + String(repeating: ",",
                              count: 4 - octaveInt)
    } else {
        return lower + String(repeating: "'",
                              count: octaveInt - 5)
    }
}

internal func formatPitchName(_ name: ABCPitchName) -> String {
    switch name {
    case .a:
        "A"

    case .aFlat:
        "Ab"

    case .aSharp:
        "A#"

    case .b:
        "B"

    case .bFlat:
        "Bb"

    case .bSharp:
        "B#"

    case .c:
        "C"

    case .cFlat:
        "Cb"

    case .cSharp:
        "C#"

    case .d:
        "D"

    case .dFlat:
        "Db"

    case .dSharp:
        "D#"

    case .e:
        "E"

    case .eFlat:
        "Eb"

    case .eSharp:
        "E#"

    case .f:
        "F"

    case .fFlat:
        "Fb"

    case .fSharp:
        "F#"

    case .g:
        "G"

    case .gFlat:
        "Gb"

    case .gSharp:
        "G#"
    }
}

internal func formatRest(_ rest: ABCRest) -> String {
    switch rest {
    case let .multiMeasure(invisible, measureCount):
        let letter = invisible ? "X" : "Z"

        return measureCount == 1 ? letter : "\(letter)\(measureCount)"

    case let .regular(invisible, length):
        let letter = invisible ? "x" : "z"

        return "\(letter)\(formatLength(length))"
    }
}

internal func formatShorthand(_ shorthand: ABCShorthand) -> String {
    switch shorthand {
    case .dot:
        "."

    case .hLower:
        "h"

    case .hUpper:
        "H"

    case .iLower:
        "i"

    case .iUpper:
        "I"

    case .jLower:
        "j"

    case .jUpper:
        "J"

    case .kLower:
        "k"

    case .kUpper:
        "K"

    case .lLower:
        "l"

    case .lUpper:
        "L"

    case .mLower:
        "m"

    case .mUpper:
        "M"

    case .nLower:
        "n"

    case .nUpper:
        "N"

    case .oLower:
        "o"

    case .oUpper:
        "O"

    case .pLower:
        "p"

    case .pUpper:
        "P"

    case .qLower:
        "q"

    case .qUpper:
        "Q"

    case .rLower:
        "r"

    case .rUpper:
        "R"

    case .sLower:
        "s"

    case .sUpper:
        "S"

    case .tilde:
        "~"

    case .tLower:
        "t"

    case .tUpper:
        "T"

    case .uLower:
        "u"

    case .uUpper:
        "U"

    case .vLower:
        "v"

    case .vUpper:
        "V"

    case .wLower:
        "w"

    case .wUpper:
        "W"
    }
}

internal func formatSlur(_ slur: ABCSlur) -> String {
    switch slur {
    case .endDotted:
        ".)"

    case .endRegular:
        ")"

    case .startDotted:
        ".("

    case .startRegular:
        "("
    }
}

internal func formatSymbolLine(_ symbolLine: ABCSymbolLine) -> String {
    symbolLine.elements.map { token in
        switch token {
        case let .annotation(annotation):
            formatAnnotation(annotation)

        case let .chordSymbol(chordSymbol):
            formatChordSymbol(chordSymbol)

        case let .decoration(decoration):
            formatDecoration(decoration)

        case .skip:
            "*"
        }
    }.joined(separator: " ")
}

internal func formatTie(_ tie: ABCTie) -> String {
    switch tie {
    case .dotted:
        ".-"

    case .regular:
        "-"
    }
}

internal func formatTuplet(_ tuplet: ABCTuplet) -> String {
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

internal func formatVariantEnding(_ variantEnding: ABCVariantEnding) -> String {
    var result = "["

    result += variantEnding.endings.map { range in
        range.lowerBound == range.upperBound
        ? "\(range.lowerBound)"
        : "\(range.lowerBound)-\(range.upperBound)"
    }.joined(separator: ",")

    return result
}

// MARK: Private Functions

private func _formatLengthComponents(_ numerator: UInt,
                                     _ denominator: UInt) -> String {
    if numerator == 1,
       denominator == 1 {
        return ""
    }

    if denominator == 1 {
        return "\(numerator)"
    }

    if numerator == 1 {
        if denominator.isPowerOf2 {
            return String(repeating: "/",
                          count: _uintLog2(denominator))
        } else {
            return "/\(denominator)"
        }
    }

    return "\(numerator)/\(denominator)"
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
