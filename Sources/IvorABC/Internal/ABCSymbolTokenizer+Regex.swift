// © 2025–2026 John Gary Pusey (see LICENSE.md)

@preconcurrency internal import RegexBuilder

private import XestiTools

extension ABCSymbolTokenizer {

    // MARK: Internal Type Properties

    nonisolated(unsafe) internal static let regexAnnotation = Regex {
        "\""
        annotationCC
        annotationValue
        "\""
    }

    nonisolated(unsafe) internal static let regexBarRepeat = Regex {
        Optionally {
            "."
        }
        ChoiceOf {
            ":||:"
            ":|:"
            "[|]"
            "::"
            ":|"
            "[|"
            "|:"
            "|]"
            "||"
            "|"
        }
        Optionally {
            repeatRangeList
        }
    }

    nonisolated(unsafe) internal static let regexBrokenRhythm = Regex {
        ChoiceOf {
            Repeat(1...3) {
                "<"
            }
            Repeat(1...3) {
                ">"
            }
        }
    }

    nonisolated(unsafe) internal static let regexChordSymbol = Regex {
        "\""
        chordPitch
        ZeroOrMore {
            chordTypeLetterCC
        }
        Optionally {
            "/"
            chordPitch
        }
        Optionally {
            "("
            chordPitch
            ZeroOrMore {
                chordTypeLetterCC
            }
            ")"
        }
        "\""
    }

    nonisolated(unsafe) internal static let regexDecoration = Regex {
        ChoiceOf {
            decorationShorthandCC
            Regex {
                "!"
                OneOrMore {
                    decorationNameCC
                }
                "!"
            }
        }
    }

    nonisolated(unsafe) internal static let regexInlineField = Regex {
        "["
        letterCC
        ":"
        inlineFieldValue
        "]"
    }

    nonisolated(unsafe) internal static let regexNote = Regex {
        ZeroOrMore {
            accidentalCC
        }
        pitchLetterCC
        ZeroOrMore {
            octaveCC
        }
        Optionally {
            duration
        }
        Optionally {
            "-"
        }
    }

    nonisolated(unsafe) internal static let regexRest = Regex {
        restCC
        Optionally {
            duration
        }
    }

    nonisolated(unsafe) internal static let regexTuplet = Regex {
        "("
        tupletDigitCC
        Repeat(...2) {
            ":"
            Optionally {
                tupletDigitCC
            }
        }
    }

    nonisolated(unsafe) internal static let regexVariantEnding = Regex {
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

    nonisolated(unsafe) private static let annotationValue = Regex {
        OneOrMore {
            ChoiceOf {
                "\\\\"
                "\\&"
                "\\%"
                "\\\""
                CharacterClass.anyOf("\n\r\\%\"").inverted
            }
        }
    }

    nonisolated(unsafe) private static let chordPitch = Regex {
        chordPitchLetterCC
        Optionally {
            chordAccidentalCC
        }
    }

    nonisolated(unsafe) private static let duration = Regex {
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

    nonisolated(unsafe) private static let inlineFieldValue = Regex {
        ZeroOrMore {
            ChoiceOf {
                "\\\\"
                "\\&"
                "\\%"
                CharacterClass.anyOf("\n\r\\%]").inverted
            }
        }
    }

    nonisolated(unsafe) private static let repeatRange = Regex {
        repeatDigitCC
        Optionally {
            "-"
            repeatDigitCC
        }
    }

    nonisolated(unsafe) private static let repeatRangeList = Regex {
        repeatRange
        ZeroOrMore {
            ","
            repeatRange
        }
    }

    nonisolated(unsafe) private static let uinteger = Regex {
        OneOrMore {
            digitCC
        }
    }

    private static let accidentalCC          = CharacterClass(.anyOf("=^_"))
    private static let alphaNumericCC        = digitCC.union(letterCC)
    private static let annotationCC          = CharacterClass(.anyOf("_@^<>"))
    private static let chordAccidentalCC     = CharacterClass(.anyOf("b#"))
    private static let chordPitchLetterCC    = CharacterClass("A"..."G")
    private static let chordTypeLetterCC     = alphaNumericCC.union(.anyOf("+"))
    private static let decorationNameCC      = alphaNumericCC.union(.anyOf(".()+<>"))
    private static let decorationShorthandCC = CharacterClass(.anyOf(".~HLMOPSTuv"))
    private static let digitCC               = CharacterClass("0"..."9")
    private static let letterCC              = CharacterClass("A"..."Z",
                                                              "a"..."z")
    private static let octaveCC              = CharacterClass(.anyOf("',"))
    private static let pitchLetterCC         = CharacterClass("A"..."G",
                                                              "a"..."g")
    private static let repeatDigitCC         = CharacterClass("1"..."9")
    private static let restCC                = CharacterClass(.anyOf("XZxz"))
    private static let tupletDigitCC         = CharacterClass("2"..."9")
}
