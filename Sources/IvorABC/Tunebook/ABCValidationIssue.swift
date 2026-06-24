// © 2026 John Gary Pusey (see LICENSE.md)

/// An issue found when validating an ``ABCTunebook`` against the ABC
/// specification.
public enum ABCValidationIssue {

    /// A longhand `!name!` decoration was encountered while the `+` dialect
    /// is active.
    ///
    /// Per §12.1.2, `!…!` is invalid once `I:decoration +` is in effect.
    case bangDialectDecorationInPlusMode(tuneIndex: Int?)

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
