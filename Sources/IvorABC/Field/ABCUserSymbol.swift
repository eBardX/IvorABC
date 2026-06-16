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
                decoration: ABCDecoration) {
        self.decoration = decoration
        self.symbol = symbol            // validate ???
    }

    // MARK: Public Instance Properties

    /// The decoration this symbol maps to.
    public let decoration: ABCDecoration

    /// The character being mapped.
    public let symbol: Character
}

// MARK: - Equatable

extension ABCUserSymbol: Equatable {
}

// MARK: - Sendable

extension ABCUserSymbol: Sendable {
}
