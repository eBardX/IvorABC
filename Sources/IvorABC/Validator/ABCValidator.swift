// © 2026 John Gary Pusey (see LICENSE.md)

/// A type that validates an ABC tunebook against the ABC 2.1 specification.
public struct ABCValidator {

    // MARK: Public Initializers

    /// Creates a new ABC validator.
    public init() {
    }
}

// MARK: -

extension ABCValidator {

    // MARK: Public Instance Methods

    /// Validates the provided tunebook against the ABC specification and
    /// returns any issues found.
    ///
    /// - Parameter tunebook:   The tunebook to validate.
    ///
    /// - Returns:  A tuple of the validated tunebook and an array of
    ///             ``Issue`` values. The tunebook in the tuple is a copy of
    ///             `tunebook` with ``ABCTunebook/isValidated`` set to `true`
    ///             when no issues are found; otherwise `tunebook` is returned
    ///             unchanged (re-validating after fixing issues is required).
    ///             An empty issues array means the tunebook is fully conformant.
    ///
    /// - Throws:   ``Error/notNormalized`` if ``ABCTunebook/isNormalized`` is
    ///             `false`. Call ``ABCNormalizer/normalize(_:)`` before calling
    ///             this method.
    public func validate(_ tunebook: ABCTunebook) throws -> (ABCTunebook, [Issue]) {
        guard !tunebook.isValidated
        else { return (tunebook, []) }

        guard tunebook.isNormalized
        else { throw Error.notNormalized }

        var runner = Checker(tunebook: tunebook)

        let issues = runner.checkTunebook()

        guard issues.isEmpty
        else { return (tunebook, issues) }

        return (ABCTunebook(version: tunebook.version,
                            fileHeader: tunebook.fileHeader,
                            tunes: tunebook.tunes,
                            isNormalized: tunebook.isNormalized,
                            isValidated: true), [])
    }
}

// MARK: - Sendable

extension ABCValidator: Sendable {
}
