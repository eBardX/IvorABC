// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

// MARK: - ABCField Expectations

func expectFieldIsAlignedLyrics(_ field: ABCField,
                                _ expected: String,
                                sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .alignedLyrics(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .alignedLyrics", sourceLocation: sourceLocation)
    }
}

func expectFieldIsArea(_ field: ABCField,
                       _ expected: String,
                       sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .area(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .area", sourceLocation: sourceLocation)
    }
}

func expectFieldIsBook(_ field: ABCField,
                       _ expected: String,
                       sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .book(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .book", sourceLocation: sourceLocation)
    }
}

func expectFieldIsComposer(_ field: ABCField,
                           _ expected: String,
                           sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .composer(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .composer", sourceLocation: sourceLocation)
    }
}

func expectFieldIsContinuation(_ field: ABCField,
                               _ expected: String,
                               sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .continuation(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .continuation", sourceLocation: sourceLocation)
    }
}

func expectFieldIsDiscography(_ field: ABCField,
                              _ expected: String,
                              sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .discography(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .discography", sourceLocation: sourceLocation)
    }
}

func expectFieldIsFileURL(_ field: ABCField,
                          _ expected: String,
                          sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .fileURL(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .fileURL", sourceLocation: sourceLocation)
    }
}

func expectFieldIsGroup(_ field: ABCField,
                        _ expected: String,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .group(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .group", sourceLocation: sourceLocation)
    }
}

func expectFieldIsHistory(_ field: ABCField,
                          _ expected: String,
                          sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .history(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .history", sourceLocation: sourceLocation)
    }
}

func expectFieldIsInstruction(_ field: ABCField,
                              _ expected: String,
                              sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .instruction(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .instruction", sourceLocation: sourceLocation)
    }
}

func expectFieldIsKey(_ field: ABCField,
                      sourceLocation: SourceLocation = #_sourceLocation) {
    if case .key = field { } else {
        Issue.record("Expected .key", sourceLocation: sourceLocation)
    }
}

func expectFieldIsLyrics(_ field: ABCField,
                         _ expected: String,
                         sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .lyrics(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .lyrics", sourceLocation: sourceLocation)
    }
}

func expectFieldIsMacro(_ field: ABCField,
                        _ expected: String,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .macro(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .macro", sourceLocation: sourceLocation)
    }
}

func expectFieldIsMeter(_ field: ABCField,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case .meter = field { } else {
        Issue.record("Expected .meter", sourceLocation: sourceLocation)
    }
}

func expectFieldIsNotes(_ field: ABCField,
                        _ expected: String,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .notes(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .notes", sourceLocation: sourceLocation)
    }
}

func expectFieldIsOrigin(_ field: ABCField,
                         _ expected: String,
                         sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .origin(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .origin", sourceLocation: sourceLocation)
    }
}

func expectFieldIsParts(_ field: ABCField,
                        _ expected: String,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .parts(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .parts", sourceLocation: sourceLocation)
    }
}

func expectFieldIsRefNumber(_ field: ABCField,
                            sourceLocation: SourceLocation = #_sourceLocation) {
    if case .refNumber = field { } else {
        Issue.record("Expected .refNumber", sourceLocation: sourceLocation)
    }
}

func expectFieldIsRemark(_ field: ABCField,
                         _ expected: String,
                         sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .remark(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .remark", sourceLocation: sourceLocation)
    }
}

func expectFieldIsRhythm(_ field: ABCField,
                         _ expected: String,
                         sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .rhythm(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .rhythm", sourceLocation: sourceLocation)
    }
}

func expectFieldIsSource(_ field: ABCField,
                         _ expected: String,
                         sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .source(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .source", sourceLocation: sourceLocation)
    }
}

func expectFieldIsSymbolLine(_ field: ABCField,
                             _ expected: String,
                             sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .symbolLine(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .symbolLine", sourceLocation: sourceLocation)
    }
}

func expectFieldIsTempo(_ field: ABCField,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case .tempo = field { } else {
        Issue.record("Expected .tempo", sourceLocation: sourceLocation)
    }
}

func expectFieldIsTitle(_ field: ABCField,
                        _ expected: String,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .title(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .title", sourceLocation: sourceLocation)
    }
}

func expectFieldIsTranscription(_ field: ABCField,
                                _ expected: String,
                                sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .transcription(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .transcription", sourceLocation: sourceLocation)
    }
}

func expectFieldIsUnitNoteLength(_ field: ABCField,
                                 sourceLocation: SourceLocation = #_sourceLocation) {
    if case .unitNoteLength = field { } else {
        Issue.record("Expected .unitNoteLength", sourceLocation: sourceLocation)
    }
}

func expectFieldIsUserDefined(_ field: ABCField,
                              _ expected: String,
                              sourceLocation: SourceLocation = #_sourceLocation) {
    if case let .userDefined(v) = field {
        #expect(v == expected, sourceLocation: sourceLocation)
    } else {
        Issue.record("Expected .userDefined", sourceLocation: sourceLocation)
    }
}

func expectFieldIsVoice(_ field: ABCField,
                        sourceLocation: SourceLocation = #_sourceLocation) {
    if case .voice = field { } else {
        Issue.record("Expected .voice", sourceLocation: sourceLocation)
    }
}
