// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCClef {

    // MARK: Public Nested Types

    /// The name of an ABC clef.
    ///
    /// Standard names are `treble`, `alto`, `tenor`, `bass`, `perc`, and
    /// `none`. Valid names consist of lowercase ASCII letters only.
    public struct Name: StringRepresentable {

        // MARK: Public Type Properties

        /// The alto clef (C clef, default on the 3rd line).
        public static let alto = Self("alto")

        /// The bass clef (F clef, default on the 4th line).
        public static let bass = Self("bass")

        /// No clef drawn on the staff.
        public static let noClef = Self("none")

        /// The percussion (drum) clef.
        public static let percussion = Self("perc")

        /// The tenor clef (C clef, default on the 4th line).
        public static let tenor = Self("tenor")

        /// The treble clef (G clef, default on the 2nd line).
        public static let treble = Self("treble")

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the given string is a
        /// valid clef name.
        ///
        /// - Parameter stringValue: The string to validate.
        ///
        /// - Returns: `true` if `stringValue` is non-empty and contains only
        ///   lowercase ASCII letters.
        public static func isValid(_ stringValue: String) -> Bool {
            guard let first = stringValue.first,
                  first.isASCII, first.isLowercase, first.isLetter
            else { return false }

            return stringValue.dropFirst().allSatisfy {
                $0.isASCII && $0.isLetter && $0.isLowercase
            }
        }

        // MARK: Public Initializers

        /// Creates a new clef name from the provided string, or `nil` if it
        /// is invalid.
        ///
        /// - Parameter stringValue: The string to store. Must consist of
        ///   lowercase ASCII letters only.
        public init?(stringValue: String) {
            guard Self.isValid(stringValue)
            else { return nil }

            self.stringValue = stringValue
        }

        // MARK: Public Instance Properties

        /// The string value of this clef name.
        public let stringValue: String
    }
}
