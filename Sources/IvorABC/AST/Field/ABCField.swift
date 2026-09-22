// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC field.
///
/// See §3 (“Information fields”) of the ABC 2.1 standard.
public enum ABCField {
    /// An area field (`A:`, §3.1.5).
    case area(ABCText)

    /// A book field (`B:`, §3.1.16).
    case book(ABCText)

    /// A composer field (`C:`, §3.1.3).
    case composer(ABCText)

    /// A discography field (`D:`, §3.1.16).
    case discography(ABCText)

    /// A legacy elemskip field (`E:`, §10.1).
    ///
    /// This is a 1.6-only field with no ABC 2.x equivalent. It was
    /// specific to `abc2mtex` and controlled the `\elemskip` TeX dimension —
    /// the horizontal spacing between notes on a staff. Modern tools ignore
    /// it. ``ABCNormalizer/normalize(_:)`` collapses it to ``remark(_:)``
    /// when upgrading to ABC 2.1.
    case elemskip(ABCElemskip)

    /// A file URL field (`F:`, §3.1.16).
    case fileURL(ABCText)

    /// A group field (`G:`, §3.1.12).
    case group(ABCText)

    /// A history field (`H:`, §3.1.13).
    case history(ABCText)

    /// A legacy information field (`I:`, §10.1).
    ///
    /// In ABC 1.6, `I:` carried free-text information. ABC 2.x repurposed
    /// `I:` as an inline instruction/directive; the 2.x form is represented
    /// by ``instruction(_:)``. ``ABCNormalizer/normalize(_:)`` collapses
    /// this case to ``remark(_:)`` when upgrading to ABC 2.1.
    case information(ABCText)

    /// An inline instruction field (`[I:]`, §3.1.17).
    ///
    /// Standalone `I:name value` lines are parsed as ``ABCDirective`` and
    /// emitted as ``ABCHeaderEntry/directive(_:)`` or
    /// ``ABCBodyEntry/directive(_:)`` — identical to `%%name value`. This
    /// case is only produced for inline `[I:name value]` fields embedded in
    /// a music body line.
    case instruction(ABCDirective)

    /// A key signature field (`K:`, §3.1.14).
    case key(ABCKeySignature)

    /// A macro field (`m:`, §9).
    case macro(ABCMacro)

    /// A meter (time signature) field (`M:`, §3.1.6).
    case meter(ABCTimeSignature)

    /// A notes field (`N:`, §3.1.11).
    case notes(ABCText)

    /// An origin field (`O:`, §3.1.4).
    case origin(ABCText)

    /// A part field (`P:`, §3.1.9) in the tune body.
    ///
    /// Marks the start of a named section in the tune body, e.g. `P:A`. The
    /// associated ``ABCPart`` is the single part label.
    ///
    /// For the tune header form of the `P:` field, see ``parts(_:)``.
    case part(ABCPart)

    /// A parts field (`P:`, §3.1.9) in the tune header.
    ///
    /// Declares the part play order, e.g. `P:A2B(CD)3`. The associated
    /// ``ABCPartSequence`` may contain multiple items, nested groups, and
    /// repeat counts.
    ///
    /// For the tune body form of the `P:` field, see ``part(_:)``.
    case parts(ABCPartSequence)

    /// A reference number field (`X:`, §3.1.1).
    case referenceNumber(ABCReferenceNumber)

    /// A remark field (`r:`, §2.2.5).
    case remark(ABCText)

    /// A rhythm field (`R:`, §3.1.15).
    case rhythm(ABCText)

    /// A source field (`S:`, §3.1.16).
    case source(ABCText)

    /// A symbol line field (`s:`, §4.15).
    case symbolLine(ABCSymbolLine)

    /// A tempo field (`Q:`, §3.1.8).
    case tempo(ABCTempo)

    /// A transcription field (`Z:`, §3.1.10).
    case transcription(ABCText)

    /// A tune title field (`T:`, §3.1.2).
    case tuneTitle(ABCText)

    /// A unit note length field (`L:`, §3.1.7).
    case unitNoteLength(ABCLength)

    /// A user-defined symbol field (`U:`, §4.16).
    case userDefined(ABCUserSymbol)

    /// A voice field (`V:`, §7.1).
    case voice(ABCVoice)

    /// A words (lyrics) field (`W:`, §5).
    case words(ABCText)

    /// An aligned lyrics field (`w:`, §5.1).
    case wordsAligned(ABCAlignedWords)
}

// MARK: -

extension ABCField {

    // MARK: Internal Instance Properties

    internal var isValidInFileHeader: Bool {
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

    internal var isValidInline: Bool {
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

    internal var isValidInTuneBody: Bool {
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

    internal var isValidInTuneHeader: Bool {
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
