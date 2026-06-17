// © 2026 John Gary Pusey (see LICENSE.md)

/// A structured representation of an ABC `P:` (parts) field value.
///
/// ## Dual use of `P:`
///
/// The ABC standard uses the `P:` field for two distinct purposes depending on
/// where it appears:
///
/// - **Tune header** — declares the overall part play order, optionally with
///   repeat counts and nested groups:
///   ```
///   P:ABABCDCD
///   P:A2B(CD)3
///   ```
/// - **Tune body** — marks the start of a named part. The value is always a
///   single uppercase letter:
///   ```
///   P:A
///   P:B
///   ```
///
/// ## Unified representation
///
/// The parser produces an `ABCPartSequence` for **both** uses. It has no
/// knowledge of whether a given `P:` field appears in a tune header or a tune
/// body — that distinction is determined by position in the entry stream, which
/// only the caller can observe.
///
/// A body-context `P:A` therefore parses to a one-item sequence
/// `[.part("A", 1)]`, indistinguishable in type from a header-context
/// `P:A`. **The caller is responsible for using the surrounding context to
/// decide which interpretation applies.**
///
/// ## Accessing the play order
///
/// The ``items`` property provides the structured tree of parts and groups.
/// The ``expansion`` property provides the same information as a flat string
/// of part letters in play order — for example, `P:A2B(CD)3` expands to
/// `"AABCDCDCD"`. Choose whichever form suits your use case.
///
/// The parser does **not** enforce the body-context rule that the value must
/// be a single letter. A multi-item sequence in the body position is
/// syntactically accepted. Callers that care about this constraint must check
/// it themselves.
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
                String(repeating: _expand(children), count: Int(count))

            case let .part(letter, count):
                String(repeating: String(letter), count: Int(count))
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
