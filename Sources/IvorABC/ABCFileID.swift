// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC file identifier.
public struct ABCFileID {

    // MARK: Public Initializers

    /// Creates a new file identifier with the provided version.
    ///
    /// - Parameter version: The ABC version.
    public init(version: ABCVersion) {
        self.version = version
    }

    // MARK: Public Instance Properties

    /// The ABC version specified in this file identifier.
    public let version: ABCVersion
}

// MARK: - Equatable

extension ABCFileID: Equatable {
}

// MARK: - Sendable

extension ABCFileID: Sendable {
}
