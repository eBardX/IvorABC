// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCAnnotationPositionTests {
}

// MARK: -

extension ABCAnnotationPositionTests {
    @Test
    func equality() {
        let a = ABCAnnotation.Position.above
        let b = ABCAnnotation.Position.above

        #expect(a == b)
    }

    @Test
    func inequality() {
        #expect(ABCAnnotation.Position.above != ABCAnnotation.Position.below)
    }
}
