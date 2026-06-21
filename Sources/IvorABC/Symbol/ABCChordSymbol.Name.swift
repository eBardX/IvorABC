// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCChordSymbol {

    // MARK: Public Nested Types

    /// The name (root and quality) of a chord symbol.
    public struct Name {

        // MARK: Public Instance Properties

        /// The chord quality/type string (e.g. `"m"`, `"7"`, `"maj7"`, `"dim"`),
        /// or `nil` for a plain major triad.
        public let kind: String?

        /// The root pitch class of the chord.
        public let root: Root

        // MARK: Public Initializers

        /// Creates a chord name.
        ///
        /// - Parameter root: The root pitch class of the chord.
        /// - Parameter kind: The chord quality/type string, or `nil` for a major triad.
        public init(root: Root,
                    kind: String? = nil) {
            self.kind = kind
            self.root = root
        }
    }
}

// MARK: - Equatable

extension ABCChordSymbol.Name: Equatable {
}

// MARK: - Sendable

extension ABCChordSymbol.Name: Sendable {
}
