// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension ABCUserSymbol {

    // MARK: Public Nested Types

    /// What a shorthand character is mapped to.
    public enum Definition {

        // MARK: Public Cases

        /// Maps the shorthand to an annotation.
        case annotation(ABCAnnotation)

        /// Maps the shorthand to a decoration.
        case decoration(ABCDecoration)
    }
}

// MARK: - Equatable

extension ABCUserSymbol.Definition: Equatable {
}

// MARK: - Sendable

extension ABCUserSymbol.Definition: Sendable {
}
