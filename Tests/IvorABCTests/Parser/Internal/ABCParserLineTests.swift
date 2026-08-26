// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCParserLineTests {
}

// MARK: -

extension ABCParserLineTests {
    @Test
    func continuation_holdsText() {
        let line = ABCParser.Line.continuation("more text")

        guard case let .continuation(text) = line
        else { Issue.record("Expected .continuation"); return }

        #expect(text == "more text")
    }

    @Test
    func directive_holdsDirective() {
        let directive = makeDirective("staffwidth", "170")
        let line = ABCParser.Line.directive(directive)

        guard case let .directive(value) = line
        else { Issue.record("Expected .directive"); return }

        #expect(value == directive)
    }

    @Test
    func empty_isEmptyCase() {
        let line = ABCParser.Line.empty

        guard case .empty = line
        else { Issue.record("Expected .empty"); return }
    }

    @Test
    func field_holdsField() {
        let line = ABCParser.Line.field(.part(.a))

        guard case let .field(value) = line
        else { Issue.record("Expected .field"); return }

        #expect(value == .part(.a))
    }

    @Test
    func symbols_holdsSymbols() {
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let line = ABCParser.Line.symbols([.note(note)])

        guard case let .symbols(value) = line
        else { Issue.record("Expected .symbols"); return }

        #expect(value == [.note(note)])
    }
}
