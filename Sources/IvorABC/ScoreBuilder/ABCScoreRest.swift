// © 2026 John Gary Pusey (see LICENSE.md)

/// A fully resolved rest for playback or rendering.
///
/// Unlike ``ABCRest``, whose `.multiMeasure` case spans an unresolved number
/// of measures, `ABCScoreRest` always carries a single absolute duration —
/// a multi-measure rest is resolved against the active meter to a concrete
/// duration before becoming an `ABCScoreRest`.
public struct ABCScoreRest {

    // MARK: Internal Initializers

    /// Creates a new resolved rest.
    ///
    /// - Parameter duration:   The absolute duration of the rest.
    /// - Parameter isInvisible: Whether the rest is invisible. Defaults to
    ///                          `false`.
    internal init(duration: ABCScoreDuration,
                  isInvisible: Bool = false) {
        self.duration = duration
        self.isInvisible = isInvisible
    }

    // MARK: Public Instance Properties

    /// The absolute duration of this rest.
    public let duration: ABCScoreDuration

    /// Whether this rest is invisible.
    public let isInvisible: Bool
}

// MARK: - Equatable

extension ABCScoreRest: Equatable {
}

// MARK: - Sendable

extension ABCScoreRest: Sendable {
}
