// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC version number.
public struct ABCVersion {

    // MARK: Public Type Properties

    /// The current ABC version supported by this library.
    public static let current = Self(major: 2,
                                     minor: 1)

    /// All ABC versions supported by this library.
    public static let supported = [Self(major: 1,
                                        minor: 6),
                                   Self(major: 2,
                                        minor: 0),
                                   Self(major: 2,
                                        minor: 1)]

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

// MARK: - Comparable

extension ABCVersion: Comparable {
    public static func < (lhs: Self,
                          rhs: Self) -> Bool {
        (lhs.major, lhs.minor) < (rhs.major, rhs.minor)
    }
}

// MARK: - Equatable

extension ABCVersion: Equatable {
}

// MARK: - Sendable

extension ABCVersion: Sendable {
}
