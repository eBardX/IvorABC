// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A fraction with an unsigned integer numerator and denominator.
public struct ABCFraction {

    // MARK: Public Initializers

    /// Creates a new fraction with the provided numerator and denominator.
    ///
    /// If `denominator` is zero, this initializer stops execution.
    ///
    /// - Parameter numerator:   The numerator of the fraction.
    /// - Parameter denominator: The denominator of the fraction. Must be
    ///                          greater than zero.
    /// - Parameter reduce:      Whether to reduce the fraction to its simplest
    ///                          form.
    public init(numerator: UInt,
                denominator: UInt,
                reduce: Bool) {
        precondition(denominator > 0)

        var num = numerator
        var den = denominator

        if reduce, den != 1 {
            if num != 0 {
                let tmp = _gcd(num, den)

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

// MARK: - Private Functions

private func _gcd(_ n1: UInt,
                  _ n2: UInt) -> UInt {
    var val1 = n1
    var val2 = n2

    while val2 != 0 {
        (val1, val2) = (val2, val1 % val2)
    }

    return val1
}
