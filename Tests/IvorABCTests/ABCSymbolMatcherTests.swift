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

        let expected: [ABCSymbol] = [.chord([ABCNote(pitch: _pit(.c, .natural, 4),
                                                     duration: _dur(1, 8),
                                                     isTied: false),
                                             ABCNote(pitch: _pit(.e, .natural, 4),
                                                     duration: _dur(1, 8),
                                                     isTied: false)])]

        #expect(symbols == expected)
    }

    @Test
    func matchSymbols_chordSymbol() throws {
        let symbols = try _matchSymbols("\"Am\"")

        #expect(symbols == [.chordSymbol("Am")])
    }

    @Test
    func matchSymbols_decoration() throws {
        let symbols = try _matchSymbols("~")

        #expect(symbols == [.decoration("~")])
    }

    @Test
    func matchSymbols_empty() throws {
        let symbols = try _matchSymbols("")

        #expect(symbols.isEmpty)
    }

    @Test
    func matchSymbols_graceNotes() throws {
        let symbols = try _matchSymbols("{C}")

        let expected: [ABCSymbol] = [.graceNotes(false, [ABCNote(pitch: _pit(.c, .natural, 4),
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
    func matchSymbols_keyContextAffectsAccidentals() throws {
        var ctx = ABCParseContext()

        ctx.update(with: .key(.standard(.g, .major, [], nil)))

        let symbols = try _matchSymbols("F", context: &ctx)

        if case let .note(note) = try #require(symbols.first) {
            #expect(note.pitch.letter == .f)
            #expect(note.pitch.accidental == .sharp)
        } else {
            Issue.record("Expected .note")
        }
    }

    @Test
    func matchSymbols_note_uppercase() throws {
        let symbols = try _matchSymbols("C")

        let expected: [ABCSymbol] = [.note(ABCNote(pitch: _pit(.c, .natural, 4),
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
    func matchSymbols_tuplet() throws {
        let symbols = try _matchSymbols("(3")

        #expect(symbols == [.tuplet(3, 2, 3)])
    }

    @Test
    func matchSymbols_variantEnding() throws {
        let symbols = try _matchSymbols("[1")

        #expect(symbols == [.variantEnding("[1")])
    }
}
