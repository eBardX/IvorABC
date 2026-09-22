// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Type Aliases

internal typealias ParseNoteResult = (pitch: ParsePitchResult, length: ABCLength?, tie: ABCTie?)
internal typealias ParsePitchResult = (letter: ABCPitch.Letter, accidental: ABCPitch.Accidental, octave: ABCPitch.Octave)
internal typealias ParseRestResult = (kind: String, length: ABCLength?)

// A pitch letter's natural octave (upper-case A–G is octave 4, lower-case a–g is octave 5).
internal typealias PitchLetterResult = (letter: ABCPitch.Letter, octave: Int)

// MARK: Internal Constants

// A pitch letter's natural octave and canonical upper/lower-case forms, shared
// with clef middle-pitch parsing (`K:`/`V:` fields).
internal let pitchLetterOctaves: [Substring: PitchLetterResult] = ["A": (.a, 4),
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

// MARK: Internal Functions

internal func parseAlignedWords(_ tidyInput: Substring) -> ABCAlignedWords {
    var segments: [ABCAlignedWords.Segment] = []
    var input = tidyInput
    var currentText = ""

    func appendSegment(_ segment: ABCAlignedWords.Segment) {
        flushText()

        segments.append(segment)
    }

    func flushText() {
        guard !currentText.isEmpty
        else { return }

        segments.append(.syllable(ABCAlignedWords.Segment.Syllable(currentText)))

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

    return ABCAlignedWords(segments: segments)
}

internal func parseNote(_ tidyInput: Substring) -> ParseNoteResult? {
    let isDottedTie = tidyInput.hasSuffix(".-")
    let isRegularTie = !isDottedTie && tidyInput.hasSuffix("-")
    let tie: ABCTie? = isDottedTie ? .dotted : (isRegularTie ? .regular : nil)
    let input = tidyInput.dropLast(isDottedTie ? 2 : (isRegularTie ? 1 : 0))

    let result = input.splitBeforeFirst(lengthCS)

    guard let pitch = parsePitch(result.head)
    else { return nil }

    let length: ABCLength?

    if let tail = result.tail {
        guard let len = parseLength(tail)
        else { return nil }

        length = len
    } else {
        length = nil
    }

    return (pitch, length, tie)
}

internal func parsePitch(_ tidyInput: Substring) -> ParsePitchResult? {
    guard !tidyInput.isEmpty
    else { return nil }

    let result1 = tidyInput.splitBeforeFirst(octaveCS)
    let result2 = result1.head.splitBeforeFirst(pitchLetterCS)

    guard let plLetter = result2.tail,
          let plResult = pitchLetterOctaves[plLetter]
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

    guard octave >= 0,
          let octaveValue = ABCPitch.Octave(uintValue: UInt(octave))
    else { return nil }

    return (plResult.letter, accidental, octaveValue)
}

internal func parseRest(_ tidyInput: Substring) -> ParseRestResult? {
    let result = tidyInput.splitBeforeFirst(lengthCS)

    guard result.head.count == 1,
          let restLetter = result.head.first,
          restLetterCS.contains(restLetter)
    else { return nil }

    let length: ABCLength?

    if let tail = result.tail {
        if restLetter.isUppercase {
            guard let cnt = UInt(tail)
            else { return nil }

            length = ABCLength(numerator: cnt,
                               denominator: 1)
        } else {
            guard let len = parseLength(tail)
            else { return nil }

            length = len
        }
    } else {
        length = nil
    }

    return (String(restLetter), length)
}

// MARK: Private Constants

private let lengthCS: Set<Character>      = ["/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
private let octaveCS: Set<Character>      = [",", "'"]

private let pitchAccidentals: [Substring: ABCPitch.Accidental] = ["_": .flat,
                                                                  "__": .doubleFlat,
                                                                  "^": .sharp,
                                                                  "^^": .doubleSharp,
                                                                  "=": .natural]

private let pitchLetterCS: Set<Character> = ["A", "B", "C", "D", "E", "F", "G", "a", "b", "c", "d", "e", "f", "g"]
private let restLetterCS: Set<Character>  = ["X", "Z", "x", "z"]
