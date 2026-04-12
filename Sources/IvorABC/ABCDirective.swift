// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC directive.
public struct ABCDirective {

    // MARK: Public Initializers

    /// Creates a new directive with the provided name and value.
    ///
    /// - Parameter name:   The name of the directive.
    /// - Parameter value:  The value of the directive.
    public init(name: String,
                value: String) {
        self.name = name
        self.value = value
    }

    // MARK: Public Instance Properties

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
