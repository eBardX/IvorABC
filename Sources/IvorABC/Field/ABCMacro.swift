// © 2026 John Gary Pusey (see LICENSE.md)

/// An ABC macro definition (`m:`).
///
/// Maps a target pattern to a replacement string, for example:
/// ```
/// m: ~G2 = {A}G{F}G
/// m: ~n = !trill!n
/// ```
///
/// The definition is preserved in ``ABCField/macro(_:)``.
public struct ABCMacro {

    // MARK: Public Initializers

    /// Creates a new macro definition, or `nil` if any parameter is invalid.
    ///
    /// - Parameter target:      The target pattern (left-hand side of `=`); must be 1–31 characters.
    /// - Parameter replacement: The replacement string (right-hand side of `=`); must be 1–200 characters.
    public init?(target: String,
                 replacement: String) {
        guard Self._isValid(target, replacement)
        else { return nil }

        self.replacement = replacement
        self.target = target
    }

    // MARK: Public Instance Properties

    /// The replacement string (right-hand side of `=`).
    public let replacement: String

    /// The target pattern (left-hand side of `=`).
    public let target: String
}

// MARK: -

extension ABCMacro {

    // MARK: Private Type Methods

    private static func _isValid(_ target: String,
                                 _ replacement: String) -> Bool {
        (1...31).contains(target.count)
        && (1...200).contains(replacement.count)
    }
}

// MARK: - Equatable

extension ABCMacro: Equatable {
}

// MARK: - Sendable

extension ABCMacro: Sendable {
}
