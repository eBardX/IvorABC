// © 2026 John Gary Pusey (see LICENSE.md)

/// An issue found when validating an ``ABCTunebook`` against the ABC
/// specification.
public enum ABCValidationIssue {

    /// A longhand `!name!` decoration was encountered while the `+` dialect
    /// is active.
    ///
    /// Per §12.1.2, `!…!` is invalid once `I:decoration +` is in effect.
    case bangDialectDecorationInPlusMode(tuneIndex: Int?)

    /// A stale `%%abc-charset` or `I:abc-charset` directive was found in a
    /// normalized tunebook.
    ///
    /// This directive is decoded during preprocessing and must be dropped by
    /// ``ABCTunebook/normalized()``. Its presence indicates a normalization
    /// bug; call ``ABCTunebook/normalized()`` to remove it.
    case legacyCharsetDirective(tuneIndex: Int?)

    /// A `%%decoration +` or `I:decoration +` directive was found in a
    /// normalized tunebook.
    ///
    /// This directive must be dropped by ``ABCTunebook/normalized()``. Its
    /// presence indicates a normalization bug; call
    /// ``ABCTunebook/normalized()`` to remove it.
    case legacyDecorationDirective(tuneIndex: Int?)

    /// A legacy `E:` elemskip field was found in a normalized tunebook.
    ///
    /// Elemskip fields must be converted to remarks by
    /// ``ABCTunebook/normalized()``. Their presence indicates a normalization
    /// bug; call ``ABCTunebook/normalized()`` to convert them.
    case legacyElemskipField(tuneIndex: Int?)

    /// A legacy `I:` free-text field (``ABCField/information(_:)``) was found
    /// in a normalized tunebook.
    ///
    /// Free-text `I:` fields must be converted to remarks by
    /// ``ABCTunebook/normalized()``. Their presence indicates a normalization
    /// bug; call ``ABCTunebook/normalized()`` to convert them.
    case legacyInformationField(tuneIndex: Int?)

    /// A `Q:` tempo field with a legacy beat-multiple (e.g. `Q:C=120`) was
    /// found in a normalized tunebook.
    ///
    /// The ``ABCTempo/legacyBeatMultiple`` flag must be cleared by
    /// ``ABCTunebook/normalized()``. Its presence indicates a normalization
    /// bug; call ``ABCTunebook/normalized()`` to clear it.
    case legacyTempoForm(tuneIndex: Int?)

    /// A stale `%%abc-version` or `I:abc-version` directive was found in a
    /// normalized tunebook.
    ///
    /// The version is authoritative in ``ABCTunebook/version`` and this
    /// directive must be dropped by ``ABCTunebook/normalized()``. Its
    /// presence indicates a normalization bug; call
    /// ``ABCTunebook/normalized()`` to remove it.
    case legacyVersionDirective(tuneIndex: Int?)

    /// A `+name+` decoration was encountered without a preceding
    /// `I:decoration +` instruction.
    ///
    /// The `+…+` delimiter form requires the `+` dialect to be in effect.
    case plusDialectDecorationWithoutDirective(tuneIndex: Int?)

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
        case let .bangDialectDecorationInPlusMode(tuneIndex):
            "\(_tuneLabel(tuneIndex)) contains a !name! decoration while the + dialect is active"

        case let .legacyCharsetDirective(tuneIndex):
            "\(_tuneLabel(tuneIndex)) contains a stale abc-charset directive; call normalized() to remove it"

        case let .legacyDecorationDirective(tuneIndex):
            "\(_tuneLabel(tuneIndex)) contains a legacy decoration+ directive; call normalized() to remove it"

        case let .legacyElemskipField(tuneIndex):
            "\(_tuneLabel(tuneIndex)) contains a legacy E: elemskip field; call normalized() to convert it to a remark"

        case let .legacyInformationField(tuneIndex):
            "\(_tuneLabel(tuneIndex)) contains a legacy I: free-text field; call normalized() to convert it to a remark"

        case let .legacyTempoForm(tuneIndex):
            "\(_tuneLabel(tuneIndex)) contains a legacy tempo form (Q:Cn=rate); call normalized() to clear the beat-multiple flag"

        case let .legacyVersionDirective(tuneIndex):
            "\(_tuneLabel(tuneIndex)) contains a stale abc-version directive; call normalized() to remove it"

        case let .plusDialectDecorationWithoutDirective(tuneIndex):
            "\(_tuneLabel(tuneIndex)) contains a +name+ decoration without a preceding I:decoration + instruction"

        case let .undefinedUserSymbol(tuneIndex):
            "\(_tuneLabel(tuneIndex)) contains a shorthand decoration with no preceding U: definition and no builtin shorthand"
        }
    }

    /// The severity of this issue.
    public var severity: Severity {
        switch self {
        case .bangDialectDecorationInPlusMode,
             .legacyCharsetDirective,
             .legacyDecorationDirective,
             .legacyElemskipField,
             .legacyInformationField,
             .legacyTempoForm,
             .legacyVersionDirective,
             .plusDialectDecorationWithoutDirective,
             .undefinedUserSymbol:
            .error
        }
    }

    /// The zero-based index of the tune containing this issue,
    /// or `nil` if the issue is in the file header.
    public var tuneIndex: Int? {
        switch self {
        case let .bangDialectDecorationInPlusMode(tuneIndex),
             let .legacyCharsetDirective(tuneIndex),
             let .legacyDecorationDirective(tuneIndex),
             let .legacyElemskipField(tuneIndex),
             let .legacyInformationField(tuneIndex),
             let .legacyTempoForm(tuneIndex),
             let .legacyVersionDirective(tuneIndex),
             let .plusDialectDecorationWithoutDirective(tuneIndex),
             let .undefinedUserSymbol(tuneIndex):
            tuneIndex
        }
    }
}

// MARK: - Equatable

extension ABCValidationIssue: Equatable {
}

// MARK: - Hashable

extension ABCValidationIssue: Hashable {
}

// MARK: - Sendable

extension ABCValidationIssue: Sendable {
}

// MARK: - Private Functions

private func _tuneLabel(_ tuneIndex: Int?) -> String {
    tuneIndex.map { "Tune \($0)" } ?? "File header"
}
