// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCScoreBuilderErrorTests {
}

// MARK: -

extension ABCScoreBuilderErrorTests {
    @Test
    func category_isIvorABC() {
        let error = ABCScoreBuilder.Error.notValidated

        #expect(error.category?.description == "IvorABC")
    }

    @Test
    func equality() {
        let a = ABCScoreBuilder.Error.unresolvableMacro("~G2")
        let b = ABCScoreBuilder.Error.unresolvableMacro("~G2")

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a = ABCScoreBuilder.Error.unresolvableMacro("~G2")
        let b = ABCScoreBuilder.Error.unresolvableMacro("~n")

        #expect(a != b)
    }

    @Test
    func message_notValidated() {
        #expect(ABCScoreBuilder.Error.notValidated.message.lowercased().contains("validate"))
    }

    @Test
    func message_unrepresentableDuration() {
        #expect(ABCScoreBuilder.Error.unrepresentableDuration("3/0").message.contains("3/0"))
    }

    @Test
    func message_unresolvableMacro() {
        #expect(ABCScoreBuilder.Error.unresolvableMacro("~G2").message.contains("~G2"))
    }

    @Test
    func message_unsupportedOption() {
        #expect(ABCScoreBuilder.Error.unsupportedOption.message.lowercased().contains("optimizeforplayback"))
    }
}
