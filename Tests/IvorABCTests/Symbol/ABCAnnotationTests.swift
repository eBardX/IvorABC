// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCAnnotationTests {
}

// MARK: -

extension ABCAnnotationTests {
    @Test
    func equality() {
        let a = ABCAnnotation(position: .above, text: "Hello")
        let b = ABCAnnotation(position: .above, text: "Hello")

        #expect(a == b)
    }

    @Test
    func inequality_differentPosition() {
        let a = ABCAnnotation(position: .above, text: "Hello")
        let b = ABCAnnotation(position: .below, text: "Hello")

        #expect(a != b)
    }

    @Test
    func inequality_differentText() {
        let a = ABCAnnotation(position: .above, text: "Hello")
        let b = ABCAnnotation(position: .above, text: "World")

        #expect(a != b)
    }

    @Test
    func init_storesProperties() {
        let annotation = ABCAnnotation(position: .right, text: "sfz")

        #expect(annotation.position == .right)
        #expect(annotation.text == "sfz")
    }

    @Test
    func init_stringValue_above() throws {
        let annotation = try #require(ABCAnnotation(stringValue: "^Hello"))

        #expect(annotation.position == .above)
        #expect(annotation.text == "Hello")
    }

    @Test
    func init_stringValue_auto() throws {
        let annotation = try #require(ABCAnnotation(stringValue: "@"))

        #expect(annotation.position == .auto)
        #expect(annotation.text.isEmpty)
    }

    @Test
    func init_stringValue_below() throws {
        let annotation = try #require(ABCAnnotation(stringValue: "_sfz"))

        #expect(annotation.position == .below)
        #expect(annotation.text == "sfz")
    }

    @Test
    func init_stringValue_emptyString() {
        #expect(ABCAnnotation(stringValue: "") == nil)
    }

    @Test
    func init_stringValue_invalidPrefix() {
        #expect(ABCAnnotation(stringValue: "xHello") == nil)
    }

    @Test
    func init_stringValue_left() throws {
        let annotation = try #require(ABCAnnotation(stringValue: "<sfz"))

        #expect(annotation.position == .left)
        #expect(annotation.text == "sfz")
    }

    @Test
    func init_stringValue_right() throws {
        let annotation = try #require(ABCAnnotation(stringValue: ">sfz"))

        #expect(annotation.position == .right)
        #expect(annotation.text == "sfz")
    }

    @Test
    func stringValue() {
        let annotation = ABCAnnotation(position: .above, text: "Hello")

        #expect(annotation.stringValue == "^Hello")
    }
}
