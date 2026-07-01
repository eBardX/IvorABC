// © 2026 John Gary Pusey (see LICENSE.md)

// NOTE: Resolver work is parked while the parser/normalizer/validator/formatter
// are cleaned up. The code below is preserved but disabled via `#if false`,
// pending a redesigned resolver.
#if false

/// A type that resolves an ABC tunebook's written note lengths and pitches into
/// absolute values.
///
/// The parser produces a purely syntactic tunebook: note, rest, chord, and
/// spacer lengths are written multipliers of the unit note length (`L:`), and
/// pitch accidentals are recorded exactly as written (``ABCPitch/Accidental/omitted``
/// when none appears in the source). `ABCResolver` walks the tunebook applying
/// the active `L:`/`M:` to produce absolute lengths, and applying the active
/// key signature together with within-bar accidental propagation to produce a
/// concrete accidental for every note.
///
/// The resolved tunebook (``ABCTunebook/isResolved`` is `true`) is intended for
/// interpretation, playback, and analysis. It is *not* suitable for
/// re-serialization with ``ABCFormatter``, which expects written (unresolved)
/// lengths.
public struct ABCResolver {

    // MARK: Public Initializers

    /// Creates a new ABC resolver.
    public init() {
    }
}

// MARK: -

extension ABCResolver {

    // MARK: Public Instance Methods

    /// Returns a copy of the provided tunebook with every written note length
    /// resolved to an absolute length and every pitch accidental resolved to a
    /// concrete value.
    ///
    /// Resolution is idempotent: calling `resolve(_:)` on an already-resolved
    /// tunebook returns it unchanged.
    ///
    /// - Parameter tunebook:   The tunebook to resolve.
    ///
    /// - Returns:  A new ``ABCTunebook`` whose ``ABCTunebook/isResolved`` is
    ///             `true`. In the result, note/rest/chord/spacer lengths are
    ///             absolute fractions of a whole note, and no pitch accidental is
    ///             ``ABCPitch/Accidental/omitted``.
    public func resolve(_ tunebook: ABCTunebook) -> ABCTunebook {
        guard !tunebook.isResolved
        else { return tunebook }

        return Resolver(tunebook: tunebook).resolveTunebook()
    }
}

// MARK: - Sendable

extension ABCResolver: Sendable {
}

#endif
