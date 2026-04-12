// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// An error that occurs during parsing of ABC notation.
public enum ABCParseError {
    /// The input data could not be converted from UTF-8.
    case dataConversionFailed

    /// The parser encountered a directive it could not parse.
    case invalidDirective(Substring)

    /// The parser encountered a field it could not parse.
    ///
    /// The associated `Bool` value is `true` if the field was inline.
    case invalidField(Bool, Substring)

    /// The parser encountered an invalid file identifier.
    case invalidFileID(Substring)

    /// The parser encountered an invalid key signature.
    case invalidKeySignature(Substring)

    /// The parser encountered an invalid note.
    case invalidNote(Substring)

    /// The parser encountered an invalid pitch.
    case invalidPitch(Substring)

    /// The parser encountered an invalid reference number.
    case invalidRefNumber(Substring)

    /// The parser encountered an invalid rest.
    case invalidRest(Substring)

    /// The parser encountered an invalid sequence of music code symbols.
    case invalidSymbols(Substring)

    /// The parser encountered an invalid tempo specification.
    case invalidTempo(Substring)

    /// The parser encountered an invalid time signature.
    case invalidTimeSignature(Substring)

    /// The parser encountered an invalid tuplet specification.
    case invalidTuplet(Substring)

    /// The parser encountered an invalid unit note length.
    case invalidUnitNoteLength(Substring)

    /// The parser encountered an invalid version string.
    case invalidVersion(Substring)

    /// The parser encountered an invalid voice specification.
    case invalidVoice(Substring)

    /// The parser encountered a field in a location where it is not permitted.
    case misplacedField(ABCField)

    /// The input is missing the required file identifier on the first line.
    case missingFileID

    /// The file identifier specifies a version of ABC that is not supported.
    case unsupportedVersion(ABCVersion)
}

// MARK: - EnhancedError

extension ABCParseError: EnhancedError {
    public var category: Category? {
        Category("IvorABC")
    }

    public var message: String {
        switch self {
        case .dataConversionFailed:
            "Failed to convert UTF-8 data to string"

        case let .invalidDirective(value):
            "Invalid directive: ‘\(value)’"

        case let .invalidField(isInline, value):
            if isInline {
                "Invalid inline field: ‘\(value)’"
            } else {
                "Invalid field: ‘\(value)’"
            }

        case let .invalidFileID(value):
            "Invalid file identifier: ‘\(value)’"

        case let .invalidKeySignature(value):
            "Invalid key signature: ‘\(value)’"

        case let .invalidNote(value):
            "Invalid note: ‘\(value)’"

        case let .invalidPitch(value):
            "Invalid pitch: ‘\(value)’"

        case let .invalidRefNumber(value):
            "Invalid reference number: ‘\(value)’"

        case let .invalidRest(value):
            "Invalid rest: ‘\(value)’"

        case let .invalidSymbols(value):
            "Invalid music code symbols: ‘\(value)’"

        case let .invalidTempo(value):
            "Invalid tempo: ‘\(value)’"

        case let .invalidTimeSignature(value):
            "Invalid time signature: ‘\(value)’"

        case let .invalidTuplet(value):
            "Invalid tuplet: ‘\(value)’"

        case let .invalidUnitNoteLength(value):
            "Invalid unit note length: ‘\(value)’"

        case let .invalidVersion(value):
            "Invalid version: ‘\(value)’"

        case let .invalidVoice(value):
            "Invalid voice: ‘\(value)’"

        case let .misplacedField(field):
            "Misplaced field: \(field)"

        case .missingFileID:
            "Missing required file ID"

        case let .unsupportedVersion(version):
            "Unsupported ABC version: \(version.major).\(version.minor)"
        }
    }
}

// MARK: - Sendable

extension ABCParseError: Sendable {
}
