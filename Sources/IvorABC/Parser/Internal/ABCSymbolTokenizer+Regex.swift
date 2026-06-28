// © 2025–2026 John Gary Pusey (see LICENSE.md)

@preconcurrency internal import RegexBuilder

private import XestiTools

extension ABCSymbolTokenizer {

    // MARK: Internal Type Properties

    internal nonisolated(unsafe) static let regexAnnotation = Regex {
        "\""
        annotationPlacementCC
        annotationText
        "\""
    }

    internal nonisolated(unsafe) static let regexBarLine = Regex {
        Optionally {
            "."
        }
        ChoiceOf {
            Regex {
                OneOrMore {
                    ":"
                }
                ZeroOrMore {
                    barGlyph
                }
                ZeroOrMore {
                    ":"
                }
            }
            Regex {
                OneOrMore {
                    barGlyph
                }
                ZeroOrMore {
                    ":"
                }
            }
        }
        Optionally {
            repeatRangeList
        }
    }

    internal nonisolated(unsafe) static let regexBrokenRhythm = Regex {
        ChoiceOf {
            Repeat(1...3) {
                "<"
            }
            Repeat(1...3) {
                ">"
            }
        }
    }

    internal nonisolated(unsafe) static let regexChordSuffix = Regex {
        ChoiceOf {
            Regex {
                duration
                Optionally {
                    ChoiceOf {
                        ".-"
                        "-"
                    }
                }
            }
            ".-"
            "-"
        }
    }

    internal nonisolated(unsafe) static let regexChordSymbol = Regex {
        "\""
        chordSymbolPitchName
        ZeroOrMore {
            chordSymbolKindLetterCC
        }
        Optionally {
            "/"
            chordSymbolPitchName
        }
        Optionally {
            "("
            chordSymbolPitchName
            ZeroOrMore {
                chordSymbolKindLetterCC
            }
            ")"
        }
        "\""
    }

    internal nonisolated(unsafe) static let regexDecoration = Regex {
        ChoiceOf {
            Regex {
                "!"
                OneOrMore {
                    decorationNameCC
                }
                "!"
            }
            Regex {
                "+"
                OneOrMore {
                    decorationLegacyNameCC
                }
                "+"
            }
        }
    }

    internal nonisolated(unsafe) static let regexInlineField = Regex {
        "["
        letterCC
        ":"
        inlineFieldValue
        "]"
    }

    internal nonisolated(unsafe) static let regexNote = Regex {
        ZeroOrMore {
            pitchAccidentalCC
        }
        pitchLetterCC
        ZeroOrMore {
            pitchOctaveCC
        }
        Optionally {
            duration
        }
        Optionally {
            ChoiceOf {
                ".-"
                "-"
            }
        }
    }

    internal nonisolated(unsafe) static let regexRest = Regex {
        restCC
        Optionally {
            duration
        }
    }

    internal nonisolated(unsafe) static let regexShorthand = Regex {
        shorthandCC
    }

    internal nonisolated(unsafe) static let regexSpacer = Regex {
        "y"
        Optionally {
            duration
        }
    }

    internal nonisolated(unsafe) static let regexTuplet = Regex {
        "("
        tupletDigit2To9CC
        Repeat(...2) {
            ":"
            Optionally {
                tupletDigit1To9CC
            }
        }
    }

    internal nonisolated(unsafe) static let regexVariantEnding = Regex {
        "["
        repeatRangeList
        NegativeLookahead {
            ":"
        }
    }
}

// MARK: -

extension ABCSymbolTokenizer {

    // MARK: Private Type Properties

    private nonisolated(unsafe) static let annotationText = Regex {
        OneOrMore {
            ChoiceOf {
                Regex {
                    "\\"
                    CharacterClass.anyOf("\n\r").inverted
                }
                CharacterClass.anyOf("\n\r\\\"").inverted
            }
        }
    }

    private nonisolated(unsafe) static let barGlyph = Regex {
        ChoiceOf {
            "[|]"
            "[|"
            "|]"
            "||"
            "|"
        }
    }

    private nonisolated(unsafe) static let chordSymbolPitchName = Regex {
        chordSymbolPitchLetterCC
        Optionally {
            chordSymbolAccidentalCC
        }
    }

    private nonisolated(unsafe) static let duration = Regex {
        ChoiceOf {
            Regex {
                Optionally {
                    uinteger
                }
                ChoiceOf {
                    Regex {
                        "/"
                        uinteger
                    }
                    Repeat(1...7) {
                        "/"
                    }
                }
            }
            uinteger
        }
    }

    private nonisolated(unsafe) static let inlineFieldValue = Regex {
        ZeroOrMore {
            ChoiceOf {
                "\\\\"
                "\\&"
                "\\%"
                CharacterClass.anyOf("\n\r\\%]").inverted
            }
        }
    }

    private nonisolated(unsafe) static let repeatRange = Regex {
        repeatDigitCC
        Optionally {
            "-"
            repeatDigitCC
        }
    }

    private nonisolated(unsafe) static let repeatRangeList = Regex {
        repeatRange
        ZeroOrMore {
            ","
            repeatRange
        }
    }

    private nonisolated(unsafe) static let uinteger = Regex {
        OneOrMore {
            digitCC
        }
    }

    private static let alphaNumericCC           = digitCC.union(letterCC)
    private static let annotationPlacementCC    = CharacterClass(.anyOf("_@^<>"))
    private static let chordSymbolAccidentalCC  = CharacterClass(.anyOf("b#"))
    private static let chordSymbolKindLetterCC  = alphaNumericCC.union(.anyOf("+"))
    private static let chordSymbolPitchLetterCC = CharacterClass("A"..."G")
    private static let decorationLegacyNameCC   = alphaNumericCC.union(.anyOf(".()<>"))
    private static let decorationNameCC         = alphaNumericCC.union(.anyOf(".()+<>"))
    private static let digitCC                  = CharacterClass("0"..."9")
    private static let letterCC                 = CharacterClass("A"..."Z",
                                                                 "a"..."z")
    private static let pitchAccidentalCC        = CharacterClass(.anyOf("=^_"))
    private static let pitchLetterCC            = CharacterClass("A"..."G",
                                                                 "a"..."g")
    private static let pitchOctaveCC            = CharacterClass(.anyOf("',"))
    private static let repeatDigitCC            = CharacterClass("1"..."9")
    private static let restCC                   = CharacterClass(.anyOf("XZxz"))
    private static let shorthandCC              = CharacterClass(.anyOf(".~"),
                                                                 "H"..."W",
                                                                 "h"..."w")
    private static let tupletDigit1To9CC        = CharacterClass("1"..."9")
    private static let tupletDigit2To9CC        = CharacterClass("2"..."9")
}
