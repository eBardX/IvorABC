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

    // Symbols produced as a side effect of matching the current token, emitted
    // after it. Used to decompose an abbreviated bar mark (e.g. `:|2`) into a
    // bar line followed by a separate variant ending.
    private var pendingSymbols: [ABCSymbol] = []
    private var tokenMatcher: TokenMatcher<[Tokenizer.Token]>
}

// MARK: -

extension ABCSymbolMatcher {

    // MARK: Internal Instance Methods

    internal mutating func matchSymbols(_ context: inout ABCParser.Context) throws -> [ABCSymbol] {
        var symbols: [ABCSymbol] = []

        while tokenMatcher.hasMore {
            if let symbol = try _matchSymbol(&context) {
                symbols.append(symbol)
            }

            symbols.append(contentsOf: pendingSymbols)

            pendingSymbols.removeAll()
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

    // MARK: Private Type Methods

    private func _makeDuration(_ duration: ABCDuration?,
                               _ context: inout ABCParser.Context) -> ABCDuration {
        let baseDuration = context.baseDuration

        if let duration {
            return ABCDuration(numerator: baseDuration.numerator * duration.numerator,
                               denominator: baseDuration.denominator * duration.denominator).require()
        }

        return baseDuration
    }

    private func _makePitch(_ result: ParsePitchResult) -> ABCPitch {
        ABCPitch(letter: result.letter,
                 accidental: result.accidental,
                 octave: result.octave)
    }

    private mutating func _matchAnnotation() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.annotation)

        guard let annotation = parseAnnotation(token.value)
        else { throw ABCParser.Error.invalidSymbols(token.value) }

        return .annotation(annotation)
    }

