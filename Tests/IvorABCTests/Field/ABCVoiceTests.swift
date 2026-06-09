// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCVoiceTests {
}

// MARK: -

extension ABCVoiceTests {
    @Test
    func name_fromName() {
        let voice = ABCVoice(id: "1",
                             properties: ["name": "Soprano"])

        #expect(voice.name == "Soprano")
    }

    @Test
    func name_fromNm() {
        let voice = ABCVoice(id: "1",
                             properties: ["nm": "Alto"])

        #expect(voice.name == "Alto")
    }

    @Test
    func name_nil() {
        let voice = ABCVoice(id: "1",
                             properties: [:])

        #expect(voice.name == nil)
    }

    @Test
    func name_prefersNameOverNm() {
        let voice = ABCVoice(id: "1",
                             properties: ["name": "Soprano",
                                          "nm": "S"])

        #expect(voice.name == "Soprano")
    }

    @Test
    func subname_fromSname() {
        let voice = ABCVoice(id: "1",
                             properties: ["sname": "S.I"])

        #expect(voice.subname == "S.I")
    }

    @Test
    func subname_fromSnm() {
        let voice = ABCVoice(id: "1",
                             properties: ["snm": "T.II"])

        #expect(voice.subname == "T.II")
    }

    @Test
    func subname_fromSubname() {
        let voice = ABCVoice(id: "1",
                             properties: ["subname": "First"])

        #expect(voice.subname == "First")
    }

    @Test
    func subname_nil() {
        let voice = ABCVoice(id: "1",
                             properties: [:])

        #expect(voice.subname == nil)
    }

    @Test
    func subname_prefersSnamOverSnm() {
        let voice = ABCVoice(id: "1",
                             properties: ["sname": "1st",
                                          "snm": "I"])

        #expect(voice.subname == "1st")
    }

    @Test
    func subname_prefersSubnameOverSname() {
        let voice = ABCVoice(id: "1",
                             properties: ["subname": "First",
                                          "sname": "1st",
                                          "snm": "I"])

        #expect(voice.subname == "First")
    }
}
