// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single tune in an ABC tunebook.
public struct ABCTune {

    // MARK: Public Initializers

    /// Creates a new tune with the provided entries.
    ///
    /// - Parameter entries: The entries that make up the tune.
    public init(entries: [ABCEntry]) {
        self.entries = entries
    }

    // MARK: Public Instance Properties

    /// The entries that make up this tune.
    public let entries: [ABCEntry]
}

// MARK: - Equatable

extension ABCTune: Equatable {
}

// MARK: - Sendable

extension ABCTune: Sendable {
}
