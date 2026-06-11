// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCValidationIssue {

    // MARK: Public Nested Types

    /// The severity of a validation issue.
    public enum Severity {

        // MARK: Public Cases

        /// The issue will cause ``ABCFormatter`` to emit invalid ABC.
        case error

        /// The issue is a deviation from a "should" rule in the specification
        /// that may cause interoperability problems.
        case warning
    }
}

// MARK: - Equatable

extension ABCValidationIssue.Severity: Equatable {
}

// MARK: - Sendable

extension ABCValidationIssue.Severity: Sendable {
}
