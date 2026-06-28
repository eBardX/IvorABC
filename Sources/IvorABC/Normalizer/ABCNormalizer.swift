// © 2026 John Gary Pusey (see LICENSE.md)

/// A type that normalizes an ABC tunebook to the current ABC version.
public struct ABCNormalizer {

    // MARK: Public Initializers

    /// Creates a new ABC normalizer.
    public init() {
    }
}

// MARK: -

extension ABCNormalizer {

    // MARK: Public Instance Methods

    /// Returns a copy of the provided tunebook normalized to the current ABC version.
    ///
    /// Normalization is idempotent: calling `normalize(_:)` on an already-normalized
    /// tunebook returns it immediately.
    ///
    /// The following conversions are applied:
    /// - ``ABCField/elemskip(_:)`` → ``ABCField/remark(_:)``
    /// - ``ABCField/information(_:)`` → ``ABCField/remark(_:)``
    /// - ``ABCTempo/legacyBeatMultiple`` cleared (durations already resolved)
    /// - `+name+` decorations (``ABCDecoration/Dialect/plus``) → `!name!` (`bang`)
    /// - `%%decoration +` / `I:decoration +` directives dropped
    /// - `%%abc-charset` / `I:abc-charset` directives dropped (stale after decoding)
    /// - `%%abc-version` / `I:abc-version` directives dropped (version is in ``ABCTunebook/version``)
    ///
    /// - Parameter tunebook:   The tunebook to normalize.
    ///
    /// - Returns: A new ``ABCTunebook`` whose ``ABCTunebook/isNormalized`` is `true` and
    ///            ``ABCTunebook/version`` is ``ABCVersion/current``.
    public func normalize(_ tunebook: ABCTunebook) -> ABCTunebook {
        guard !tunebook.isNormalized
        else { return tunebook }

        return Runner().run(tunebook)
    }
}

// MARK: - Sendable

extension ABCNormalizer: Sendable {
}
