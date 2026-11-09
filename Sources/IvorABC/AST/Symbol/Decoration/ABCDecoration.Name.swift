// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCDecoration {

    // MARK: Public Nested Types

    /// The name of an ABC decoration, without delimiters.
    ///
    /// Valid names are non-empty and, as the ABC 2.1 standard requires
    /// (§4.14), contain no whitespace or `[`, `]`, `|` or `:` signs. They also
    /// contain no `!`, which delimits them. Anything else is allowed, so
    /// names that programs define for themselves, such as abcm2ps’s
    /// `ped-up`, are valid too.
    public struct Name {

        // MARK: Public Initializers

        /// Creates a new decoration name from the provided string, or `nil` if
        /// it is invalid.
        ///
        /// - Parameter stringValue: The string to store. Must be non-empty and
        ///   contain no whitespace or `!`, `:`, `[`, `]` or `|` characters.
        public init?(stringValue: String) {
            guard Self.isValid(stringValue)
            else { return nil }

            self.stringValue = stringValue
        }

        // MARK: Public Instance Properties

        /// The string value of this decoration name.
        public let stringValue: String
    }
}

// MARK: -

extension ABCDecoration.Name {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the given string is a
    /// valid decoration name.
    ///
    /// - Parameter stringValue: The string to validate.
    ///
    /// - Returns: `true` if `stringValue` is non-empty and contains no
    ///   whitespace or `!`, `:`, `[`, `]` or `|` characters.
    public static func isValid(_ stringValue: String) -> Bool {
        !stringValue.isEmpty && stringValue.allSatisfy { Self._isValidElement($0) }
    }

    // MARK: Private Type Methods

    private static func _isValidElement(_ element: Character) -> Bool {
        !element.isWhitespace && !"!:[]|".contains(element)
    }
}

// MARK: - StringRepresentable

extension ABCDecoration.Name: StringRepresentable {
}
