// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC version number.
public struct ABCVersion {

    // MARK: Public Type Properties

    /// The current major version number supported by this library.
    public static let currentMajor: UInt = 2

    /// The current minor version number supported by this library.
    public static let currentMinor: UInt = 1

    // MARK: Public Initializers

    /// Creates a new version number with the provided major and minor
    /// components.
    ///
    /// - Parameter major: The major version number.
    /// - Parameter minor: The minor version number.
    public init(major: UInt,
                minor: UInt) {
        self.major = major
        self.minor = minor
    }

    // MARK: Public Instance Properties

    /// The major version number.
    public let major: UInt

    /// The minor version number.
    public let minor: UInt
}

// MARK: - Equatable

extension ABCVersion: Equatable {
}

// MARK: - Sendable

extension ABCVersion: Sendable {
}
