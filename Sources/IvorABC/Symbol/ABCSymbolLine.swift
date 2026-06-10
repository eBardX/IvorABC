// © 2026 John Gary Pusey (see LICENSE.md)

/// A parsed ABC symbol line (`s:`).
///
/// A symbol line associates decorations with specific notes in the music line.
/// Each token corresponds positionally to a note.
public struct ABCSymbolLine {

    // MARK: Public Initializers

    /// Creates a new symbol line with the given tokens.
    ///
    /// - Parameter tokens: The positional tokens.
    public init(tokens: [Element]) {
        self.tokens = tokens
    }

    // MARK: Public Instance Properties

    /// The positional tokens, each corresponding to a note in the music line.
    public let tokens: [Element]
}

// MARK: - Equatable

extension ABCSymbolLine: Equatable {
}

// MARK: - Sendable

extension ABCSymbolLine: Sendable {
}
