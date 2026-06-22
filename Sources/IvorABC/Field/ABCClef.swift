// © 2026 John Gary Pusey (see LICENSE.md)

/// Clef and transposition properties that can appear in a `K:` or `V:` field.
public struct ABCClef {

    // MARK: Public Initializers

    /// Creates a new clef specification, or returns `nil` if any parameter
    /// is invalid.
    ///
    /// - Parameter name:       The clef name (e.g., `.treble`, `.bass`,
    ///                         `.alto`, `.tenor`, `.percussion`, `.noClef`).
    ///                         Defaults to `nil`, meaning unspecified.
    /// - Parameter line:       The staff line on which the clef symbol is
    ///                         placed (e.g., `4` for bass on line 4). Must
    ///                         be in the range `1...stafflines`. Defaults to
    ///                         `nil`, meaning use the spec default for the
    ///                         given clef name (treble: 2, alto: 3,
    ///                         bass/tenor: 4, all others: 1).
    /// - Parameter ottava:     The `+8`/`-8` clef marker: `.alta` draws '8'
    ///                         above the staff and transposes up one octave
    ///                         for playback; `.bassa` draws '8' below and
    ///                         transposes down one octave. Defaults to `nil`,
    ///                         meaning unspecified.
    /// - Parameter middle:     The pitch displayed on the middle (3rd) line of
    ///                         the staff. Defaults to `nil`, meaning
    ///                         unspecified.
    /// - Parameter transpose:  Transposition in semitones. Defaults to `0`.
    /// - Parameter octave:     Transposition in octaves. Defaults to `0`.
    /// - Parameter stafflines: The number of staff lines. Must be ≥ 1.
    ///                         Defaults to `5`.
    public init?(name: Name? = nil,
                 line: Int? = nil,
                 ottava: Ottava? = nil,
                 middle: Middle? = nil,
                 transpose: Int = 0,
                 octave: Int = 0,
                 stafflines: Int = 5) {
        let resolvedLine = line ?? Self.defaultLine(for: name)

        guard Self._isValid(name,
                            resolvedLine,
                            ottava,
                            transpose,
                            octave,
                            stafflines)
        else { return nil }

        self.line = resolvedLine
        self.middle = middle
        self.name = name
        self.octave = octave
        self.ottava = ottava
        self.stafflines = stafflines
        self.transpose = transpose
    }

    // MARK: Public Instance Properties

    /// The staff line on which the clef symbol is placed. Defaults to the
    /// spec-defined default for the given clef name (treble: 2, alto: 3,
    /// bass/tenor: 4), or 1 for all other cases.
    public let line: Int

    /// The pitch displayed on the middle (3rd) line of the staff, or `nil` if
    /// not specified.
    public let middle: Middle?

    /// The clef name, or `nil` if not specified.
    public let name: Name?

    /// Transposition in octaves. Defaults to `0`.
    public let octave: Int

    /// The `+8`/`-8` clef marker, or `nil` if not specified.
    public let ottava: Ottava?

    /// The number of staff lines. Defaults to `5`.
    public let stafflines: Int

    /// Transposition in semitones. Defaults to `0`.
    public let transpose: Int
}

// MARK: -

extension ABCClef {

    // MARK: Internal Type Methods

    internal static func defaultLine(for name: Name?) -> Int {
        name.flatMap { defaultLines[$0] } ?? 1
    }

    // MARK: Private Type Properties

    private static let defaultLines: [Name: Int] = [.alto: 3,
                                                    .bass: 4,
                                                    .tenor: 4,
                                                    .treble: 2]

    // MARK: Private Type Methods

    private static func _isValid(_ name: Name?,
                                 _ line: Int,
                                 _ ottava: Ottava?,
                                 _ transpose: Int,
                                 _ octave: Int,
                                 _ stafflines: Int) -> Bool {
        guard stafflines >= 1
        else { return false }

        guard (1...stafflines).contains(line)
        else { return false }

        return true
    }
}

// MARK: - Equatable

extension ABCClef: Equatable {
}

// MARK: - Sendable

extension ABCClef: Sendable {
}
