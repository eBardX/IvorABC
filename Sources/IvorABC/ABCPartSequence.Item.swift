// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCPartSequence {

    // MARK: Public Nested Types

    /// A single element in a part sequence.
    ///
    /// Items are recursive: a ``group(_:_:)`` contains further items, allowing
    /// arbitrary nesting such as `P:(A(BC)2)3`.
    ///
    /// ## Repeat counts
    ///
    /// Both cases carry an explicit repeat count. When no count appears in the
    /// source (e.g. `P:AB`), the count is `1`. A count of `0` is syntactically
    /// accepted by the parser but has no well-defined meaning in the ABC
    /// standard; callers should treat it as they see fit.
    ///
    /// The parser stores counts as-is and never expands them. Callers that need
    /// a flat play list must perform expansion themselves:
    ///
    /// ```swift
    /// func expand(_ items: [ABCPartSequence.Item]) -> [Character] {
    ///     items.flatMap { item -> [Character] in
    ///         switch item {
    ///         case let .part(letter, count):
    ///             Array(repeating: letter, count: Int(count))
    ///         case let .group(children, count):
    ///             Array(repeating: expand(children), count: Int(count)).flatMap { $0 }
    ///         }
    ///     }
    /// }
    /// ```
    public enum Item {
        /// A parenthesized group of items with an optional repeat count.
        ///
        /// The first associated value is the (possibly nested) list of items
        /// inside the parentheses. The second is the repeat count that follows
        /// the closing parenthesis; `1` is used when no count appears in the
        /// source.
        case group([Self], UInt)

        /// A single part letter (`A`–`Z`) with an optional repeat count.
        ///
        /// The first associated value is the uppercase ASCII letter that names
        /// the part. The second is the repeat count; `1` is used when no count
        /// appears in the source.
        case part(Character, UInt)
    }
}

// MARK: - Equatable

extension ABCPartSequence.Item: Equatable {
}

// MARK: - Sendable

extension ABCPartSequence.Item: Sendable {
}
