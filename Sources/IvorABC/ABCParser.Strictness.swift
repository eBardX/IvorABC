// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCParser {

    // MARK: Public Nested Types

    /// Controls how strictly the parser enforces ABC notation standard conformance.
    public enum Strictness {
        /// Tolerates common real-world deviations from the ABC notation
        /// standard and collects ``ABCDiagnostic`` values describing what was
        /// recovered.
        ///
        /// Specifically, lenient mode accepts:
        /// - A missing `%abc` file identifier (assumes ABC 2.1; emits
        ///   ``ABCDiagnostic/missingFileID``).
        /// - A `%abc` identifier with a version other than 2.1 (parses with
        ///   the declared version; emits
        ///   ``ABCDiagnostic/unsupportedVersion(_:)``).
        /// - A bare-integer tempo such as `Q:120` with no beat unit (the beat
        ///   unit is implied by the active `L:` value; emits
        ///   ``ABCDiagnostic/bareTempoRate(_:)``).
        /// - A field outside its permitted section (the field is skipped;
        ///   emits ``ABCDiagnostic/misplacedField(_:)``).
        /// - A line that cannot otherwise be parsed (the line is skipped;
        ///   emits ``ABCDiagnostic/unrecognizedLine(_:)``).
        case lenient

        /// Requires full conformance to ABC notation standard version 2.1;
        /// any deviation throws an ``ABCParseError``. This is the default.
        ///
        /// Specifically, strict mode requires:
        /// - A `%abc-2.1` file identifier on the first line.
        /// - All fields in their permitted sections.
        /// - Tempo in the `note=rate` form (e.g. `Q:1/4=120`).
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
