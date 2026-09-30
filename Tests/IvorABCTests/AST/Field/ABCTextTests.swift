// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCTextTests {
}

// MARK: -

extension ABCTextTests {
    @Test
    func equality() {
        let a = ABCText(stringValue: "hello")
        let b = ABCText(stringValue: "hello")

        #expect(a == b)
    }

    @Test
    func inequality() {
        #expect(ABCText(stringValue: "hello") != ABCText(stringValue: "goodbye"))
    }

    @Test
    func init_emptyStringIsValid() {
        let text = ABCText(stringValue: "")

        #expect(text?.stringValue.isEmpty == true)
    }

    @Test
    func init_storesStringValue() {
        let text = ABCText(stringValue: "Some text")

        #expect(text?.stringValue == "Some text")
    }

    @Test
    func isValid_alwaysTrue() {
        #expect(ABCText.isValid(""))
        #expect(ABCText.isValid("Some text"))
    }
}
