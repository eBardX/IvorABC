// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCVoiceParseFunctionsTests {
}

// MARK: -

extension ABCVoiceParseFunctionsTests {
    @Test
    func parseVoice_bareClefName() throws {
        let bassClef = try #require(ABCClef(name: "bass"))
        let bassMidClef = try #require(ABCClef(name: "bass", middle: ABCClef.Middle(letter: .d, octave: 5)))

        #expect(parseVoice("B bass") == makeVoice("B", clef: bassClef))
        #expect(parseVoice("B middle=d bass") == makeVoice("B", clef: bassMidClef))
    }

    @Test
    func parseVoice_failure() {
        #expect(parseVoice("") == nil)
    }

    @Test
    func parseVoice_success() throws {
        let trebleClef = try #require(ABCClef(name: "treble"))
        let bassMidClef = try #require(ABCClef(name: "bass", middle: ABCClef.Middle(letter: .d, octave: 5)))
        let bassMidTransposeClef = try #require(ABCClef(name: "bass", middle: ABCClef.Middle(letter: .d, octave: 5), transpose: -24))
        let trebleBelow8Clef = try #require(ABCClef(name: "treble", ottava: .bassa))

        #expect(parseVoice("1 clef=treble name=\"Soprano\"sname=\"A\"") == makeVoice("1",
                                                                                     clef: trebleClef,
                                                                                     ["name": "Soprano",
                                                                                      "sname": "A"]))
        #expect(parseVoice("2") == makeVoice("2"))
        #expect(parseVoice("3 clef = bass middle = d name = \"Tenor\" sname = \"B\"") ==
                makeVoice("3",
                          clef: bassMidClef,
                          ["name": "Tenor",
                           "sname": "B"]))
        #expect(parseVoice("B1   middle=d   clef=bass      name=\"Basso I\"     snm=\"B.I\"    transpose=-24") ==
                makeVoice("B1",
                          clef: bassMidTransposeClef,
                          ["name": "Basso I",
                           "snm": "B.I"]))
        #expect(parseVoice("T1") == makeVoice("T1"))
        #expect(parseVoice("T2               clef=treble-8    name=\"Tenore II\"    snm=\"T.II\"") ==
                makeVoice("T2",
                          clef: trebleBelow8Clef,
                          ["name": "Tenore II",
                           "snm": "T.II"]))
    }
}
