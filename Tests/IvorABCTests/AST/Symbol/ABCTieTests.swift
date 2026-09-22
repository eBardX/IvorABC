// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCTieTests {
}

// MARK: -

extension ABCTieTests {
    @Test
    func allCasesAreDistinct() {
        #expect(ABCTie.dotted != .regular)
    }

    @Test
    func equality() {
        #expect(ABCTie.dotted == .dotted)
        #expect(ABCTie.regular == .regular)
    }
}
