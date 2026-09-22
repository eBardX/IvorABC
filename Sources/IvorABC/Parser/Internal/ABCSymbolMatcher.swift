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

    internal mutating func matchSymbols() throws(ABCParser.Error) -> [ABCSymbol] {
        var symbols: [ABCSymbol] = []

        while tokenMatcher.hasMore {
            if let symbol = try _matchSymbol() {
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

    // MARK: Private Instance Methods

    private mutating func _failOnNext() throws(ABCParser.Error) {
        do {
            try tokenMatcher.failOnNext()
        } catch {
            throw ABCParser.Error.tokenizationFailed(error.message)
        }
    }

    private func _makePitch(_ result: ParsePitchResult) -> ABCPitch {
        ABCPitch(letter: result.letter,
                 accidental: result.accidental,
                 octave: result.octave)
    }

    private mutating func _matchAnnotation() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch(.annotation)

        guard let annotation = parseAnnotation(token.value)
        else { throw ABCParser.Error.invalidSymbols(token.value) }

        return .annotation(annotation)
    }

    private mutating func _matchBarLine() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch(.barLine)

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

    private mutating func _matchBrokenRhythm() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch(.brokenRhythm)

        guard let brokenRhythm = parseBrokenRhythm(token.value)
        else { throw ABCParser.Error.invalidSymbols(token.value) }

        return .brokenRhythm(brokenRhythm)
    }

    private mutating func _matchChord() throws(ABCParser.Error) -> ABCSymbol? {
        try _readMustMatch(.chordBegin)

        var chord: [ABCNote] = []

        while let chordNote = try _matchChordNote() {
            chord.append(chordNote)
        }

        try _readMustMatch(.chordEnd)

        let length: ABCLength
        let tie: ABCTie?

        if let suffixToken = tokenMatcher.readIfMatches(.chordSuffix) {
            let value = suffixToken.value
            let isDottedTie = value.hasSuffix(".-")
            let isRegularTie = !isDottedTie && value.hasSuffix("-")

            tie = isDottedTie ? .dotted : (isRegularTie ? .regular : nil)

            let lengthText = value.dropLast(isDottedTie ? 2 : (isRegularTie ? 1 : 0))

            length = _writtenLength(lengthText.isEmpty ? nil : parseLength(lengthText))
        } else {
            length = _writtenLength(nil)
            tie = nil
        }

        guard let chord = ABCChord(notes: chord,
                                   length: length,
                                   tie: tie)
        else { return nil }

        return .chord(chord)
    }

    private mutating func _matchChordNote() throws(ABCParser.Error) -> ABCNote? {
        guard let token = tokenMatcher.readIfMatches(.note)
        else { return nil }

        guard let result = parseNote(token.value)
        else { throw ABCParser.Error.invalidNote(token.value) }

        let length = _writtenLength(result.length)
        let pitch = _makePitch(result.pitch)

        return ABCNote(pitch: pitch,
                       length: length,
                       tie: result.tie)
    }

    private mutating func _matchChordSymbol() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch(.chordSymbol)

        guard let chordSymbol = parseChordSymbol(token.value)
        else { return nil }

        return .chordSymbol(chordSymbol)
    }

    private mutating func _matchDecoration() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch(.decoration)
        let value = token.value
        let dialect: ABCDecoration.Dialect = value.first == "+" ? .plus : .bang

        guard let name = ABCDecoration.Name(stringValue: String(value.dropFirst().dropLast())),
              let decoration = ABCDecoration(name: name, dialect: dialect)
        else { throw ABCParser.Error.invalidSymbols(value) }

        return .decoration(decoration)
    }

    private mutating func _matchGraceNote() throws(ABCParser.Error) -> ABCNote? {
        guard let token = tokenMatcher.readIfMatches(.note)
        else { return nil }

        guard let result = parseNote(token.value)
        else { throw ABCParser.Error.invalidNote(token.value) }

        let length = _writtenLength(result.length)
        let pitch = _makePitch(result.pitch)

        return ABCNote(pitch: pitch,
                       length: length,
                       tie: result.tie)
    }

    private mutating func _matchGraceNotes() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch(.graceNotesBegin)
        let hasSlash = token.value.hasSuffix("/")

        var graceNotes: [ABCNote] = []

        while let graceNote = try _matchGraceNote() {
            graceNotes.append(graceNote)
        }

        try _readMustMatch(.graceNotesEnd)

        guard let graceNotes = ABCGraceNotes(notes: graceNotes,
                                             isSlashed: hasSlash)
        else { return nil }

        return .graceNotes(graceNotes)
    }

    private mutating func _matchInlineField() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch(.inlineField)

        var field = try parseField(token.value)

        if case let .parts(partSequence) = field,
           partSequence.items.count == 1,
           case let .part(part, 1) = partSequence.items[0] {
            field = .part(part)
        }

        return .inlineField(field)
    }

    private mutating func _matchNote() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch(.note)

        guard let result = parseNote(token.value)
        else { throw ABCParser.Error.invalidNote(token.value) }

        let length = _writtenLength(result.length)
        let pitch = _makePitch(result.pitch)

        let note = ABCNote(pitch: pitch,
                           length: length,
                           tie: result.tie)

        return .note(note)
    }

    private mutating func _matchOverlay() throws(ABCParser.Error) -> ABCSymbol? {
        try _readMustMatch(.overlay)

        return .overlay
    }

    private mutating func _matchRest() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch(.rest)

        guard let result = parseRest(token.value)
        else { throw ABCParser.Error.invalidRest(token.value) }

        let rest: ABCRest

        switch result.kind {
        case "X",
            "Z":
            let count = result.length?.numerator ?? 1

            rest = .multiMeasure(result.kind == "X", ABCRest.MeasureCount(count))

        case "x",
            "z":
            let length = _writtenLength(result.length)

            rest = .regular(result.kind == "x", length)

        default:
            throw ABCParser.Error.invalidRest(token.value)
        }

        return .rest(rest)
    }

    private mutating func _matchShorthand() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch(.shorthand)
        let value = token.value

        guard let shorthand = parseShorthand(value)
        else { throw ABCParser.Error.invalidSymbols(value) }

        return .shorthand(shorthand)
    }

    private mutating func _matchSlur() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch([.dottedSlurBegin,
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

    private mutating func _matchSpacer() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch(.spacer)
        let rest = token.value.dropFirst()
        let length = _writtenLength(rest.isEmpty ? nil : parseLength(rest))

        return .spacer(length)
    }

    private mutating func _matchSymbol() throws(ABCParser.Error) -> ABCSymbol? { // swiftlint:disable:this cyclomatic_complexity
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
            return try _matchChord()
        }

        if tokenMatcher.nextMatches(.chordSymbol) {
            return try _matchChordSymbol()
        }

        if tokenMatcher.nextMatches(.decoration) {
            return try _matchDecoration()
        }

        if tokenMatcher.nextMatches(.graceNotesBegin) {
            return try _matchGraceNotes()
        }

        if tokenMatcher.nextMatches(.inlineField) {
            return try _matchInlineField()
        }

        if tokenMatcher.nextMatches(.note) {
            return try _matchNote()
        }

        if tokenMatcher.nextMatches(.overlay) {
            return try _matchOverlay()
        }

        if tokenMatcher.nextMatches(.rest) {
            return try _matchRest()
        }

        if tokenMatcher.nextMatches(.shorthand) {
            return try _matchShorthand()
        }

        if tokenMatcher.nextMatches([.dottedSlurBegin, .dottedSlurEnd, .slurBegin, .slurEnd]) {
            return try _matchSlur()
        }

        if tokenMatcher.nextMatches(.spacer) {
            return try _matchSpacer()
        }

        if tokenMatcher.nextMatches(.tuplet) {
            return try _matchTuplet()
        }

        if tokenMatcher.nextMatches(.variantEnding) {
            return try _matchVariantEnding()
        }

        try _failOnNext()

        return nil
    }

    private mutating func _matchTuplet() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch(.tuplet)

        guard let result = parseTuplet(token.value),
              let tuplet = ABCTuplet(noteCount: result.pcount,
                                     beatCount: result.qcount,
                                     affectedCount: result.rcount)
        else { throw ABCParser.Error.invalidTuplet(token.value) }

        return .tuplet(tuplet)
    }

    private mutating func _matchVariantEnding() throws(ABCParser.Error) -> ABCSymbol? {
        let token = try _readMustMatch(.variantEnding)

        guard let variantEnding = parseVariantEnding(token.value)
        else { throw ABCParser.Error.invalidSymbols(token.value) }

        return .variantEnding(variantEnding)
    }

    @discardableResult
    private mutating func _readMustMatch(_ kind: TokenMatcher<[Tokenizer.Token]>.Kind) throws(ABCParser.Error) -> Tokenizer.Token {
        do {
            return try tokenMatcher.readMustMatch(kind)
        } catch {
            throw ABCParser.Error.tokenizationFailed(error.message)
        }
    }

    @discardableResult
    private mutating func _readMustMatch(_ kinds: [TokenMatcher<[Tokenizer.Token]>.Kind]) throws(ABCParser.Error) -> Tokenizer.Token {
        do {
            return try tokenMatcher.readMustMatch(kinds)
        } catch {
            throw ABCParser.Error.tokenizationFailed(error.message)
        }
    }

    // The written length of a note, rest, chord, or spacer as a multiplier of
    // the unit note length: the parsed modifier as-is, or 1/1 when no modifier
    // was written. Resolution against `L:`/`M:` is the resolver's job, not the
    // parser's.
    private func _writtenLength(_ length: ABCLength?) -> ABCLength {
        length ?? ABCLength(numerator: 1).require()
    }
}
