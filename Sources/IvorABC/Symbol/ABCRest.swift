// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A rest in ABC notation.
public enum ABCRest {
    /// A multi-measure rest.
    ///
    /// The associated `Bool` value indicates whether the rest is invisible, and
    /// the associated ``MeasureCount`` value is the number of measures.
    case multiMeasure(Bool, MeasureCount)

    /// A regular rest.
    ///
    /// The associated `Bool` value indicates whether the rest is invisible, and
    /// the associated ``ABCDuration`` value is the duration of the rest.
    case regular(Bool, ABCDuration)
}

// MARK: -

extension ABCRest {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this rest is invisible.
    public var isInvisible: Bool {
        switch self {
        case let .multiMeasure(invisible, _),
             let .regular(invisible, _):
            invisible
        }
    }

    /// A Boolean value indicating whether this rest spans multiple measures.
    public var isMultiMeasure: Bool {
        switch self {
        case .multiMeasure:
            true

        default:
            false
        }
    }
}

// MARK: - Equatable

extension ABCRest: Equatable {
}

// MARK: - Sendable

extension ABCRest: Sendable {
}
