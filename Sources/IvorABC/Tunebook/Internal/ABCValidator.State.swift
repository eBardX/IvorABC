// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCValidator {

    // MARK: Internal Nested Types

    internal struct State {

        // MARK: Internal Initializers

        internal init() {
            self.activeDialect = .bang
            self.globalDeassignedShorthands = []
            self.globalDefinedShorthands = [.tilde,
                                            .hUpper,
                                            .lUpper,
                                            .mUpper,
                                            .oUpper,
                                            .pUpper,
                                            .sUpper,
                                            .tUpper,
                                            .uLower,
                                            .vLower]
            self.tuneDeassignedShorthands = []
            self.tuneDefinedShorthands = []
        }

        // MARK: Internal Intance Properties

        internal var activeDialect: ABCDecoration.Dialect
        internal var globalDeassignedShorthands: Set<ABCShorthand>
        internal var globalDefinedShorthands: Set<ABCShorthand>
        internal var tuneDeassignedShorthands: Set<ABCShorthand>
        internal var tuneDefinedShorthands: Set<ABCShorthand>

        // MARK: Internal Instance Methods

        internal func isShorthandDefined(_ shorthand: ABCShorthand) -> Bool {
            tuneDefinedShorthands.contains(shorthand)
            || (!tuneDeassignedShorthands.contains(shorthand)
                && globalDefinedShorthands.contains(shorthand))
        }

        internal mutating func resetTuneScope() {
            tuneDeassignedShorthands = []
            tuneDefinedShorthands = []
        }
    }
}
