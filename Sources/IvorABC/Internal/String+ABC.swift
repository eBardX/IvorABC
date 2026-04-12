// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension String {
    //
    // A representation of the string with whitespace normalized by stripping
    // any leading and trailing whitespace and replacing sequences of
    // whitespace characters by a single space. If only whitespace exists,
    // return an empty string.
    //
    internal func normalizedABCWhitespace(trimLeadingWhitespace: Bool = true,
                                          trimTrailingWhitespace: Bool = true) -> String {
        guard !isEmpty
        else { return "" }

        var outChars: [Character] = []
        var whitespace = trimLeadingWhitespace

        for inChar in self {
            if !inChar.isABCWhitespace {
                outChars.append(inChar)

                whitespace = false
            } else if !whitespace {
                outChars.append(" ")

                whitespace = true
            }
        }

        if whitespace, trimTrailingWhitespace {
            outChars = outChars.dropLast()
        }

        return String(outChars)
    }
}
