// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCDirective {

    // MARK: Public Nested Types

    /// The name of an ABC directive.
    ///
    /// Standard names adopted by the abc 2.1 specification are `abc-charset`,
    /// `abc-creator`, `abc-include`, `abc-version`, `decoration`, and
    /// `linebreak`. Valid names begin with an ASCII letter and consist entirely
    /// of ASCII letters, digits, and hyphens.
    public struct Name: StringRepresentable {

        // MARK: Public Type Properties

        /// The `I:abc-charset` / `%%abc-charset` directive, which indicates
        /// the character set in which text strings are coded.
        public static let abcCharset = Self("abc-charset")

        /// The `I:abc-creator` / `%%abc-creator` directive, which records the
        /// name and version of the program that created the abc file.
        public static let abcCreator = Self("abc-creator")

        /// The `I:abc-include` / `%%abc-include` directive, which imports
        /// definitions from a separate abc header file (`.abh`).
        public static let abcInclude = Self("abc-include")

        /// The `I:abc-version` / `%%abc-version` directive, which indicates
        /// the abc standard version that individual tunes conform to.
        public static let abcVersion = Self("abc-version")

        /// The `I:decoration` / `%%decoration` directive, which selects the
        /// decoration dialect (`!` or `+`).
        public static let decoration = Self("decoration")

        /// The `I:linebreak` / `%%linebreak` directive, which controls
        /// typesetting line breaks.
        public static let linebreak = Self("linebreak")

        // MARK: Public Type Methods

        /// Returns a Boolean value indicating whether the given string is a
        /// valid directive name.
        ///
        /// - Parameter stringValue: The string to validate.
        ///
        /// - Returns: `true` if `stringValue` is non-empty, begins with an
        ///   ASCII letter, and contains only ASCII letters, digits, and
        ///   hyphens.
        public static func isValid(_ stringValue: String) -> Bool {
            guard let head = stringValue.first
            else { return false }

            return head.isABCDirectiveNameHead
                   && stringValue.dropFirst().allSatisfy { $0.isABCDirectiveNameTail }
        }

        // MARK: Public Initializers

        /// Creates a new directive name from the provided string, or `nil` if
        /// it is invalid.
        ///
        /// - Parameter stringValue: The string to store. Must begin with an
        ///   ASCII letter and contain only ASCII letters, digits, and hyphens.
        public init?(stringValue: String) {
            guard Self.isValid(stringValue)
            else { return nil }

            self.stringValue = stringValue
        }

        // MARK: Public Instance Properties

        /// The string value of this directive name.
        public let stringValue: String
    }
}
