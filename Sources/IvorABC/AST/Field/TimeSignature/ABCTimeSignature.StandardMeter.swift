// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension ABCTimeSignature {

    // MARK: Public Nested Types

    /// A standard meter expressed as a numerator and denominator.
    public struct StandardMeter {

        // MARK: Public Initializers

        /// Creates a new standard meter with the provided numerator and
        /// denominator, or `nil` if the numerator is zero or the denominator
        /// is not a power of 2 in the range 1...64.
        ///
        /// - Parameter numerator:   The numerator of the meter. Must be
        ///                          greater than zero.
        /// - Parameter denominator: The denominator of the meter. Must be a
        ///                          power of 2 in the range 1...64.
        public init?(numerator: UInt,
                     denominator: UInt) {
            guard Self._isValid(numerator, denominator)
            else { return nil }

            self.numerator = numerator
            self.denominator = denominator
        }

        // MARK: Public Instance Properties

        /// The denominator of this meter.
        public let denominator: UInt

        /// The numerator of this meter.
        public let numerator: UInt
    }
}

// MARK: -

extension ABCTimeSignature.StandardMeter {

    // MARK: Internal Instance Properties

    internal var doubleValue: Double {
        Double(numerator) / Double(denominator)
    }

    // MARK: Private Type Methods

    private static func _isValid(_ numerator: UInt,
                                 _ denominator: UInt) -> Bool {
        numerator > 0
        && (1...64).contains(denominator)
        && denominator.isPowerOf2
    }
}

// MARK: - Equatable

extension ABCTimeSignature.StandardMeter: Equatable {
}

// MARK: - Sendable

extension ABCTimeSignature.StandardMeter: Sendable {
}
