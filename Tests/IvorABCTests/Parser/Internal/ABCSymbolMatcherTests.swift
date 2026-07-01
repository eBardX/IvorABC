// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCSymbolMatcherTests {
}

// MARK: -

extension ABCSymbolMatcherTests {
    @Test
    func matchSymbols_barLine() throws {
        let symbols = try matchSymbols("|")

        #expect(symbols == [.barLine(makeBarLine())])
    }

    @Test
    func matchSymbols_barLine_abbreviatedEnding_decomposes() throws {
        let symbols = try matchSymbols(":|2")

        #expect(symbols == [.barLine(makeBarLine(.repeat, precedingPlayCount: 2)),
                            .variantEnding(makeVariantEnding([2...2]))])
    }

    @Test
    func matchSymbols_barLine_abbreviatedEndingList_decomposes() throws {
        let symbols = try matchSymbols("|1,3-5")

        #expect(symbols == [.barLine(makeBarLine()),
                            .variantEnding(makeVariantEnding([1...1, 3...5]))])
    }

    @Test
    func matchSymbols_beamBreak_spaceSeparated_producesBeamBreakSymbol() throws {
        let symbols = try matchSymbols("C D")

        #expect(symbols == [.note(makeNote(makePitch(.c, .omitted, 4),
                                           makeLength(1, 1))),
                            .beamBreak,
                            .note(makeNote(makePitch(.d, .omitted, 4),
                                           makeLength(1, 1)))])
    }

    @Test
    func matchSymbols_brokenRhythm() throws {
        let symbols = try matchSymbols(">")

        #expect(symbols == [.brokenRhythm(.dotted)])
    }

    @Test
    func matchSymbols_brokenRhythm_doubleRight() throws {
        let symbols = try matchSymbols(">>")

        #expect(symbols == [.brokenRhythm(.doubleDotted)])
    }

    @Test
    func matchSymbols_brokenRhythm_left() throws {
        let symbols = try matchSymbols("<")

        #expect(symbols == [.brokenRhythm(.reverseDotted)])
    }

    @Test
    func matchSymbols_chord() throws {
        let symbols = try matchSymbols("[CE]")

        let notes: [ABCNote] = [makeNote(makePitch(.c, .omitted, 4), makeLength(1, 1)),
                                makeNote(makePitch(.e, .omitted, 4), makeLength(1, 1))]
        let expected: [ABCSymbol] = [.chord(makeChord(notes, makeLength(1, 1)))]

        #expect(symbols == expected)
    }

    @Test
    func matchSymbols_chordSymbol() throws {
        let symbols = try matchSymbols("\"Am\"")

        #expect(symbols == [.chordSymbol(ABCChordSymbol(name: .init(root: .a, kind: "m")))])
    }

    @Test
    func matchSymbols_chord_length() throws {
        let symbols = try matchSymbols("[CEG]2")

        if case let .chord(chord) = try #require(symbols.first) {
            #expect(chord.notes.count == 3)
            #expect(chord.length == makeLength(2, 1))
            #expect(chord.tie == nil)
        } else {
            Issue.record("Expected .chord")
        }
    }

    @Test
    func matchSymbols_chord_fractionLength() throws {
        let symbols = try matchSymbols("[CEG]/2")

        if case let .chord(chord) = try #require(symbols.first) {
            #expect(chord.notes.count == 3)
            #expect(chord.length == makeLength(1, 2))
            #expect(chord.tie == nil)
        } else {
            Issue.record("Expected .chord")
        }
    }

    @Test
    func matchSymbols_chord_tied() throws {
        let symbols = try matchSymbols("[CEG]-")

        if case let .chord(chord) = try #require(symbols.first) {
            #expect(chord.notes.count == 3)
            #expect(chord.tie == .regular)
        } else {
            Issue.record("Expected .chord")
        }
    }

    @Test
    func matchSymbols_shorthand_tilde() throws {
        let symbols = try matchSymbols("~")

        #expect(symbols == [.shorthand(.tilde)])
    }

    @Test
    func matchSymbols_shorthand_upperW() throws {
        let symbols = try matchSymbols("W")

        #expect(symbols == [.shorthand(.wUpper)])
    }

    @Test
    func matchSymbols_shorthand_userDefinedSymbol_stillEmitsShorthand() throws {
        // Whether a shorthand is defined is a semantic concern handled by the
        // validator; the matcher emits the shorthand regardless.
        let symbols = try matchSymbols("W")

        #expect(symbols == [.shorthand(.wUpper)])
    }

    @Test
    func matchSymbols_shorthand_annotationDefinedSymbol_emitsShorthand() throws {
        let symbols = try matchSymbols("N")

        #expect(symbols == [.shorthand(.nUpper)])
    }

    @Test
    func matchSymbols_shorthand_deassigned_emitsShorthand() throws {
        let symbols = try matchSymbols("T")

        #expect(symbols == [.shorthand(.tUpper)])
    }

    @Test
    func matchSymbols_decoration_legacyPlusSyntax() throws {
        let symbols = try matchSymbols("+trill+")

        #expect(symbols == [.decoration(makeDecoration("trill", .plus))])
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
                                                                          makeLength(1, 1))],
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
            #expect(sig == makeKeySignature(.g, .major))
        } else {
            Issue.record("Expected .inlineField(.key)")
        }
    }

    @Test
    func matchSymbols_note_uppercase() throws {
        let symbols = try matchSymbols("C")

        let expected: [ABCSymbol] = [.note(makeNote(makePitch(.c, .omitted, 4),
                                                    makeLength(1, 1)))]

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

        #expect(symbols == [.rest(.regular(false, makeLength(1, 1)))])
    }

    @Test
    func matchSymbols_slur() throws {
        let symbols = try matchSymbols("(")

        #expect(symbols == [.slur(.startRegular)])
    }

    @Test
    func matchSymbols_slur_close() throws {
        let symbols = try matchSymbols(")")

        #expect(symbols == [.slur(.endRegular)])
    }

    @Test
    func matchSymbols_slur_dottedStart() throws {
        let symbols = try matchSymbols(".(")

        #expect(symbols == [.slur(.startDotted)])
    }

    @Test
    func matchSymbols_slur_dottedEnd() throws {
        let symbols = try matchSymbols(".)")

        #expect(symbols == [.slur(.endDotted)])
    }

    @Test
    func matchSymbols_spacer() throws {
        let symbols = try matchSymbols("y")

        #expect(symbols == [.spacer(makeLength(1, 1))])
    }

    @Test
    func matchSymbols_spacer_withLength() throws {
        let symbols = try matchSymbols("y2")

        #expect(symbols == [.spacer(makeLength(2, 1))])
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
