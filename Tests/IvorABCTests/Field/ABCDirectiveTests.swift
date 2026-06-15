// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCDirectiveTests {
}

// MARK: -

extension ABCDirectiveTests {
    @Test
    func equality() {
        let a = makeDirective("pagewidth", "21cm")
        let b = makeDirective("pagewidth", "21cm")

        #expect(a == b)
    }

    @Test
    func inequality() {
        let base = makeDirective("pagewidth", "21cm")
        let diffName = makeDirective("staffwidth", "21cm")
        let diffValue = makeDirective("pagewidth", "18cm")
        let diffContent = makeDirective("pagewidth", "21cm", [])

        #expect(base != diffName)
        #expect(base != diffValue)
        #expect(base != diffContent)
    }

    @Test
    func init_storesValues() {
        let directive = makeDirective("pagewidth", "21cm")

        #expect(directive.content == nil)
        #expect(directive.name == "pagewidth")
        #expect(directive.value == "21cm")
    }

    @Test
    func init_storesBlockContent() {
        let directive = makeDirective("text",
                                      "justify",
                                      ["Line one", "Line two"])

        #expect(directive.content == ["Line one", "Line two"])
        #expect(directive.name == "text")
        #expect(directive.value == "justify")
    }
}
