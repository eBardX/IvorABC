// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Functions

// swiftlint:disable:next cyclomatic_complexity
internal func parseField(_ tidyInput: Substring) throws(ABCParser.Error) -> ABCField {
    let (ntext, vtext, isInline) = try _splitField(tidyInput)

    switch ntext {
    case "A" where !isInline:
        return try .area(parseText(vtext))

    case "B" where !isInline:
        return try .book(parseText(vtext))

    case "C" where !isInline:
        return try .composer(parseText(vtext))

    case "D" where !isInline:
        return try .discography(parseText(vtext))

    case "F" where !isInline:
        return try .fileURL(parseText(vtext))

    case "G" where !isInline:
        return try .group(parseText(vtext))

    case "H" where !isInline:
        return try .history(parseText(vtext))

    case "I":
        guard let dir = _parseInstruction(vtext)
        else { throw ABCParser.Error.invalidField(isInline, tidyInput) }

        return .instruction(dir)

    case "K":
        guard let ks = parseKeySignature(vtext)
        else { throw ABCParser.Error.invalidKeySignature(vtext) }

        return .key(ks)

    case "L":
        guard let unl = parseUnitNoteLength(vtext)
        else { throw ABCParser.Error.invalidUnitNoteLength(vtext) }

        return .unitNoteLength(unl)

    case "M":
        guard let ts = parseTimeSignature(vtext)
        else { throw ABCParser.Error.invalidTimeSignature(vtext) }

        return .meter(ts)

    case "m":
        guard let macro = parseMacro(vtext)
        else { throw ABCParser.Error.invalidMacro(vtext) }

        return .macro(macro)

    case "N":
        return try .notes(parseText(vtext))

    case "O" where !isInline:
        return try .origin(parseText(vtext))

    case "P":
        guard let ps = parsePartSequence(vtext)
        else { throw ABCParser.Error.invalidPartSequence(vtext) }

        return .parts(ps)

    case "Q":
        guard let tempo = parseTempo(vtext)
        else { throw ABCParser.Error.invalidTempo(vtext) }

        return .tempo(tempo)

    case "R":
        return try .rhythm(parseText(vtext))

    case "r":
        return try .remark(parseText(vtext))

    case "S" where !isInline:
        return try .source(parseText(vtext))

    case "s" where !isInline:
        guard let sl = parseSymbolLine(vtext)
        else { throw ABCParser.Error.invalidSymbolLine(vtext) }

        return .symbolLine(sl)

    case "T" where !isInline:
        return try .tuneTitle(parseText(vtext))

    case "U":
        guard let uds = parseUserSymbol(vtext)
        else { throw ABCParser.Error.invalidUserSymbol(vtext) }

        return .userDefined(uds)

    case "V":
        guard let voice = parseVoice(vtext)
        else { throw ABCParser.Error.invalidVoice(vtext) }

        return .voice(voice)

    case "W" where !isInline:
        return try .words(parseText(vtext))

    case "w" where !isInline:
        return .wordsAligned(parseAlignedWords(vtext))

    case "X" where !isInline:
        guard let rn = parseReferenceNumber(vtext)
        else { throw ABCParser.Error.invalidRefNumber(vtext) }

        return .referenceNumber(rn)

    case "Z" where !isInline:
        return try .transcription(parseText(vtext))

    default:
        break
    }

    throw ABCParser.Error.invalidField(isInline, tidyInput)
}

internal func parsePartSequence(_ tidyInput: Substring) -> ABCPartSequence? {
    guard !tidyInput.isEmpty
    else { return nil }

    var input = tidyInput

    guard let items = _parsePartItems(&input,
                                      terminator: nil)
    else { return nil }

    return ABCPartSequence(items: items)
}

internal func parseUnitNoteLength(_ tidyInput: Substring) -> ABCLength? {
    guard let length = parseExplicitLength(tidyInput),
          length.numerator > 0,
          [1, 2, 4, 8, 16, 32, 64, 128, 256, 512].contains(length.denominator)
    else { return nil }

    return length
}

