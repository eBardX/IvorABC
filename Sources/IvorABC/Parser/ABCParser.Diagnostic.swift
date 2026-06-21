// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCParser {

    // MARK: Public Nested Types

    /// A diagnostic message produced by ``ABCParser`` when parsing in lenient mode.
    public enum Diagnostic {

        /// A `Q:` field used the bare-integer form (e.g. `Q:120`) with no beat
        /// unit specified; the beat unit is implied by the active `L:` value.
        /// The associated value is the tempo rate that was parsed.
        case bareTempoRate(UInt)

        /// A field appeared outside its permitted tune header or body section and
        /// was skipped. The associated value is the field that was skipped.
        case misplacedField(ABCField)

        /// The input had no `%abc` file identifier line; ABC version 2.1 was assumed.
        case missingFileID

        /// A tune had no ``ABCField/key(_:)`` field terminating its header; the
        /// tune body was started at the first music symbols line.
        case missingKeyField

        /// A line could not be parsed and was skipped. The associated value is
        /// the text of the skipped line.
        case unrecognizedLine(String)

        /// The file identifier specified an unsupported ABC version; parsing
        /// continued with the declared version. The associated value is the
        /// version that was declared.
        case unsupportedVersion(ABCVersion)
    }
}

// MARK: -

extension ABCParser.Diagnostic {

    // MARK: Public Instance Properties

    /// A human-readable description of this diagnostic.
    public var message: String {
        switch self {
        case let .bareTempoRate(rate):
            "Bare tempo '\(rate)' has no beat unit; beat unit is implied by L:"

        case let .misplacedField(field):
            "Misplaced field '\(field)' was skipped"

        case .missingFileID:
            "Missing file identifier; assumed ABC 2.1"

        case .missingKeyField:
            "Tune has no K: field; tune body assumed to start at first music line"

        case let .unrecognizedLine(line):
            "Unrecognized line skipped: '\(line)'"

        case let .unsupportedVersion(version):
            "Unsupported ABC version \(version.major).\(version.minor); parsing continued"
        }
    }
}

// MARK: - Equatable

extension ABCParser.Diagnostic: Equatable {
}

// MARK: - Sendable

extension ABCParser.Diagnostic: Sendable {
}
