// © 2026 John Gary Pusey (see LICENSE.md)

// swiftlint:disable file_length

import Foundation
@testable import IvorABC
import Testing
import XestiTools

struct ABCParserTests {
}

// MARK: -

extension ABCParserTests {
    @Test
    func parse_alignedLyrics_textEscapes_roundTrip() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nK:C\nCDEF|\nw:f\\'o \\\"u-zy foo\\%bar\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tune = try #require(tunebook.tunes.first)

        let lyricsEntry = tune.entries.first {
            if case .field(.alignedLyrics) = $0 {
                return true
            }

            return false
        }

        if case let .field(.alignedLyrics(al)) = lyricsEntry {
            #expect(al == makeAlignedLyrics([.syllable("fó"),
                                             .syllable("ü"),
                                             .continuation,
                                             .syllable("zy"),
                                             .syllable("foo%bar")]))
        } else {
            Issue.record("Expected .field(.alignedLyrics)")
        }

        let formatter = ABCFormatter()
        let outputData = try formatter.format(tunebook)
        let output = try #require(String(data: outputData, encoding: .utf8))

        #expect(output.contains("w:fó ü-zy foo\\%bar\n"))
    }

    @Test
    func parse_beamBreak_beamedSequence_hasNoBeamBreaks() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/8\nK:C\nABcd|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbols = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)

        #expect(!symbols.contains(.beamBreak))
    }

    @Test
    func parse_beamBreak_inlineFieldInBeam_doesNotBreakBeam() throws {
        // Per ABC v2.1 spec: inline fields can appear in the middle of a beam without breaking it.
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/8\nK:C\nAB[K:G]cd|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbols = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)

        #expect(!symbols.contains(.beamBreak))
    }

    @Test
    func parse_beamBreak_spaceSeparated_hasBeamBreaks() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/8\nK:C\nA B c d|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbols = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)

        let beamBreakCount = symbols.filter { $0 == .beamBreak }.count

        #expect(beamBreakCount == 3)
    }

    @Test
    func parse_beginEndBlock_beginValueStored() throws {
        let input = "%abc-2.1\n%%begintext justify\nSome text\n%%endtext\n\nX:1\nT:Test\nK:C\n|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let directive = try #require(tunebook.headers.compactMap { header -> ABCDirective? in
            guard case let .directive(d) = header
            else { return nil }

            return d
        }.first)

        #expect(directive.name == "text")
        #expect(directive.value == "justify")
        #expect(directive.content == ["Some text"])
    }

    @Test
    func parse_beginEndBlock_beginWithInlineComment() throws {
        let input = "%abc-2.1\n%%begintext%this is a comment\nLine one\n%%endtext\n\nX:1\nT:Test\nK:C\n|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let directive = try #require(tunebook.headers.compactMap { header -> ABCDirective? in
            guard case let .directive(d) = header
            else { return nil }

            return d
        }.first)

        #expect(directive.name == "text")
        #expect(directive.value.isEmpty)
        #expect(directive.content == ["Line one"])
    }

    @Test
    func parse_beginEndBlock_contentStoredAsLines() throws {
        let input = "%abc-2.1\n%%begintext\nLine one\nLine two\n%%endtext\n\nX:1\nT:Test\nK:C\n|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let directive = try #require(tunebook.headers.compactMap { header -> ABCDirective? in
            guard case let .directive(d) = header
            else { return nil }

            return d
        }.first)

        #expect(directive.name == "text")
        #expect(directive.value.isEmpty)
        #expect(directive.content == ["Line one", "Line two"])
    }

    @Test
    func parse_beginEndBlock_endWithInlineComment() throws {
        let input = "%abc-2.1\n%%begintext\nLine one\n%%endtext%this is a comment\n\nX:1\nT:Test\nK:C\n|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let directive = try #require(tunebook.headers.compactMap { header -> ABCDirective? in
            guard case let .directive(d) = header
            else { return nil }

            return d
        }.first)

        #expect(directive.name == "text")
        #expect(directive.value.isEmpty)
        #expect(directive.content == ["Line one"])
    }

    @Test
    func parse_beginEndBlock_inTuneBody() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nK:C\n%%beginsvg\n<rect/>\n%%endsvg\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tune = try #require(tunebook.tunes.first)
        let directive = try #require(tune.entries.compactMap { entry -> ABCDirective? in
            guard case let .directive(d) = entry
            else { return nil }

            return d
        }.first)

        #expect(directive.name == "svg")
        #expect(directive.value.isEmpty)
        #expect(directive.content == ["<rect/>"])
    }

    @Test
    func parse_beginEndBlock_unclosedThrows() {
        let input = "%abc-2.1\n%%begintext\nLine one\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        #expect(throws: ABCParser.Error.self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_brokenRhythm_doubleRight_producesSymbol() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/8\nK:C\nC>>D|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbols = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)

        let brokenRhythms = symbols.compactMap { sym -> ABCBrokenRhythm? in
            guard case let .brokenRhythm(br) = sym
            else { return nil }

            return br
        }

        #expect(brokenRhythms == [.doubleDotted])
    }

    @Test
    func parse_emptyTunebook_throws() {
        let input = "%abc-2.1\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        #expect(throws: ABCParser.Error.self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_fieldContinuation_mergesIntoField() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nH:First line\n+:Second line\nK:C\n|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tune = try #require(tunebook.tunes.first)

        let historyEntries = tune.entries.filter {
            if case .field(.history) = $0 {
                return true
            }

            return false
        }

        #expect(historyEntries.count == 1)

        if case let .field(.history(text)) = historyEntries[0] {
            #expect(text == "First line Second line")
        } else {
            Issue.record("Expected .field(.history)")
        }
    }

    @Test
    func parse_instruction_equivalentToDirective() throws {
        let directiveInput = "%abc-2.1\n\nX:1\nT:Test\nK:C\n%%pagewidth 21cm\nCDEF|\n"
        let instructionInput = "%abc-2.1\n\nX:1\nT:Test\nK:C\nI:pagewidth 21cm\nCDEF|\n"
        let parser = ABCParser()

        let directiveTunebook = try parser.parse(Data(directiveInput.utf8))
        let instructionTunebook = try parser.parse(Data(instructionInput.utf8))

        #expect(directiveTunebook.tunes[0] == instructionTunebook.tunes[0])
    }

    @Test
    func parse_invalidUTF8_throws() {
        let data = Data([0xff, 0xfe])
        let parser = ABCParser()

        #expect(throws: ABCParser.Error.self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_keyHP_noAccidentals() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/4\nK:HP\nCFG|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tune = try #require(tunebook.tunes.first)
        let symbolLine = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)
        let notes = symbolLine.compactMap { sym -> ABCNote? in
            guard case let .note(n) = sym
            else { return nil }

            return n
        }

        #expect(notes.count == 3)
        #expect(notes[0].pitch.letter == .c)
        #expect(notes[0].pitch.accidental == .omitted)
        #expect(notes[1].pitch.letter == .f)
        #expect(notes[1].pitch.accidental == .omitted)
        #expect(notes[2].pitch.letter == .g)
        #expect(notes[2].pitch.accidental == .omitted)
    }

    @Test
    func parse_keyHp_presetAccidentalsInContext() throws {
        // K:Hp sets accidentalsInKey (C♯, F♯, G♮), but the parser stores written
        // pitch only — no implicit accidentals are folded into notes. The preset
        // accidentals are available via the parse context for callers who need them.
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/4\nK:Hp\nCFG|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tune = try #require(tunebook.tunes.first)
        let symbolLine = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)
        let notes = symbolLine.compactMap { sym -> ABCNote? in
            guard case let .note(n) = sym
            else { return nil }

            return n
        }

        #expect(notes.count == 3)
        #expect(notes[0].pitch.letter == .c)
        #expect(notes[0].pitch.accidental == .omitted)
        #expect(notes[1].pitch.letter == .f)
        #expect(notes[1].pitch.accidental == .omitted)
        #expect(notes[2].pitch.letter == .g)
        #expect(notes[2].pitch.accidental == .omitted)
    }

    @Test
    func parse_lineContinuation_fieldLineBreaksAccumulation() throws {
        // A w: lyrics field appearing between two \-continued music lines must
        // be emitted as its own field, not merged into the joined music line.
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/4\nK:C\nCDE\\\nw: do re mi\\\nFGA|\nw: fa sol la\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbolEntries = tune.entries.filter { if case .symbols = $0 { true } else { false } }
        let lyricsEntries = tune.entries.filter { if case .field(.alignedLyrics) = $0 { true } else { false } }

        #expect(symbolEntries.count == 2)
        #expect(lyricsEntries.count == 2)
    }

    @Test
    func parse_lineContinuation_inlineFieldBreaksAccumulation() throws {
        // An M: meter change between two \-continued music lines must be emitted
        // as its own field, not merged into the joined music line.
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/8\nK:C\nCDEF\\\nM:3/4\nGAB|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let meterEntries = tune.entries.filter { if case .field(.meter) = $0 { true } else { false } }

        #expect(meterEntries.count == 1)
    }

    @Test
    func parse_lineContinuation_joinsContinuedLines() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/4\nK:C\nCDE\\\nFGA|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tune = try #require(tunebook.tunes.first)

        // Continued lines should merge into one .symbols entry
        let symbolEntries = tune.entries.filter {
            if case .symbols = $0 {
                return true
            }

            return false
        }

        #expect(symbolEntries.count == 1)

        if case let .symbols(symbols) = symbolEntries[0] {
            let notes = symbols.compactMap { sym -> ABCNote? in
                guard case let .note(n) = sym
                else { return nil }

                return n
            }

            #expect(notes.count == 6)
        } else {
            Issue.record("Expected .symbols")
        }
    }

    @Test
    func parse_minimalTune() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test Tune\nK:C\nCDEF|GABc|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.tunes.count == 1)

        let tune = tunebook.tunes[0]

        #expect(!tune.entries.isEmpty)
    }

    @Test
    func parse_missingFileID_throws() {
        let input = "X:1\nT:Test\nK:C\nabc\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        #expect(throws: ABCParser.Error.self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_multipleTunes() throws {
        let input = "%abc-2.1\n\nX:1\nT:First\nK:C\nCDEF|\n\nX:2\nT:Second\nK:G\nGABc|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.tunes.count == 2)
    }

    @Test
    func parse_overlay_multipleMarkers() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/4\nK:C\nCDEF&GABG&CDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tune = try #require(tunebook.tunes.first)
        let symbols = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)

        let overlayCount = symbols.filter { $0 == .overlay }.count

        #expect(overlayCount == 2)
    }

    @Test
    func parse_overlay_preservesSurroundingNotes() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/4\nK:C\nCG&EG|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tune = try #require(tunebook.tunes.first)
        let symbols = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)

        let overlayIndex = try #require(symbols.indices.first { symbols[$0] == .overlay })

        let notesBefore = symbols[..<overlayIndex].compactMap { sym -> ABCNote? in
            guard case let .note(n) = sym
            else { return nil }

            return n
        }
        let notesAfter = symbols[overlayIndex...].dropFirst().compactMap { sym -> ABCNote? in
            guard case let .note(n) = sym
            else { return nil }

            return n
        }

        #expect(notesBefore.count == 2)
        #expect(notesBefore[0].pitch.letter == .c)
        #expect(notesBefore[1].pitch.letter == .g)
        #expect(notesAfter.count == 2)
        #expect(notesAfter[0].pitch.letter == .e)
        #expect(notesAfter[1].pitch.letter == .g)
    }

    @Test
    func parse_overlay_singleMarker() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/4\nK:C\nCDEF&GABC|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tune = try #require(tunebook.tunes.first)
        let symbols = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)

        let overlayIndices = symbols.indices.filter { symbols[$0] == .overlay }

        #expect(overlayIndices.count == 1)
    }

    @Test
    func parse_percentEscape_roundTrips() throws {
        let input = "%abc-2.1\n\nX:1\nT:Foo \\% Bar\nK:C\n|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tune = try #require(tunebook.tunes.first)

        let titleEntry = tune.entries.first {
            if case .field(.title) = $0 {
                return true
            }

            return false
        }

        if case let .field(.title(text)) = titleEntry {
            #expect(text == "Foo % Bar")
        } else {
            Issue.record("Expected .field(.title)")
        }

        let formatter = ABCFormatter()
        let outputData = try formatter.format(tunebook)
        let output = try #require(String(data: outputData, encoding: .utf8))

        #expect(output.contains("T:Foo \\% Bar\n"))
    }

    @Test
    func parse_percentEscape_stripsCommentNormalizesWhitespace() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nH:  Foo  \\%    Bar   % This is a comment\nK:C\n|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)
        let tune = try #require(tunebook.tunes.first)

        let historyEntry = tune.entries.first {
            if case .field(.history) = $0 {
                return true
            }

            return false
        }

        if case let .field(.history(text)) = historyEntry {
            #expect(text == "Foo % Bar")
        } else {
            Issue.record("Expected .field(.history)")
        }

        let formatter = ABCFormatter()
        let outputData = try formatter.format(tunebook)
        let output = try #require(String(data: outputData, encoding: .utf8))

        #expect(output.contains("H:Foo \\% Bar\n"))
    }

    @Test
    func parse_slur_nested_producesOpenClosePairs() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/8\nK:C\n(C(DE)F)|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbols = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)

        let slurs = symbols.compactMap { sym -> ABCSlur? in
            guard case let .slur(s) = sym
            else { return nil }

            return s
        }

        #expect(slurs == [.startRegular, .startRegular, .endRegular, .endRegular])
    }

    @Test
    func parse_slur_openAndClose_producesSymbols() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/8\nK:C\n(CD)|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbols = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)

        let slurs = symbols.compactMap { sym -> ABCSlur? in
            guard case let .slur(s) = sym
            else { return nil }

            return s
        }

        #expect(slurs == [.startRegular, .endRegular])
    }

    @Test
    func parse_slur_dottedAndRegular_mixedWithStaccatoAndTies() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/8\nK:C\n.C.(D.-E.) (F-G)|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbols = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)

        let cNote = makeNote(makePitch(.c, .omitted, 4), makeDuration(1, 8))
        let dNote = makeNote(makePitch(.d, .omitted, 4), makeDuration(1, 8), .dotted)
        let eNote = makeNote(makePitch(.e, .omitted, 4), makeDuration(1, 8))
        let fNote = makeNote(makePitch(.f, .omitted, 4), makeDuration(1, 8), .regular)
        let gNote = makeNote(makePitch(.g, .omitted, 4), makeDuration(1, 8))

        #expect(symbols == [.shorthand(.dot),
                            .note(cNote),
                            .slur(.startDotted),
                            .note(dNote),
                            .note(eNote),
                            .slur(.endDotted),
                            .beamBreak,
                            .slur(.startRegular),
                            .note(fNote),
                            .note(gNote),
                            .slur(.endRegular),
                            .barRepeat("|")])
    }

    @Test
    func parse_spacer_producesSpacerSymbol() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/8\nK:C\nyC|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbols = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)

        #expect(symbols.first == .spacer(makeDuration(1, 8)))
    }

    @Test
    func parse_spacer_withDuration_producesCorrectDuration() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/8\nK:C\ny2|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbols = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)

        let spacerDurations = symbols.compactMap { sym -> ABCDuration? in
            guard case let .spacer(d) = sym
            else { return nil }

            return d
        }

        #expect(spacerDurations.first == makeDuration(1, 4))
    }

    @Test
    func parse_tuneWithDirective() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\n%%pagewidth 21cm\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_tunebookWithFileHeaders() throws {
        let input = "%abc-2.1\nM:4/4\nL:1/8\n\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.headers.count == 2)
        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func parse_unsupportedVersion_throws() {
        let input = "%abc-3.0\nX:1\nT:Test\nK:C\nabc\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        #expect(throws: ABCParser.Error.self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_variantEnding_range_producesRangeEnding() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\nL:1/8\nK:C\n|[1-3 C|\n"
        let tunebook = try ABCParser().parse(Data(input.utf8))
        let tune = try #require(tunebook.tunes.first)

        let symbols = try #require(tune.entries.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(s) = entry
            else { return nil }

            return s
        }.first)

        let endings = symbols.compactMap { sym -> ABCVariantEnding? in
            guard case let .variantEnding(ve) = sym
            else { return nil }

            return ve
        }

        #expect(endings.first?.endings == [1...3])
    }
}
