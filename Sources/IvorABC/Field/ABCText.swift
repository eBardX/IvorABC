// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

public struct ABCText: StringRepresentable {

    // MARK: Public Type Methods

    public static func isValid(_ stringValue: String) -> Bool {
        true
    }

    // MARK: Public Initializers

    public init?(stringValue: String) {
        guard Self.isValid(stringValue)
        else { return nil }

        self.stringValue = stringValue
    }

    // MARK: Public Instance Properties

    public let stringValue: String
}
