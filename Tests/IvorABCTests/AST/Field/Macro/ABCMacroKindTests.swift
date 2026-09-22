// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCMacroKindTests {
}

// MARK: -

extension ABCMacroKindTests {
    @Test
    func allCasesAreDistinct() {
        #expect(ABCMacro.Kind.static != .transposing)
    }

    @Test
    func equality() {
        #expect(ABCMacro.Kind.static == .static)
        #expect(ABCMacro.Kind.transposing == .transposing)
    }
}
