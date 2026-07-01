// © 2026 John Gary Pusey (see LICENSE.md)

/// A type that builds a playback/render model from a validated ABC tunebook.
public struct ABCScoreBuilder {

    // MARK: Public Initializers

    /// Creates a new ABC score builder.
    public init() {
    }
}

// MARK: -

extension ABCScoreBuilder {

    // MARK: Public Instance Methods

    /// Builds a standalone playback/render model for every tune in the
    /// provided tunebook.
    ///
    /// - Parameter tunebook: The tunebook to build scores from.
    /// - Parameter options:  Options controlling how the scores are built.
    ///                       Defaults to no options.
    ///
    /// - Returns:  One ``ABCScore`` per tune in `tunebook`, in tunebook order.
    ///
    /// - Throws:   ``Error/notValidated`` if the tunebook has not been
    ///             validated. Call ``ABCValidator/validate(_:)`` first.
    ///             ``Error/unsupportedOption`` if `options` contains
    ///             ``Options-swift.struct/optimizeForPlayback``, which is not
    ///             yet implemented.
    public func build(_ tunebook: ABCTunebook,
                      options: Options = []) throws -> [ABCScore] {
        guard tunebook.isValidated
        else { throw Error.notValidated }

        guard !options.contains(.optimizeForPlayback)
        else { throw Error.unsupportedOption }

        return Builder(tunebook: tunebook,
                       options: options).buildScores()
    }
}

// MARK: - Sendable

extension ABCScoreBuilder: Sendable {
}
