// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCValidator {

    // MARK: Internal Nested Types

    internal struct State {
        var activeDialect: ABCDecoration.Dialect = .bang
        var globalDeassignedShorthands: Set<ABCShorthand> = []
        var globalDefinedShorthands: Set<ABCShorthand> = [.tilde,
                                                          .hUpper,
                                                          .lUpper,
                                                          .mUpper,
                                                          .oUpper,
                                                          .pUpper,
                                                          .sUpper,
                                                          .tUpper,
                                                          .uLower,
                                                          .vLower]
        var tuneDeassignedShorthands: Set<ABCShorthand> = []
        var tuneDefinedShorthands: Set<ABCShorthand> = []

        func isShorthandDefined(_ shorthand: ABCShorthand) -> Bool {
            if tuneDeassignedShorthands.contains(shorthand) {
                return false
            }

            if tuneDefinedShorthands.contains(shorthand) {
                return true
            }

            if globalDeassignedShorthands.contains(shorthand) {
                return false
            }

            return globalDefinedShorthands.contains(shorthand)
        }

        mutating func resetTuneScope() {
            tuneDeassignedShorthands = []
            tuneDefinedShorthands = []
        }
    }
}
