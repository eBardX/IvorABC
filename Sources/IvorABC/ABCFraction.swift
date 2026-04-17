// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A fraction with an unsigned integer numerator and denominator.
public struct ABCFraction {

    // MARK: Public Initializers

    /// Creates a new fraction with the provided numerator and denominator.
    ///
    /// - Parameter numerator:   The numerator of the fraction.
    /// - Parameter denominator: The denominator of the fraction.
    /// - Parameter reduce:      Whether to reduce the fraction to its simplest
    ///                          form.
    ///
    /// - Precondition: The denominator must be greater than zero.
    public init(numerator: UInt,
                denominator: UInt,
                reduce: Bool) {
        precondition(denominator > 0)

        var num = numerator
        var den = denominator

        if reduce, den != 1 {
            if num != 0 {
                let tmp = UInt.gcd(num, den)

                if tmp != 1 {
                    num /= tmp
                    den /= tmp
                }
            } else {
                den = 1
            }
        }

        self.denominator = den
        self.numerator = num
    }

    // MARK: Public Instance Properties

    /// The denominator of this fraction.
    public let denominator: UInt

    /// The numerator of this fraction.
    public let numerator: UInt
}

// MARK: - Equatable

extension ABCFraction: Equatable {
}

// MARK: - Sendable

extension ABCFraction: Sendable {
}
