// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// A bar or repeat marker in ABC music notation.
public struct ABCBarRepeat {

    // MARK: Public Initializers

    /// Creates a new bar repeat, or `nil` if the combination of arguments is
    /// invalid.
    ///
    /// The initializer fails when:
    /// - `barLine` is not `.repeat` but either play count exceeds `1`.
    /// - `barLine` is `.repeat` but both play counts equal `1` (no actual
    ///   repeat).
    ///
    /// - Parameter barLine:            The bar line symbol.
    /// - Parameter precedingPlayCount: How many times the section before this
    ///                                 bar line is played in total. Defaults
    ///                                 to `1`.
    /// - Parameter followingPlayCount: How many times the section after this
    ///                                 bar line is played in total. Defaults
    ///                                 to `1`.
    /// - Parameter isDotted:           Whether this is a dotted bar line.
    ///                                 Defaults to `false`.
    public init?(barLine: BarLine = .standard,
                 precedingPlayCount: PlayCount = 1,
                 followingPlayCount: PlayCount = 1,
                 isDotted: Bool = false) {
        guard Self._isValid(barLine,
                            precedingPlayCount,
                            followingPlayCount,
                            isDotted)
        else { return nil }

        self.barLine = barLine
        self.followingPlayCount = followingPlayCount
        self.isDotted = isDotted
        self.precedingPlayCount = precedingPlayCount
    }

    // MARK: Public Instance Properties

    /// The bar line symbol.
    public var barLine: BarLine

    /// How many times the section after this bar line is played in total.
    ///
    /// A value greater than `1` indicates a start-repeat (e.g. `|:` = `2`,
    /// `|::` = `3`). Only meaningful when ``barLine`` is `.repeat`.
    public var followingPlayCount: PlayCount

    /// Whether this is a dotted bar line.
    ///
    /// A dotted bar line is notated by preceding it with a dot (e.g. `.|`),
    /// and may be useful for marking bar divisions in music with very
    /// long measures.
    public var isDotted: Bool

    /// How many times the section before this bar line is played in total.
    ///
    /// A value greater than `1` indicates an end-repeat (e.g. `:|` = `2`,
    /// `::|` = `3`). Only meaningful when ``barLine`` is `.repeat`.
    public var precedingPlayCount: PlayCount
}

// MARK: -

extension ABCBarRepeat {

    // MARK: Private Type Methods

    private static func _isValid(_ barLine: BarLine,
                                 _ precedingPlayCount: PlayCount,
                                 _ followingPlayCount: PlayCount,
                                 _ isDotted: Bool) -> Bool {
        switch barLine {
        case .repeat:
            guard precedingPlayCount > 1
                  || followingPlayCount > 1
            else { return false }

        default:
            guard precedingPlayCount == 1,
                  followingPlayCount == 1
            else { return false }
        }

        return true
    }
}

// MARK: - Equatable

extension ABCBarRepeat: Equatable {
}

// MARK: - Sendable

extension ABCBarRepeat: Sendable {
}
