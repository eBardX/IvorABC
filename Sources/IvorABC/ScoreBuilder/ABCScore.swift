// © 2026 John Gary Pusey (see LICENSE.md)

/// A standalone, non-serializable playback/render model for a single tune.
///
/// Unlike ``ABCTune``, which is a syntactic AST that round-trips through
/// ``ABCFormatter``, `ABCScore` carries fully-resolved events — absolute
/// durations, explicit accidentals, expanded macros/shorthands, and
/// decorations aggregated onto the notes they modify — suitable for playback
/// or rendering.
///
/// An `ABCScore` is self-contained: its ``events`` stream starts with the
/// file-header-derived events (duplicated into every score produced from the
/// same tunebook), followed by the tune-header-derived events, followed by
/// the body — all in source order.
public struct ABCScore {

    // MARK: Public Instance Properties

    /// The events that make up this score, in source order.
    public let events: [ABCScoreEvent]
}

// MARK: - Equatable

extension ABCScore: Equatable {
}

// MARK: - Sendable

extension ABCScore: Sendable {
}
