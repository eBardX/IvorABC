// © 2026 John Gary Pusey (see LICENSE.md)

/// The decorations, annotations, grace notes, and chord symbol that precede a
/// note, chord, or rest in the ABC source, aggregated onto the event they
/// attach to.
public struct ABCScoreAttachments {

    // MARK: Public Initializers

    /// Creates a new set of attachments.
    ///
    /// - Parameter decorations: The decorations attached to the following
    ///                          note/chord/rest, in source order — including
    ///                          `U:`-resolved shorthands and the `.dot`
    ///                          shorthand resolved to staccato. Defaults to
    ///                          empty.
    /// - Parameter annotations: The annotations attached to the following
    ///                          note/chord/rest, in source order. Defaults to
    ///                          empty.
    /// - Parameter graceNotes:  The grace note group attached to the
    ///                          following note/chord/rest, or `nil` if none.
    ///                          Defaults to `nil`.
    /// - Parameter chordSymbol: The chord symbol attached to the following
    ///                          note/chord/rest, or `nil` if none. Defaults
    ///                          to `nil`.
    public init(decorations: [ABCDecoration] = [],      // make this internal ???
                annotations: [ABCAnnotation] = [],
                graceNotes: ABCScoreGraceNotes? = nil,
                chordSymbol: ABCChordSymbol? = nil) {
        self.annotations = annotations
        self.chordSymbol = chordSymbol
        self.decorations = decorations
        self.graceNotes = graceNotes
    }

    // MARK: Public Instance Properties

    /// The annotations attached to the following note/chord/rest, in source
    /// order.
    public let annotations: [ABCAnnotation]

    /// The chord symbol attached to the following note/chord/rest, or `nil`
    /// if none.
    public let chordSymbol: ABCChordSymbol?

    /// The decorations attached to the following note/chord/rest, in source
    /// order — including `U:`-resolved shorthands and the `.dot` shorthand
    /// resolved to staccato.
    public let decorations: [ABCDecoration]

    /// The grace note group attached to the following note/chord/rest, or
    /// `nil` if none.
    public let graceNotes: ABCScoreGraceNotes?
}

// MARK: -

extension ABCScoreAttachments {

    // MARK: Public Type Properties

    /// An empty set of attachments.
    public static let empty = Self()
}

// MARK: - Equatable

extension ABCScoreAttachments: Equatable {
}

// MARK: - Sendable

extension ABCScoreAttachments: Sendable {
}
