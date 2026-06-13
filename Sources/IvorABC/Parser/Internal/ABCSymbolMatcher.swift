// © 2025–2026 John Gary Pusey (see LICENSE.md)

internal import XestiTokens

private import Foundation
private import XestiTools

internal struct ABCSymbolMatcher {

    // MARK: Internal Initializers

    internal init(tokens: [Tokenizer.Token]) {
        self.tokenMatcher = TokenMatcher(tokens)
    }

    // MARK: Private Instance Properties

    private var tokenMatcher: TokenMatcher<[Tokenizer.Token]>
}

// MARK: -

extension ABCSymbolMatcher {

    // MARK: Internal Instance Methods

    internal mutating func matchSymbols(_ context: inout ABCParseContext) throws -> [ABCSymbol] {
        var symbols: [ABCSymbol] = []

        while tokenMatcher.hasMore {
            if let symbol = try _matchSymbol(&context) {
                symbols.append(symbol)
            }
        }

        // Strip leading and trailing beam-break markers: whitespace at the
        // edges of a music line carries no beam-grouping information.
        while symbols.first == .beamBreak {
            symbols.removeFirst()
        }

        while symbols.last == .beamBreak {
            symbols.removeLast()
        }

        return symbols
    }

    // MARK: Private Type Properties

    private static let builtinShorthandDecorations: [Character: String] = [".": "staccato",
                                                                           "~": "roll",
                                                                           "H": "fermata",
                                                                           "L": "accent",
                                                                           "M": "lowermordent",
                                                                           "O": "coda",
                                                                           "P": "uppermordent",
                                                                           "S": "segno",
                                                                           "T": "trill",
                                                                           "u": "upbow",
                                                                           "v": "downbow"]

    // MARK: Private Type Methods

    private func _expandMacroReplacement(_ replacement: String,
                                         _ context: inout ABCParseContext) throws -> [ABCSymbol] {
        let tokens = try ABCSymbolTokenizer(tracing: .silent).tokenize(replacement)

        var matcher = ABCSymbolMatcher(tokens: tokens)

        return try matcher.matchSymbols(&context)
    }

    private func _makeDuration(_ duration: ABCDuration?,
                               _ context: inout ABCParseContext) -> ABCDuration {
        let baseDuration = context.baseDuration

        if let duration {
            return ABCDuration(baseDuration.numerator * duration.numerator,
                               baseDuration.denominator * duration.denominator)
        }

        return baseDuration
    }

    private func _makePitch(_ result: ParsePitchResult) -> ABCPitch {
        ABCPitch(letter: result.letter,
                 accidental: result.accidental ?? .omitted,
                 octave: result.octave)
    }

    private mutating func _matchBeamBreak() -> ABCSymbol? {
        tokenMatcher.readIfMatches(.whitespace) != nil ? .beamBreak : nil
    }

