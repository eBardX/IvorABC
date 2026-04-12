// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCVoiceTests {
}

// MARK: -

extension ABCVoiceTests {
    @Test
    func test_nameFromName() {
        let voice = ABCVoice(id: "1",
                             properties: ["name": "Soprano"])

        #expect(voice.name == "Soprano")
    }

    @Test
    func test_nameFromNm() {
        let voice = ABCVoice(id: "1",
                             properties: ["nm": "Alto"])

        #expect(voice.name == "Alto")
    }

    @Test
    func test_nameNil() {
        let voice = ABCVoice(id: "1",
                             properties: [:])

        #expect(voice.name == nil)
    }

    @Test
    func test_namePrefersNameOverNm() {
        let voice = ABCVoice(id: "1",
                             properties: ["name": "Soprano",
                                          "nm": "S"])

        #expect(voice.name == "Soprano")
    }

    @Test
    func test_subnameFromSname() {
        let voice = ABCVoice(id: "1",
                             properties: ["sname": "S.I"])

        #expect(voice.subname == "S.I")
    }

    @Test
    func test_subnameFromSnm() {
        let voice = ABCVoice(id: "1",
                             properties: ["snm": "T.II"])

        #expect(voice.subname == "T.II")
    }

    @Test
    func test_subnameFromSubname() {
        let voice = ABCVoice(id: "1",
                             properties: ["subname": "First"])

        #expect(voice.subname == "First")
    }

    @Test
    func test_subnameNil() {
        let voice = ABCVoice(id: "1",
                             properties: [:])

        #expect(voice.subname == nil)
    }

    @Test
    func test_subnamePrefersSubnameOverSname() {
        let voice = ABCVoice(id: "1",
                             properties: ["subname": "First",
                                          "sname": "1st",
                                          "snm": "I"])

        #expect(voice.subname == "First")
    }

    @Test
    func test_subnamePrefersSnamOverSnm() {
        let voice = ABCVoice(id: "1",
                             properties: ["sname": "1st",
                                          "snm": "I"])

        #expect(voice.subname == "1st")
    }
}
