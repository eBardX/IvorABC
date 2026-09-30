// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCShorthandTests {
}

// MARK: -

extension ABCShorthandTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCShorthand] = [.dot,
                                        .hLower,
                                        .hUpper,
                                        .iLower,
                                        .iUpper,
                                        .jLower,
                                        .jUpper,
                                        .kLower,
                                        .kUpper,
                                        .lLower,
                                        .lUpper,
                                        .mLower,
                                        .mUpper,
                                        .nLower,
                                        .nUpper,
                                        .oLower,
                                        .oUpper,
                                        .pLower,
                                        .pUpper,
                                        .qLower,
                                        .qUpper,
                                        .rLower,
                                        .rUpper,
                                        .sLower,
                                        .sUpper,
                                        .tilde,
                                        .tLower,
                                        .tUpper,
                                        .uLower,
                                        .uUpper,
                                        .vLower,
                                        .vUpper,
                                        .wLower,
                                        .wUpper]

        for i in allCases.indices {
            for j in allCases.indices where i != j {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test
    func equality() {
        #expect(ABCShorthand.dot == .dot)
        #expect(ABCShorthand.tilde == .tilde)
        #expect(ABCShorthand.hLower == .hLower)
    }
}
