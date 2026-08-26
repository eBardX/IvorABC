// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension Character {

    // MARK: Internal Instance Properties

    internal var isABCAlphanumeric: Bool {
        isABCDigit || isABCLetter
    }

    internal var isABCDigit: Bool {
        switch self {
        case "0"..."9":
             true

        default:
             false
        }
    }

    internal var isABCDirectiveNameHead: Bool {
        isABCLetter
    }

    internal var isABCDirectiveNameTail: Bool {
        self == "-" || isABCAlphanumeric
    }

    internal var isABCHexDigit: Bool {
        switch self {
        case "a"..."f",
             "A"..."F":
             true

        default:
             isABCDigit
        }
    }

    internal var isABCLetter: Bool {
        switch self {
        case "a"..."z",
             "A"..."Z":
             true

        default:
             false
        }
    }

    internal var isABCVisible: Bool {
        switch self {
        case "\u{00}"..."\u{1f}",
             "\u{7f}"..."\u{a0}",
             "\u{034f}",
             "\u{200b}"..."\u{200d}",
             "\u{feff}":
            false

        default:
            true
        }
    }

    internal var isABCWhitespace: Bool {
        switch self {
        case " ",
             "\t":
            true

        default:
            false
        }
    }
}
