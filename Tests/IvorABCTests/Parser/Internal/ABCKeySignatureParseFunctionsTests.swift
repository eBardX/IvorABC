// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCKeySignatureParseFunctionsTests {
}

// MARK: -

extension ABCKeySignatureParseFunctionsTests {
    @Test
    func parseKeySignature_clef() throws {
        let bassClef = try #require(ABCClef(name: "bass"))
        let percClef = try #require(ABCClef(name: "perc"))
        let trebleClef = try #require(ABCClef(name: "treble"))
        let transposeClef = try #require(ABCClef(transpose: -2))
        let combinedClef = try #require(ABCClef(name: "bass", transpose: -2))
        let percStafflinesClef = try #require(ABCClef(name: "perc", stafflines: 1))
        let trebleAbove8Clef = try #require(ABCClef(name: "treble", ottava: .alta))
        let bassBelow8Clef = try #require(ABCClef(name: "bass", ottava: .bassa))
        let middleTransposeClef = try #require(ABCClef(name: "bass", middle: ABCClef.Middle(letter: .d, octave: 5), transpose: -24))

        // clef= prefix form
        #expect(parseKeySignature("G clef=bass") == makeKeySignature(.g, .major, bassClef))
        #expect(parseKeySignature("C transpose=-2") == makeKeySignature(.c, .major, transposeClef))
        #expect(parseKeySignature("C major transpose=-2") == makeKeySignature(.c, .major, transposeClef))
        #expect(parseKeySignature("G clef=bass transpose=-2") == makeKeySignature(.g, .major, combinedClef))
        #expect(parseKeySignature("clef=treble") == .clefOnly(trebleClef))
        #expect(parseKeySignature("none clef=treble") == .clefOnly(trebleClef))

        // bare clef name form (no clef= prefix)
        #expect(parseKeySignature("perc stafflines=1") == .clefOnly(percStafflinesClef))
        #expect(parseKeySignature("G bass") == makeKeySignature(.g, .major, bassClef))
        #expect(parseKeySignature("G perc") == makeKeySignature(.g, .major, percClef))

        // +8 / -8 ottava markers
        #expect(parseKeySignature("clef=treble+8") == .clefOnly(trebleAbove8Clef))
        #expect(parseKeySignature("clef=bass-8") == .clefOnly(bassBelow8Clef))
        #expect(parseKeySignature("treble+8") == .clefOnly(trebleAbove8Clef))

        // m= and t= abbreviations
        #expect(parseKeySignature("C t=-2") == makeKeySignature(.c, .major, transposeClef))
        #expect(parseKeySignature("bass middle=d t=-24") == .clefOnly(middleTransposeClef))
        #expect(parseKeySignature("bass m=d t=-24") == .clefOnly(middleTransposeClef))

        // line number (clef= prefix form)
        let bass3Clef = try #require(ABCClef(name: "bass", line: 3))
        let alto2Clef = try #require(ABCClef(name: "alto", line: 2))
        let treble2Above8Clef = try #require(ABCClef(name: "treble", line: 2, ottava: .alta))

        #expect(parseKeySignature("clef=bass3") == .clefOnly(bass3Clef))
        #expect(parseKeySignature("clef=alto2") == .clefOnly(alto2Clef))
        #expect(parseKeySignature("clef=treble2+8") == .clefOnly(treble2Above8Clef))
        #expect(parseKeySignature("G clef=bass3") == makeKeySignature(.g, .major, bass3Clef))

        // line number (bare form)
        #expect(parseKeySignature("bass3") == .clefOnly(bass3Clef))
        #expect(parseKeySignature("treble2+8") == .clefOnly(treble2Above8Clef))
    }

    @Test
    func parseKeySignature_failure() {
        #expect(parseKeySignature("B##") == nil)
        #expect(parseKeySignature("C# neutral") == nil)
        #expect(parseKeySignature("G clef=bass unknown=x") == nil)
        #expect(parseKeySignature("G transpose=abc") == nil)
    }

    @Test
    func parseKeySignature_success() {
        #expect(parseKeySignature("") == .empty)
        #expect(parseKeySignature("ADor") == makeKeySignature(.a, .dorian))
        #expect(parseKeySignature("AMix") == makeKeySignature(.a, .mixolydian))
        #expect(parseKeySignature("D =c") == makeKeySignature(.d, .major, [makePitch(.c, .natural, 5)]))
        #expect(parseKeySignature("D exp _b _e ^f") == makeKeySignature(.d,
                                                                        .explicit,
                                                                        [makePitch(.b, .flat, 5),
                                                                         makePitch(.e, .flat, 5),
                                                                         makePitch(.f, .sharp, 5)]))
        #expect(parseKeySignature("D maj =c") == makeKeySignature(.d, .major, [makePitch(.c, .natural, 5)]))
        #expect(parseKeySignature("D Phr ^f") == makeKeySignature(.d, .phrygian, [makePitch(.f, .sharp, 5)]))
        #expect(parseKeySignature("D") == makeKeySignature(.d, .major))
        #expect(parseKeySignature("Dm") == makeKeySignature(.d, .minor))
        #expect(parseKeySignature("Eb") == makeKeySignature(.eFlat, .major))
        #expect(parseKeySignature("F# mixolydian") == makeKeySignature(.fSharp, .mixolydian))
        #expect(parseKeySignature("F#Mix") == makeKeySignature(.fSharp, .mixolydian))
        #expect(parseKeySignature("F#MIX") == makeKeySignature(.fSharp, .mixolydian))
        #expect(parseKeySignature("G") == makeKeySignature(.g, .major))
        #expect(parseKeySignature("HP") == .highlandPipes)
        #expect(parseKeySignature("Hp") == .highlandPipesPreset)
        #expect(parseKeySignature("none") == .empty)
    }
}
