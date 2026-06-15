// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCSymbolMatcherTests {
}

// MARK: -

extension ABCSymbolMatcherTests {
    @Test
    func matchSymbols_barRepeat() throws {
        let symbols = try matchSymbols("|")

        #expect(symbols == [.barRepeat("|")])
    }

    @Test
    func matchSymbols_beamBreak_spaceSeparated_producesBeamBreakSymbol() throws {
        let symbols = try matchSymbols("C D")

        #expect(symbols == [.note(makeNote(makePitch(.c, .omitted, 4),
                                           makeDuration(1, 8),
                                           false)),
                            .beamBreak,
                            .note(makeNote(makePitch(.d, .omitted, 4),
                                           makeDuration(1, 8),
                                           false))])
    }

    @Test
    func matchSymbols_brokenRhythm() throws {
        let symbols = try matchSymbols(">")

        #expect(symbols == [.brokenRhythm(">")])
    }

    @Test
    func matchSymbols_brokenRhythm_doubleRight() throws {
        let symbols = try matchSymbols(">>")

        #expect(symbols == [.brokenRhythm(">>")])
    }

    @Test
    func matchSymbols_brokenRhythm_left() throws {
        let symbols = try matchSymbols("<")

        #expect(symbols == [.brokenRhythm("<")])
    }

    @Test
    func matchSymbols_chord() throws {
        let symbols = try matchSymbols("[CE]")

        let notes: [ABCNote] = [makeNote(makePitch(.c, .omitted, 4),
                                         makeDuration(1, 8),
                                         false),
                                makeNote(makePitch(.e, .omitted, 4),
                                         makeDuration(1, 8),
                                         false)]
        let expected: [ABCSymbol] = [.chord(makeChord(notes, makeDuration(1, 8), false))]

        #expect(symbols == expected)
    }

    @Test
    func matchSymbols_chordSymbol() throws {
        let symbols = try matchSymbols("\"Am\"")

        #expect(symbols == [.chordSymbol("Am")])
    }

    @Test
    func matchSymbols_chord_duration() throws {
        let symbols = try matchSymbols("[CEG]2")

        if case let .chord(chord) = try #require(symbols.first) {
            #expect(chord.notes.count == 3)
            #expect(chord.duration == makeDuration(1, 4))
            #expect(!chord.isTied)
        } else {
            Issue.record("Expected .chord")
        }
    }

    @Test
    func matchSymbols_chord_fractionDuration() throws {
        let symbols = try matchSymbols("[CEG]/2")

        if case let .chord(chord) = try #require(symbols.first) {
            #expect(chord.notes.count == 3)
            #expect(chord.duration == makeDuration(1, 16))
            #expect(!chord.isTied)
        } else {
            Issue.record("Expected .chord")
        }
    }

    @Test
    func matchSymbols_chord_tied() throws {
        let symbols = try matchSymbols("[CEG]-")

        if case let .chord(chord) = try #require(symbols.first) {
            #expect(chord.notes.count == 3)
            #expect(chord.isTied)
        } else {
            Issue.record("Expected .chord")
        }
    }

    @Test
    func matchSymbols_decoration() throws {
        let symbols = try matchSymbols("~")

        #expect(symbols == [.decoration(makeDecoration("roll", "~", .bang))])
    }

    @Test
    func matchSymbols_decoration_legacyPlusSyntax() throws {
        let symbols = try matchSymbols("+trill+")

        #expect(symbols == [.decoration(makeDecoration("trill", nil, .plus))])
    }

    @Test
    func matchSymbols_decoration_undefinedUserSymbol_throws() {
        #expect(throws: (any Error).self) {
            try matchSymbols("W")
        }
    }

    @Test
    func matchSymbols_decoration_userDefinedSymbol() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .userSymbol(makeUserSymbol("W", makeDecoration("trill"))))

        let symbols = try matchSymbols("W", context: &ctx)

        #expect(symbols == [.decoration(makeDecoration("trill", "W", .bang))])
    }

    @Test
    func matchSymbols_empty() throws {
        let symbols = try matchSymbols("")

        #expect(symbols.isEmpty)
    }

    @Test
    func matchSymbols_graceNotes() throws {
        let symbols = try matchSymbols("{C}")

        let expected: [ABCSymbol] = [.graceNotes(makeGraceNotes([makeNote(makePitch(.c, .omitted, 4),
                                                                          makeDuration(1, 8),
                                                                          false)],
                                                                false))]

        #expect(symbols == expected)
    }

    @Test
    func matchSymbols_graceNotes_slash() throws {
        let symbols = try matchSymbols("{/C}")

        if case let .graceNotes(gn) = try #require(symbols.first) {
            #expect(gn.isSlashed)
            #expect(gn.notes.count == 1)
        } else {
            Issue.record("Expected .graceNotes")
        }
    }

    @Test
    func matchSymbols_inlineField() throws {
        let symbols = try matchSymbols("[K:G]")

        if case let .inlineField(field) = try #require(symbols.first),
           case let .key(sig) = field {
            #expect(sig == .standard(.g, .major, [], nil))
        } else {
            Issue.record("Expected .inlineField(.key)")
        }
    }

    @Test
    func matchSymbols_keyContextDoesNotAffectAccidentals() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .key(.standard(.g, .major, [], nil)))

        let symbols = try matchSymbols("F", context: &ctx)

        if case let .note(note) = try #require(symbols.first) {
            #expect(note.pitch.letter == .f)
            #expect(note.pitch.accidental == .omitted)
        } else {
            Issue.record("Expected .note")
        }
    }

    @Test
    func matchSymbols_macroCall_inlineFieldUpdate() throws {
        var ctx = ABCParseContext()

        let symbols = try matchSymbols("[m:~n=!trill!n]~G",
                                       context: &ctx)

        guard case .inlineField = try #require(symbols.first)
        else {
            Issue.record("Expected .inlineField first")
            return
        }

        guard case let .macroCall(call) = try #require(symbols.dropFirst().first)
        else {
            Issue.record("Expected .macroCall after inline field")
            return
        }

        #expect(call.trigger == "~G")
        #expect(!call.expansion.isEmpty)
    }

    @Test
    func matchSymbols_macroCall_longestTriggerWins() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(makeMacro("~G", "!trill!G")))
        ctx.update(with: .macro(makeMacro("~G2", "{A}G{F}G")))

        let symbols = try matchSymbols("~G2", context: &ctx)

        guard case let .macroCall(call) = try #require(symbols.first)
        else {
            Issue.record("Expected .macroCall")
            return
        }

        #expect(call.trigger == "~G2")
    }

    @Test
    func matchSymbols_macroCall_noMacrosFallsThroughToDecoration() throws {
        let symbols = try matchSymbols("~")

        #expect(symbols == [.decoration(makeDecoration("roll", "~", .bang))])
    }

    @Test
    func matchSymbols_macroCall_noMatchFallsThroughToDecoration() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(makeMacro("~A", "!trill!A")))

        let symbols = try matchSymbols("~", context: &ctx)

        #expect(symbols == [.decoration(makeDecoration("roll", "~", .bang))])
    }

    @Test
    func matchSymbols_macroCall_roundTrip() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(makeMacro("~G2", "{A}G{F}G")))

        let symbols = try matchSymbols("~G2", context: &ctx)

        let formatted = try symbols.map { try formatSymbol($0, makeDuration(1, 8), nil) }.joined()

        #expect(formatted == "~G2")
    }

    @Test
    func matchSymbols_macroCall_static() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(makeMacro("~G2", "{A}G{F}G")))

        let symbols = try matchSymbols("~G2", context: &ctx)

        let graceA = makeNote(makePitch(.a, .omitted, 4), makeDuration(1, 8), false)
        let graceF = makeNote(makePitch(.f, .omitted, 4), makeDuration(1, 8), false)
        let noteG  = makeNote(makePitch(.g, .omitted, 4), makeDuration(1, 8), false)

        let expansion: [ABCSymbol] = [.graceNotes(makeGraceNotes([graceA], false)),
                                      .note(noteG),
                                      .graceNotes(makeGraceNotes([graceF], false)),
                                      .note(noteG)]

        #expect(symbols == [.macroCall(makeMacroCall("~G2",
                                                     expansion))])
    }

    @Test
    func matchSymbols_macroCall_transposing() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(makeMacro("~n", "!trill!n")))

        let symbols = try matchSymbols("~G", context: &ctx)

        let expansion: [ABCSymbol] = [.decoration(makeDecoration("trill", nil, .bang)),
                                      .note(makeNote(makePitch(.g, .omitted, 4),
                                                     makeDuration(1, 8),
                                                     false))]

        #expect(symbols == [.macroCall(makeMacroCall("~G",
                                                     expansion))])
    }

    @Test
    func matchSymbols_note_uppercase() throws {
        let symbols = try matchSymbols("C")

        let expected: [ABCSymbol] = [.note(makeNote(makePitch(.c, .omitted, 4),
                                                    makeDuration(1, 8),
                                                    false))]

        #expect(symbols == expected)
    }

    @Test
    func matchSymbols_overlay() throws {
        let symbols = try matchSymbols("&")

        #expect(symbols == [.overlay])
    }

    @Test
    func matchSymbols_rest_multiMeasure() throws {
        let symbols = try matchSymbols("Z")

        #expect(symbols == [.rest(.multiMeasure(false, 1))])
    }

    @Test
    func matchSymbols_rest_regular() throws {
        let symbols = try matchSymbols("z")

        #expect(symbols == [.rest(.regular(false, makeDuration(1, 8)))])
    }

    @Test
    func matchSymbols_slur() throws {
        let symbols = try matchSymbols("(")

        #expect(symbols == [.slur("(")])
    }

    @Test
    func matchSymbols_slur_close() throws {
        let symbols = try matchSymbols(")")

        #expect(symbols == [.slur(")")])
    }

    @Test
    func matchSymbols_spacer() throws {
        let symbols = try matchSymbols("y")

        #expect(symbols == [.spacer(makeDuration(1, 8))])
    }

    @Test
    func matchSymbols_spacer_withDuration() throws {
        let symbols = try matchSymbols("y2")

        #expect(symbols == [.spacer(makeDuration(1, 4))])
    }

    @Test
    func matchSymbols_tuplet_pAndQ() throws {
        let symbols = try matchSymbols("(3:2")

        #expect(symbols == [.tuplet(makeTuplet(3, 2))])
    }

    @Test
    func matchSymbols_tuplet_pOnly() throws {
        let symbols = try matchSymbols("(3")

        #expect(symbols == [.tuplet(makeTuplet(3))])
    }

    @Test
    func matchSymbols_tuplet_pQAndR() throws {
        let symbols = try matchSymbols("(3:2:4")

        #expect(symbols == [.tuplet(makeTuplet(3, 2, 4))])
    }

    @Test
    func matchSymbols_variantEnding() throws {
        let symbols = try matchSymbols("[1")

        #expect(symbols == [.variantEnding(makeVariantEnding([1...1]))])
    }

    @Test
    func matchSymbols_variantEnding_list() throws {
        let symbols = try matchSymbols("[1,3")

        #expect(symbols == [.variantEnding(makeVariantEnding([1...1, 3...3]))])
    }

    @Test
    func matchSymbols_variantEnding_range() throws {
        let symbols = try matchSymbols("[1-3")

        #expect(symbols == [.variantEnding(makeVariantEnding([1...3]))])
    }
}
