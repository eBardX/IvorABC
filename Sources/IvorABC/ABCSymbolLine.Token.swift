// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCSymbolLine {

    // MARK: Public Nested Tyoes

    /// A single positional token in a symbol line.
    public enum Token {
        /// An annotation to attach to the corresponding note.
        ///
        /// The string includes the positioning prefix (`^`, `_`, `@`, `<`, `>`)
        /// but not the surrounding quotes.
        case annotation(String)

        /// A chord symbol to attach to the corresponding note.
        ///
        /// The string does not include the surrounding quotes.
        case chordSymbol(String)

        /// A decoration to apply to the corresponding note.
        ///
        /// The string includes the surrounding `!` delimiters.
        case decoration(String)

        /// No decoration for the corresponding note.
        case skip
    }
}

// MARK: - Equatable

extension ABCSymbolLine.Token: Equatable {
}

// MARK: - Sendable

extension ABCSymbolLine.Token: Sendable {
}
