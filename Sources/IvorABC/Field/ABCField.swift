// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC field.
public enum ABCField {
    /// An area field (`A:`).
    case area(ABCText)

    /// A book field (`B:`).
    case book(ABCText)

    /// A composer field (`C:`).
    case composer(ABCText)

    /// A discography field (`D:`).
    case discography(ABCText)

    /// A legacy elemskip field (`E:`).
    ///
    /// This is a 1.6-only field with no ABC 2.x equivalent. It was
    /// specific to `abc2mtex` and controlled the `\elemskip` TeX dimension —
    /// the horizontal spacing between notes on a staff. Modern tools ignore
    /// it. ``ABCTunebook/migrate()`` collapses it to ``remark(_:)`` when
    /// upgrading to ABC 2.1.
    case elemskip(ABCElemskip)

    /// A file URL field (`F:`).
    case fileURL(ABCText)

    /// A group field (`G:`).
    case group(ABCText)

    /// A history field (`H:`).
    case history(ABCText)

    /// A legacy information field (`I:`).
    ///
    /// In ABC 1.6, `I:` carried free-text information. ABC 2.x repurposed
    /// `I:` as an inline instruction/directive; the 2.x form is represented
    /// by ``instruction(_:)``. ``ABCTunebook/migrate()`` collapses this
    /// case to ``remark(_:)`` when upgrading to ABC 2.1.
    case information(ABCText)

    /// An inline instruction field (`[I:]`).
    ///
    /// Standalone `I:name value` lines are parsed as ``ABCDirective`` and
    /// emitted as ``ABCEntry/directive(_:)`` — identical to `%%name value`.
    /// This case is only produced for inline `[I:name value]` fields embedded
    /// in a music body line.
    case instruction(ABCDirective)

    /// A key signature field (`K:`).
    case key(ABCKeySignature)

    /// A macro field (`m:`).
    case macro(ABCMacro)

    /// A meter (time signature) field (`M:`).
    case meter(ABCTimeSignature)

    /// A notes field (`N:`).
    case notes(ABCText)

    /// An origin field (`O:`).
    case origin(ABCText)

    /// A part field (`P:`) in the tune body.
    ///
    /// Marks the start of a named section in the tune body, e.g. `P:A`. The
    /// associated ``ABCPart`` is the single part label.
    ///
    /// For the tune header form of the `P:` field, see ``parts(_:)``.
    case part(ABCPart)

    /// A parts field (`P:`) in the tune header.
    ///
    /// Declares the part play order, e.g. `P:A2B(CD)3`. The associated
    /// ``ABCPartSequence`` may contain multiple items, nested groups, and
    /// repeat counts.
    ///
    /// For the tune body form of the `P:` field, see ``part(_:)``.
    case parts(ABCPartSequence)

    /// A reference number field (`X:`).
    case referenceNumber(ABCReferenceNumber)

    /// A remark field (`r:`).
    case remark(ABCText)

    /// A rhythm field (`R:`).
    case rhythm(ABCText)

    /// A source field (`S:`).
    case source(ABCText)

    /// A symbol line field (`s:`).
    case symbolLine(ABCSymbolLine)

    /// A tempo field (`Q:`).
    case tempo(ABCTempo)

    /// A tune title field (`T:`).
    case tuneTitle(ABCText)

    /// A transcription field (`Z:`).
    case transcription(ABCText)

    /// A unit note length field (`L:`).
    case unitNoteLength(ABCDuration)

    /// A user-defined symbol field (`U:`).
    case userDefined(ABCUserSymbol)

    /// A voice field (`V:`).
    case voice(ABCVoice)

    /// A words (lyrics) field (`W:`).
    case words(ABCText)

    /// An aligned lyrics field (`w:`).
    case wordsAligned(ABCAlignedWords)
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

    public var isValidInline: Bool {
        switch self {
        case .instruction,
             .key,
             .macro,
             .meter,
             .notes,
             .part,
             .remark,
             .rhythm,
             .tempo,
             .unitNoteLength,
             .userDefined,
             .voice:
            true

        default:
            false
        }
    }

    /// A Boolean value indicating whether this field is valid in a tune body.
    public var isValidInTuneBody: Bool {
        switch self {
        case .instruction,
             .key,
             .macro,
             .meter,
             .notes,
             .part,
             .remark,
             .rhythm,
             .symbolLine,
             .tempo,
             .tuneTitle,
             .unitNoteLength,
             .userDefined,
             .voice,
             .words,
             .wordsAligned:
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
             .discography,
             .elemskip,
             .fileURL,
             .group,
             .history,
             .information,
             .instruction,
             .key,
             .macro,
             .meter,
             .notes,
             .origin,
             .parts,
             .referenceNumber,
             .remark,
             .rhythm,
             .source,
             .tempo,
             .transcription,
             .tuneTitle,
             .unitNoteLength,
             .userDefined,
             .voice,
             .words:
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
