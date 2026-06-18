// © 2026 John Gary Pusey (see LICENSE.md)

/// A slur marker in ABC notation.
public enum ABCSlur {
    /// A dotted slur end (`.)`, per the ABC 2.1 spec: "it is optional to dot
    /// the closing brace."
    case endDotted

    /// A regular slur end (`)`).
    case endRegular

    /// A dotted slur start (`.(`) .
    case startDotted

    /// A regular slur start (`(`).
    case startRegular
}

// MARK: - Equatable

extension ABCSlur: Equatable {
}

// MARK: - Sendable

extension ABCSlur: Sendable {
}
