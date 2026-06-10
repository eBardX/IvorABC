// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCParser {

    // MARK: Public Nested Types

    /// An error that occurs during parsing of ABC notation.
    public enum Error {
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

        /// The parser encountered an invalid macro definition.
        case invalidMacro(Substring)

        /// The parser encountered an invalid note.
        case invalidNote(Substring)

        /// The parser encountered an invalid part sequence.
        case invalidPartSequence(Substring)

        /// The parser encountered an invalid pitch.
        case invalidPitch(Substring)

        /// The parser encountered an invalid reference number.
        case invalidRefNumber(Substring)

        /// The parser encountered an invalid rest.
        case invalidRest(Substring)

        /// The parser encountered an invalid symbol line.
        case invalidSymbolLine(Substring)

        /// The parser encountered an invalid sequence of music code symbols.
        case invalidSymbols(Substring)

        /// The parser encountered an invalid tempo specification.
        ///
        /// In ``ABCParser/Strictness/lenient`` mode, or in
        /// ``ABCParser/Strictness/strict`` mode when parsing a known older
        /// version (e.g. 2.0), a bare-integer tempo (e.g. `Q:120`) is
        /// recovered instead. In lenient mode it is also reported as
        /// ``ABCParser/Diagnostic/bareTempoRate(_:)``.
        case invalidTempo(Substring)

        /// The parser encountered an invalid time signature.
        case invalidTimeSignature(Substring)

        /// The parser encountered an invalid tuplet specification.
        case invalidTuplet(Substring)

        /// The parser encountered an invalid unit note length.
        case invalidUnitNoteLength(Substring)

        /// The parser encountered an invalid user-defined symbol mapping.
        case invalidUserSymbol(Substring)

        /// The parser encountered an invalid version string.
        case invalidVersion(Substring)

        /// The parser encountered an invalid voice specification.
        case invalidVoice(Substring)

        /// The parser encountered a field in a location where it is not permitted.
        ///
        /// In ``ABCParser/Strictness/lenient`` mode, this condition is recovered
        /// instead and reported as ``ABCParser/Diagnostic/misplacedField(_:)``.
        case misplacedField(ABCField)

        /// The input is missing the required file identifier on the first line.
        ///
        /// In ``ABCParser/Strictness/lenient`` mode, this condition is recovered
        /// instead and reported as ``ABCParser/Diagnostic/missingFileID``.
        case missingFileID

        /// The parser encountered a `%%beginXxx` directive with no matching `%%endXxx`.
        case unmatchedBeginDirective(String)

        /// The file identifier specifies an unsupported ABC version.
        ///
        /// In ``ABCParser/Strictness/lenient`` mode, this condition is recovered
        /// instead and reported as ``ABCParser/Diagnostic/unsupportedVersion(_:)``.
        case unsupportedVersion(ABCVersion)
    }
}

// MARK: - EnhancedError

extension ABCParser.Error: EnhancedError {
    /// The error category identifying the source module.
    public var category: Category? {
        Category("IvorABC")
    }

    /// A human-readable description of this error.
    public var message: String {
        switch self {
        case .dataConversionFailed:
            "Failed to convert UTF-8 data to string"

        case let .invalidDirective(value):
            "Invalid directive: '\(value)'"

        case let .invalidField(isInline, value):
            if isInline {
                "Invalid inline field: '\(value)'"
            } else {
                "Invalid field: '\(value)'"
            }

        case let .invalidFileID(value):
            "Invalid file identifier: '\(value)'"

        case let .invalidKeySignature(value):
            "Invalid key signature: '\(value)'"

        case let .invalidMacro(value):
            "Invalid macro: '\(value)'"

        case let .invalidNote(value):
            "Invalid note: '\(value)'"

        case let .invalidPartSequence(value):
            "Invalid part sequence: '\(value)'"

        case let .invalidPitch(value):
            "Invalid pitch: '\(value)'"

        case let .invalidRefNumber(value):
            "Invalid reference number: '\(value)'"

        case let .invalidRest(value):
            "Invalid rest: '\(value)'"

        case let .invalidSymbolLine(value):
            "Invalid symbol line: '\(value)'"

        case let .invalidSymbols(value):
            "Invalid music code symbols: '\(value)'"

        case let .invalidTempo(value):
            "Invalid tempo: '\(value)'"

        case let .invalidTimeSignature(value):
            "Invalid time signature: '\(value)'"

        case let .invalidTuplet(value):
            "Invalid tuplet: '\(value)'"

        case let .invalidUnitNoteLength(value):
            "Invalid unit note length: '\(value)'"

        case let .invalidUserSymbol(value):
            "Invalid user-defined symbol: '\(value)'"

        case let .invalidVersion(value):
            "Invalid version: '\(value)'"

        case let .invalidVoice(value):
            "Invalid voice: '\(value)'"

        case let .misplacedField(field):
            "Misplaced field: \(field)"

        case .missingFileID:
            "Missing required file ID"

        case let .unmatchedBeginDirective(name):
            "'%%begin\(name)' has no matching '%%end\(name)'"

        case let .unsupportedVersion(version):
            "Unsupported ABC version: \(version.major).\(version.minor)"
        }
    }
}

// MARK: - Sendable

extension ABCParser.Error: Sendable {
}
