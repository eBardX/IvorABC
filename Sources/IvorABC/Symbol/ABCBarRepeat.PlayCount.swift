// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCBarRepeat {

    // MARK: Public Nested Types

    /// The number of times a section is played in total.
    ///
    /// A value of `1` means the section plays once (no repeat). Values of `2`
    /// or higher correspond to repeat signs, with `3` or higher corresponding
    /// to the n-fold repeat notation (e.g. `|::` plays three times).
    public struct PlayCount: UIntRepresentable {

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the provided value is a
        /// valid play count.
        ///
        /// - Parameter uintValue: The value to validate.
        ///
        /// - Returns: `true` if the value is greater than `0`;
        ///   otherwise, `false`.
        public static func isValid(_ uintValue: UInt) -> Bool {
            uintValue > 0
        }

        // MARK: Public Initializers

        /// Creates a `PlayCount` instance with the provided value, or `nil`
        /// if the value is not valid.
        ///
        /// - Parameter uintValue: The play count value. Must be at least `1`.
        public init?(uintValue: UInt) {
            guard Self.isValid(uintValue)
            else { return nil }

            self.uintValue = uintValue
        }

        // MARK: Public Instance Properties

        /// The unsigned integer value of this play count.
        public let uintValue: UInt
    }
}
