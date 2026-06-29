// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCValidator {

    // MARK: Public Nested Types

    /// An issue found when validating an ``ABCTunebook`` against the ABC
    /// specification.
    public enum Issue {

        /// An inline field in a tune body is not allowed to appear inline.
        case invalidInlineField(ABCField, Int)

        /// A field in the file header is not valid in that position.
        case misplacedFileHeaderField(ABCField)

        /// A tune has a key (`K:`) field but it is not the last header field.
        case misplacedKey(Int)

        /// A tune has a reference number (`X:`) field but it is not the first
        /// header field.
        case misplacedReferenceNumber(Int)

        /// A field in a tune body is not valid in that position.
        case misplacedTuneBodyField(ABCField, Int)

        /// A field in a tune header is not valid in that position.
        case misplacedTuneHeaderField(ABCField, Int)

        /// A tune has a title (`T:`) field but it is not the second header
        /// field.
        case misplacedTuneTitle(Int)

        /// A tune has no key (`K:`) field.
        case missingKey(Int)

        /// A tune has no reference number (`X:`) field.
        case missingReferenceNumber(Int)

        /// A tune has no title (`T:`) field.
        case missingTuneTitle(Int)

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
        case let .invalidInlineField(field, tuneIndex):
            "Tune \(tuneIndex) contains an inline field not allowed to appear inline: \(field)"

        case let .misplacedFileHeaderField(field):
            "The file header contains a field not valid in that position: \(field)"

        case let .misplacedKey(tuneIndex):
            "Tune \(tuneIndex) has a key (K:) field but it is not the last header field"

        case let .misplacedReferenceNumber(tuneIndex):
            "Tune \(tuneIndex) has a reference number (X:) field but it is not the first header field"

        case let .misplacedTuneBodyField(field, tuneIndex):
            "Tune \(tuneIndex) contains a field not valid in the tune body: \(field)"

        case let .misplacedTuneHeaderField(field, tuneIndex):
            "Tune \(tuneIndex) contains a field not valid in the tune header: \(field)"

        case let .misplacedTuneTitle(tuneIndex):
            "Tune \(tuneIndex) has a title (T:) field but it is not the second header field"

        case let .missingKey(tuneIndex):
            "Tune \(tuneIndex) has no key (K:) field"

        case let .missingReferenceNumber(tuneIndex):
            "Tune \(tuneIndex) has no reference number (X:) field"

        case let .missingTuneTitle(tuneIndex):
            "Tune \(tuneIndex) has no title (T:) field"

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

        case let .invalidInlineField(_, tuneIndex),
             let .misplacedKey(tuneIndex),
             let .misplacedReferenceNumber(tuneIndex),
             let .misplacedTuneBodyField(_, tuneIndex),
             let .misplacedTuneHeaderField(_, tuneIndex),
             let .misplacedTuneTitle(tuneIndex),
             let .missingKey(tuneIndex),
             let .missingReferenceNumber(tuneIndex),
             let .missingTuneTitle(tuneIndex):
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
    tuneIndex.map { "Tune \($0)" } ?? "The file header"
}
