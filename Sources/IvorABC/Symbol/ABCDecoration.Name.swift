// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCDecoration {

    // MARK: Public Nested Types

    /// The name of an ABC decoration, without delimiters.
    ///
    /// Valid names consist entirely of ASCII letters, digits, and the
    /// characters `.()+<>`, and must be non-empty.
    public struct Name: StringRepresentable {

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the given string is a
        /// valid decoration name.
        ///
        /// - Parameter stringValue: The string to validate.
        ///
        /// - Returns: `true` if `stringValue` is non-empty and contains only
        ///   ASCII letters, digits, or the characters `.()+<>`.
        public static func isValid(_ stringValue: String) -> Bool {
            !stringValue.isEmpty && stringValue.allSatisfy { Self._isValidElement($0) }
        }

        // MARK: Public Initializers

        /// Creates a new decoration name from the provided string, or `nil` if
        /// it is invalid.
        ///
        /// - Parameter stringValue: The string to store. Must be non-empty and
        ///   contain only ASCII letters, digits, or the characters `.()+<>`.
        public init?(stringValue: String) {
            guard Self.isValid(stringValue)
            else { return nil }

            self.stringValue = stringValue
        }

        // MARK: Public Instance Properties

        /// The string value of this decoration name.
        public let stringValue: String

        // MARK: Private Type Methods

        private static func _isValidElement(_ element: Character) -> Bool {
            element.isASCII
            && (element.isLetter
                || element.isNumber
                || ".()+<>".contains(element))
        }
    }
}