    private mutating func _matchAnnotation() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.annotation)
        let stripped = token.value.dropFirst().dropLast()

        guard let annotation = ABCAnnotation(stringValue: stripped)
        else { throw ABCParser.Error.invalidSymbols(token.value) }

        return .annotation(annotation)
    }

    private mutating func _matchBarRepeat() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.barRepeat)

        return .barRepeat(String(token.value))
    }

    private mutating func _matchBrokenRhythm() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.brokenRhythm)

        return .brokenRhythm(String(token.value))
    }

    private mutating func _matchChord(_ context: inout ABCParseContext) throws -> ABCSymbol? {
        try tokenMatcher.readMustMatch(.chordBegin)

        var chord: [ABCNote] = []

        while let chordNote = try _matchChordNote(&context) {
            chord.append(chordNote)
        }

        try tokenMatcher.readMustMatch(.chordEnd)

        let duration: ABCDuration
        let isTied: Bool

        if let suffixToken = tokenMatcher.readIfMatches(.chordSuffix) {
            let value = suffixToken.value

            isTied = value.hasSuffix("-")

            let durationText = isTied ? value.dropLast() : value

            duration = _makeDuration(durationText.isEmpty ? nil : parseDuration(durationText),
                                     &context)
        } else {
            duration = _makeDuration(nil, &context)
            isTied = false
        }

        guard let chord = ABCChord(notes: chord,
                                   duration: duration,
                                   isTied: isTied)
        else { return nil }

        return .chord(chord)
    }

    private mutating func _matchChordNote(_ context: inout ABCParseContext) throws -> ABCNote? {
        guard let token = tokenMatcher.readIfMatches(.note)
        else { return nil }

        guard let result = parseNote(token.value)
        else { throw ABCParser.Error.invalidNote(token.value) }

        let duration = _makeDuration(result.duration, &context)
        let pitch = _makePitch(result.pitch)

        return ABCNote(pitch: pitch,
                       duration: duration,
                       isTied: result.isTied)
    }

    private mutating func _matchChordSymbol() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.chordSymbol)

        let chordSymbol = String(token.value.dropFirst().dropLast())

        return .chordSymbol(chordSymbol)
    }

    private mutating func _matchDecoration(_ context: inout ABCParseContext) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.decoration)
        let value = token.value

        if value.count == 1,
           let letter = value.first {
            guard let name = context.userSymbolDecorations[letter]
                  ?? Self.builtinShorthandDecorations[letter]
            else { throw ABCParser.Error.invalidSymbols(value) }

            return .decoration(ABCDecoration(name,
                                             letter,
                                             context.decorationDialect))
        }

        // In + dialect mode, !...! decorations are an error per spec §12.1.2.
        if context.decorationDialect == .plus, value.first == "!" {
            throw ABCParser.Error.invalidSymbols(value)
        }

        let dialect: ABCDecoration.Dialect = value.first == "+" ? .plus : .bang

        return .decoration(ABCDecoration(String(value.dropFirst().dropLast()),
                                         nil,
                                         dialect))
    }

    private mutating func _matchGraceNote(_ context: inout ABCParseContext) throws -> ABCNote? {
        guard let token = tokenMatcher.readIfMatches(.note)
        else { return nil }

        guard let result = parseNote(token.value)
        else { throw ABCParser.Error.invalidNote(token.value) }

        let duration = _makeDuration(result.duration, &context)
        let pitch = _makePitch(result.pitch)

        return ABCNote(pitch: pitch,
                       duration: duration,
                       isTied: result.isTied)
    }

    private mutating func _matchGraceNotes(_ context: inout ABCParseContext) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.graceNotesBegin)
        let hasSlash = token.value.hasSuffix("/")

        var graceNotes: [ABCNote] = []

        while let graceNote = try _matchGraceNote(&context) {
            graceNotes.append(graceNote)
        }

        try tokenMatcher.readMustMatch(.graceNotesEnd)

        guard let graceNotes = ABCGraceNotes(notes: graceNotes,
                                             isSlashed: hasSlash)
        else { return nil }

        return .graceNotes(graceNotes)
    }

    private mutating func _matchInlineField(_ context: inout ABCParseContext) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.inlineField)

        let field = try parseField(token.value)

        context.update(with: field)

        return .inlineField(field)
    }

    private mutating func _matchMacroCall(_ context: inout ABCParseContext) throws -> ABCSymbol? {
        guard !context.macros.isEmpty
        else { return nil }

        let savedMatcher = tokenMatcher
        let decorToken = try tokenMatcher.readMustMatch(.decoration)
        let decorValue = String(decorToken.value)
        let afterDecorMatcher = tokenMatcher

        if let noteToken = tokenMatcher.readIfMatches(.note) {
            let noteValue = String(noteToken.value)
            let fullTrigger = decorValue + noteValue

            if let macro = context.macros[fullTrigger] {
                let expansion = try _expandMacroReplacement(macro.replacement, &context)

                return .macroCall(ABCMacroCall(trigger: fullTrigger,
                                               expansion: expansion))
            }

            if let transposedKey = _transposedTriggerKey(decorValue, noteValue),
               let macro = context.macros[transposedKey],
               let letter = _notePitchLetter(noteValue) {
                let replacement = macro.replacement.replacingOccurrences(of: "n",
                                                                         with: String(letter))
                let expansion = try _expandMacroReplacement(replacement, &context)

                return .macroCall(ABCMacroCall(trigger: fullTrigger,
                                               expansion: expansion))
            }
        }

        tokenMatcher = afterDecorMatcher

        if let macro = context.macros[decorValue] {
            let expansion = try _expandMacroReplacement(macro.replacement, &context)

            return .macroCall(ABCMacroCall(trigger: decorValue,
                                           expansion: expansion))
        }

        tokenMatcher = savedMatcher

        return nil
    }

    private func _notePitchLetter(_ noteValue: String) -> Character? {
        for ch in noteValue where ("A"..."G").contains(ch) || ("a"..."g").contains(ch) {
            return ch
        }

        return nil
    }

    private mutating func _matchOverlay() throws -> ABCSymbol? {
        try tokenMatcher.readMustMatch(.overlay)

        return .overlay
    }

    private mutating func _matchNote(_ context: inout ABCParseContext) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.note)

        guard let result = parseNote(token.value)
        else { throw ABCParser.Error.invalidNote(token.value) }

        let duration = _makeDuration(result.duration, &context)
        let pitch = _makePitch(result.pitch)

        let note = ABCNote(pitch: pitch,
                           duration: duration,
                           isTied: result.isTied)

        return .note(note)
    }

    private mutating func _matchRest(_ context: inout ABCParseContext) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.rest)

        guard let result = parseRest(token.value)
        else { throw ABCParser.Error.invalidRest(token.value) }

        let rest: ABCRest

        switch result.kind {
        case "X",
            "Z":
            let count = result.duration?.numerator ?? 1

            rest = .multiMeasure(result.kind == "X", count)

        case "x",
            "z":
            let duration = _makeDuration(result.duration, &context)

            rest = .regular(result.kind == "x", duration)

        default:
            throw ABCParser.Error.invalidRest(token.value)
        }

        return .rest(rest)
    }

    private mutating func _matchSlur() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch([.slurBegin, .slurEnd])

        return .slur(String(token.value))
    }

    private mutating func _matchSpacer(_ context: inout ABCParseContext) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.spacer)
        let rest = token.value.dropFirst()
        let duration = _makeDuration(rest.isEmpty ? nil : parseDuration(rest), &context)

        return .spacer(duration)
    }

    private mutating func _matchSymbol(_ context: inout ABCParseContext) throws -> ABCSymbol? { // swiftlint:disable:this cyclomatic_complexity
        if tokenMatcher.nextMatches(.whitespace) {
            return _matchBeamBreak()
        }

        if tokenMatcher.nextMatches(.annotation) {
            return try _matchAnnotation()
        }

        if tokenMatcher.nextMatches(.barRepeat) {
            return try _matchBarRepeat()
        }

        if tokenMatcher.nextMatches(.brokenRhythm) {
            return try _matchBrokenRhythm()
        }

        if tokenMatcher.nextMatches(.chordBegin) {
            return try _matchChord(&context)
        }

        if tokenMatcher.nextMatches(.chordSymbol) {
            return try _matchChordSymbol()
        }

        if tokenMatcher.nextMatches(.decoration) {
            return try _matchMacroCall(&context) ?? _matchDecoration(&context)
        }

        if tokenMatcher.nextMatches(.graceNotesBegin) {
            return try _matchGraceNotes(&context)
        }

        if tokenMatcher.nextMatches(.inlineField) {
            return try _matchInlineField(&context)
        }

        if tokenMatcher.nextMatches(.note) {
            return try _matchNote(&context)
        }

        if tokenMatcher.nextMatches(.overlay) {
            return try _matchOverlay()
        }

        if tokenMatcher.nextMatches(.rest) {
            return try _matchRest(&context)
        }

        if tokenMatcher.nextMatches([.slurBegin, .slurEnd]) {
            return try _matchSlur()
        }

        if tokenMatcher.nextMatches(.spacer) {
            return try _matchSpacer(&context)
        }

        if tokenMatcher.nextMatches(.tuplet) {
            return try _matchTuplet()
        }

        if tokenMatcher.nextMatches(.variantEnding) {
            return try _matchVariantEnding()
        }

        try tokenMatcher.failOnNext()

        return nil
    }

    private mutating func _matchTuplet() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.tuplet)

        guard let tuplet = ABCTuplet(stringValue: token.value)
        else { throw ABCParser.Error.invalidTuplet(token.value) }

        return .tuplet(tuplet)
    }

    private mutating func _matchVariantEnding() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.variantEnding)

        guard let variantEnding = ABCVariantEnding(stringValue: token.value)
        else { throw ABCParser.Error.invalidSymbols(token.value) }

        return .variantEnding(variantEnding)
    }

    private func _transposedTriggerKey(_ decorValue: String,
                                       _ noteValue: String) -> String? {
        guard let letter = _notePitchLetter(noteValue)
        else { return nil }

        var result = decorValue
        var replaced = false

        for ch in noteValue {
            if !replaced, ch == letter {
                result.append("n")
                replaced = true
            } else {
                result.append(ch)
            }
        }

        return result
    }
}
