// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCFormatter {

    // MARK: Public Nested Types

    /// An error that occurs when formatting an ABC tunebook.
    public enum Error {
        /// ``ABCFormatter/format(_:)`` was called on a tunebook whose
        /// ``ABCTunebook/isValidated`` flag is `false`.
        ///
        /// Call ``ABCTunebook/validated()`` before ``ABCFormatter/format(_:)``.
        case notValidated
    }
}

// MARK: - EnhancedError

extension ABCFormatter.Error: EnhancedError {
    /// The error category identifying the source module.
    public var category: Category? {
        Category("IvorABC")
    }

    /// A human-readable description of this error.
    public var message: String {
        switch self {
        case .notValidated:
            "Tunebook must be validated before formatting; call validated() first"
        }
    }
}

// MARK: - Equatable

extension ABCFormatter.Error: Equatable {
}

// MARK: - Sendable

extension ABCFormatter.Error: Sendable {
}
