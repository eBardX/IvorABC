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
        let directive = makeDirective("pagewidth", "21cm")

        #expect(ABCHeaderEntry.directive(directive) == .directive(directive))
    }

    @Test
    func equality_field() {
        #expect(ABCHeaderEntry.field(.composer("J.S. Bach")) == .field(.composer("J.S. Bach")))
    }

    @Test
    func inequality() {
        let directive = makeDirective("pagewidth", "21cm")

        #expect(ABCHeaderEntry.directive(directive) != .field(.composer("J.S. Bach")))
        #expect(ABCHeaderEntry.field(.composer("Bach")) != .field(.composer("Handel")))
    }
}
