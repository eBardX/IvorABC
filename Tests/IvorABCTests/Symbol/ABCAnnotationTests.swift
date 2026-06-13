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
    func inequality_differentPosition() {
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

        #expect(annotation.position == .right)
        #expect(annotation.text == "sfz")
    }

    @Test
    func init_stringValue_above() throws {
        let annotation = try #require(makeAnnotation(stringValue: "^Hello"))

        #expect(annotation.position == .above)
        #expect(annotation.text == "Hello")
    }

    @Test
    func init_stringValue_auto() throws {
        let annotation = try #require(makeAnnotation(stringValue: "@"))

        #expect(annotation.position == .auto)
        #expect(annotation.text.isEmpty)
    }

    @Test
    func init_stringValue_below() throws {
        let annotation = try #require(makeAnnotation(stringValue: "_sfz"))

        #expect(annotation.position == .below)
        #expect(annotation.text == "sfz")
    }

    @Test
    func init_stringValue_emptyString() {
        #expect(makeAnnotation(stringValue: "") == nil)
    }

    @Test
    func init_stringValue_invalidPrefix() {
        #expect(makeAnnotation(stringValue: "xHello") == nil)
    }

    @Test
    func init_stringValue_left() throws {
        let annotation = try #require(makeAnnotation(stringValue: "<sfz"))

        #expect(annotation.position == .left)
        #expect(annotation.text == "sfz")
    }

    @Test
    func init_stringValue_right() throws {
        let annotation = try #require(makeAnnotation(stringValue: ">sfz"))

        #expect(annotation.position == .right)
        #expect(annotation.text == "sfz")
    }

    @Test
    func stringValue() {
        let annotation = makeAnnotation(.above, "Hello")

        #expect(annotation.stringValue == "^Hello")
    }
}
