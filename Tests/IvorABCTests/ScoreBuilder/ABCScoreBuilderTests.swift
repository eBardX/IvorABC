// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCScoreBuilderTests {
}

// MARK: -

extension ABCScoreBuilderTests {
    @Test
    func build_throwsNotValidated_whenTunebookNotValidated() {
        let book = makeTunebook([makeTune(header: [.field(.key(makeKeySignature(.c, .major)))])])

        #expect(throws: ABCScoreBuilder.Error.notValidated) {
            try ABCScoreBuilder().build(book)
        }
    }

    @Test
    func build_throwsUnsupportedOption_whenOptimizeForPlaybackSet() throws {
        #expect(throws: ABCScoreBuilder.Error.unsupportedOption) {
            try buildScores(minimalTunebook(), options: .optimizeForPlayback)
        }
    }

    @Test
    func build_returnsOneScorePerTune_inOrder() throws {
        let book = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                   .field(.tuneTitle("First")),
                                                   .field(.key(makeKeySignature(.c, .major)))]),
                                 makeTune(header: [.field(.referenceNumber(makeReferenceNumber(2))),
                                                   .field(.tuneTitle("Second")),
                                                   .field(.key(makeKeySignature(.c, .major)))])])
        let scores = try buildScores(book)

        #expect(scores.count == 2)
        #expect(scores[0].events.contains(.title("First")))
        #expect(scores[1].events.contains(.title("Second")))
    }
}

// MARK: - Structural / Metadata Events

extension ABCScoreBuilderTests {
    @Test
    func build_fileHeaderEvents_areDuplicatedIntoEveryScore() throws {
        let fileHeader: [ABCHeaderEntry] = [.field(.composer("Traditional"))]
        let book = makeTunebook(fileHeader,
                                [makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                   .field(.tuneTitle("First")),
                                                   .field(.key(makeKeySignature(.c, .major)))]),
                                 makeTune(header: [.field(.referenceNumber(makeReferenceNumber(2))),
                                                   .field(.tuneTitle("Second")),
                                                   .field(.key(makeKeySignature(.c, .major)))])])
        let scores = try buildScores(book)
        let composer = ABCScoreEvent.composer("Traditional")

        #expect(scores[0].events.contains(composer))
        #expect(scores[1].events.contains(composer))
    }

    @Test
    func build_tuneHeader_emitsReferenceNumberTitleAndKey() throws {
        let scores = try buildScores(minimalTunebook())
        let events = scores[0].events

        #expect(events.contains(.referenceNumber(makeReferenceNumber(1))))
        #expect(events.contains(.title("Test")))
        #expect(events.contains(.key(makeKeySignature(.c, .major))))
    }

    @Test
    func build_tempoField_emitsTempoEvent() throws {
        let tempo = makeTempo(1, 4, 120)
        let scores = try buildScores(minimalTunebookWithTempo(tempo))

        #expect(scores[0].events.contains(.tempo(tempo)))
    }

    @Test
    func build_voiceField_emitsVoiceEvent() throws {
        let voice = makeVoice("1")
        let book = minimalTunebook(symbols: [.inlineField(.voice(voice))])
        let scores = try buildScores(book)

        #expect(scores[0].events.contains(.voice(voice)))
    }

    @Test
    func build_partField_emitsPartEvent() throws {
        let book = minimalTunebook(symbols: [.inlineField(.part(.a))])
        let scores = try buildScores(book)

        #expect(scores[0].events.contains(.part(.a)))
    }

    @Test
    func build_genericField_passesThroughUnchanged() throws {
        let book = minimalTunebook(symbols: [.inlineField(.rhythm("Reel"))])
        let scores = try buildScores(book)

        #expect(scores[0].events.contains(.field(.rhythm("Reel"))))
    }

    @Test
    func build_barLine_emitsBarLineEvent() throws {
        let book = minimalTunebook(symbols: [.barLine(makeBarLine())])
        let scores = try buildScores(book)

        #expect(scores[0].events.contains(.barLine(makeBarLine())))
    }

    @Test
    func build_variantEnding_emitsVariantEndingEvent() throws {
        let variantEnding = makeVariantEnding([1...1])
        let book = minimalTunebook(symbols: [.variantEnding(variantEnding)])
        let scores = try buildScores(book)

        #expect(scores[0].events.contains(.variantEnding(variantEnding)))
    }
}

// MARK: - Directives

