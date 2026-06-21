// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single entry in an ABC file header or tune header.
public enum ABCHeaderEntry {
    /// A directive entry.
    case directive(ABCDirective)

    /// A field entry.
    case field(ABCField)
}

// MARK: - Equatable

extension ABCHeaderEntry: Equatable {
}

// MARK: - Sendable

extension ABCHeaderEntry: Sendable {
}
