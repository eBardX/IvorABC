// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC directive.
public struct ABCDirective {

    // MARK: Public Initializers

    /// Creates a new directive with the provided name, value, and optional block content,
    /// or `nil` if `name` is not a valid directive name.
    ///
    /// - Parameter name:    The name of the directive. Must begin with a letter and contain
    ///                      only letters, digits, and hyphens.
    /// - Parameter value:   The value of the directive.
    /// - Parameter content: The block content lines, or `nil` if this is not a block directive.
    public init?(name: String,
                 value: String,
                 content: [String]? = nil) {
        guard Self._isValid(name, value, content)
        else { return nil }

        self.content = content
        self.name = name
        self.value = value
    }

    // MARK: Public Instance Properties

    /// The block content lines of this directive, or `nil` if this is not a block directive.
    public let content: [String]?

    /// The name of this directive.
    public let name: String

    /// The value of this directive.
    public let value: String
}

// MARK: -

extension ABCDirective {

    // MARK: Private Type Methods

    private static func _isValid(_ name: String,
                                 _ value: String,
                                 _ content: [String]?) -> Bool {
        guard let head = name.first
        else { return false }

        return head.isABCDirectiveNameHead
               && name.dropFirst().allSatisfy { $0.isABCDirectiveNameTail }
    }
}

// MARK: - Equatable

extension ABCDirective: Equatable {
}

// MARK: - Sendable

extension ABCDirective: Sendable {
}
