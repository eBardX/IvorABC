// © 2025–2026 John Gary Pusey (see LICENSE.md)

internal import XestiTokens

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

        return symbols
    }

    // MARK: Private Type Methods

    private func _determineQCount(_ pcount: UInt,
                                  _ context: inout ABCParseContext) -> UInt {
        switch pcount {
        case 2,
             4,
             8:
            3

        case 3,
             6:
            2

        default:
            context.isCompoundMeter ? 3 : 2
        }
    }

    private func _makeDuration(_ duration: ABCDuration?,
                               _ context: inout ABCParseContext) -> ABCDuration {
        let baseDuration = context.baseDuration

        if let duration {
            return ABCDuration(numerator: baseDuration.numerator * duration.numerator,
                               denominator: baseDuration.denominator * duration.denominator,
                               reduce: true)
        }

        return baseDuration
    }

    private func _makePitch(_ result: ParsePitchResult,
                            _ context: inout ABCParseContext) -> ABCPitch {
        let accidental = result.accidental ?? context.accidentalsInKey[result.letter] ?? .natural

        return ABCPitch(letter: result.letter,
                        accidental: accidental,
                        octave: result.octave)
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

        return .chord(chord)
    }

    private mutating func _matchChordNote(_ context: inout ABCParseContext) throws -> ABCNote? {
        guard let token = tokenMatcher.readIfMatches(.note)
        else { return nil }

        guard let result = parseNote(token.value)
        else { throw ABCParseError.invalidNote(token.value) }

        let duration = _makeDuration(result.duration, &context)
        let pitch = _makePitch(result.pitch, &context)

        return ABCNote(pitch: pitch,
                       duration: duration,
                       isTied: result.isTied)
    }

    private mutating func _matchChordSymbol() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.chordSymbol)

        let chordSymbol = String(token.value.dropFirst().dropLast())

        return .chordSymbol(chordSymbol)
    }

    private mutating func _matchDecoration() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.decoration)

        return .decoration(String(token.value))
    }

    private mutating func _matchGraceNote(_ context: inout ABCParseContext) throws -> ABCNote? {
        guard let token = tokenMatcher.readIfMatches(.note)
        else { return nil }

        guard let result = parseNote(token.value)
        else { throw ABCParseError.invalidNote(token.value) }

        let duration = _makeDuration(result.duration, &context)
        let pitch = _makePitch(result.pitch, &context)

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

        return .graceNotes(hasSlash, graceNotes)
    }

    private mutating func _matchInlineField() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.inlineField)

        let field = try parseField(token.value)

        return .inlineField(field)
    }

    private mutating func _matchNote(_ context: inout ABCParseContext) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.note)

        guard let result = parseNote(token.value)
        else { throw ABCParseError.invalidNote(token.value) }

        let duration = _makeDuration(result.duration, &context)
        let pitch = _makePitch(result.pitch, &context)

        let note = ABCNote(pitch: pitch,
                           duration: duration,
                           isTied: result.isTied)

        return .note(note)
    }

    private mutating func _matchRest(_ context: inout ABCParseContext) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.rest)

        guard let result = parseRest(token.value)
        else { throw ABCParseError.invalidRest(token.value) }

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
            throw ABCParseError.invalidRest(token.value)
        }

        return .rest(rest)
    }

    private mutating func _matchSlur() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch([.slurBegin, .slurEnd])

        return .slur(String(token.value))
    }

    private mutating func _matchSymbol(_ context: inout ABCParseContext) throws -> ABCSymbol? { // swiftlint:disable:this cyclomatic_complexity
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
            return try _matchDecoration()
        }

        if tokenMatcher.nextMatches(.graceNotesBegin) {
            return try _matchGraceNotes(&context)
        }

        if tokenMatcher.nextMatches(.inlineField) {
            return try _matchInlineField()
        }

        if tokenMatcher.nextMatches(.note) {
            return try _matchNote(&context)
        }

        if tokenMatcher.nextMatches(.rest) {
            return try _matchRest(&context)
        }

        if tokenMatcher.nextMatches([.slurBegin, .slurEnd]) {
            return try _matchSlur()
        }

        if tokenMatcher.nextMatches(.tuplet) {
            return try _matchTuplet(&context)
        }

        if tokenMatcher.nextMatches(.variantEnding) {
            return try _matchVariantEnding()
        }

        try tokenMatcher.failOnNext()

        return nil
    }

    private mutating func _matchTuplet(_ context: inout ABCParseContext) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.tuplet)

        guard let result = parseTuplet(token.value)
        else { throw ABCParseError.invalidTuplet(token.value) }

        let pcount = result.pcount
        let qcount = result.qcount ?? _determineQCount(pcount, &context)
        let rcount = result.rcount ?? pcount

        return .tuplet(pcount, qcount, rcount)
    }

    private mutating func _matchVariantEnding() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.variantEnding)

        return .variantEnding(String(token.value))
    }
}
