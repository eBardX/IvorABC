// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCParser {

    // MARK: Public Nested Types

    /// Controls how strictly the parser enforces ABC notation standard conformance.
    public enum Strictness {
        /// Tolerates common real-world deviations and collects
        /// ``ABCDiagnostic`` values describing what was recovered.
        case lenient

        /// Requires strict conformance to the ABC notation standard; any
        /// deviation throws an error. This is the default.
        case strict
    }
}

// MARK: - Equatable

extension ABCParser.Strictness: Equatable {
}

// MARK: - Hashable

extension ABCParser.Strictness: Hashable {
}

// MARK: - Sendable

extension ABCParser.Strictness: Sendable {
}