internal func parseUserSymbol(_ tidyInput: Substring) -> ABCUserSymbol? {
    guard let first = tidyInput.first,
          let shorthand = parseShorthand(Substring(String(first)))
    else { return nil }

    let rest = trimPrefix(tidyInput.dropFirst())

    guard rest.hasPrefix("=")
    else { return nil }

    let raw = String(trim(rest.dropFirst()))

    guard !raw.isEmpty
    else { return nil }

    if ["!nil!", "!none!", "+nil+", "+none+"].contains(raw) {
        return ABCUserSymbol(shorthand: shorthand,
                             definition: nil)
    }

    let definition: ABCUserSymbol.Definition? = if raw.first == "\"" {
        parseAnnotation(Substring(raw)).map { .annotation($0) }
    } else if raw.count >= 2, raw.first == "!", raw.last == "!" {
        ABCDecoration.Name(stringValue: String(raw.dropFirst().dropLast()))
            .flatMap { ABCDecoration(name: $0) }
            .map { .decoration($0) }
    } else if raw.count >= 2, raw.first == "+", raw.last == "+" {
        ABCDecoration.Name(stringValue: String(raw.dropFirst().dropLast()))
            .flatMap { ABCDecoration(name: $0, dialect: .plus) }
            .map { .decoration($0) }
    } else {
        ABCDecoration.Name(stringValue: raw)
            .flatMap { ABCDecoration(name: $0) }
            .map { .decoration($0) }
    }

    guard let definition
    else { return nil }

    return ABCUserSymbol(shorthand: shorthand,
                         definition: definition)
}

// MARK: Private Constants

private let parts: [Character: ABCPart] = ["A": .a,
                                           "B": .b,
                                           "C": .c,
                                           "D": .d,
                                           "E": .e,
                                           "F": .f,
                                           "G": .g,
                                           "H": .h,
                                           "I": .i,
                                           "J": .j,
                                           "K": .k,
                                           "L": .l,
                                           "M": .m,
                                           "N": .n,
                                           "O": .o,
                                           "P": .p,
                                           "Q": .q,
                                           "R": .r,
                                           "S": .s,
                                           "T": .t,
                                           "U": .u,
                                           "V": .v,
                                           "W": .w,
                                           "X": .x,
                                           "Y": .y,
                                           "Z": .z]

// MARK: Private Functions

private func _parseInstruction(_ tidyInput: Substring) -> ABCDirective? {
    let result = tidyInput.splitBeforeFirst { $0.isABCWhitespace }

    guard let name = parseDirectiveName(result.head)
    else { return nil }

    let value = String(trimPrefix(result.tail ?? ""))

    return ABCDirective(name: name,
                        value: value)
}

private func _parsePartItemRepeatCount(_ input: inout Substring) -> ABCPartSequence.Item.RepeatCount {
    var digits = ""

    while let ch = input.first,
          ch.isABCDigit {
        digits.append(ch)

        input = input.dropFirst()
    }

    return UInt(digits).flatMap { ABCPartSequence.Item.RepeatCount(uintValue: $0) } ?? 1
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

            let repeatCount = _parsePartItemRepeatCount(&input)

            items.append(.group(groupItems, repeatCount))

        case "A"..."Z":
            guard let part = parts[ch]
            else { return nil }

            let repeatCount = _parsePartItemRepeatCount(&input)

            items.append(.part(part, repeatCount))

        default:
            return nil
        }
    }
}

private func _splitField(_ tidyInput: Substring) throws(ABCParser.Error) -> (Substring, Substring, Bool) {
    var input = tidyInput

    let isInline: Bool

    if input.first == "[" {
        isInline = true

        guard input.last == "]"
        else { throw ABCParser.Error.invalidField(isInline, tidyInput) }

        input = input.dropFirst().dropLast()
    } else {
        isInline = false
    }

    precondition(input.dropFirst().first == ":")

    let result = input.splitBeforeFirst([":"])

    guard let tail = result.tail
    else { throw ABCParser.Error.invalidField(isInline, tidyInput) }

    let name = result.head
    let value = trim(tail.dropFirst())

    return (name, value, isInline)
}
