// © 2025–2026 John Gary Pusey (see LICENSE.md)

internal import XestiTokens
internal import XestiTools

internal struct ABCSymbolTokenizer {

    // MARK: Internal Initializers

    internal init(tracing: Verbosity) {
        self.baseTokenizer = Tokenizer(rules: Self.rules,
                                       tracing: tracing)
    }

    // MARK: Private Instance Properties

    private let baseTokenizer: Tokenizer
}

// MARK: -

extension ABCSymbolTokenizer {

    // MARK: Internal Nested Types

    internal typealias BaseTokenizer = Tokenizer
    internal typealias Token         = BaseTokenizer.Token

    // MARK: Internal Instance Properties

    internal var tracing: Verbosity {
        baseTokenizer.tracing
    }

    // MARK: Internal Instance Methods

    internal func tokenize(_ input: String) throws -> [Token] {
        try baseTokenizer.tokenize(input: input)
    }

    // MARK: Private Nested Types

    private typealias Rule = BaseTokenizer.Rule

    // MARK: Private Type Properties

    private nonisolated(unsafe) static let rules: [Rule] = [Rule(regexAnnotation, .annotation),
                                                            Rule(regexBarRepeat, .barRepeat),
                                                            Rule(regexBrokenRhythm, .brokenRhythm),
                                                            Rule(regexChordSymbol, .chordSymbol),
                                                            Rule(regexDecoration, .decoration),
                                                            Rule(regexInlineField, .inlineField),
                                                            Rule(regexNote, .note),
                                                            Rule(regexRest, .rest),
                                                            Rule(regexTuplet, .tuplet),
                                                            Rule(regexVariantEnding, .variantEnding),
                                                            Rule(/`+/, .backquotes),
                                                            Rule(/\[/, .chordBegin),
                                                            Rule(/]/, .chordEnd),
                                                            Rule(/\{\/?/, .graceNotesBegin),
                                                            Rule(/\}/, .graceNotesEnd),
                                                            Rule(/&/, .overlay),
                                                            Rule(/\(/, .slurBegin),
                                                            Rule(/\)/, .slurEnd),
                                                            Rule(regex: /[$\\]$/,
                                                                 disposition: .skip(nil)),
                                                            Rule(regex: /[$\\](?=\s)/,
                                                                 disposition: .skip(nil)),
                                                            Rule(regex: /\s+/,
                                                                 disposition: .skip(nil)),
                                                            Rule(regex: /%.*$/,
                                                                 disposition: .skip(nil))]
}

// MARK: -

extension Tokenizer.Token.Kind {
    internal static let annotation         = Self("annotation")
    internal static let backquotes         = Self("backquotes")
    internal static let barRepeat          = Self("barRepeat")
    internal static let brokenRhythm       = Self("brokenRhythm")
    internal static let chordBegin         = Self("chordBegin")
    internal static let chordEnd           = Self("chordEnd")
    internal static let chordSymbol        = Self("chordSymbol")
    internal static let decoration         = Self("decoration")
    internal static let graceNotesBegin    = Self("graceNotesBegin")
    internal static let graceNotesEnd      = Self("graceNotesEnd")
    internal static let inlineField        = Self("inlineField")
    internal static let note               = Self("note")
    internal static let overlay            = Self("overlay")
    internal static let rest               = Self("rest")
    internal static let slurBegin          = Self("slurBegin")
    internal static let slurEnd            = Self("slurEnd")
    internal static let tuplet             = Self("tuplet")
    internal static let variantEnding      = Self("variantEnding")
}
