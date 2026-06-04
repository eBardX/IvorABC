// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC field.
public enum ABCField {
    /// An aligned lyrics field (`w:`).
    case alignedLyrics(ABCAlignedLyrics)

    /// An area field (`A:`).
    case area(String)

    /// A book field (`B:`).
    case book(String)

    /// A composer field (`C:`).
    case composer(String)

    /// A field continuation (`+:`).
    case continuation(String)

    /// A discography field (`D:`).
    case discography(String)

    /// A file URL field (`F:`).
    case fileURL(String)

    /// A group field (`G:`).
    case group(String)

    /// A history field (`H:`).
    case history(String)

    /// An instruction field (`I:`).
    case instruction(String)

    /// A key signature field (`K:`).
    case key(ABCKeySignature)

    /// A lyrics field (`W:`).
    case lyrics(String)

    /// A macro field (`m:`).
    case macro(ABCMacro)

    /// A meter (time signature) field (`M:`).
    case meter(ABCTimeSignature)

    /// A notes field (`N:`).
    case notes(String)

    /// An origin field (`O:`).
    case origin(String)

    /// A parts field (`P:`).
    ///
    /// The associated ``ABCPartSequence`` models the field value for both of
    /// the two positions in which `P:` may appear:
    ///
    /// - **Tune header** — a part play-order declaration such as `P:A2B(CD)3`.
    ///   The sequence may contain multiple items, nested groups, and repeat
    ///   counts greater than one.
    /// - **Tune body** — a part-start marker such as `P:A`. The sequence
    ///   contains exactly one ``ABCPartSequence/Item/part(_:_:)`` item with a
    ///   repeat count of `1`, although the parser does not enforce this.
    ///
    /// Because the parser processes fields without positional context, the
    /// caller must examine the surrounding entry stream to determine which
    /// interpretation applies. See ``ABCPartSequence`` for a full discussion of
    /// the dual-use design and the obligations this places on the caller.
    case parts(ABCPartSequence)

    /// A reference number field (`X:`).
    case refNumber(ABCRefNumber)

    /// A remark field (`r:`).
    case remark(String)

    /// A rhythm field (`R:`).
    case rhythm(String)

    /// A source field (`S:`).
    case source(String)

    /// A symbol line field (`s:`).
    case symbolLine(ABCSymbolLine)

    /// A tempo field (`Q:`).
    case tempo(ABCTempo)

    /// A title field (`T:`).
    case title(String)

    /// A transcription field (`Z:`).
    case transcription(String)

    /// A unit note length field (`L:`).
    case unitNoteLength(ABCDuration)

    /// A user symbol field (`U:`).
    case userSymbol(ABCUserSymbol)

    /// A voice field (`V:`).
    case voice(ABCVoice)
}

// MARK: -

extension ABCField {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this field is valid in the file
    /// header.
    public var isValidInFileHeader: Bool {
        switch self {
        case .area,
             .book,
             .composer,
             .continuation,
             .discography,
             .fileURL,
             .group,
             .history,
             .instruction,
             .macro,
             .meter,
             .notes,
             .origin,
             .remark,
             .rhythm,
             .source,
             .transcription,
             .unitNoteLength,
             .userSymbol:
            true

        default:
            false
        }
    }

    /// A Boolean value indicating whether this field is valid in a tune body.
    public var isValidInTuneBody: Bool {
        switch self {
        case .alignedLyrics,
             .continuation,
             .instruction,
             .key,
             .lyrics,
             .macro,
             .meter,
             .notes,
             .parts,
             .remark,
             .rhythm,
             .symbolLine,
             .tempo,
             .title,
             .unitNoteLength,
             .userSymbol,
             .voice:
            true

        default:
            false
        }
    }

    /// A Boolean value indicating whether this field is valid in a tune header.
    public var isValidInTuneHeader: Bool {
        switch self {
        case .area,
             .book,
             .composer,
             .continuation,
             .discography,
             .fileURL,
             .group,
             .history,
             .instruction,
             .key,
             .lyrics,
             .macro,
             .meter,
             .notes,
             .origin,
             .parts,
             .refNumber,
             .remark,
             .rhythm,
             .source,
             .tempo,
             .title,
             .transcription,
             .unitNoteLength,
             .userSymbol,
             .voice:
            true

        default:
            false
        }
    }
}

// MARK: - Equatable

extension ABCField: Equatable {
}

// MARK: - Sendable

extension ABCField: Sendable {
}
