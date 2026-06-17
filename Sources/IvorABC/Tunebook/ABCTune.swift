// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A single tune in an ABC tunebook.
public struct ABCTune {

    // MARK: Public Initializers

    /// Creates a new tune with the provided entries, or returns `nil` if
    /// `entries` is empty.
    ///
    /// - Parameter entries: The entries that make up the tune.
    public init?(entries: [ABCEntry]) {
        guard Self._isValid(entries)
        else { return nil }

        self.entries = entries
    }

    // MARK: Public Instance Properties

    /// The entries that make up this tune.
    public let entries: [ABCEntry]
}

// MARK: -

extension ABCTune {

    // MARK: Private Type Methods

    private static func _isValid(_ entries: [ABCEntry]) -> Bool {
        !entries.isEmpty
    }
}

// MARK: - Equatable

extension ABCTune: Equatable {
}

// MARK: - Sendable

extension ABCTune: Sendable {
}
