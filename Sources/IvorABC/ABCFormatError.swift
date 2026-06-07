// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// An error that occurs when formatting an ABC tunebook.
public enum ABCFormatError {
    /// A text value contains a newline character.
    case invalidStringArgument(String)

    /// A field appears in a position where it is not permitted in the file
    /// header.
    case misplacedFileHeaderField(ABCField)

    /// A field appears in a position where it is not permitted in the tune
    /// header or body.
    case misplacedTuneField(ABCField)

    /// A tune header has no terminating key signature (`K:`) field.
    case missingKeySignature

    /// A tune does not begin with a reference number (`X:`) field.
    case missingReferenceNumber

    /// The formatted buffer could not be converted to UTF-8 data.
    case stringConversionFailed
}

// MARK: - EnhancedError

extension ABCFormatError: EnhancedError {
    /// The error category identifying the source module.
    public var category: Category? {
        Category("IvorABC")
    }

    /// A human-readable description of this error.
    public var message: String {
        switch self {
        case let .invalidStringArgument(value):
            "String argument contains invalid characters: \(value)"

        case let .misplacedFileHeaderField(field):
            "Field is not valid in the file header: \(field)"

        case let .misplacedTuneField(field):
            "Field is not valid at this position in the tune: \(field)"

        case .missingKeySignature:
            "Tune header has no terminating key signature (K:) field"

        case .missingReferenceNumber:
            "Tune does not begin with a reference number (X:) field"

        case .stringConversionFailed:
            "Failed to convert string to UTF-8 data"
        }
    }
}

// MARK: - Equatable

extension ABCFormatError: Equatable {
}

// MARK: - Sendable

extension ABCFormatError: Sendable {
}
