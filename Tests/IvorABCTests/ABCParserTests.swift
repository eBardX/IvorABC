// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorABC
import Testing

struct ABCParserTests {
}

// MARK: -

extension ABCParserTests {
    @Test
    func parse_beginEndBlock_beginValueStored() throws {
        let input = "%abc-2.1\n%%begintext justify\nSome text\n%%endtext\n"
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
        let input = "%abc-2.1\n%%begintext%this is a comment\nLine one\n%%endtext\n"
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
        let input = "%abc-2.1\n%%begintext\nLine one\nLine two\n%%endtext\n"
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
        let input = "%abc-2.1\n%%begintext\nLine one\n%%endtext%this is a comment\n"
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

        #expect(throws: ABCParseError.self) {
            try parser.parse(data)
        }
    }

    @Test
    func parse_emptyTunebook() throws {
        let input = "%abc-2.1\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.version.major == 2)
        #expect(tunebook.version.minor == 1)
        #expect(tunebook.headers.isEmpty)
        #expect(tunebook.tunes.isEmpty)
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

        #expect(throws: ABCParseError.self) {
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
        #expect(notes[0].pitch.accidental == .natural)
        #expect(notes[1].pitch.letter == .f)
        #expect(notes[1].pitch.accidental == .natural)
        #expect(notes[2].pitch.letter == .g)
        #expect(notes[2].pitch.accidental == .natural)
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
        #expect(notes[0].pitch.accidental == .natural)
        #expect(notes[1].pitch.letter == .f)
        #expect(notes[1].pitch.accidental == .natural)
        #expect(notes[2].pitch.letter == .g)
        #expect(notes[2].pitch.accidental == .natural)
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

        #expect(throws: ABCParseError.self) {
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
    func parse_tunebookWithFileHeaders() throws {
        let input = "%abc-2.1\nM:4/4\nL:1/8\n\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.headers.count == 2)
        #expect(tunebook.tunes.count == 1)
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
    func parse_unsupportedVersion_throws() {
        let input = "%abc-3.0\nX:1\nT:Test\nK:C\nabc\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        #expect(throws: ABCParseError.self) {
            try parser.parse(data)
        }
    }
}
