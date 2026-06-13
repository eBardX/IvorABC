// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCHeaderTests {
}

// MARK: -

extension ABCHeaderTests {
    @Test
    func equality_directive() {
        let directive = ABCDirective(name: "pagewidth", value: "21cm")

        #expect(ABCHeader.directive(directive) == .directive(directive))
    }

    @Test
    func equality_field() {
        #expect(ABCHeader.field(.composer("J.S. Bach")) == .field(.composer("J.S. Bach")))
    }

    @Test
    func inequality() {
        let directive = ABCDirective(name: "pagewidth", value: "21cm")

        #expect(ABCHeader.directive(directive) != .field(.composer("J.S. Bach")))
        #expect(ABCHeader.field(.composer("Bach")) != .field(.composer("Handel")))
    }
}
