// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Functions

internal func formatField(_ field: ABCField) -> (String, String) {
    switch field {
    case let .area(text):
        ("A", formatText(text))

    case let .book(text):
        ("B", formatText(text))

    case let .composer(text):
        ("C", formatText(text))

    case let .discography(text):
        ("D", formatText(text))

    case let .elemskip(elemskip):
        ("E", formatElemskip(elemskip))

    case let .fileURL(text):
        ("F", formatText(text))

    case let .group(text):
        ("G", formatText(text))

    case let .history(text):
        ("H", formatText(text))

    case let .information(text):
        ("I", formatText(text))

    case let .instruction(directive):
        ("I", formatInstructionDirective(directive))

    case let .key(ABCKeySignature):
        ("K", formatKeySignature(ABCKeySignature))

    case let .macro(macro):
        ("m", formatMacro(macro))

    case let .meter(timeSignature):
        ("M", formatTimeSignature(timeSignature))

    case let .notes(text):
        ("N", formatText(text))

    case let .origin(text):
        ("O", formatText(text))

    case let .part(part):
        ("P", formatPart(part))

    case let .parts(partSequence):
        ("P", formatPartSequence(partSequence))

    case let .referenceNumber(referenceNumber):
        ("X", "\(referenceNumber.uintValue)")

    case let .remark(text):
        ("r", formatText(text))

    case let .rhythm(text):
        ("R", formatText(text))

    case let .source(text):
        ("S", formatText(text))

    case let .symbolLine(symbolLine):
        ("s", formatSymbolLine(symbolLine))

    case let .tempo(tempo):
        ("Q", formatTempo(tempo))

    case let .transcription(text):
        ("Z", formatText(text))

    case let .tuneTitle(text):
        ("T", formatText(text))

    case let .unitNoteLength(length):
        ("L", "\(length.numerator)/\(length.denominator)")

    case let .userDefined(userSymbol):
        ("U", formatUserSymbol(userSymbol))

    case let .voice(voice):
        ("V", formatVoice(voice))

    case let .words(text):
        ("W", formatText(text))

    case let .wordsAligned(alignedLyrics):
        ("w", formatAlignedWords(alignedLyrics))
    }
}

internal func formatPart(_ part: ABCPart) -> String {
    switch part {
    case .a:
        "A"

    case .b:
        "B"

    case .c:
        "C"

    case .d:
        "D"

    case .e:
        "E"

    case .f:
        "F"

    case .g:
        "G"

    case .h:
        "H"

    case .i:
        "I"

    case .j:
        "J"

    case .k:
        "K"

    case .l:
        "L"

    case .m:
        "M"

    case .n:
        "N"

    case .o:
        "O"

    case .p:
        "P"

    case .q:
        "Q"

    case .r:
        "R"

    case .s:
        "S"

    case .t:
        "T"

    case .u:
        "U"

    case .v:
        "V"

    case .w:
        "W"

    case .x:
        "X"

    case .y:
        "Y"

    case .z:
        "Z"
    }
}

internal func formatSymbol(_ symbol: ABCSymbol) -> String {
    switch symbol {
    case let .annotation(annotation):
        formatAnnotation(annotation)

    case let .barLine(barLine):
        formatBarLine(barLine)

    case .beamBreak:
        preconditionFailure("beamBreak must be handled by the caller")

    case let .brokenRhythm(brokenRhythm):
        formatBrokenRhythm(brokenRhythm)

    case let .chord(chord):
        formatChord(chord)

    case let .chordSymbol(chordSymbol):
        formatChordSymbol(chordSymbol)

    case let .decoration(decoration):
        formatDecoration(decoration)

    case let .graceNotes(graceNotes):
        formatGraceNotes(graceNotes)

    case let .inlineField(field):
        formatInlineField(field)

    case let .note(note):
        formatNote(note)

    case .overlay:
        "&"

    case let .rest(rest):
        formatRest(rest)

    case let .shorthand(shorthand):
        formatShorthand(shorthand)

    case let .slur(slur):
        formatSlur(slur)

    case let .spacer(length):
        "y\(formatLength(length))"

    case let .tuplet(tuplet):
        formatTuplet(tuplet)

    case let .variantEnding(variantEnding):
        formatVariantEnding(variantEnding)
    }
}
