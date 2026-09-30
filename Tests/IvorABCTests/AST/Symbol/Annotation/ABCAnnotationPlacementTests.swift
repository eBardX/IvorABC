// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCAnnotationPlacementTests {
}

// MARK: -

extension ABCAnnotationPlacementTests {
    @Test
    func equality() {
        let a = ABCAnnotation.Placement.above
        let b = ABCAnnotation.Placement.above

        #expect(a == b)
    }

    @Test
    func inequality() {
        #expect(ABCAnnotation.Placement.above != ABCAnnotation.Placement.below)
    }
}
