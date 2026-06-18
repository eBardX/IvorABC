// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCBarRepeat {

    // MARK: Public Nested Types

    /// The core bar or repeat symbol, without the editorial prefix or repeat-range suffix.
    ///
    /// Valid strings are the ten recognized ABC bar/repeat marks:
    /// `|`, `||`, `|:`, `:|`, `:|:`, `::`, `:||:`, `[|`, `|]`, and `[|]`.
    public struct Mark: StringRepresentable {

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the given string is a
        /// valid bar or repeat mark.
        ///
        /// - Parameter stringValue: The string to validate.
        ///
        /// - Returns: `true` if `stringValue` is one of the ten recognized
        ///   bar/repeat symbols.
        public static func isValid(_ stringValue: String) -> Bool {
            _validMarks.contains(stringValue)
        }

        // MARK: Public Initializers

        /// Creates a new mark from the provided string, or `nil` if it is
        /// invalid.
        ///
        /// - Parameter stringValue: The string to store. Must be one of the
        ///   ten recognized bar/repeat symbols.
        public init?(stringValue: String) {
            guard Self.isValid(stringValue)
            else { return nil }

            self.stringValue = stringValue
        }

        // MARK: Public Instance Properties

        /// The string value of this mark.
        public let stringValue: String

        // MARK: Private Type Properties

        // The ABC v2.1 spec suggests being very lenient here. Not sure what to do.
        private static let _validMarks: Set<String> = ["|",
                                                       "||",
                                                       "|:",
                                                       ":|",
                                                       ":|:",
                                                       "::",
                                                       ":||:",
                                                       "[|",
                                                       "|]",
                                                       "[|]"]
    }
}
