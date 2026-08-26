// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCParserPolicyModeTests {
}

// MARK: -

extension ABCParserPolicyModeTests {
    @Test
    func loose_isLooseCase() {
        let mode = ABCParser.Policy.Mode.loose

        guard case .loose = mode
        else { Issue.record("Expected .loose"); return }
    }

    @Test
    func nilVersion_isLoose() {
        let policy = ABCParser.Policy(version: nil)

        guard case .loose = policy.mode
        else { Issue.record("Expected .loose"); return }
    }

    @Test
    func strict_isStrictCase() {
        let mode = ABCParser.Policy.Mode.strict

        guard case .strict = mode
        else { Issue.record("Expected .strict"); return }
    }

    @Test
    func versionAtOrAboveV2_1_isStrict() {
        let policy = ABCParser.Policy(version: ABCVersion(major: 2, minor: 1))

        guard case .strict = policy.mode
        else { Issue.record("Expected .strict"); return }
    }

    @Test
    func versionBelowV2_1_isLoose() {
        let policy = ABCParser.Policy(version: ABCVersion(major: 2, minor: 0))

        guard case .loose = policy.mode
        else { Issue.record("Expected .loose"); return }
    }
}
