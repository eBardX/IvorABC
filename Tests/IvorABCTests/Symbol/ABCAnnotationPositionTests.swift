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

    @Test
    func init_prefix_above() {
        #expect(ABCAnnotation.Position(prefix: "^") == .above)
    }

    @Test
    func init_prefix_auto() {
        #expect(ABCAnnotation.Position(prefix: "@") == .auto)
    }

    @Test
    func init_prefix_below() {
        #expect(ABCAnnotation.Position(prefix: "_") == .below)
    }

    @Test
    func init_prefix_invalidCharacter() {
        #expect(ABCAnnotation.Position(prefix: "x") == nil)
    }

    @Test
    func init_prefix_left() {
        #expect(ABCAnnotation.Position(prefix: "<") == .left)
    }

    @Test
    func init_prefix_right() {
        #expect(ABCAnnotation.Position(prefix: ">") == .right)
    }

    @Test
    func prefix_above() {
        #expect(ABCAnnotation.Position.above.prefix == "^")
    }

    @Test
    func prefix_auto() {
        #expect(ABCAnnotation.Position.auto.prefix == "@")
    }

    @Test
    func prefix_below() {
        #expect(ABCAnnotation.Position.below.prefix == "_")
    }

    @Test
    func prefix_left() {
        #expect(ABCAnnotation.Position.left.prefix == "<")
    }

    @Test
    func prefix_right() {
        #expect(ABCAnnotation.Position.right.prefix == ">")
    }
}