    private mutating func _matchBarLine() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.barLine)

        guard let result = parseBarLine(token.value)
        else { throw ABCParser.Error.invalidSymbols(token.value) }

        if let variantEnding = result.variantEnding {
            pendingSymbols.append(.variantEnding(variantEnding))
        }

        return .barLine(result.barLine)
    }

    private mutating func _matchBeamBreak() -> ABCSymbol? {
        tokenMatcher.readIfMatches(.whitespace) != nil ? .beamBreak : nil
    }

    private mutating func _matchBrokenRhythm() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.brokenRhythm)

        guard let brokenRhythm = parseBrokenRhythm(token.value)
        else { throw ABCParser.Error.invalidSymbols(token.value) }

        return .brokenRhythm(brokenRhythm)
    }

    private mutating func _matchChord(_ context: inout ABCParser.Context) throws -> ABCSymbol? {
        try tokenMatcher.readMustMatch(.chordBegin)

        var chord: [ABCNote] = []

        while let chordNote = try _matchChordNote(&context) {
            chord.append(chordNote)
        }

        try tokenMatcher.readMustMatch(.chordEnd)

        let duration: ABCDuration
        let tie: ABCTie?

        if let suffixToken = tokenMatcher.readIfMatches(.chordSuffix) {
            let value = suffixToken.value
            let isDottedTie = value.hasSuffix(".-")
            let isRegularTie = !isDottedTie && value.hasSuffix("-")

            tie = isDottedTie ? .dotted : (isRegularTie ? .regular : nil)

            let durationText = value.dropLast(isDottedTie ? 2 : (isRegularTie ? 1 : 0))

            duration = _makeDuration(durationText.isEmpty ? nil : parseDuration(durationText),
                                     &context)
        } else {
            duration = _makeDuration(nil, &context)
            tie = nil
        }

        guard let chord = ABCChord(notes: chord,
                                   duration: duration,
                                   tie: tie)
        else { return nil }

        return .chord(chord)
    }

    private mutating func _matchChordNote(_ context: inout ABCParser.Context) throws -> ABCNote? {
        guard let token = tokenMatcher.readIfMatches(.note)
        else { return nil }

        guard let result = parseNote(token.value)
        else { throw ABCParser.Error.invalidNote(token.value) }

        let duration = _makeDuration(result.duration, &context)
        let pitch = _makePitch(result.pitch)

        return ABCNote(pitch: pitch,
                       duration: duration,
                       tie: result.tie)
    }

    private mutating func _matchChordSymbol() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.chordSymbol)

        guard let chordSymbol = parseChordSymbol(token.value)
        else { return nil }

        return .chordSymbol(chordSymbol)
    }

    private mutating func _matchDecoration(_ context: inout ABCParser.Context) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.decoration)
        let value = token.value

        // In + dialect mode, !...! decorations are an error per spec §12.1.2.
        if context.decorationDialect == .plus,
           value.first == "!" {
            throw ABCParser.Error.invalidSymbols(value)
        }

        let dialect: ABCDecoration.Dialect = value.first == "+" ? .plus : .bang

        guard let name = ABCDecoration.Name(stringValue: String(value.dropFirst().dropLast())),
              let decoration = ABCDecoration(name: name, dialect: dialect)
        else { throw ABCParser.Error.invalidSymbols(value) }

        return .decoration(decoration)
    }

    private mutating func _matchGraceNote(_ context: inout ABCParser.Context) throws -> ABCNote? {
        guard let token = tokenMatcher.readIfMatches(.note)
        else { return nil }

        guard let result = parseNote(token.value)
        else { throw ABCParser.Error.invalidNote(token.value) }

        let duration = _makeDuration(result.duration, &context)
        let pitch = _makePitch(result.pitch)

        return ABCNote(pitch: pitch,
                       duration: duration,
                       tie: result.tie)
    }

    private mutating func _matchGraceNotes(_ context: inout ABCParser.Context) throws -> ABCSymbol? {
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

    private mutating func _matchInlineField(_ context: inout ABCParser.Context) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.inlineField)

        var field = try parseField(token.value)

        if case let .parts(ps) = field {
            guard ps.items.count == 1,
                  case let .part(abcPart, 1) = ps.items[0]
            else { throw ABCParser.Error.misplacedField(field) }

            field = .part(abcPart)
        }

        context.update(with: field)

        return .inlineField(field)
    }

    private mutating func _matchOverlay() throws -> ABCSymbol? {
        try tokenMatcher.readMustMatch(.overlay)

        return .overlay
    }

    private mutating func _matchNote(_ context: inout ABCParser.Context) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.note)

        guard let result = parseNote(token.value)
        else { throw ABCParser.Error.invalidNote(token.value) }

        let duration = _makeDuration(result.duration, &context)
        let pitch = _makePitch(result.pitch)

        let note = ABCNote(pitch: pitch,
                           duration: duration,
                           tie: result.tie)

        return .note(note)
    }

    private mutating func _matchRest(_ context: inout ABCParser.Context) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.rest)

        guard let result = parseRest(token.value)
        else { throw ABCParser.Error.invalidRest(token.value) }

        let rest: ABCRest

        switch result.kind {
        case "X",
            "Z":
            let count = result.duration?.numerator ?? 1

            rest = .multiMeasure(result.kind == "X", ABCRest.MeasureCount(count))

        case "x",
            "z":
            let duration = _makeDuration(result.duration, &context)

            rest = .regular(result.kind == "x", duration)

        default:
            throw ABCParser.Error.invalidRest(token.value)
        }

        return .rest(rest)
    }

    private mutating func _matchShorthand(_ context: ABCParser.Context) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.shorthand)
        let value = token.value

        guard let shorthand = parseShorthand(value)
        else { throw ABCParser.Error.invalidSymbols(value) }

        guard !context.isShorthandDeassigned(shorthand)
        else { throw ABCParser.Error.undefinedShorthand(value) }

        return .shorthand(shorthand)
    }

    private mutating func _matchSlur() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch([.dottedSlurBegin,
                                                    .dottedSlurEnd,
                                                    .slurBegin,
                                                    .slurEnd])

        switch token.kind {
        case .dottedSlurBegin:
            return .slur(.startDotted)

        case .dottedSlurEnd:
            return .slur(.endDotted)

        case .slurBegin:
            return .slur(.startRegular)

        default:
            return .slur(.endRegular)
        }
    }

    private mutating func _matchSpacer(_ context: inout ABCParser.Context) throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.spacer)
        let rest = token.value.dropFirst()
        let duration = _makeDuration(rest.isEmpty ? nil : parseDuration(rest), &context)

        return .spacer(duration)
    }

    private mutating func _matchSymbol(_ context: inout ABCParser.Context) throws -> ABCSymbol? { // swiftlint:disable:this cyclomatic_complexity
        if tokenMatcher.nextMatches(.whitespace) {
            return _matchBeamBreak()
        }

        if tokenMatcher.nextMatches(.annotation) {
            return try _matchAnnotation()
        }

        if tokenMatcher.nextMatches(.barLine) {
            return try _matchBarLine()
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
            return try _matchDecoration(&context)
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

        if tokenMatcher.nextMatches(.shorthand) {
            return try _matchShorthand(context)
        }

        if tokenMatcher.nextMatches([.dottedSlurBegin, .dottedSlurEnd, .slurBegin, .slurEnd]) {
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

        guard let result = parseTuplet(token.value),
              let tuplet = ABCTuplet(noteCount: result.pcount,
                                     beatCount: result.qcount,
                                     affectedCount: result.rcount)
        else { throw ABCParser.Error.invalidTuplet(token.value) }

        return .tuplet(tuplet)
    }

    private mutating func _matchVariantEnding() throws -> ABCSymbol? {
        let token = try tokenMatcher.readMustMatch(.variantEnding)

        guard let variantEnding = parseVariantEnding(token.value)
        else { throw ABCParser.Error.invalidSymbols(token.value) }

        return .variantEnding(variantEnding)
    }
}
