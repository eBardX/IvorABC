// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCScoreBuilder {

    // MARK: Public Nested Types

    /// An error that occurs when building scores from an ABC tunebook.
    public enum Error {
        /// ``ABCScoreBuilder/build(_:options:)`` was called on a tunebook
        /// whose ``ABCTunebook/isValidated`` flag is `false`.
        ///
        /// Call ``ABCValidator/validate(_:)`` before ``ABCScoreBuilder/build(_:options:)``.
        case notValidated

        /// A resolved duration could not be represented.
        ///
        /// The associated `String` describes the offending value.
        case unrepresentableDuration(String)

        /// A macro invocation could not be expanded.
        ///
        /// The associated `String` is the unexpandable macro target text.
        case unresolvableMacro(String)

        /// ``Options-swift.struct/optimizeForPlayback`` was set, but that
        /// option is not yet implemented.
        case unsupportedOption
    }
}

// MARK: - EnhancedError

extension ABCScoreBuilder.Error: EnhancedError {
    /// The error category identifying the source module.
    public var category: Category? {
        Category("IvorABC")
    }

    /// A human-readable description of this error.
    public var message: String {
        switch self {
        case .notValidated:
            "Tunebook must be validated before building scores; call ABCValidator.validate(_:) first"

        case let .unrepresentableDuration(description):
            "Unrepresentable duration: ‘\(description)’"

        case let .unresolvableMacro(target):
            "Unresolvable macro: ‘\(target)’"

        case .unsupportedOption:
            "The .optimizeForPlayback option is not yet implemented"
        }
    }
}

// MARK: - Equatable

extension ABCScoreBuilder.Error: Equatable {
}

// MARK: - Sendable

extension ABCScoreBuilder.Error: Sendable {
}
