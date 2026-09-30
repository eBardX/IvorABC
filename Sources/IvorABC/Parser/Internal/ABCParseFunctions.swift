// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Type Aliases

internal typealias ParseTupletResult = (pcount: UInt, qcount: UInt?, rcount: UInt?)

// MARK: Internal Functions

internal func normalize(_ input: Substring) -> String {
    unescape(String(input).normalizedABCWhitespace())
}

internal func parseBrokenRhythm(_ tidyInput: Substring) -> ABCBrokenRhythm? {
    brokenRhythms[tidyInput]
}

internal func parseDirectiveName(_ tidyInput: Substring) -> ABCDirective.Name? {
    ABCDirective.Name(stringValue: String(tidyInput))
}

internal func parseElemskip(_ tidyInput: Substring) -> ABCElemskip? {
    let stringValue = normalize(tidyInput)

    // Try Int first — Double("3") also succeeds, which would misclassify
    // whole numbers as decimal.
    if let intValue = Int(stringValue) {
        return .integer(intValue)
    }

    if let doubleValue = Double(stringValue) {
        return .decimal(doubleValue)
    }

    return nil
}

internal func parseLength(_ tidyInput: Substring) -> ABCLength? {
    guard !tidyInput.isEmpty
    else { return nil }

    //
    // <decUInteger>? "/" ( <decUInteger>? | "/"{2,6} )
    //
    let result = tidyInput.splitBeforeFirst("/")

    var denominator: UInt = 1
    var numerator: UInt = 1

    if !result.head.isEmpty {
        guard let numer = UInt(result.head)
        else { return nil }

        numerator = numer
    }

    if var tail = result.tail {
        while tail.hasPrefix("/") {
            denominator *= 2
            tail = tail.dropFirst()
        }

        if !tail.isEmpty {
            guard denominator == 2,         // i.e. only one "/" seen
                  let denom = UInt(tail)
            else { return nil }

            denominator = denom
        }
    }

    return ABCLength(numerator: numerator,
                     denominator: denominator)
}

internal func parseMacro(_ tidyInput: Substring) -> ABCMacro? {
    guard let eqIdx = tidyInput.firstIndex(of: "=")
    else { return nil }

    let target = String(trim(tidyInput[..<eqIdx]))
    let replacement = String(trim(tidyInput[tidyInput.index(after: eqIdx)...]))

    return ABCMacro(target: target,
                    replacement: replacement)
}

internal func parseReferenceNumber(_ tidyInput: Substring) -> ABCReferenceNumber? {
    guard let uintValue = UInt(tidyInput)
    else { return nil }

    return ABCReferenceNumber(uintValue: uintValue)
}

internal func parseShorthand(_ tidyInput: Substring) -> ABCShorthand? {
    shorthands[tidyInput]
}

internal func parseText(_ tidyInput: Substring) throws(ABCParser.Error) -> ABCText {
    guard let text = ABCText(stringValue: normalize(tidyInput))
    else { throw ABCParser.Error.invalidText(tidyInput) }

    return text
}

internal func parseTuplet(_ tidyInput: Substring) -> ParseTupletResult? {
    guard tidyInput.hasPrefix("(")
    else { return nil }

    let presult = tidyInput.dropFirst().splitBeforeFirst(":")

    guard let pcount = UInt(presult.head),
          (2...9).contains(pcount)
    else { return nil }

    guard let ptail = presult.tail?.dropFirst()
    else { return (pcount, nil, nil) }

    let qresult = ptail.splitBeforeFirst(":")
    let qcount: UInt?

    if !qresult.head.isEmpty {
        guard let qcnt = UInt(qresult.head),
              qcnt > 0
        else { return nil }

        qcount = qcnt
    } else {
        qcount = nil
    }

    guard let qtail = qresult.tail?.dropFirst(),
          !qtail.isEmpty
    else { return (pcount, qcount, nil) }

    guard let rcount = UInt(qtail),
          rcount > 0
    else { return nil }

    return (pcount, qcount, rcount)
}

internal func tidy(_ input: Substring) -> Substring {
    trim(uncomment(input))
}

internal func trim(_ input: Substring) -> Substring {
    trimPrefix(trimSuffix(input))
}

internal func trimPrefix(_ input: Substring) -> Substring {
    input.dropPrefix { $0.isABCWhitespace }
}

internal func trimSuffix(_ input: Substring) -> Substring {
    input.dropSuffix { $0.isABCWhitespace }
}

internal func uncomment(_ input: Substring) -> Substring {
    var idx = input.startIndex

loop:
    while idx < input.endIndex {
        switch input[idx] {
        case "\\":
            input.formIndex(after: &idx)

            guard idx < input.endIndex
            else { break loop }

        case "%":
            break loop

        default:
            break
        }

        input.formIndex(after: &idx)
    }

    guard idx < input.endIndex
    else { return input }

    return input[..<idx]
}

// MARK: Private Constants

private let brokenRhythms: [Substring: ABCBrokenRhythm] = ["<": .reverseDotted,
                                                           "<<": .reverseDoubleDotted,
                                                           "<<<": .reverseTripleDotted,
                                                           ">": .dotted,
                                                           ">>": .doubleDotted,
                                                           ">>>": .tripleDotted]

private let shorthands: [Substring: ABCShorthand] = [".": .dot,
                                                     "~": .tilde,
                                                     "h": .hLower,
                                                     "H": .hUpper,
                                                     "i": .iLower,
                                                     "I": .iUpper,
                                                     "j": .jLower,
                                                     "J": .jUpper,
                                                     "k": .kLower,
                                                     "K": .kUpper,
                                                     "l": .lLower,
                                                     "L": .lUpper,
                                                     "m": .mLower,
                                                     "M": .mUpper,
                                                     "n": .nLower,
                                                     "N": .nUpper,
                                                     "o": .oLower,
                                                     "O": .oUpper,
                                                     "p": .pLower,
                                                     "P": .pUpper,
                                                     "q": .qLower,
                                                     "Q": .qUpper,
                                                     "r": .rLower,
                                                     "R": .rUpper,
                                                     "s": .sLower,
                                                     "S": .sUpper,
                                                     "t": .tLower,
                                                     "T": .tUpper,
                                                     "u": .uLower,
                                                     "U": .uUpper,
                                                     "v": .vLower,
                                                     "V": .vUpper,
                                                     "w": .wLower,
                                                     "W": .wUpper]
