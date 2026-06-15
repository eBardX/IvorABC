// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCVoiceTests {
}

// MARK: -

extension ABCVoiceTests {
    @Test
    func name_fromName() {
        let voice = makeVoice("1", ["name": "Soprano"])

        #expect(voice.name == "Soprano")
    }

    @Test
    func name_fromNm() {
        let voice = makeVoice("1", ["nm": "Alto"])

        #expect(voice.name == "Alto")
    }

    @Test
    func name_nil() {
        let voice = makeVoice("1")

        #expect(voice.name == nil)
    }

    @Test
    func name_prefersNameOverNm() {
        let voice = makeVoice("1",
                              ["name": "Soprano",
                               "nm": "S"])

        #expect(voice.name == "Soprano")
    }

    @Test
    func subname_fromSname() {
        let voice = makeVoice("1", ["sname": "S.I"])

        #expect(voice.subname == "S.I")
    }

    @Test
    func subname_fromSnm() {
        let voice = makeVoice("1", ["snm": "T.II"])

        #expect(voice.subname == "T.II")
    }

    @Test
    func subname_fromSubname() {
        let voice = makeVoice("1", ["subname": "First"])

        #expect(voice.subname == "First")
    }

    @Test
    func subname_nil() {
        let voice = makeVoice("1")

        #expect(voice.subname == nil)
    }

    @Test
    func subname_prefersSnamOverSnm() {
        let voice = makeVoice("1",
                              ["sname": "1st",
                               "snm": "I"])

        #expect(voice.subname == "1st")
    }

    @Test
    func subname_prefersSubnameOverSname() {
        let voice = makeVoice("1",
                              ["subname": "First",
                               "sname": "1st",
                               "snm": "I"])

        #expect(voice.subname == "First")
    }
}
