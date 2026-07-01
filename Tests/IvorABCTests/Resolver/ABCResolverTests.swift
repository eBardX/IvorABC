// © 2026 John Gary Pusey (see LICENSE.md)

// NOTE: Parked alongside ABCResolver — disabled via `#if false`, preserved
// pending a redesigned resolver.
#if false

import Foundation
@testable import IvorABC
import Testing
import XestiTools

struct ABCResolverTests {
}

// MARK: -

extension ABCResolverTests {

    // MARK: Metadata

    @Test
    func resolve_setsIsResolvedFlag() throws {
        let resolved = try resolved("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\nC|\n")

        #expect(resolved.isResolved)
    }

    @Test
    func resolve_alreadyResolved_returnsUnchanged() throws {
        let once = try resolved("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\nC2|\n")
        let twice = ABCResolver().resolve(once)

        #expect(once == twice)
        #expect(twice.isResolved)
    }

    @Test
    func resolve_preservesUnaffectedContent() throws {
        let resolved = try resolved("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\nC|\n")
        let tune = try #require(resolved.tunes.first)

        #expect(tune.header.contains(.field(.tuneTitle("Test"))))
    }

    // MARK: Length resolution

    @Test
    func resolve_length_underExplicitL() throws {
        // C2 under L:1/4 → 2 × 1/4 = 1/2
        let notes = try firstNotes("%abc-2.1\nX:1\nT:Test\nL:1/4\nK:C\nC2|\n")

        #expect(notes.first?.length == makeLength(1, 2))
    }

    @Test
    func resolve_length_bareNoteIsOneUnit() throws {
        // bare C under L:1/8 → 1 × 1/8 = 1/8
        let notes = try firstNotes("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\nC|\n")

        #expect(notes.first?.length == makeLength(1, 8))
    }

    @Test
    func resolve_length_defaultLFromCommonMeter() throws {
        // No L:; M:4/4 (≥ 0.75) → default L 1/8; bare C → 1/8
        let notes = try firstNotes("%abc-2.1\nX:1\nT:Test\nM:4/4\nK:C\nC|\n")

        #expect(notes.first?.length == makeLength(1, 8))
    }

    @Test
    func resolve_length_defaultLFromSmallMeter() throws {
        // No L:; M:3/8 (< 0.75) → default L 1/16; bare C → 1/16
        let notes = try firstNotes("%abc-2.1\nX:1\nT:Test\nM:3/8\nK:C\nC|\n")

        #expect(notes.first?.length == makeLength(1, 16))
    }

    @Test
    func resolve_length_fileHeaderLCarriesIntoTune() throws {
        let notes = try firstNotes("%abc-2.1\nL:1/4\n\nX:1\nT:Test\nK:C\nC|\n")

        #expect(notes.first?.length == makeLength(1, 4))
    }

    @Test
    func resolve_length_inlineLChangeAppliesToLaterNotes() throws {
        // C [L:1/4] C → first 1/8, second 1/4
        let notes = try firstNotes("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\nC[L:1/4]C|\n")

        #expect(notes.count == 2)
        #expect(notes[0].length == makeLength(1, 8))
        #expect(notes[1].length == makeLength(1, 4))
    }

    @Test
    func resolve_length_doesNotLeakBetweenTunes() throws {
        // Tune 1 sets L:1/4; tune 2 has no L: and there is no file-header L:,
        // so tune 2 falls back to the default 1/8.
        let resolved = try resolved("%abc-2.1\nX:1\nT:One\nL:1/4\nK:C\nC|\n\nX:2\nT:Two\nK:C\nC|\n")

        let first = try notes(of: resolved, tuneIndex: 0)
        let second = try notes(of: resolved, tuneIndex: 1)

        #expect(first.first?.length == makeLength(1, 4))
        #expect(second.first?.length == makeLength(1, 8))
    }

    @Test
    func resolve_rest_lengthResolved() throws {
        // z2 under L:1/8 → 1/4
        let symbols = try firstSymbols(resolved("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\nz2|\n"))

        let lengths = symbols.compactMap { symbol -> ABCLength? in
            guard case let .rest(.regular(_, length)) = symbol
            else { return nil }

            return length
        }

        #expect(lengths.first == makeLength(1, 4))
    }

    @Test
    func resolve_spacer_lengthResolved() throws {
        // y2 under L:1/8 → 1/4
        let symbols = try firstSymbols(resolved("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\ny2|\n"))

        let lengths = symbols.compactMap { symbol -> ABCLength? in
            guard case let .spacer(length) = symbol
            else { return nil }

            return length
        }

        #expect(lengths.first == makeLength(1, 4))
    }

