// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension ABCTimeSignature {

    // MARK: Public Nested Types

    /// An additive meter with multiple numerator groups and a single
    /// denominator, e.g. `(2+3+2)/8`.
    public struct AdditiveMeter {

        // MARK: Public Initializers

        /// Creates a new additive meter with the provided numerators and
        /// denominator, or `nil` if the numerators are empty, any numerator
        /// is zero, or the denominator is not a power of 2 in the range
        /// 1...64.
        ///
        /// - Parameter numerators:  The numerator groups of the meter. Must
        ///                          be non-empty and all greater than zero.
        /// - Parameter denominator: The denominator of the meter. Must be a
        ///                          power of 2 in the range 1...64.
        public init?(numerators: [UInt],
                     denominator: UInt) {
            // guard Self._isValid(numerators, denominator)
            // else { return nil }

            guard !numerators.isEmpty,
                  numerators.allSatisfy({ $0 > 0 }),
                  (1...64).contains(denominator),
                  denominator.isPowerOf2
            else { return nil }

            self.numerators = numerators
            self.denominator = denominator
        }

        // MARK: Public Instance Properties

        /// The denominator of this meter.
        public let denominator: UInt

        /// The numerator groups of this meter.
        public let numerators: [UInt]
    }
}

// MARK: - Equatable

extension ABCTimeSignature.AdditiveMeter: Equatable {
}

// MARK: - Sendable

extension ABCTimeSignature.AdditiveMeter: Sendable {
}
