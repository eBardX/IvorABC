// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC tunebook.
public struct ABCTunebook {

    // MARK: Public Initializers

    /// Creates a new tunebook with the provided version, headers, and tunes.
    ///
    /// - Parameter version: The ABC version of the tunebook.
    /// - Parameter headers: The file-level header entries.
    /// - Parameter tunes:   The tunes contained in the tunebook.
    public init(version: ABCVersion,
                headers: [ABCHeader],
                tunes: [ABCTune]) {
        self.headers = headers
        self.tunes = tunes
        self.version = version
    }

    // MARK: Public Instance Properties

    /// The file-level header entries of this tunebook.
    public let headers: [ABCHeader]

    /// The tunes contained in this tunebook.
    public let tunes: [ABCTune]

    /// The ABC version of this tunebook.
    public let version: ABCVersion
}

// MARK: - Equatable

extension ABCTunebook: Equatable {
}

// MARK: - Sendable

extension ABCTunebook: Sendable {
}
