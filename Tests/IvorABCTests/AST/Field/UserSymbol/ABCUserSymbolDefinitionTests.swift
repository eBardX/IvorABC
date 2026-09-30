// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCUserSymbolDefinitionTests {
}

// MARK: -

extension ABCUserSymbolDefinitionTests {
    @Test
    func equality_annotation() {
        let a = ABCUserSymbol.Definition.annotation(makeAnnotation(.above, "text"))
        let b = ABCUserSymbol.Definition.annotation(makeAnnotation(.above, "text"))

        #expect(a == b)
    }

    @Test
    func equality_decoration() {
        let a = ABCUserSymbol.Definition.decoration(makeDecoration("roll"))
        let b = ABCUserSymbol.Definition.decoration(makeDecoration("roll"))

        #expect(a == b)
    }

    @Test
    func inequality_annotationVsDecoration() {
        let a = ABCUserSymbol.Definition.annotation(makeAnnotation(.above, "text"))
        let b = ABCUserSymbol.Definition.decoration(makeDecoration("roll"))

        #expect(a != b)
    }

    @Test
    func inequality_differentAnnotations() {
        let a = ABCUserSymbol.Definition.annotation(makeAnnotation(.above, "up"))
        let b = ABCUserSymbol.Definition.annotation(makeAnnotation(.below, "up"))

        #expect(a != b)
    }

    @Test
    func inequality_differentDecorations() {
        let a = ABCUserSymbol.Definition.decoration(makeDecoration("roll"))
        let b = ABCUserSymbol.Definition.decoration(makeDecoration("trill"))

        #expect(a != b)
    }
}
