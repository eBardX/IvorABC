// © 2026 John Gary Pusey (see LICENSE.md)

/// A structured representation of an ABC `P:` (parts) field value in the tune
/// header.
///
/// A `P:` field in the tune _header_ declares the overall part play order,
/// optionally with repeat counts and nested groups:
///
/// ```
/// P:ABABCDCD
/// P:A2B(CD)3
/// ```
///
/// For the `P:` field in the tune _body_ (a single part label such as `P:A`),
/// see ``ABCPart`` and ``ABCField/part(_:)``.
///
/// ## Accessing the play order
///
/// The ``items`` property provides the structured tree of parts and groups.
/// The ``expansion`` property provides the same information as a flat string
/// of part letters in play order — for example, `P:A2B(CD)3` expands to
/// `"AABCDCDCD"`. Choose whichever form suits your use case.
public struct ABCPartSequence {

    // MARK: Public Initializers

    /// Creates a new part sequence with the given items, or `nil` if `items` is
    /// empty.
    ///
    /// - Parameter items: The top-level items in the sequence. Must be
    ///                    non-empty.
    public init?(items: [Item]) {
        guard !items.isEmpty
        else { return nil }

        self.expansion = Self._expand(items)
        self.items = items
    }

    // MARK: Public Instance Properties

    /// The play order as a flat string of part letters.
    ///
    /// This is the fully expanded form of ``items``: every repeat count is
    /// applied and every group is inlined, leaving a plain sequence of
    /// uppercase letters. For example:
    ///
    /// | `P:` value  | `expansion`      |
    /// |-------------|------------------|
    /// | `ABABCDCD`  | `"ABABCDCD"`     |
    /// | `A2B(CD)3`  | `"AABCDCDCD"`   |
    /// | `A`         | `"A"`            |
    ///
    /// A repeat count of zero silently contributes nothing to the expansion
    /// (e.g. `A0` → `""`). The ABC standard does not define this case; treat
    /// it as you see fit.
    ///
    /// The value is computed once during initialization and cached. Use
    /// ``items`` instead if you need the structured tree.
    public let expansion: String

    /// The top-level items in the sequence.
    ///
    /// Each element is either a single part letter (with an optional repeat
    /// count) or a parenthesized group of items (with an optional repeat count).
    /// Repeat counts are **not** pre-expanded; use ``expansion`` if you need a
    /// flat play list.
    public let items: [Item]

    // MARK: Private Type Methods

    private static func _expand(_ items: [Item]) -> String {
        items.map { item -> String in
            switch item {
            case let .group(children, count):
                String(repeating: _expand(children),
                       count: Int(count.uintValue))

            case let .part(part, count):
                String(repeating: formatPart(part),
                       count: Int(count.uintValue))
            }
        }.joined()
    }
}

// MARK: - Equatable

extension ABCPartSequence: Equatable {
}

// MARK: - Sendable

extension ABCPartSequence: Sendable {
}
