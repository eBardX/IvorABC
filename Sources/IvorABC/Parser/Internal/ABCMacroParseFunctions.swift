// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTokens
private import XestiTools

// Macro-aware fragment parsing (§8.2). A macro target is either fully
// literal (static) or a literal prefix followed by a trailing `n` wildcard
// note-slot (transposing); a transposing macro's replacement may reference
// the matched note — verbatim via `n`, or diatonically transposed via
// `h`–`m` (below) and `o`–`w` (above). These placeholder letters overlap
// `ABCShorthand`'s redefinable-symbol letters, so they can only be
// recognized contextually — not via the general-purpose tokenizer/matcher
// used for ordinary tune-body content, which is why this file exists.
// `x`, `y`, and `z` are excluded from the placeholder set: they are already
// claimed by rest and spacer symbols.

// MARK: Internal Functions

// Parses a static macro's replacement as a literal symbol sequence,
// best-effort — an unparseable replacement yields no symbols rather than
// failing macro construction, matching the leniency `parseMacro` has always
// had for macro content.
internal func parseMacroReplacementSymbols(_ replacement: String) -> [ABCSymbol] {
    _matchMacroFragment(replacement)
}

// Parses a transposing macro's replacement into a template, or `nil` if it
// cannot be parsed.
internal func parseMacroReplacementTemplate(_ replacement: String) -> [ABCMacro.Element]? {
    let (substituted, placeholderOffsets) = _substitutePlaceholders(in: replacement)

    guard let tokens = try? ABCSymbolTokenizer(tracing: .silent).tokenize(substituted)
    else { return nil }

    var matcher = ABCSymbolMatcher(tokens: tokens)

    guard let symbols = try? matcher.matchSymbols()
    else { return nil }

    let noteTokenOffsets: [Int?] = tokens
        .filter { $0.kind == .note }
        .map { token in
            placeholderOffsets[substituted.distance(from: substituted.startIndex,
                                                    to: token.value.startIndex)]
        }

    return _macroTemplate(from: symbols,
                          noteTokenOffsets: noteTokenOffsets)
}

// Determines whether `target` is static or transposing, and splits it into
// its literal prefix (the whole string, for a static target) and, for a
// transposing target, the required written length of the trailing `n`
// note-slot.
internal func parseMacroTarget(_ target: String) -> (kind: ABCMacro.Kind, prefix: [ABCSymbol], noteLength: ABCLength?) {
    let chars = Substring(target)
    var lengthStart = chars.endIndex

    while lengthStart > chars.startIndex,
          "0123456789/".contains(chars[chars.index(before: lengthStart)]) {
        lengthStart = chars.index(before: lengthStart)
    }

    guard lengthStart > chars.startIndex,
          chars[chars.index(before: lengthStart)] == "n"
    else { return (.static, _matchMacroFragment(target), nil) }

    let lengthText = chars[lengthStart...]
    let noteLength = lengthText.isEmpty ? ABCLength(numerator: 1).require() : parseLength(lengthText)

    guard let noteLength
    else { return (.static, _matchMacroFragment(target), nil) }

    let prefixText = String(chars[..<chars.index(before: lengthStart)])

    return (.transposing, _matchMacroFragment(prefixText), noteLength)
}

// MARK: Private Constants

// `n` is offset 0 (the matched note itself); `h`–`m` step diatonically
// downward, `o`–`w` upward — the 16 letters immediately surrounding `n` in
// the alphabet, matching `ABCShorthand`'s conspicuous omission of `n` from
// its own letter range.
private let placeholderDiatonicOffsets: [Character: Int] = ["h": -6,
                                                            "i": -5,
                                                            "j": -4,
                                                            "k": -3,
                                                            "l": -2,
                                                            "m": -1,
                                                            "n": 0,
                                                            "o": 1,
                                                            "p": 2,
                                                            "q": 3,
                                                            "r": 4,
                                                            "s": 5,
                                                            "t": 6,
                                                            "u": 7,
                                                            "v": 8,
                                                            "w": 9]

