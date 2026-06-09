// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single entry in an ABC file header.
public enum ABCHeader {
    /// A directive entry.
    case directive(ABCDirective)

    /// A field entry.
    case field(ABCField)
}

// MARK: - Equatable

extension ABCHeader: Equatable {
}

// MARK: - Sendable

extension ABCHeader: Sendable {
}
