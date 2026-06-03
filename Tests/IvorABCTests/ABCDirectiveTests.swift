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

        #expect(base != diffName)
        #expect(base != diffValue)
    }

    @Test
    func init_storesValues() {
        let directive = ABCDirective(name: "pagewidth",
                                     value: "21cm")

        #expect(directive.name == "pagewidth")
        #expect(directive.value == "21cm")
    }
}
