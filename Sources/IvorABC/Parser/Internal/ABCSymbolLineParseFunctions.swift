// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

// MARK: Internal Functions

internal func parseAnnotation(_ tidyInput: Substring) -> ABCAnnotation? {
    guard tidyInput.first == "\"",
          tidyInput.last == "\""
    else { return nil }

    let content = tidyInput.dropFirst().dropLast()

    guard !tidyInput.isEmpty,
          let placement = _parseAnnotationPlacement(content[...content.startIndex])
    else { return nil }

    return ABCAnnotation(placement: placement,
                         text: normalize(content.dropFirst()))
}

internal func parseBarLine(_ tidyInput: Substring) -> (barLine: ABCBarLine, variantEnding: ABCVariantEnding?)? {
    var rest = tidyInput

    let isDotted = rest.hasPrefix(".")

    if isDotted {
        rest = rest.dropFirst()
    }

    let markRun = rest.prefix { ":|[]".contains($0) }

    guard let (kind, preceding, following) = _parseBarLineKind(markRun)
    else { return nil }

    rest = rest.dropFirst(markRun.count)

    guard let barLine = ABCBarLine(kind: kind,
                                   precedingPlayCount: preceding,
                                   followingPlayCount: following,
                                   isDotted: isDotted)
    else { return nil }

    // A trailing range list (e.g. `:|2` or `|1,3`) is the abbreviated form of
    // a bar mark immediately followed by a variant ending (§4.9). Decompose it
    // into a separate variant ending.
    guard !rest.isEmpty
    else { return (barLine, nil) }

    guard let endings = _parseRepeatRangeList(rest),
          let variantEnding = ABCVariantEnding(endings: endings)
    else { return nil }

    return (barLine, variantEnding)
}

internal func parseChordSymbol(_ tidyInput: Substring) -> ABCChordSymbol? {
    guard tidyInput.first == "\"",
          tidyInput.last == "\""
    else { return nil }

    var rest = tidyInput.dropFirst().dropLast()

    guard let root = _parseChordSymbolRoot(&rest)
    else { return nil }

    let kind = _parseChordSymbolKind(&rest)

    var bass: ABCChordSymbol.Root?

    if rest.first == "/" {
        rest = rest.dropFirst()
        bass = _parseChordSymbolRoot(&rest)
    }

    var parenthesized: ABCChordSymbol.Name?

    if rest.first == "(" {
        rest = rest.dropFirst()

        if let parenRoot = _parseChordSymbolRoot(&rest) {
            parenthesized = ABCChordSymbol.Name(root: parenRoot,
                                                kind: _parseChordSymbolKind(&rest))
        }
    }

    return ABCChordSymbol(name: ABCChordSymbol.Name(root: root, kind: kind),
                          bass: bass,
                          parenthesized: parenthesized)
}

internal func parseSymbolLine(_ tidyInput: Substring) -> ABCSymbolLine? {
    var elements: [ABCSymbolLine.Element] = []
    var input = tidyInput

    while !input.isEmpty {
        input = trimPrefix(input)

        guard !input.isEmpty
        else { break }

        switch input.first {
        case "*":
            elements.append(.skip)

            input = input.dropFirst()

        case "!":
            let rest = input.dropFirst()

            guard let closeIdx = rest.firstIndex(of: "!"),
                  !rest[..<closeIdx].isEmpty,
                  rest[..<closeIdx].allSatisfy({ $0.isABCAlphanumeric || ".()+<>".contains($0) }),
                  let name = ABCDecoration.Name(stringValue: String(rest[..<closeIdx])),
                  let decoration = ABCDecoration(name: name)
            else { return nil }

            elements.append(.decoration(decoration))

            input = rest[rest.index(after: closeIdx)...]

        case "+":
            let rest = input.dropFirst()

            guard let closeIdx = rest.firstIndex(of: "+"),
                  !rest[..<closeIdx].isEmpty,
                  rest[..<closeIdx].allSatisfy({ $0.isABCAlphanumeric || ".()<>".contains($0) }),
                  let name = ABCDecoration.Name(stringValue: String(rest[..<closeIdx])),
                  let decoration = ABCDecoration(name: name, dialect: .plus)
            else { return nil }

            elements.append(.decoration(decoration))

            input = rest[rest.index(after: closeIdx)...]

        case "\"":
            let rest = input.dropFirst()

            guard let closeIdx = rest.firstIndex(of: "\"")
            else { return nil }

            if let annotation = parseAnnotation(input[...closeIdx]) {
                elements.append(.annotation(annotation))
            } else if let chordSymbol = parseChordSymbol(input[...closeIdx]) {
                elements.append(.chordSymbol(chordSymbol))
            }

            input = rest[rest.index(after: closeIdx)...]

        default:        // what about decoration shorthands?
            return nil
        }
    }

    return ABCSymbolLine(elements: elements)
}

internal func parseVariantEnding(_ tidyInput: Substring) -> ABCVariantEnding? {
    // Parses a variant ending from the ABC token text (e.g. `[1` or
    // `[2,3` or `[1-3`).
    guard tidyInput.hasPrefix("[")
    else { return nil }

    guard let ranges = _parseRepeatRangeList(tidyInput.dropFirst())
    else { return nil }

    return ABCVariantEnding(endings: ranges)
}

// MARK: Private Constants

private let annotationPlacements: [Substring: ABCAnnotation.Placement] = ["^": .above,
                                                                          "@": .auto,
                                                                          "_": .below,
                                                                          "<": .left,
                                                                          ">": .right]

private let barLineKinds: [Substring: ABCBarLine.Kind] = ["[|": .double,
                                                          "[|]": .invisible,
                                                          "|": .standard,
                                                          "|]": .end,
                                                          "||": .double]

