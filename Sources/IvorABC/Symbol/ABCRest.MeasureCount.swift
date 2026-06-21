// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCRest {

    // MARK: Public Nested Types

    /// The number of measures in a multi-measure rest.
    public struct MeasureCount: UIntRepresentable {

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the provided value is a
        /// valid measure count.
        ///
        /// - Parameter uintValue:  The value to validate.
        ///
        /// - Returns:  `true` if the value is greater than zero; otherwise,
        ///             `false`.
        public static func isValid(_ uintValue: UInt) -> Bool {
            uintValue > 0
        }

        // MARK: Public Initializers

        /// Creates a `MeasureCount` instance with the provided value, or `nil`
        /// if the value is not valid.
        ///
        /// - Parameter uintValue:  The measure count value. Must be greater
        ///                         than zero.
        public init?(uintValue: UInt) {
            guard Self.isValid(uintValue)
            else { return nil }

            self.uintValue = uintValue
        }

        // MARK: Public Instance Properties

        /// The unsigned integer value of this measure count.
        public let uintValue: UInt
    }
}
