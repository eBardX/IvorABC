// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCVoice {

    // MARK: Public Nested Types

    /// The identifier of an ABC voice.
    ///
    /// Valid identifiers consist entirely of ASCII letters or digits, and must
    /// be non-empty.
    public struct ID: StringRepresentable {

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the given string is a
        /// valid voice identifier.
        ///
        /// - Parameter stringValue: The string to validate.
        ///
        /// - Returns:  `true` if `stringValue` is non-empty and contains only
        ///             ASCII letters or digits.
        public static func isValid(_ stringValue: String) -> Bool {
            !stringValue.isEmpty
            && stringValue.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber) }
        }

        // MARK: Public Initializers

        /// Creates a new voice identifier from the provided string, or `nil` if
        /// it is invalid.
        ///
        /// - Parameter stringValue: The string to store. Must be non-empty and
        ///   contain only ASCII letters or digits.
        public init?(stringValue: String) {
            guard Self.isValid(stringValue)
            else { return nil }

            self.stringValue = stringValue
        }

        // MARK: Public Instance Properties

        /// The string value of this voice identifier.
        public let stringValue: String
    }
}
