// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCVoiceIDTests {
}

// MARK: -

extension ABCVoiceIDTests {
    @Test
    func equality() {
        let a = ABCVoice.ID(stringValue: "T1")
        let b = ABCVoice.ID(stringValue: "T1")

        #expect(a == b)
    }

    @Test
    func inequality() {
        #expect(ABCVoice.ID(stringValue: "T1") != ABCVoice.ID(stringValue: "T2"))
    }

    @Test
    func init_nilForEmptyString() {
        #expect(ABCVoice.ID(stringValue: "") == nil)
    }

    @Test
    func init_nilForStringWithNonAlphanumericCharacter() {
        #expect(ABCVoice.ID(stringValue: "T-1") == nil)
    }

    @Test
    func init_storesStringValue() {
        let id = ABCVoice.ID(stringValue: "T1")

        #expect(id?.stringValue == "T1")
    }

    @Test
    func isValid_alphanumericStringsAreValid() {
        #expect(ABCVoice.ID.isValid("T1"))
        #expect(ABCVoice.ID.isValid("bass"))
    }

    @Test
    func isValid_emptyStringIsInvalid() {
        #expect(!ABCVoice.ID.isValid(""))
    }
}
