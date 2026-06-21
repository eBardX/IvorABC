// © 2026 John Gary Pusey (see LICENSE.md)

/// A chord symbol (guitar chord / harmony) in ABC music notation.
public struct ABCChordSymbol {

    // MARK: Public Instance Properties

    /// The bass note of a slash chord (e.g. `B` in `"G/B"`),
    /// or `nil` if there is no explicit bass note.
    public let bass: Root?

    /// The chord name (root and quality).
    public let name: Name

    /// A secondary chord written in parentheses (e.g. the `Em` in `"G(Em)"`),
    /// or `nil` if absent.
    public let parenthesized: Name?

    // MARK: Public Initializers

    /// Creates a chord symbol.
    ///
    /// - Parameter name:          The chord name (root and quality).
    /// - Parameter bass:          The bass note for a slash chord, or `nil`.
    /// - Parameter parenthesized: An optional secondary chord written in parentheses.
    public init(name: Name,
                bass: Root? = nil,
                parenthesized: Name? = nil) {
        self.bass = bass
        self.name = name
        self.parenthesized = parenthesized
    }
}

// MARK: - Equatable

extension ABCChordSymbol: Equatable {
}

// MARK: - Sendable

extension ABCChordSymbol: Sendable {
}
