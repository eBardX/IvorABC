// © 2026 John Gary Pusey (see LICENSE.md)

/// A tie in ABC notation.
public enum ABCTie {
    /// A dotted tie (`.-`).
    case dotted

    /// A regular tie (`-`).
    case regular
}

// MARK: - Equatable

extension ABCTie: Equatable {
}

// MARK: - Sendable

extension ABCTie: Sendable {
}
