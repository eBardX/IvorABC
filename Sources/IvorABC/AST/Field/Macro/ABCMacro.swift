// © 2026 John Gary Pusey (see LICENSE.md)

/// An ABC macro definition (`m:`).
///
/// Maps a target pattern to a replacement string, for example:
/// ```
/// m: ~G2 = {A}G{F}G
/// m: ~n = !trill!n
/// ```
///
/// The definition is preserved in ``ABCField/macro(_:)``.
///
/// See §9 (“Macros”) of the ABC 2.1 standard.
public struct ABCMacro {

    // MARK: Public Initializers

    /// Creates a new macro definition, or `nil` if any parameter is invalid.
    ///
    /// - Parameter target:      The target pattern (left-hand side of `=`); must be 1–31 characters.
    /// - Parameter replacement: The replacement string (right-hand side of `=`); must be 1–200 characters.
    public init?(target: String,
                 replacement: String) {
        guard Self._isValid(target, replacement)
        else { return nil }

        let parsedTarget = parseMacroTarget(target)

        switch parsedTarget.kind {
        case .static:
            self.kind = .static
            self.replacementSymbols = parseMacroReplacementSymbols(replacement)
            self.replacementTemplate = nil

        case .transposing:
            guard let template = parseMacroReplacementTemplate(replacement)
            else { return nil }

            self.kind = .transposing
            self.replacementSymbols = nil
            self.replacementTemplate = template
        }

        self.targetNoteLength = parsedTarget.noteLength
        self.targetSymbols = parsedTarget.prefix
        self.replacement = replacement
        self.target = target
    }

    // MARK: Public Instance Properties

    /// The replacement string (right-hand side of `=`).
    public let replacement: String

    /// The target pattern (left-hand side of `=`).
    public let target: String

    // MARK: Internal Instance Properties

    // Which flavor of macro this is, as determined from ``target``.
    internal let kind: Kind

    // The pre-parsed replacement, if ``kind`` is ``Kind/static``; `nil` otherwise.
    internal let replacementSymbols: [ABCSymbol]?

    // The pre-parsed replacement template, if ``kind`` is ``Kind/transposing``; `nil` otherwise.
    internal let replacementTemplate: [Element]?

    // The required written length of the trailing `n` note-slot, if ``kind``
    // is ``Kind/transposing``; `nil` otherwise.
    internal let targetNoteLength: ABCLength?

    // The literal symbols to match. If ``kind`` is ``Kind/static``, this is
    // the entire target; if ``Kind/transposing``, this is the literal prefix
    // before the trailing `n` note-slot.
    internal let targetSymbols: [ABCSymbol]
}

// MARK: -

extension ABCMacro {

    // MARK: Private Type Methods

    private static func _isValid(_ target: String,
                                 _ replacement: String) -> Bool {
        (1...31).contains(target.count)
        && (1...200).contains(replacement.count)
    }
}

// MARK: - Equatable

extension ABCMacro: Equatable {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether two macros are equal.
    ///
    /// Two macros are equal when their ``target`` and ``replacement`` strings
    /// match.
    public static func == (lhs: Self,
                           rhs: Self) -> Bool {
        lhs.replacement == rhs.replacement
        && lhs.target == rhs.target
    }
}

// MARK: - Sendable

extension ABCMacro: Sendable {
}
