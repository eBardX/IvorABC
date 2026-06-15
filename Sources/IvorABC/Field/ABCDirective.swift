// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC directive.
public struct ABCDirective {

    // MARK: Public Initializers

    /// Creates a new directive with the provided name, value, and optional block content.
    ///
    /// - Parameter name:    The name of the directive.
    /// - Parameter value:   The value of the directive.
    /// - Parameter content: The block content lines, or `nil` if this is not a block directive.
    public init(name: String,
                value: String,
                content: [String]? = nil) {
        self.content = content
        self.name = name        // validate?
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

// MARK: - Equatable

extension ABCDirective: Equatable {
}

// MARK: - Sendable

extension ABCDirective: Sendable {
}
