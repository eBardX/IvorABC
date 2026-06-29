// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCValidator {

    // MARK: Public Nested Types

    /// An issue found when validating an ``ABCTunebook`` against the ABC
    /// specification.
    public enum Issue {

        /// A field in the file header is not valid in that position.
        case misplacedFileHeaderField(ABCField)

        /// A tune has a reference number (`X:`) field but it is not the first
        /// header field.
        case misplacedReferenceNumber(Int)

        /// A field in a tune header or body is not valid in that position.
        case misplacedTuneField(ABCField, Int)

        /// A tune has no reference number (`X:`) field.
        case missingReferenceNumber(Int)

        /// A shorthand decoration was encountered that is neither a builtin
        /// shorthand nor defined by a preceding `U:` field.
        case undefinedUserSymbol(Int?)
    }
}

// MARK: -

extension ABCValidator.Issue {

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

extension ABCValidator.Issue: Equatable {
}

// MARK: - Sendable

extension ABCValidator.Issue: Sendable {
}

// MARK: - Private Functions

private func _tuneLabel(_ tuneIndex: Int?) -> String {
    tuneIndex.map { "Tune \($0)" } ?? "File header"
}
