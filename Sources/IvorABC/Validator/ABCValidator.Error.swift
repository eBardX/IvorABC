// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCValidator {

    // MARK: Public Nested Types

    /// An error thrown when a tunebook operation requires prior normalization.
    public enum Error {

        /// ``ABCValidator/validate(_:)`` was called on a tunebook whose
        /// ``ABCTunebook/isNormalized`` flag is `false`.
        ///
        /// Call ``ABCNormalizer/normalize(_:)`` before ``ABCValidator/validate(_:)``.
        case notNormalized
    }
}

// MARK: - EnhancedError

extension ABCValidator.Error: EnhancedError {

    /// The error category identifying the source module.
    public var category: Category? {
        Category("IvorABC")
    }

    /// A human-readable description of this error.
    public var message: String {
        switch self {
        case .notNormalized:
            "Tunebook must be normalized before validation; call ABCNormalizer.normalize(_:) first"
        }
    }
}

// MARK: - Equatable

extension ABCValidator.Error: Equatable {
}

// MARK: - Sendable

extension ABCValidator.Error: Sendable {
}
