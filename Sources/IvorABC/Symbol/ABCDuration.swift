// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A note duration expressed as a fraction of a whole note.
public struct ABCDuration {

    // MARK: Public Initializers

    /// Creates a new duration with the provided numerator and denominator,
    /// reduced to its simplest form, or `nil` if either is zero.
    ///
    /// - Parameter numerator:   The numerator of the duration. Must be
    ///                          greater than zero.
    /// - Parameter denominator: The denominator of the duration. Must be
    ///                          greater than zero.
    public init?(numerator: UInt,
                 denominator: UInt) {
        guard numerator > 0,
              (1...512).contains(denominator),
              denominator.isPowerOf2
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

// MARK: - Equatable

extension ABCDuration: Equatable {
}

// MARK: - Sendable

extension ABCDuration: Sendable {
}
