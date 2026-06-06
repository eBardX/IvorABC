// © 2026 John Gary Pusey (see LICENSE.md)

/// A diagnostic message produced by ``ABCParser`` when parsing in lenient mode.
public enum ABCDiagnostic {

    /// A `Q:` field used the bare-integer form (e.g. `Q:120`) with no beat
    /// unit specified; the beat unit is implied by the active `L:` value.
    case bareTempoRate(UInt)

    /// A field appeared outside its permitted section and was skipped.
    case misplacedField(ABCField)

    /// The input had no `%abc` file identifier line; ABC version 2.1 was assumed.
    case missingFileID

    /// A line could not be parsed and was skipped.
    case unrecognizedLine(String)

    /// The file identifier specified an unsupported ABC version; parsing
    /// continued with the declared version.
    case unsupportedVersion(ABCVersion)
}

// MARK: -

extension ABCDiagnostic {

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

        case let .unrecognizedLine(line):
            "Unrecognized line skipped: '\(line)'"

        case let .unsupportedVersion(version):
            "Unsupported ABC version \(version.major).\(version.minor); parsing continued"
        }
    }
}

// MARK: - Equatable

extension ABCDiagnostic: Equatable {
}

// MARK: - Sendable

extension ABCDiagnostic: Sendable {
}
