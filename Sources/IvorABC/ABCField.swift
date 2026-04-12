// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC field.
public enum ABCField {
    /// An aligned lyrics field (`w:`).
    case alignedLyrics(String)

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
    case macro(String)

    /// A meter (time signature) field (`M:`).
    case meter(ABCTimeSignature)

    /// A notes field (`N:`).
    case notes(String)

    /// An origin field (`O:`).
    case origin(String)

    /// A parts field (`P:`).
    case parts(String)

    /// A reference number field (`X:`).
    case refNumber(ABCRefNumber)

    /// A remark field (`r:`).
    case remark(String)

    /// A rhythm field (`R:`).
    case rhythm(String)

    /// A source field (`S:`).
    case source(String)

    /// A symbol line field (`s:`).
    case symbolLine(String)

    /// A tempo field (`Q:`).
    case tempo(ABCTempo)

    /// A title field (`T:`).
    case title(String)

    /// A transcription field (`Z:`).
    case transcription(String)

    /// A unit note length field (`L:`).
    case unitNoteLength(ABCDuration)

    /// A user-defined field (`U:`).
    case userDefined(String)

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
                .userDefined:
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
                .userDefined,
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
                .userDefined,
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
