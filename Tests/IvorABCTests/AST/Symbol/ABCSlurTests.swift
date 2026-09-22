// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCSlurTests {
}

// MARK: -

extension ABCSlurTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCSlur] = [.endDotted, .endRegular, .startDotted, .startRegular]

        for i in allCases.indices {
            for j in allCases.indices where i != j {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test
    func equality() {
        #expect(ABCSlur.endDotted == .endDotted)
        #expect(ABCSlur.endRegular == .endRegular)
        #expect(ABCSlur.startDotted == .startDotted)
        #expect(ABCSlur.startRegular == .startRegular)
    }
}
