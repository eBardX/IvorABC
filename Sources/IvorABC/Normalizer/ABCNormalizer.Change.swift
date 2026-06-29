// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCNormalizer {

    // MARK: Public Nested Types

    /// A change applied when normalizing an ``ABCTunebook`` to the current ABC version.
    public enum Change {

        /// The legacy ``ABCTempo/beatMultiplier`` was cleared from a tempo field.
        case clearedBeatMultiplier(ABCTempo, Int?)

        /// A `+name+` decoration was converted to the `!name!` form. The first associated
        /// value is the original decoration.
        case convertedDecoration(ABCDecoration, Int?)

        /// A stale directive was dropped.
        case droppedDirective(ABCDirective, Int?)

        /// A deprecated field was replaced. The first associated value is the original
        /// field; the second is the replacement.
        case replacedField(ABCField, ABCField, Int?)
    }
}

// MARK: -

extension ABCNormalizer.Change {

    // MARK: Public Instance Properties

    /// A human-readable description of this change.
    public var message: String {
        switch self {
        case let .clearedBeatMultiplier(tempo, tuneIndex):
            "\(_tuneLabel(tuneIndex)): legacy beat multiplier cleared from tempo field '\(tempo)'"

        case let .convertedDecoration(decoration, tuneIndex):
            "\(_tuneLabel(tuneIndex)): decoration '\(decoration)' converted from +name+ to !name! form"

        case let .droppedDirective(directive, tuneIndex):
            "\(_tuneLabel(tuneIndex)): stale directive '\(directive)' dropped"

        case let .replacedField(old, new, tuneIndex):
            "\(_tuneLabel(tuneIndex)): field '\(old)' replaced with '\(new)'"
        }
    }

    /// The zero-based index of the tune containing this change,
    /// or `nil` if the change is in the file header.
    public var tuneIndex: Int? {
        switch self {
        case let .clearedBeatMultiplier(_, tuneIndex),
             let .convertedDecoration(_, tuneIndex),
             let .droppedDirective(_, tuneIndex),
             let .replacedField(_, _, tuneIndex):
            tuneIndex
        }
    }
}

// MARK: - Equatable

extension ABCNormalizer.Change: Equatable {
}

// MARK: - Sendable

extension ABCNormalizer.Change: Sendable {
}

// MARK: - Private Functions

private func _tuneLabel(_ tuneIndex: Int?) -> String {
    tuneIndex.map { "Tune \($0)" } ?? "File header"
}
