// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// An error thrown when a tunebook operation requires prior normalization.
public enum ABCValidationError {

    /// ``ABCTunebook/validated()`` was called on a tunebook whose
    /// ``ABCTunebook/isNormalized`` flag is `false`.
    ///
    /// Call ``ABCTunebook/normalized()`` before ``ABCTunebook/validated()``.
    case notNormalized
}

// MARK: - EnhancedError

extension ABCValidationError: EnhancedError {

    /// The error category identifying the source module.
    public var category: Category? {
        Category("IvorABC")
    }

    /// A human-readable description of this error.
    public var message: String {
        switch self {
        case .notNormalized:
            "Tunebook must be normalized before validation; call normalized() first"
        }
    }
}

// MARK: - Equatable

extension ABCValidationError: Equatable {
}

// MARK: - Sendable

extension ABCValidationError: Sendable {
}
