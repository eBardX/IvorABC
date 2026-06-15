// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// An ABC text field value.
public struct ABCText: StringRepresentable {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the given string is a valid
    /// ABC text value.
    ///
    /// - Parameter stringValue: The string to validate.
    ///
    /// - Returns:  Always `true`; all strings are accepted as valid text values.
    public static func isValid(_ stringValue: String) -> Bool {
        true
    }

    // MARK: Public Initializers

    /// Creates a new text value from the provided string, or `nil` if it is
    /// invalid.
    ///
    /// - Parameter stringValue: The string to store. All strings are currently
    ///                          accepted.
    public init?(stringValue: String) {
        guard Self.isValid(stringValue)
        else { return nil }

        self.stringValue = stringValue
    }

    // MARK: Public Instance Properties

    /// The string value of this text.
    public let stringValue: String
}
