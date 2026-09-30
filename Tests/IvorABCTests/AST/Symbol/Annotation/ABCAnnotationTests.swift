// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCAnnotationTests {
}

// MARK: -

extension ABCAnnotationTests {
    @Test
    func equality() {
        let a = makeAnnotation(.above, "Hello")
        let b = makeAnnotation(.above, "Hello")

        #expect(a == b)
    }

    @Test
    func inequality_differentPlacement() {
        let a = makeAnnotation(.above, "Hello")
        let b = makeAnnotation(.below, "Hello")

        #expect(a != b)
    }

    @Test
    func inequality_differentText() {
        let a = makeAnnotation(.above, "Hello")
        let b = makeAnnotation(.above, "World")

        #expect(a != b)
    }

    @Test
    func init_storesProperties() {
        let annotation = makeAnnotation(.right, "sfz")

        #expect(annotation.placement == .right)
        #expect(annotation.text == "sfz")
    }
}