extension ABCScoreBuilderTests {
    @Test
    func build_standaloneDirective_emittedByDefault() throws {
        let directive = makeDirective("MIDI", "program 1")
        let book = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                   .field(.tuneTitle("Test")),
                                                   .field(.key(makeKeySignature(.c, .major)))],
                                          body: [.directive(directive)])])
        let scores = try buildScores(book)

        #expect(scores[0].events.contains(.directive(directive)))
    }

    @Test
    func build_standaloneDirective_omittedWhenStripDirectivesSet() throws {
        let directive = makeDirective("MIDI", "program 1")
        let book = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                   .field(.tuneTitle("Test")),
                                                   .field(.key(makeKeySignature(.c, .major)))],
                                          body: [.directive(directive)])])
        let scores = try buildScores(book, options: .stripDirectives)

        #expect(!scores[0].events.contains(.directive(directive)))
    }

    @Test
    func build_inlineInstructionField_becomesDirectiveEvent() throws {
        let directive = makeDirective("MIDI", "program 1")
        let book = minimalTunebook(symbols: [.inlineField(.instruction(directive))])
        let scores = try buildScores(book)

        #expect(scores[0].events.contains(.directive(directive)))
    }
}

// MARK: - Musical Events (Placeholder Resolution)

extension ABCScoreBuilderTests {
    @Test
    func build_note_resolvesDurationAgainstUnitNoteLength() throws {
        let book = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                   .field(.tuneTitle("Test")),
                                                   .field(.unitNoteLength(makeLength(1, 8))),
                                                   .field(.key(makeKeySignature(.c, .major)))],
                                          body: [.symbols([.note(makeNote(makePitch(.c, .natural, 4),
                                                                          makeLength(2, 1)))])])])
        let scores = try buildScores(book)
        let note = makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 4))

        #expect(scores[0].events.contains(.note(note, .empty)))
    }

    @Test
    func build_note_defaultsUnitNoteLengthFromMeter() throws {
        // No explicit L:, but M:2/4 has a `doubleValue < 0.75`, defaulting
        // the unit note length to 1/16.
        let book = makeTunebook([makeTune(header: [.field(.referenceNumber(makeReferenceNumber(1))),
                                                   .field(.tuneTitle("Test")),
                                                   .field(.meter(makeTimeSignature(2, 4))),
                                                   .field(.key(makeKeySignature(.c, .major)))],
                                          body: [.symbols([.note(makeNote(makePitch(.c, .natural, 4),
                                                                          makeLength(1, 1)))])])])
        let scores = try buildScores(book)
        let note = makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 16))

        #expect(scores[0].events.contains(.note(note, .empty)))
    }

    @Test
    func build_note_omittedAccidental_placeholderIsNatural() throws {
        let book = minimalTunebook(symbols: [.note(makeNote(makePitch(.c, .omitted, 4),
                                                            makeLength(1, 1)))])
        let scores = try buildScores(book)
        let note = makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 8))

        #expect(scores[0].events.contains(.note(note, .empty)))
    }

    @Test
    func build_note_explicitAccidental_passesThrough() throws {
        let book = minimalTunebook(symbols: [.note(makeNote(makePitch(.f, .sharp, 4),
                                                            makeLength(1, 1)))])
        let scores = try buildScores(book)
        let note = makeScoreNote(makePitch(.f, .sharp, 4), makeScoreDuration(1, 8))

        #expect(scores[0].events.contains(.note(note, .empty)))
    }

    @Test
    func build_rest_resolvesDuration() throws {
        let book = minimalTunebook(symbols: [.rest(.regular(false, makeLength(2, 1)))])
        let scores = try buildScores(book)
        let rest = makeScoreRest(makeScoreDuration(1, 4))

        #expect(scores[0].events.contains(.rest(rest, .empty)))
    }

    @Test
    func build_chord_resolvesNotesAndSharedDuration() throws {
        let notes = [makeNote(makePitch(.c, .natural, 4), makeLength(1, 1)),
                     makeNote(makePitch(.e, .natural, 4), makeLength(1, 1))]
        let chord = makeChord(notes, makeLength(2, 1))
        let book = minimalTunebook(symbols: [.chord(chord)])
        let scores = try buildScores(book)
        let expected = makeScoreChord([makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 8)),
                                       makeScoreNote(makePitch(.e, .natural, 4), makeScoreDuration(1, 8))],
                                      makeScoreDuration(1, 4))

        #expect(scores[0].events.contains(.chord(expected, .empty)))
    }

    @Test
    func build_midTuneUnitNoteLengthChange_affectsSubsequentNoteResolution() throws {
        // An inline L: change partway through the body must apply to notes
        // that follow it.
        let book = minimalTunebook(symbols: [.note(makeNote(makePitch(.c, .natural, 4), makeLength(1, 1))),
                                             .inlineField(.unitNoteLength(makeLength(1, 4))),
                                             .note(makeNote(makePitch(.d, .natural, 4), makeLength(1, 1)))])
        let scores = try buildScores(book)
        let firstNote = makeScoreNote(makePitch(.c, .natural, 4), makeScoreDuration(1, 8))
        let secondNote = makeScoreNote(makePitch(.d, .natural, 4), makeScoreDuration(1, 4))

        #expect(scores[0].events.contains(.note(firstNote, .empty)))
        #expect(scores[0].events.contains(.note(secondNote, .empty)))
    }
}
