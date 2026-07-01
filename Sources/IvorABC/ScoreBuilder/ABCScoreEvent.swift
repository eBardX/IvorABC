// © 2026 John Gary Pusey (see LICENSE.md)

/// An event in an ``ABCScore`` event stream.
///
/// A single flat, ordered stream carries both structural/metadata events and
/// fully-resolved musical events, so a mid-tune change (e.g. a `K:` or `M:`
/// field appearing partway through the body) lands at the correct position
/// relative to the notes around it.
public enum ABCScoreEvent {
    /// A bar line marker.
    case barLine(ABCBarLine)

    /// A fully resolved chord, with any leading decorations, annotations,
    /// grace notes, or chord symbol aggregated onto it.
    case chord(ABCScoreChord, ABCScoreAttachments)

    /// A composer field (`C:`).
    case composer(ABCText)

    /// A standalone directive (`%%name value` or `I:name value`).
    ///
    /// Omitted when the `.stripDirectives` builder option is set.
    case directive(ABCDirective)

    /// A field with no dedicated case above, passed through unchanged.
    case field(ABCField)

    /// A key signature field (`K:`).
    case key(ABCKeySignature)

    /// A meter (time signature) field (`M:`).
    case meter(ABCTimeSignature)

    /// A fully resolved note, with any leading decorations, annotations,
    /// grace notes, or chord symbol aggregated onto it.
    case note(ABCScoreNote, ABCScoreAttachments)

    /// A part field (`P:`) marking the start of a named section in the tune
    /// body.
    case part(ABCPart)

    /// A reference number field (`X:`).
    case referenceNumber(ABCReferenceNumber)

    /// A fully resolved rest, with any leading decorations or annotations
    /// aggregated onto it.
    case rest(ABCScoreRest, ABCScoreAttachments)

    /// A tempo field (`Q:`).
    case tempo(ABCTempo)

    /// A tune title field (`T:`).
    case title(ABCText)

    /// A unit note length field (`L:`).
    case unitNoteLength(ABCLength)

    /// A variant ending marker.
    case variantEnding(ABCVariantEnding)

    /// A voice field (`V:`).
    case voice(ABCVoice)
}

// MARK: - Equatable

extension ABCScoreEvent: Equatable {
}

// MARK: - Sendable

extension ABCScoreEvent: Sendable {
}
