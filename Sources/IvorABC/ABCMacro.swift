// © 2026 John Gary Pusey (see LICENSE.md)

/// An ABC macro definition (`m:`).
///
/// Maps a trigger pattern to a replacement string, for example:
/// ```
/// m: ~G2 = {A}G{F}G
/// m: ~n = !n!
/// ```
public struct ABCMacro {

    // MARK: Public Initializers

    /// Creates a new macro definition.
    ///
    /// - Parameter trigger:     The trigger pattern (left-hand side of `=`).
    /// - Parameter replacement: The replacement string (right-hand side of `=`).
    public init(trigger: String,
                replacement: String) {
        self.trigger = trigger
        self.replacement = replacement
    }

    // MARK: Public Instance Properties

    /// The replacement string (right-hand side of `=`).
    public let replacement: String

    /// The trigger pattern (left-hand side of `=`).
    public let trigger: String
}

// MARK: - Equatable

extension ABCMacro: Equatable {
}

// MARK: - Sendable

extension ABCMacro: Sendable {
}
