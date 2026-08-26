// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCClefOttavaTests {
}

// MARK: -

extension ABCClefOttavaTests {
    @Test
    func allCasesAreDistinct() {
        #expect(ABCClef.Ottava.alta != .bassa)
    }

    @Test
    func equality() {
        #expect(ABCClef.Ottava.alta == .alta)
        #expect(ABCClef.Ottava.bassa == .bassa)
    }
}
