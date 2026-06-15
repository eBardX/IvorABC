// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCParser {

    // MARK: Public Nested Types

    /// Controls how strictly the parser enforces ABC notation standard conformance.
    public enum Strictness {
        /// Tolerates common real-world deviations from the ABC notation
        /// standard and collects ``Diagnostic`` values describing what was
        /// recovered.
        ///
        /// Specifically, lenient mode accepts:
        /// - A missing `%abc` file identifier (assumes ABC 2.1; emits
        ///   ``Diagnostic/missingFileID``).
        /// - A `%abc` identifier with an unsupported version (parses with
        ///   the declared version; emits
        ///   ``Diagnostic/unsupportedVersion(_:)``).
        /// - A bare-integer tempo such as `Q:120` with no beat unit (the beat
        ///   unit is implied by the active `L:` value; emits
        ///   ``Diagnostic/bareTempoRate(_:)``).
        /// - A field outside its permitted section (the field is skipped;
        ///   emits ``Diagnostic/misplacedField(_:)``).
        /// - A line that cannot otherwise be parsed (the line is skipped;
        ///   emits ``Diagnostic/unrecognizedLine(_:)``).
        case lenient

        /// Requires full conformance to the declared ABC notation version;
        /// any deviation throws an ``Error``. This is the default.
        ///
        /// Specifically, strict mode requires:
        /// - A `%abc-M.m` file identifier on the first line, where `M.m`
        ///   is a known supported version (currently 1.6, 2.0, or 2.1).
        /// - All fields in their permitted sections.
        /// - Tempo in the `note=rate` form (e.g. `Q:1/4=120`) when parsing
        ///   an ABC 2.1 file. ABC 2.0 and 1.6 files may use the bare-integer
        ///   form (e.g. `Q:120`). ABC 1.6 files additionally accept the
        ///   `Q:C=rate` and `Q:Cn=rate` forms where `C` represents the
        ///   active default note length.
        ///
        /// ABC 1.6 differences accepted in strict mode:
        /// - `I:` is treated as a free-text information field (not a 2.x
        ///   instruction/directive) and stored as ``ABCField/information(_:)``.
        /// - `E:` (elemskip) is accepted and stored as ``ABCField/elemskip(_:)``.
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
