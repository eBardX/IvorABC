// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single entry in an ABC tune.
public enum ABCEntry {
    /// A directive entry.
    case directive(ABCDirective)

    /// A field entry.
    case field(ABCField)

    /// A music code symbols entry.
    case symbols([ABCSymbol])
}

// MARK: - Equatable

extension ABCEntry: Equatable {
}

// MARK: - Sendable

extension ABCEntry: Sendable {
}
