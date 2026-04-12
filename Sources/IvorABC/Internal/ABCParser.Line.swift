// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension ABCParser {
    internal enum Line {
        case directive(ABCDirective)
        case empty
        case field(ABCField)
        case fileID(ABCFileID)
        case symbols([ABCSymbol])
    }
}

// MARK: - Sendable

extension ABCParser.Line: Sendable {
}
