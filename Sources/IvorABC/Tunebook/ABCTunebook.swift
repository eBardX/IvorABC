// © 2025–2026 John Gary Pusey (see LICENSE.md)

internal import XestiTools

/// An ABC file containing one or more tunes.
///
/// In the ABC 2.1 specification, a file with a single tune is an *abc file*;
/// a file with two or more tunes is called an *abc tunebook*. This type
/// represents either form.
public struct ABCTunebook {

    // MARK: Public Initializers

    /// Creates a new ABC file with the provided version, file header, and tunes,
    /// or returns `nil` if `tunes` is empty.
    ///
    /// - Parameter version:    The ABC version of the file, or `nil` for an
    ///                         unversioned file.
    /// - Parameter fileHeader: The entries that make up the file header.
    /// - Parameter tunes:      The tunes contained in the file.
    public init?(version: ABCVersion?,
                 fileHeader: [ABCHeaderEntry],
                 tunes: [ABCTune]) {
        guard Self._isValid(version, fileHeader, tunes)
        else { return nil }

        self.fileHeader = fileHeader
        self.tunes = tunes
        self.version = version
    }

    // MARK: Public Instance Properties

    /// The entries that make up the file header of this tunebook.
    public let fileHeader: [ABCHeaderEntry]

    /// The tunes contained in this tunebook.
    public let tunes: [ABCTune]

    /// The ABC version of this tunebook, or `nil` if no version was declared.
    public let version: ABCVersion?
}

// MARK: -

extension ABCTunebook {

    // MARK: Private Type Methods

    private static func _isValid(_ version: ABCVersion?,
                                 _ fileHeader: [ABCHeaderEntry],
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