private let chordSymbolRootAccidentals: [String: ABCChordSymbol.Root] = ["Ab": .aFlat,
                                                                         "A#": .aSharp,
                                                                         "Bb": .bFlat,
                                                                         "B#": .bSharp,
                                                                         "Cb": .cFlat,
                                                                         "C#": .cSharp,
                                                                         "Db": .dFlat,
                                                                         "D#": .dSharp,
                                                                         "Eb": .eFlat,
                                                                         "E#": .eSharp,
                                                                         "Fb": .fFlat,
                                                                         "F#": .fSharp,
                                                                         "Gb": .gFlat,
                                                                         "G#": .gSharp]

private let chordSymbolRootNaturals: [Character: ABCChordSymbol.Root] = ["A": .a,
                                                                         "B": .b,
                                                                         "C": .c,
                                                                         "D": .d,
                                                                         "E": .e,
                                                                         "F": .f,
                                                                         "G": .g]

// MARK: Private Functions

private func _normalizeBarGlyph(_ glyph: Substring) -> ABCBarLine.Kind? {
    // Maps a non-canonical bar glyph (one not in barLineKinds) to the nearest
    // bar kind. Receives only the bar-character portion of the input with
    // colons already stripped, so the glyph contains only '|', '[', ']'.
    guard !glyph.isEmpty,
          glyph.allSatisfy({ "|[]".contains($0) })
    else { return nil }

    if glyph.hasPrefix("[") && glyph.hasSuffix("]") {
        return .invisible
    }

    if glyph.hasPrefix("[") {
        return .double
    }

    if glyph.hasSuffix("]") {
        return .end
    }

    let pipeCount = glyph.filter { $0 == "|" }.count

    return pipeCount >= 2 ? .double : .standard
}

private func _parseAnnotationPlacement(_ tidyInput: Substring) -> ABCAnnotation.Placement? {
    annotationPlacements[tidyInput]
}

private func _parseBarLineKind(_ tidyInput: Substring)
    -> (ABCBarLine.Kind, ABCBarLine.PlayCount, ABCBarLine.PlayCount)? {
    guard !tidyInput.isEmpty,
          tidyInput.allSatisfy({ ":|[]".contains($0) })
    else { return nil }

    let leadingColonCount = tidyInput.prefix { $0 == ":" }.count
    let body = tidyInput.dropFirst(leadingColonCount)
    let trailingColonCount = body.reversed().prefix { $0 == ":" }.count
    let glyph = body.dropLast(trailingColonCount)

    switch (leadingColonCount, trailingColonCount) {
    case (0, 0):
        // Plain bar lines: try canonical lookup first, then liberal normalization.
        if let kind = barLineKinds[glyph] {
            return (kind, 1, 1)
        }

        guard let kind = _normalizeBarGlyph(glyph)
        else { return nil }

        return (kind, 1, 1)

    case let (0, n) where n >= 1:
        // |: (n=1, standard 2x), |:: (n=2, 3x), |::: (n=3, 4x), etc.
        // Liberal: any non-empty bar glyph is accepted as the bar component.
        guard !glyph.isEmpty
        else { return nil }

        return (.repeat, 1, ABCBarLine.PlayCount(UInt(n + 1)))

    case let (n, 0) where n >= 1:
        if glyph.isEmpty {
            // The collapsed `::` form: greedy colon-stripping leaves both
            // colons leading. Only the 2-colon case has a defined meaning.
            return n == 2 ? (.repeat, 2, 2) : nil
        }

        // ::| (n=2, end 3x), :::| (n=3, end 4x), etc.
        // Liberal: any non-empty bar glyph is accepted.
        return (.repeat, ABCBarLine.PlayCount(UInt(n + 1)), 1)

    case let (n, m) where n >= 1 && m >= 1:
        // :|: (1,1 standard), :||: (1,1 liberal), ::|: (2,1), :|:: (1,2), etc.
        // glyph may be empty (pure colon sequence), |, ||, or a liberal sequence.
        return (.repeat,
                ABCBarLine.PlayCount(UInt(n + 1)),
                ABCBarLine.PlayCount(UInt(m + 1)))

    default:
        return nil
    }
}

private func _parseChordSymbolKind(_ input: inout Substring) -> String? {
    let kind = input.prefix { $0 != "/" && $0 != "(" && $0 != ")" }

    input = input.dropFirst(kind.count)

    return kind.isEmpty ? nil : String(kind)
}

private func _parseChordSymbolRoot(_ input: inout Substring) -> ABCChordSymbol.Root? {
    guard let letter = input.first,
          ("A"..."G").contains(letter)
    else { return nil }

    if let next = input.dropFirst().first {
        let key = String([letter, next])

        if let root = chordSymbolRootAccidentals[key] {
            input = input.dropFirst(2)

            return root
        }
    }

    input = input.dropFirst()

    return chordSymbolRootNaturals[letter]
}

private func _parseRepeatRangeList(_ tidyInput: Substring) -> [ClosedRange<UInt>]? {
    // Parses a comma-separated list of ending numbers and ranges, shared by
    // variant endings (`[1,3-5`) and the abbreviated bar-mark forms (`:|2`).
    var ranges: [ClosedRange<UInt>] = []

    for part in tidyInput.split(separator: ",") {
        if let dashIdx = part.firstIndex(of: "-") {
            guard let lo = UInt(part[..<dashIdx]),
                  let hi = UInt(part[part.index(after: dashIdx)...])
            else { return nil }

            ranges.append(lo...hi)
        } else {
            guard let n = UInt(part)
            else { return nil }

            ranges.append(n...n)
        }
    }

    return ranges
}
