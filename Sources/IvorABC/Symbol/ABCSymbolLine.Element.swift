// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCSymbolLine {

    // MARK: Public Nested Types

    /// A single positional element in a symbol line.
    public enum Element {
        /// An annotation to attach to the corresponding note.
        case annotation(ABCAnnotation)

        /// A chord symbol to attach to the corresponding note.
        ///
        /// The string does not include the surrounding quotes.
        case chordSymbol(String)    // validate ???

        /// A decoration to apply to the corresponding note.
        case decoration(ABCDecoration)

        /// No decoration for the corresponding note.
        case skip
    }
}

// MARK: - Equatable

extension ABCSymbolLine.Element: Equatable {
}

// MARK: - Sendable

extension ABCSymbolLine.Element: Sendable {
}
