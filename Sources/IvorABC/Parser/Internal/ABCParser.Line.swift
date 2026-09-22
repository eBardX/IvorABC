// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension ABCParser {

    // MARK: Internal Nested Types

    internal enum Line {
        case continuation(String)
        case directive(ABCDirective)
        case empty
        case field(ABCField)
        case symbols([ABCSymbol])
    }
}

// MARK: - Sendable

extension ABCParser.Line: Sendable {
}
