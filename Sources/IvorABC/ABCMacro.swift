// © 2026 John Gary Pusey (see LICENSE.md)

/// An ABC macro definition (`m:`).
///
/// Maps a trigger pattern to a replacement string, for example:
/// ```
/// m: ~G2 = {A}G{F}G
/// m: ~n = !trill!n
/// ```
///
/// When a macro trigger is matched in the tune body the parser emits an
/// ``ABCSymbol/macroCall(_:)`` symbol whose ``ABCMacroCall`` carries the
/// concrete trigger text and the pre-parsed expansion. The `ABCMacro`
/// definition itself is preserved in ``ABCField/macro(_:)``.
public struct ABCMacro {

    // MARK: Public Initializers

    /// Creates a new macro definition.
    ///
    /// - Parameters:
    ///   - trigger:     The trigger pattern (left-hand side of `=`).
    ///   - replacement: The replacement string (right-hand side of `=`).
    public init(trigger: String,
                replacement: String) {
        self.replacement = replacement
        self.trigger = trigger
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
