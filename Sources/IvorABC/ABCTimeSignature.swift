// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC time signature.
public enum ABCTimeSignature {
    /// Common time (4/4).
    case common

    /// Cut time (2/2).
    case cut

    /// An empty time signature.
    case empty

    /// An explicit time signature expressed as a fraction.
    case explicit(ABCFraction)
}

// MARK: - Equatable

extension ABCTimeSignature: Equatable {
}

// MARK: - Sendable

extension ABCTimeSignature: Sendable {
}
