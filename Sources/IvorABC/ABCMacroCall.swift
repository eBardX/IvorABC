// © 2026 John Gary Pusey (see LICENSE.md)

/// A resolved macro invocation in the tune body.
///
/// Produced when the parser matches a macro trigger against the registry
/// built from ``ABCField/macro(_:)`` definitions. The ``trigger`` is the
/// verbatim source text used to reproduce the source exactly on round-trip;
/// the ``expansion`` contains the pre-parsed symbols for semantic consumers.
///
/// For transposing macros the `n` placeholder in the definition's replacement
/// string is already substituted with the concrete note letter before parsing,
/// so ``expansion`` reflects the actual pitched content.
public struct ABCMacroCall {

    // MARK: Public Initializers

    /// Creates a new macro call.
    ///
    /// - Parameters:
    ///   - trigger:   The verbatim trigger text from the ABC source.
    ///   - expansion: The pre-parsed symbols produced by expanding the macro.
    public init(trigger: String,
                expansion: [ABCSymbol]) {
        self.expansion = expansion
        self.trigger = trigger
    }

    // MARK: Public Instance Properties

    /// The pre-parsed symbols produced by expanding the macro replacement.
    public let expansion: [ABCSymbol]

    /// The verbatim trigger text from the ABC source (e.g. `~G2` or `~G`).
    public let trigger: String
}

// MARK: - Equatable

extension ABCMacroCall: Equatable {
}

// MARK: - Sendable

extension ABCMacroCall: Sendable {
}
