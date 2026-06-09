// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCDirectiveTests {
}

// MARK: -

extension ABCDirectiveTests {
    @Test
    func equality() {
        let a = ABCDirective(name: "pagewidth", value: "21cm")
        let b = ABCDirective(name: "pagewidth", value: "21cm")

        #expect(a == b)
    }

    @Test
    func inequality() {
        let base = ABCDirective(name: "pagewidth", value: "21cm")
        let diffName = ABCDirective(name: "staffwidth", value: "21cm")
        let diffValue = ABCDirective(name: "pagewidth", value: "18cm")
        let diffContent = ABCDirective(name: "pagewidth", value: "21cm", content: [])

        #expect(base != diffName)
        #expect(base != diffValue)
        #expect(base != diffContent)
    }

    @Test
    func init_storesValues() {
        let directive = ABCDirective(name: "pagewidth",
                                     value: "21cm")

        #expect(directive.content == nil)
        #expect(directive.name == "pagewidth")
        #expect(directive.value == "21cm")
    }

    @Test
    func init_storesBlockContent() {
        let directive = ABCDirective(name: "text",
                                     value: "justify",
                                     content: ["Line one", "Line two"])

        #expect(directive.content == ["Line one", "Line two"])
        #expect(directive.name == "text")
        #expect(directive.value == "justify")
    }
}
