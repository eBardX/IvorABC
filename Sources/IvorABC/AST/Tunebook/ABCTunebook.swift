// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC file containing one or more tunes.
///
/// In the ABC 2.1 specification, a file with a single tune is an *abc file*;
/// a file with two or more tunes is called an *abc tunebook*. This type
/// represents either form.
///
/// See §2.2 (“ABC file structure”) of the ABC 2.1 standard.
public struct ABCTunebook {

    // MARK: Public Initializers

    /// Creates a new ABC 2.1 tunebook with the provided file header and tunes,
    /// or returns `nil` if `tunes` is empty.
    ///
    /// - Parameter fileHeader: The entries that make up the file header.
    /// - Parameter tunes:      The tunes contained in the file.
    public init?(fileHeader: [ABCHeaderEntry],
                 tunes: [ABCTune]) {
        guard Self._isValid(fileHeader, tunes)
        else { return nil }

        self.init(version: .current,
                  fileHeader: fileHeader,
                  tunes: tunes,
                  isNormalized: false,
                  isValidated: false)
    }

    // MARK: Public Instance Properties

    /// The entries that make up the file header of this tunebook.
    public let fileHeader: [ABCHeaderEntry]

    /// A Boolean value indicating whether this tunebook has been normalized to
    /// ABC 2.1 via ``ABCNormalizer/normalize(_:)``.
    ///
    /// `false` for tunebooks produced by
    /// ``init(version:fileHeader:tunes:isNormalized:isValidated:)`` or
    /// returned by the parser, until ``ABCNormalizer/normalize(_:)`` is
    /// called; `true` for all tunebooks returned by
    /// ``ABCNormalizer/normalize(_:)``.
    public let isNormalized: Bool

    /// A Boolean value indicating whether this tunebook has been validated
    /// via ``ABCValidator/validate(_:)``.
    ///
    /// `false` until a successful ``ABCValidator/validate(_:)`` call returns a
    /// copy with this flag set to `true`.
    public let isValidated: Bool

    /// The tunes contained in this tunebook.
    public let tunes: [ABCTune]

    /// The ABC version of this tunebook, or `nil` if no version was declared.
    public let version: ABCVersion?

    // MARK: Internal Initializers

    internal init(version: ABCVersion?,
                  fileHeader: [ABCHeaderEntry],
                  tunes: [ABCTune],
                  isNormalized: Bool,
                  isValidated: Bool) {
        self.fileHeader = fileHeader
        self.isNormalized = isNormalized
        self.isValidated = isValidated
        self.tunes = tunes
        self.version = version
    }
}

// MARK: -

extension ABCTunebook {

    // MARK: Private Type Methods

    private static func _isValid(_ fileHeader: [ABCHeaderEntry],
                                 _ tunes: [ABCTune]) -> Bool {
        !tunes.isEmpty
    }
}

// MARK: - Equatable

extension ABCTunebook: Equatable {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether two tunebooks are equal.
    ///
    /// Two tunebooks are equal when their ``version``, ``fileHeader``, and
    /// ``tunes`` match; ``isNormalized`` and ``isValidated`` are intentionally
    /// excluded because they are metadata, not content.
    public static func == (lhs: Self,
                           rhs: Self) -> Bool {
        lhs.fileHeader == rhs.fileHeader
        && lhs.tunes == rhs.tunes
        && lhs.version == rhs.version
    }
}

// MARK: - Sendable

extension ABCTunebook: Sendable {
}
