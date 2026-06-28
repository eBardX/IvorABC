// © 2026 John Gary Pusey (see LICENSE.md)

internal struct ABCParsePolicy {

    // MARK: Internal Initializers

    internal init(version: ABCVersion?) {
        self.iFieldIsFreeText = (version == .v1_6)
        self.mode = if let version,
                       version >= .v2_1 {
            .strict
        } else {
            .loose
        }
    }

    // MARK: Internal Instance Properties

    internal let iFieldIsFreeText: Bool
    internal let mode: Mode
}
