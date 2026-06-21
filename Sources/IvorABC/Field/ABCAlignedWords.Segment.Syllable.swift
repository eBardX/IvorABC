// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCAlignedWords.Segment {

    // MARK: Public Nested Types

    /// A single lyric syllable.
    ///
    /// `stringValue` holds the fully decoded text that a renderer should
    /// display — including characters such as spaces (from ABC `~`) and
    /// hyphens (from ABC `\-`) that are structural in ABC source but appear
    /// literally in the rendered output.
    ///
    /// Valid syllable text must be non-empty and must contain no control
    /// characters.
    public struct Syllable: StringRepresentable {

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the given string is valid
        /// syllable text.
        ///
        /// - Parameter stringValue: The string to validate.
        ///
        /// - Returns: `true` if `stringValue` is non-empty and contains no
        ///   control characters (C0 controls U+0000–U+001F, DEL U+007F, or
        ///   C1 controls U+0080–U+009F).
        public static func isValid(_ stringValue: String) -> Bool {
            !stringValue.isEmpty
            && stringValue.unicodeScalars.allSatisfy {
                $0.value >= 0x20
                && $0.value != 0x7f
                && ($0.value < 0x80 || $0.value > 0x9f)
            }
        }

        // MARK: Public Initializers

        /// Creates a new syllable value from the provided string, or `nil`
        /// if it is invalid.
        ///
        /// - Parameter stringValue: The string to store. Must be non-empty
        ///   and must contain no control characters.
        public init?(stringValue: String) {
            guard Self.isValid(stringValue)
            else { return nil }

            self.stringValue = stringValue
        }

        // MARK: Public Instance Properties

        /// The string value of this syllable.
        public let stringValue: String
    }
}
