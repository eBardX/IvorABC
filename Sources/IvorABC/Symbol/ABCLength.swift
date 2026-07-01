// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A length expressed as a fraction of a whole note.
///
/// `ABCLength` represents two related but distinct quantities:
///
/// - An **absolute length**, such as the unit note length (`L:`) or a
///   resolved note/rest/chord/spacer length, expressed directly as a
///   fraction of a whole note.
/// - A **relative (written) length**, such as the length written on a note,
///   rest, chord, or spacer, expressed as a multiplier of the unit note
///   length. A value of `1/1` is written with no length modifier (e.g. `C`);
///   `2/1` is `C2`; `1/2` is `C/`. This is the length *exactly as written* —
///   resolving it against the active unit note length to obtain an absolute
///   ``ABCLength`` is a separate, later step.
public struct ABCLength {

    // MARK: Public Initializers

    /// Creates a new length with the provided numerator and denominator, reduced
    /// to its simplest form, or `nil` if either is zero.
    ///
    /// - Parameter numerator:   The numerator of the length multiplier. Must be
    ///                          greater than zero.
    /// - Parameter denominator: The denominator of the length multiplier. Must
    ///                          be greater than zero.
    public init?(numerator: UInt,
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

    /// The denominator of this length multiplier.
    public let denominator: UInt

    /// The numerator of this length multiplier.
    public let numerator: UInt
}

// MARK: -

extension ABCLength {

    // MARK: Private Type Methods

    private static func _isValid(_ numerator: UInt,
                                 _ denominator: UInt) -> Bool {
        numerator > 0
        && (1...512).contains(denominator)
        && denominator.isPowerOf2
    }
}

// MARK: - Equatable

extension ABCLength: Equatable {
}

// MARK: - Sendable

extension ABCLength: Sendable {
}
