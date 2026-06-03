// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC user symbol mapping (`U:`).
///
/// Maps a single character to a decoration, for example:
/// ```
/// U: ~ = !roll!
/// U: T = !trill!
/// ```
public struct ABCUserSymbol {

    // MARK: Public Initializers

    /// Creates a new user symbol mapping.
    ///
    /// - Parameter symbol:     The character being mapped.
    /// - Parameter decoration: The decoration the symbol maps to.
    public init(symbol: Character,
                decoration: String) {
        self.symbol = symbol
        self.decoration = decoration
    }

    // MARK: Public Instance Properties

    /// The decoration this symbol maps to.
    public let decoration: String

    /// The character being mapped.
    public let symbol: Character
}

// MARK: - Equatable

extension ABCUserSymbol: Equatable {
}

// MARK: - Sendable

extension ABCUserSymbol: Sendable {
}
