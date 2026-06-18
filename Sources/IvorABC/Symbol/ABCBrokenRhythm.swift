// © 2026 John Gary Pusey (see LICENSE.md)

/// A broken rhythm marker in ABC notation.
///
/// The six cases correspond to the one, two, or three `>` or `<` characters
/// that can appear between two notes. For `n` `>` characters the left note is
/// lengthened and the right note shortened; `<` characters reverse the two
/// sides.
public enum ABCBrokenRhythm {
    /// A single `>`: left note dotted, right note halved.
    case dotted

    /// A double `>>`: left note double-dotted, right note quartered.
    case doubleDotted

    /// A single `<`: left note halved, right note dotted.
    case reverseDotted

    /// A double `<<`: left note quartered, right note double-dotted.
    case reverseDoubleDotted

    /// A triple `<<<`: left note divided by 8, right note triple-dotted.
    case reverseTripleDotted

    /// A triple `>>>`: left note triple-dotted, right note divided by 8.
    case tripleDotted
}

// MARK: -

extension ABCBrokenRhythm {

    // MARK: Public Instance Methods

    /// Returns the effective durations of the notes immediately before and
    /// after this broken rhythm marker.
    ///
    /// Pass the written `ABCDuration` of the note before the marker as `left`
    /// and the note after as `right`. The returned tuple contains the
    /// corresponding effective durations.
    ///
    /// For `n` `>` characters, the left note is lengthened by a factor of
    /// `(2^(n+1)−1) / 2^n` and the right note shortened by `1 / 2^n`
    /// (e.g. `>`: ×3/2 and ×1/2; `>>`: ×7/4 and ×1/4). `<` reverses the
    /// two sides.
    ///
    /// - Parameter left:   The written duration of the note before the marker.
    /// - Parameter right:  The written duration of the note after the marker.
    ///
    /// - Returns:  The effective `(left, right)` durations, or `nil` if either
    ///             adjusted duration cannot be represented.
    public func resolve(left: ABCDuration,
                        right: ABCDuration) -> (left: ABCDuration, right: ABCDuration)? {
        let denMult = UInt(1) << factor
        let numMult = (UInt(1) << (factor + 1)) - 1

        func long(_ duration: ABCDuration) -> ABCDuration? {
            ABCDuration(numerator: duration.numerator * numMult,
                        denominator: duration.denominator * denMult)
        }

        func short(_ duration: ABCDuration) -> ABCDuration? {
            ABCDuration(numerator: duration.numerator,
                        denominator: duration.denominator * denMult)
        }

        switch self {
        case .dotted,
             .doubleDotted,
             .tripleDotted:
            guard let outLeft = long(left),
                  let outRight = short(right)
            else { return nil }

            return (outLeft, outRight)

        case .reverseDotted,
             .reverseDoubleDotted,
             .reverseTripleDotted:
            guard let outLeft = short(left),
                  let outRight = long(right)
            else { return nil }

            return (outLeft, outRight)
        }
    }

    // MARK: Internal Instance Properties

    internal var factor: Int {
        switch self {
        case .dotted,
             .reverseDotted:
            1

        case .doubleDotted,
             .reverseDoubleDotted:
            2

        case .reverseTripleDotted,
             .tripleDotted:
            3
        }
    }
}

// MARK: - Equatable

extension ABCBrokenRhythm: Equatable {
}

// MARK: - Sendable

extension ABCBrokenRhythm: Sendable {
}