// The real pitch letter substituted for every placeholder before handing the
// fragment to the ordinary tokenizer/matcher. Any letter would do; `c` is as
// good as any.
private let placeholderStandIn: Character = "c"

// MARK: Private Functions

// Rewrites `symbols` into a template: a top-level note whose token was a
// placeholder substitution (per `noteTokenOffsets`, in the same left-to-right
// order the tokenizer produced note tokens) becomes a `.placeholder` element;
// everything else — including chord/grace-note contents, which are never
// substituted (see `substitutePlaceholders(in:)`) — passes through as a
// literal `.symbol`. Returns `nil` if `noteTokenOffsets` runs out before the
// notes actually found in `symbols` do, which should not happen given
// matched substitution bookkeeping but is checked defensively.
private func _macroTemplate(from symbols: [ABCSymbol],
                            noteTokenOffsets: [Int?]) -> [ABCMacro.Element]? {
    var cursor = 0
    var template: [ABCMacro.Element] = []

    for symbol in symbols {
        switch symbol {
        case let .note(note):
            guard cursor < noteTokenOffsets.count
            else { return nil }

            if let diatonicOffset = noteTokenOffsets[cursor] {
                template.append(.placeholder(diatonicOffset: diatonicOffset,
                                             length: note.length))
            } else {
                template.append(.symbol(symbol))
            }

            cursor += 1

        case let .chord(chord):
            cursor += chord.notes.count
            template.append(.symbol(symbol))

        case let .graceNotes(graceNotes):
            cursor += graceNotes.notes.count
            template.append(.symbol(symbol))

        default:
            template.append(.symbol(symbol))
        }
    }

    return template
}

// Parses `text` as a literal symbol sequence via the ordinary
// tokenizer/matcher, or returns an empty array if it cannot be parsed.
private func _matchMacroFragment(_ text: String) -> [ABCSymbol] {
    guard !text.isEmpty,
          let tokens = try? ABCSymbolTokenizer(tracing: .silent).tokenize(text)
    else { return [] }

    var matcher = ABCSymbolMatcher(tokens: tokens)

    return (try? matcher.matchSymbols()) ?? []
}

// Substitutes each depth-0 placeholder letter in `replacement` with a real
// pitch letter, so the ordinary tokenizer/matcher can parse the result.
// Depth tracks `{`/`}` and `[`/`]` nesting — placeholders are recognized only
// at depth 0, since grace-note/chord contents are always literal. `!...!`
// and `"..."` delimited spans are copied through verbatim, since letters
// there are part of a decoration name or annotation/chord-symbol text, not
// wildcards.
//
// Returns the substituted text and a map from substituted-string character
// offset to diatonic offset, one entry per substitution performed.
private func _substitutePlaceholders(in replacement: String) -> (substituted: String, placeholderOffsets: [Int: Int]) {
    var substituted = ""
    var placeholderOffsets: [Int: Int] = [:]
    var protectedDelimiter: Character?
    var nestingDepth = 0
    var characterOffset = 0

    for character in replacement {
        defer { characterOffset += 1 }

        if let delimiter = protectedDelimiter {
            substituted.append(character)

            if character == delimiter {
                protectedDelimiter = nil
            }

            continue
        }

        if character == "!" || character == "\"" {
            protectedDelimiter = character
            substituted.append(character)

            continue
        }

        if character == "{" || character == "[" {
            nestingDepth += 1
            substituted.append(character)

            continue
        }

        if character == "}" || character == "]" {
            nestingDepth = max(0, nestingDepth - 1)
            substituted.append(character)

            continue
        }

        if nestingDepth == 0,
           let diatonicOffset = placeholderDiatonicOffsets[character] {
            placeholderOffsets[characterOffset] = diatonicOffset
            substituted.append(placeholderStandIn)

            continue
        }

        substituted.append(character)
    }

    return (substituted, placeholderOffsets)
}
