// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

extension ABCFormatter {

    // MARK: Public Nested Types

    /// An error that occurs when formatting an ABC tunebook.
    public enum Error {
        /// A chord contains no notes.
        case emptyChord

        /// A grace note group contains no notes.
        case emptyGraceNotes

        /// A variant ending has no ending numbers.
        case emptyVariantEnding

        /// A voice identifier is empty.
        case emptyVoiceID

        /// A bar repeat marker string is invalid.
        case invalidBarRepeat(String)

        /// A broken rhythm marker string is invalid.
        case invalidBrokenRhythm(String)

        /// A multi-measure rest has a count of zero.
        case invalidMultiMeasureRestCount

        /// A slur marker string is invalid.
        case invalidSlur(String)

        /// A text value contains a newline character.
        case invalidTextValue(String)

        /// A time signature has a structurally invalid value.
        ///
        /// This is thrown when an `M:standard` time signature has a non-power-of-two
        /// denominator, or when an `M:complex` time signature has an empty numerator
        /// list or a non-power-of-two denominator.
        case invalidTimeSignature(ABCTimeSignature)

        /// A tuplet has a zero note count.
        case invalidTupletNoteCount

        /// A unit note length (`L:`) has a non-power-of-two denominator.
        case invalidUnitNoteLength(ABCDuration)

        /// A field appears in a position where it is not permitted in the file
        /// header.
        case misplacedFileHeaderField(ABCField)

        /// A field appears in a position where it is not permitted in the tune
        /// header or body.
        case misplacedTuneField(ABCField)

        /// A tune header has no terminating key signature (`K:`) field.
        case missingKeySignature

        /// A tune does not begin with a reference number (`X:`) field.
        case missingReferenceNumber

        /// The formatted buffer could not be converted to UTF-8 data.
        case stringConversionFailed

        /// The tunebook specifies an ABC version other than 2.1.
        case unsupportedVersion(ABCVersion)
    }
}

// MARK: - EnhancedError

extension ABCFormatter.Error: EnhancedError {
    /// The error category identifying the source module.
    public var category: Category? {
        Category("IvorABC")
    }

    /// A human-readable description of this error.
    public var message: String {
        switch self {
        case .emptyChord:
            "Chord contains no notes"

        case .emptyGraceNotes:
            "Grace note group contains no notes"

        case .emptyVariantEnding:
            "Variant ending has no ending numbers"

        case .emptyVoiceID:
            "Voice identifier is empty"

        case let .invalidBarRepeat(s):
            "Bar repeat marker is invalid: \(s.isEmpty ? "(empty)" : s)"

        case let .invalidBrokenRhythm(s):
            "Broken rhythm marker is invalid: \(s.isEmpty ? "(empty)" : s)"

        case .invalidMultiMeasureRestCount:
            "Multi-measure rest has a count of zero"

        case let .invalidSlur(s):
            "Slur marker is invalid: \(s.isEmpty ? "(empty)" : s)"

        case let .invalidTextValue(value):
            "Text value contains invalid characters: \(value)"

        case let .invalidTimeSignature(ts):
            "Time signature is structurally invalid: \(ts)"

        case .invalidTupletNoteCount:
            "Tuplet has a zero note count"

        case let .invalidUnitNoteLength(dur):
            "Unit note length has a non-power-of-two denominator: \(dur.numerator)/\(dur.denominator)"

        case let .misplacedFileHeaderField(field):
            "Field is not valid in the file header: \(field)"

        case let .misplacedTuneField(field):
            "Field is not valid at this position in the tune: \(field)"

        case .missingKeySignature:
            "Tune header has no terminating key signature (K:) field"

        case .missingReferenceNumber:
            "Tune does not begin with a reference number (X:) field"

        case .stringConversionFailed:
            "Failed to convert string to UTF-8 data"

        case let .unsupportedVersion(version):
            "Unsupported ABC version: \(version.stringValue)"
        }
    }
}

// MARK: - Equatable

extension ABCFormatter.Error: Equatable {
}

// MARK: - Sendable

extension ABCFormatter.Error: Sendable {
}
