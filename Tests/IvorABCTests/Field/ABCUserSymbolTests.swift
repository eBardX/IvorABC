// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCUserSymbolTests {
}

// MARK: -

extension ABCUserSymbolTests {
    @Test
    func target_decoration_isStored() {
        let uds = makeUserSymbol(.tilde, makeDecoration("roll"))

        guard let definition = uds.definition,
              case let .decoration(decoration) = definition
        else { Issue.record("Expected .decoration target"); return }

        #expect(decoration.name == "roll")
        #expect(decoration.dialect == .bang)
    }

    @Test
    func target_annotation_isStored() {
        let annotation = makeAnnotation(.above, "fermata")
        let uds = makeUserSymbol(.hUpper, .annotation(annotation))

        guard let definition = uds.definition,
              case let .annotation(stored) = definition
        else { Issue.record("Expected .annotation target"); return }

        #expect(stored == annotation)
    }

    @Test
    func deassignment_definitionIsNil() {
        let uds = makeUserSymbol(.tUpper)

        #expect(uds.definition == nil)
        #expect(uds.shorthand == .tUpper)
    }

    @Test
    func deassignment_dotShorthand_returnsNil() {
        #expect(ABCUserSymbol(shorthand: .dot, definition: nil) == nil)
    }

    @Test
    func equality() {
        let lhs = makeUserSymbol(.tUpper, makeDecoration("trill"))
        let rhs = makeUserSymbol(.tUpper, makeDecoration("trill"))

        #expect(lhs == rhs)
    }

    @Test
    func equality_annotation() {
        let lhs = makeUserSymbol(.hUpper, makeAnnotation(.above, "fermata"))
        let rhs = makeUserSymbol(.hUpper, makeAnnotation(.above, "fermata"))

        #expect(lhs == rhs)
    }

    @Test
    func inequality_differentDecoration() {
        let lhs = makeUserSymbol(.tUpper, makeDecoration("trill"))
        let rhs = makeUserSymbol(.tUpper, makeDecoration("roll"))

        #expect(lhs != rhs)
    }

    @Test
    func inequality_differentAnnotation() {
        let lhs = makeUserSymbol(.hUpper, makeAnnotation(.above, "fermata"))
        let rhs = makeUserSymbol(.hUpper, makeAnnotation(.above, "col legno"))

        #expect(lhs != rhs)
    }

    @Test
    func inequality_annotationVsDecoration() {
        let lhs = makeUserSymbol(.hUpper, makeAnnotation(.above, "fermata"))
        let rhs = makeUserSymbol(.hUpper, makeDecoration("fermata"))

        #expect(lhs != rhs)
    }

    @Test
    func inequality_differentShorthand() {
        let lhs = makeUserSymbol(.tUpper, makeDecoration("trill"))
        let rhs = makeUserSymbol(.hUpper, makeDecoration("trill"))

        #expect(lhs != rhs)
    }

    @Test
    func shorthand_isStored() {
        let uds = makeUserSymbol(.tilde, makeDecoration("roll"))

        #expect(uds.shorthand == .tilde)
    }
}
