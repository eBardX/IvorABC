// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single entry in an ABC tune body.
public enum ABCBodyEntry {
    /// A directive entry.
    case directive(ABCDirective)

    /// A field entry.
    case field(ABCField)

    /// A music code symbols entry.
    case symbols([ABCSymbol])
}

// MARK: - Equatable

extension ABCBodyEntry: Equatable {
}

// MARK: - Sendable

extension ABCBodyEntry: Sendable {
}
