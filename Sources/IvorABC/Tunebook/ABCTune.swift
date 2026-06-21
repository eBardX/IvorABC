// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single tune in an ABC tunebook.
public struct ABCTune {

    // MARK: Public Initializers

    /// Creates a new tune with the provided header and body, or returns `nil` if
    /// `header` is empty.
    ///
    /// - Parameter header: The entries that make up the tune header.
    /// - Parameter body:   The entries that make up the tune body.
    public init?(header: [ABCHeaderEntry],
                 body: [ABCBodyEntry]) {
        guard Self._isValid(header, body)
        else { return nil }

        self.body = body
        self.header = header
    }

    // MARK: Public Instance Properties

    /// The entries that make up this tune body.
    public let body: [ABCBodyEntry]

    /// The entries that make up this tune header.
    public let header: [ABCHeaderEntry]
}

// MARK: -

extension ABCTune {

    // MARK: Private Type Methods

    private static func _isValid(_ header: [ABCHeaderEntry],
                                 _ body: [ABCBodyEntry]) -> Bool {
        !header.isEmpty
    }
}

// MARK: - Equatable

extension ABCTune: Equatable {
}

// MARK: - Sendable

extension ABCTune: Sendable {
}