    @Test
    func resolve_chord_lengthAndMemberLengthsResolved() throws {
        // [CE]2 under L:1/8 → chord 1/4, members 1/8
        let symbols = try firstSymbols(resolved("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\n[CE]2|\n"))

        let chord = try #require(symbols.compactMap { symbol -> ABCChord? in
            guard case let .chord(chord) = symbol
            else { return nil }

            return chord
        }.first)

        #expect(chord.length == makeLength(1, 4))
        #expect(chord.notes.allSatisfy { $0.length == makeLength(1, 8) })
    }

    // MARK: Pitch resolution

    @Test
    func resolve_pitch_keySignatureAccidentalApplied() throws {
        // K:G → F sounds F♯
        let notes = try firstNotes("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:G\nF|\n")

        #expect(notes.first?.pitch.accidental == .sharp)
    }

    @Test
    func resolve_pitch_explicitAccidentalPreserved() throws {
        // =F in G major stays natural
        let notes = try firstNotes("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:G\n=F|\n")

        #expect(notes.first?.pitch.accidental == .natural)
    }

    @Test
    func resolve_pitch_naturalWhenNoKeyAccidental() throws {
        // K:C → F is natural
        let notes = try firstNotes("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\nF|\n")

        #expect(notes.first?.pitch.accidental == .natural)
    }

    @Test
    func resolve_pitch_writtenAccidentalPropagatesWithinBar() throws {
        // ^F F → both F♯ within the bar
        let notes = try firstNotes("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\n^FF|\n")

        #expect(notes.count == 2)
        #expect(notes[0].pitch.accidental == .sharp)
        #expect(notes[1].pitch.accidental == .sharp)
    }

    @Test
    func resolve_pitch_barLineResetsWrittenAccidental() throws {
        // ^F | F → first F♯, second natural (C major)
        let notes = try firstNotes("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\n^F|F|\n")

        #expect(notes.count == 2)
        #expect(notes[0].pitch.accidental == .sharp)
        #expect(notes[1].pitch.accidental == .natural)
    }

    @Test
    func resolve_pitch_inlineKeyChangeAppliesToLaterNotes() throws {
        // F [K:G] F → first natural (C major), second F♯ (G major)
        let notes = try firstNotes("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:C\nF[K:G]F|\n")

        #expect(notes.count == 2)
        #expect(notes[0].pitch.accidental == .natural)
        #expect(notes[1].pitch.accidental == .sharp)
    }

    @Test
    func resolve_pitch_noOmittedAccidentalsRemain() throws {
        let notes = try firstNotes("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:D\nDEFGABcd|\n")

        #expect(!notes.isEmpty)
        #expect(notes.allSatisfy { $0.pitch.accidental != .omitted })
    }

    @Test
    func resolve_pitch_chordMemberAccidentalFromKey() throws {
        // K:G, [FA] → F member resolves to F♯
        let symbols = try firstSymbols(resolved("%abc-2.1\nX:1\nT:Test\nL:1/8\nK:G\n[FA]|\n"))

        let chord = try #require(symbols.compactMap { symbol -> ABCChord? in
            guard case let .chord(chord) = symbol
            else { return nil }

            return chord
        }.first)

        let fNote = try #require(chord.notes.first { $0.pitch.letter == .f })

        #expect(fNote.pitch.accidental == .sharp)
    }
}

// MARK: - Private helpers

extension ABCResolverTests {

    private func firstNotes(_ input: String) throws -> [ABCNote] {
        try notes(of: resolved(input), tuneIndex: 0)
    }

    private func firstSymbols(_ tunebook: ABCTunebook) throws -> [ABCSymbol] {
        try symbols(of: tunebook, tuneIndex: 0)
    }

    private func notes(of tunebook: ABCTunebook,
                       tuneIndex: Int) throws -> [ABCNote] {
        try symbols(of: tunebook, tuneIndex: tuneIndex).compactMap { symbol in
            guard case let .note(note) = symbol
            else { return nil }

            return note
        }
    }

    private func resolved(_ input: String) throws -> ABCTunebook {
        let (tunebook, _) = try ABCParser().parse(Data(input.utf8))

        return ABCResolver().resolve(tunebook)
    }

    private func symbols(of tunebook: ABCTunebook,
                         tuneIndex: Int) throws -> [ABCSymbol] {
        let tune = tunebook.tunes[tuneIndex]

        return try #require(tune.body.compactMap { entry -> [ABCSymbol]? in
            guard case let .symbols(symbols) = entry
            else { return nil }

            return symbols
        }.first)
    }
}

#endif
