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
        switch self {
        case "-", ":":
             true

        default:
             isABCAlphanumeric
        }
    }

    internal var isABCHexDigit: Bool {
        switch self {
        case "A"..."F", "a"..."f":
             true

        default:
             isABCDigit
        }
    }

    internal var isABCLetter: Bool {
        switch self {
        case "A"..."Z", "a"..."z":
             true

        default:
             false
        }
    }

    internal var isABCWhitespace: Bool {
        switch self {
        case "\t", " ":
            true

        default:
            false
        }
    }
}
