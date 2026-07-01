// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// An absolute duration expressed as a fraction of a whole note.
///
/// Unlike ``ABCLength``, whose denominator must be a power of 2 in the range
/// 1–512, `ABCScoreDuration` allows an arbitrary reduced denominator. This is
/// required to represent durations scaled by tuplet ratios — e.g. a triplet
/// eighth note is `1/12` of a whole note, and `12` is not a power of 2.
public struct ABCScoreDuration {

    // MARK: Public Initializers

    /// Creates a new duration with the provided numerator and denominator,
    /// reduced to its simplest form, or `nil` if either is zero.
    ///
    /// - Parameter numerator:   The numerator of the duration. Must be
    ///                          greater than zero.
    /// - Parameter denominator: The denominator of the duration. Must be
    ///                          greater than zero.
    public init?(numerator: UInt,           // make this internal ???
                 denominator: UInt = 1) {
        guard Self._isValid(numerator, denominator)
        else { return nil }

        var num = numerator
        var den = denominator

        if den != 1 {
            let tmp = UInt.gcd(num, den)

            if tmp != 1 {
                num /= tmp
                den /= tmp
            }
        }

        self.denominator = den
        self.numerator = num
    }

    // MARK: Public Instance Properties

    /// The denominator of this duration.
    public let denominator: UInt

    /// The numerator of this duration.
    public let numerator: UInt
}

// MARK: -

extension ABCScoreDuration {

    // MARK: Public Initializers

    /// Creates a new duration equal to the provided ``ABCLength``.
    ///
    /// - Parameter length: The length to convert. Its numerator and
    ///                     denominator are already guaranteed valid, so this
    ///                     initializer cannot fail.
    public init(length: ABCLength) {
        self = Self(numerator: length.numerator,
                    denominator: length.denominator).require()
    }

    /// Creates a new absolute duration by resolving a written length (a
    /// multiplier of the unit note length) against the active unit note
    /// length.
    ///
    /// - Parameter written:        The written length, as a multiplier of the
    ///                             unit note length.
    /// - Parameter unitNoteLength: The active unit note length (`L:`).
    public init(written: ABCLength,
                unitNoteLength: ABCLength) {
        self = Self(numerator: written.numerator * unitNoteLength.numerator,
                    denominator: written.denominator * unitNoteLength.denominator).require()
    }

    // MARK: Private Type Methods

    private static func _isValid(_ numerator: UInt,
                                 _ denominator: UInt) -> Bool {
        numerator > 0 && denominator > 0
    }
}

// MARK: - Arithmetic Operators

extension ABCScoreDuration {

    // MARK: Public Type Methods

    /// Returns the sum of two durations, reduced to simplest form.
    ///
    /// Used for future tie coalescing.
    public static func + (lhs: Self,
                          rhs: Self) -> Self {
        Self(numerator: lhs.numerator * rhs.denominator + rhs.numerator * lhs.denominator,
             denominator: lhs.denominator * rhs.denominator).require()
    }

    /// Returns the product of two durations (fraction × fraction), reduced to
    /// simplest form.
    public static func * (lhs: Self,
                          rhs: Self) -> Self {
        Self(numerator: lhs.numerator * rhs.numerator,
             denominator: lhs.denominator * rhs.denominator).require()
    }

    /// Returns this duration scaled by the fraction `numerator /
    /// denominator`, reduced to simplest form.
    ///
    /// Used to scale a duration by a tuplet ratio (`beatCount / noteCount`)
    /// or a broken-rhythm factor.
    ///
    /// - Parameter lhs: The duration to scale.
    /// - Parameter rhs: The scaling fraction, as a `(numerator, denominator)`
    ///                  pair.
    public static func * (lhs: Self,
                          rhs: (numerator: UInt, denominator: UInt)) -> Self {
        Self(numerator: lhs.numerator * rhs.numerator,
             denominator: lhs.denominator * rhs.denominator).require()
    }

    /// Scales this duration in place by the fraction `numerator /
    /// denominator`, reduced to simplest form.
    ///
    /// - Parameter lhs: The duration to scale.
    /// - Parameter rhs: The scaling fraction, as a `(numerator, denominator)`
    ///                  pair.
    public static func *= (lhs: inout Self,
                           rhs: (numerator: UInt, denominator: UInt)) {
        lhs = lhs * rhs
    }
}

// MARK: - Comparable

extension ABCScoreDuration: Comparable {
    public static func < (lhs: Self,
                          rhs: Self) -> Bool {
        lhs.numerator * rhs.denominator < rhs.numerator * lhs.denominator
    }
}

// MARK: - Equatable

extension ABCScoreDuration: Equatable {
}

// MARK: - Sendable

extension ABCScoreDuration: Sendable {
}
