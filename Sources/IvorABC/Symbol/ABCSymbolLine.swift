// © 2026 John Gary Pusey (see LICENSE.md)

/// A parsed ABC symbol line (`s:`).
///
/// A symbol line associates decorations with specific notes in the music line.
/// Each element corresponds positionally to a note.
public struct ABCSymbolLine {

    // MARK: Public Initializers

    /// Creates a new symbol line with the given elements.
    ///
    /// - Parameter elements: The positional elements.
    public init(elements: [Element]) {
        self.elements = elements    // validate ???
    }

    // MARK: Public Instance Properties

    /// The positional elements, each corresponding to a note in the music line.
    public let elements: [Element]
}

// MARK: - Equatable

extension ABCSymbolLine: Equatable {
}

// MARK: - Sendable

extension ABCSymbolLine: Sendable {
}
