// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single entry in an ABC file header or tune header.
///
/// See §3 (“Information fields”) of the ABC 2.1 standard.
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
