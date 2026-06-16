// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC user symbol mapping (`U:`).
///
/// Maps a shorthand character to a decoration or annotation, for example:
///
/// ```
/// U: ~ = !roll!
/// U: T = !trill!
/// U: H = "^fermata"
/// ```
public struct ABCUserSymbol {

    // MARK: Public Initializers

    /// Creates a new user symbol mapping.
    ///
    /// - Parameter shorthand:   The shorthand character being mapped.
    /// - Parameter definition:  The decoration or annotation the shorthand maps to.
    public init?(shorthand: ABCShorthand,
                 definition: Definition) {
        guard Self._isValid(shorthand, definition)
        else { return nil }

        self.definition = definition
        self.shorthand = shorthand
    }

    // MARK: Public Instance Properties

    /// What this shorthand maps to.
    public let definition: Definition

    /// The shorthand character being mapped.
    public let shorthand: ABCShorthand

    // MARK: Private Type Methods

    private static func _isValid(_ shorthand: ABCShorthand,
                                 _ definition: Definition) -> Bool {
        shorthand != .dot   // not allowed to redefine `.`
    }
}

// MARK: - Equatable

extension ABCUserSymbol: Equatable {
}

// MARK: - Sendable

extension ABCUserSymbol: Sendable {
}
