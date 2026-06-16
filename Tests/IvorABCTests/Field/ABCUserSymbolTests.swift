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

        guard case let .decoration(decoration) = uds.definition
        else { Issue.record("Expected .decoration target"); return }

        #expect(decoration.name == "roll")
        #expect(decoration.dialect == .bang)
    }

    @Test
    func target_annotation_isStored() {
        let annotation = ABCAnnotation(position: .above, text: "fermata")
        let uds = makeUserSymbol(.hUpper, .annotation(annotation))

        guard case let .annotation(stored) = uds.definition
        else { Issue.record("Expected .annotation target"); return }

        #expect(stored == annotation)
    }

    @Test
    func equality() {
        let lhs = makeUserSymbol(.tUpper, makeDecoration("trill"))
        let rhs = makeUserSymbol(.tUpper, makeDecoration("trill"))

        #expect(lhs == rhs)
    }

    @Test
    func inequality_differentDecoration() {
        let lhs = makeUserSymbol(.tUpper, makeDecoration("trill"))
        let rhs = makeUserSymbol(.tUpper, makeDecoration("roll"))

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
