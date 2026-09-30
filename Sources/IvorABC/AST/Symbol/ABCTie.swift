// © 2026 John Gary Pusey (see LICENSE.md)

/// A tie in ABC notation.
///
/// See §4.11 (“Ties and slurs”) of the ABC 2.1 standard.
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
