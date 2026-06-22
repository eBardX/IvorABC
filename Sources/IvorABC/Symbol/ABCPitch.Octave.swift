// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCPitch {

    // MARK: Public Nested Types

    /// The octave number of a pitch, in the range C0 (0) through C9 (9).
    public struct Octave: UIntRepresentable {

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the provided value is a
        /// valid octave number.
        ///
        /// - Parameter uintValue:  The value to validate.
        ///
        /// - Returns:  `true` if the value is in the range 0...9 (C0 through
        ///             C9); otherwise, `false`.
        public static func isValid(_ uintValue: UInt) -> Bool {
            uintValue <= 9
        }

        // MARK: Public Initializers

        /// Creates an `Octave` instance with the provided value, or `nil` if
        /// the value is not valid.
        ///
        /// - Parameter uintValue:  The octave number. Must be in the range
        ///                         0...9 (C0 through C9).
        public init?(uintValue: UInt) {
            guard Self.isValid(uintValue)
            else { return nil }

            self.uintValue = uintValue
        }

        // MARK: Public Instance Properties

        /// The unsigned integer value of this octave.
        public let uintValue: UInt
    }
}
