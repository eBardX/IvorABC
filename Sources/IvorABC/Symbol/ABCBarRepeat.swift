// © 2026 John Gary Pusey (see LICENSE.md)

/// A bar or repeat marker in ABC music notation.
public struct ABCBarRepeat {

    // MARK: Public Initializers

    /// Creates a new bar repeat.
    ///
    /// - Parameter isEditorial: Whether this is an editorial bar line (dotted
    ///   in the ABC source). Defaults to `false`.
    /// - Parameter mark: The core bar or repeat symbol.
    /// - Parameter endings: The repeat-range suffix. Defaults to empty.
    public init(isEditorial: Bool = false,
                mark: Mark,
                endings: [ClosedRange<UInt>] = []) {
        self.endings = endings
        self.isEditorial = isEditorial
        self.mark = mark
    }

    // MARK: Public Instance Properties

    /// The repeat-range suffix, e.g. `[1...1, 3...5]` for `1,3-5`.
    ///
    /// Empty if no repeat-range suffix is present.
    public var endings: [ClosedRange<UInt>]

    /// Whether this is an editorial bar line.
    ///
    /// An editorial bar line is notated by preceding it with a dot (e.g. `.|`),
    /// and may be useful for marking editorial bar divisions in music with very
    /// long measures.
    public var isEditorial: Bool

    /// The core bar or repeat symbol.
    public var mark: Mark
}

// MARK: - Equatable

extension ABCBarRepeat: Equatable {
}

// MARK: - Sendable

extension ABCBarRepeat: Sendable {
}
