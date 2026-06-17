// © 2025–2026 John Gary Pusey (see LICENSE.md)

internal import XestiTools

/// An ABC file containing one or more tunes.
///
/// In the ABC 2.1 specification, a file with a single tune is an *abc file*;
/// a file with two or more tunes is called an *abc tunebook*. This type
/// represents either form.
public struct ABCTunebook {

    // MARK: Public Initializers

    /// Creates a new ABC file with the provided version, headers, and tunes,
    /// or returns `nil` if `tunes` is empty.
    ///
    /// - Parameter version: The ABC version of the file.
    /// - Parameter headers: The file-level header entries.
    /// - Parameter tunes:   The tunes contained in the file.
    public init?(version: ABCVersion,
                 headers: [ABCHeader],
                 tunes: [ABCTune]) {
        guard Self._isValid(version, headers, tunes)
        else { return nil }

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

// MARK: -

extension ABCTunebook {

    // MARK: Private Type Methods

    private static func _isValid(_ version: ABCVersion,
                                 _ headers: [ABCHeader],
                                 _ tunes: [ABCTune]) -> Bool {
        !tunes.isEmpty
    }
}

// MARK: - Equatable

extension ABCTunebook: Equatable {
}

// MARK: - Sendable

extension ABCTunebook: Sendable {
}
