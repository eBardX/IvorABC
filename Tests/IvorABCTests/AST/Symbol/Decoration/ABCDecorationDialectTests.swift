// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCDecorationDialectTests {
}

// MARK: -

extension ABCDecorationDialectTests {
    @Test
    func allCasesAreDistinct() {
        #expect(ABCDecoration.Dialect.bang != .plus)
    }

    @Test
    func equality() {
        #expect(ABCDecoration.Dialect.bang == .bang)
        #expect(ABCDecoration.Dialect.plus == .plus)
    }
}
