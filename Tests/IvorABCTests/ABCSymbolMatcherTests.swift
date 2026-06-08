// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCSymbolMatcherTests {
}

// MARK: -

extension ABCSymbolMatcherTests {
    @Test
    func matchSymbols_barRepeat() throws {
        let symbols = try _matchSymbols("|")

        #expect(symbols == [.barRepeat("|")])
    }

    @Test
    func matchSymbols_brokenRhythm() throws {
        let symbols = try _matchSymbols(">")

        #expect(symbols == [.brokenRhythm(">")])
    }

    @Test
    func matchSymbols_chord() throws {
        let symbols = try _matchSymbols("[CE]")

        let expected: [ABCSymbol] = [.chord([ABCNote(pitch: _pit(.c, .omitted, 4),
                                                     duration: _dur(1, 8),
                                                     isTied: false),
                                             ABCNote(pitch: _pit(.e, .omitted, 4),
                                                     duration: _dur(1, 8),
                                                     isTied: false)],
                                            _dur(1, 8),
                                            false)]

        #expect(symbols == expected)
    }

    @Test
    func matchSymbols_chord_duration() throws {
        let symbols = try _matchSymbols("[CEG]2")

        if case let .chord(notes, duration, isTied) = try #require(symbols.first) {
            #expect(notes.count == 3)
            #expect(duration == _dur(1, 4))
            #expect(!isTied)
        } else {
            Issue.record("Expected .chord")
        }
    }

    @Test
    func matchSymbols_chord_fractionDuration() throws {
        let symbols = try _matchSymbols("[CEG]/2")

        if case let .chord(notes, duration, isTied) = try #require(symbols.first) {
            #expect(notes.count == 3)
            #expect(duration == _dur(1, 16))
            #expect(!isTied)
        } else {
            Issue.record("Expected .chord")
        }
    }

    @Test
    func matchSymbols_chord_tied() throws {
        let symbols = try _matchSymbols("[CEG]-")

        if case let .chord(notes, _, isTied) = try #require(symbols.first) {
            #expect(notes.count == 3)
            #expect(isTied)
        } else {
            Issue.record("Expected .chord")
        }
    }

    @Test
    func matchSymbols_chordSymbol() throws {
        let symbols = try _matchSymbols("\"Am\"")

        #expect(symbols == [.chordSymbol("Am")])
    }

    @Test
    func matchSymbols_decoration() throws {
        let symbols = try _matchSymbols("~")

        #expect(symbols == [.decoration(ABCDecoration(name: "roll", shorthand: "~"))])
    }

    @Test
    func matchSymbols_decoration_undefinedUserSymbol_throws() {
        #expect(throws: (any Error).self) {
            try _matchSymbols("W")
        }
    }

    @Test
    func matchSymbols_decoration_userDefinedSymbol() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .userSymbol(_usym("W", "!trill!")))

        let symbols = try _matchSymbols("W", context: &ctx)

        #expect(symbols == [.decoration(ABCDecoration(name: "trill", shorthand: "W"))])
    }

    @Test
    func matchSymbols_empty() throws {
        let symbols = try _matchSymbols("")

        #expect(symbols.isEmpty)
    }

    @Test
    func matchSymbols_graceNotes() throws {
        let symbols = try _matchSymbols("{C}")

        let expected: [ABCSymbol] = [.graceNotes(false, [ABCNote(pitch: _pit(.c, .omitted, 4),
                                                                 duration: _dur(1, 8),
                                                                 isTied: false)])]

        #expect(symbols == expected)
    }

    @Test
    func matchSymbols_graceNotes_slash() throws {
        let symbols = try _matchSymbols("{/C}")

        if case let .graceNotes(hasSlash, notes) = try #require(symbols.first) {
            #expect(hasSlash)
            #expect(notes.count == 1)
        } else {
            Issue.record("Expected .graceNotes")
        }
    }

    @Test
    func matchSymbols_inlineField() throws {
        let symbols = try _matchSymbols("[K:G]")

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

        let symbols = try _matchSymbols("F", context: &ctx)

        if case let .note(note) = try #require(symbols.first) {
            #expect(note.pitch.letter == .f)
            #expect(note.pitch.accidental == .omitted)
        } else {
            Issue.record("Expected .note")
        }
    }

    @Test
    func matchSymbols_note_uppercase() throws {
        let symbols = try _matchSymbols("C")

        let expected: [ABCSymbol] = [.note(ABCNote(pitch: _pit(.c, .omitted, 4),
                                                   duration: _dur(1, 8),
                                                   isTied: false))]

        #expect(symbols == expected)
    }

    @Test
    func matchSymbols_overlay() throws {
        let symbols = try _matchSymbols("&")

        #expect(symbols == [.overlay])
    }

    @Test
    func matchSymbols_rest_multiMeasure() throws {
        let symbols = try _matchSymbols("Z")

        #expect(symbols == [.rest(.multiMeasure(false, 1))])
    }

    @Test
    func matchSymbols_rest_regular() throws {
        let symbols = try _matchSymbols("z")

        #expect(symbols == [.rest(.regular(false, _dur(1, 8)))])
    }

    @Test
    func matchSymbols_slur() throws {
        let symbols = try _matchSymbols("(")

        #expect(symbols == [.slur("(")])
    }

    @Test
    func matchSymbols_tuplet_pOnly() throws {
        let symbols = try _matchSymbols("(3")

        #expect(symbols == [.tuplet(ABCTuplet(noteCount: 3))])
    }

    @Test
    func matchSymbols_tuplet_pAndQ() throws {
        let symbols = try _matchSymbols("(3:2")

        #expect(symbols == [.tuplet(ABCTuplet(noteCount: 3, beatCount: 2))])
    }

    @Test
    func matchSymbols_tuplet_pQAndR() throws {
        let symbols = try _matchSymbols("(3:2:4")

        #expect(symbols == [.tuplet(ABCTuplet(noteCount: 3, beatCount: 2, affectedCount: 4))])
    }

    @Test
    func matchSymbols_decoration_legacyPlusSyntax() throws {
        let symbols = try _matchSymbols("+trill+")

        #expect(symbols == [.decoration(ABCDecoration(name: "trill", shorthand: nil))])
    }

    @Test
    func matchSymbols_spacer() throws {
        let symbols = try _matchSymbols("y")

        #expect(symbols == [.spacer(_dur(1, 8))])
    }

    @Test
    func matchSymbols_spacer_withDuration() throws {
        let symbols = try _matchSymbols("y2")

        #expect(symbols == [.spacer(_dur(1, 4))])
    }

    @Test
    func matchSymbols_variantEnding() throws {
        let symbols = try _matchSymbols("[1")

        #expect(symbols == [.variantEnding(ABCVariantEnding(endings: [1...1]))])
    }

    @Test
    func matchSymbols_macroCall_static() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(ABCMacro(trigger: "~G2", replacement: "{A}G{F}G")))

        let symbols = try _matchSymbols("~G2", context: &ctx)

        let graceA = ABCNote(pitch: _pit(.a, .omitted, 4), duration: _dur(1, 8), isTied: false)
        let graceF = ABCNote(pitch: _pit(.f, .omitted, 4), duration: _dur(1, 8), isTied: false)
        let noteG  = ABCNote(pitch: _pit(.g, .omitted, 4), duration: _dur(1, 8), isTied: false)

        let expansion: [ABCSymbol] = [.graceNotes(false, [graceA]),
                                      .note(noteG),
                                      .graceNotes(false, [graceF]),
                                      .note(noteG)]

        #expect(symbols == [.macroCall(ABCMacroCall(trigger: "~G2",
                                                    expansion: expansion))])
    }

    @Test
    func matchSymbols_macroCall_transposing() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(ABCMacro(trigger: "~n", replacement: "!trill!n")))

        let symbols = try _matchSymbols("~G", context: &ctx)

        let expansion: [ABCSymbol] = [.decoration(ABCDecoration(name: "trill", shorthand: nil)),
                                      .note(ABCNote(pitch: _pit(.g, .omitted, 4),
                                                    duration: _dur(1, 8),
                                                    isTied: false))]

        #expect(symbols == [.macroCall(ABCMacroCall(trigger: "~G",
                                                    expansion: expansion))])
    }

    @Test
    func matchSymbols_macroCall_longestTriggerWins() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(ABCMacro(trigger: "~G", replacement: "!trill!G")))
        ctx.update(with: .macro(ABCMacro(trigger: "~G2", replacement: "{A}G{F}G")))

        let symbols = try _matchSymbols("~G2", context: &ctx)

        guard case let .macroCall(call) = try #require(symbols.first) else {
            Issue.record("Expected .macroCall")
            return
        }

        #expect(call.trigger == "~G2")
    }

    @Test
    func matchSymbols_macroCall_inlineFieldUpdate() throws {
        var ctx = ABCParseContext()

        let symbols = try _matchSymbols("[m:~n=!trill!n]~G", context: &ctx)

        guard case .inlineField = try #require(symbols.first) else {
            Issue.record("Expected .inlineField first")
            return
        }

        guard case let .macroCall(call) = try #require(symbols.dropFirst().first) else {
            Issue.record("Expected .macroCall after inline field")
            return
        }

        #expect(call.trigger == "~G")
        #expect(!call.expansion.isEmpty)
    }

    @Test
    func matchSymbols_macroCall_roundTrip() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(ABCMacro(trigger: "~G2", replacement: "{A}G{F}G")))

        let symbols = try _matchSymbols("~G2", context: &ctx)

        let formatted = try symbols.map { try formatSymbol($0, _dur(1, 8), nil) }.joined()

        #expect(formatted == "~G2")
    }

    @Test
    func matchSymbols_macroCall_noMatchFallsThroughToDecoration() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(ABCMacro(trigger: "~A", replacement: "!trill!A")))

        let symbols = try _matchSymbols("~", context: &ctx)

        #expect(symbols == [.decoration(ABCDecoration(name: "roll", shorthand: "~"))])
    }

    @Test
    func matchSymbols_macroCall_noMacrosFallsThroughToDecoration() throws {
        let symbols = try _matchSymbols("~")

        #expect(symbols == [.decoration(ABCDecoration(name: "roll", shorthand: "~"))])
    }
}
