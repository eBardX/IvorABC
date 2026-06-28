// © 2026 John Gary Pusey (see LICENSE.md)

/// An issue found when validating an ``ABCTunebook`` against the ABC
/// specification.
public enum ABCValidationIssue {

    /// A field in the file header is not valid in that position.
    case misplacedFileHeaderField(ABCField)

    /// A tune has a reference number (`X:`) field but it is not the first
    /// header field.
    case misplacedReferenceNumber(tuneIndex: Int)

    /// A field in a tune header or body is not valid in that position.
    case misplacedTuneField(ABCField, tuneIndex: Int)

    /// A tune has no reference number (`X:`) field.
    case missingReferenceNumber(tuneIndex: Int)

    /// A shorthand decoration was encountered that is neither a builtin
    /// shorthand nor defined by a preceding `U:` field.
    case undefinedUserSymbol(tuneIndex: Int?)
}

// MARK: -

extension ABCValidationIssue {

    // MARK: Public Instance Properties

    /// A human-readable description of this issue.
    public var message: String {
        switch self {
        case let .misplacedFileHeaderField(field):
            "File header contains a field not valid in that position: \(field)"

        case let .misplacedReferenceNumber(tuneIndex):
            "Tune \(tuneIndex) has a reference number (X:) field but it is not the first header field"

        case let .misplacedTuneField(field, tuneIndex):
            "Tune \(tuneIndex) contains a field not valid at that position: \(field)"

        case let .missingReferenceNumber(tuneIndex):
            "Tune \(tuneIndex) has no reference number (X:) field"

        case let .undefinedUserSymbol(tuneIndex):
            "\(_tuneLabel(tuneIndex)) contains a shorthand decoration with no preceding U: definition and no builtin shorthand"
        }
    }

    /// The zero-based index of the tune containing this issue,
    /// or `nil` if the issue is in the file header.
    public var tuneIndex: Int? {
        switch self {
        case let .undefinedUserSymbol(tuneIndex):
            tuneIndex

        case .misplacedFileHeaderField:
            nil

        case let .misplacedReferenceNumber(tuneIndex),
             let .misplacedTuneField(_, tuneIndex),
             let .missingReferenceNumber(tuneIndex):
            tuneIndex
        }
    }
}

// MARK: - Equatable

extension ABCValidationIssue: Equatable {
}

// MARK: - Sendable

extension ABCValidationIssue: Sendable {
}

// MARK: - Private Functions

private func _tuneLabel(_ tuneIndex: Int?) -> String {
    tuneIndex.map { "Tune \($0)" } ?? "File header"
}
