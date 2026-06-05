// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCMacroTests {
}

// MARK: -

extension ABCMacroTests {
    @Test
    func equality() {
        let macro1 = ABCMacro(trigger: "~G2", replacement: "{A}G{F}G")
        let macro2 = ABCMacro(trigger: "~G2", replacement: "{A}G{F}G")

        #expect(macro1 == macro2)
    }

    @Test
    func inequality_differentReplacement() {
        let macro1 = ABCMacro(trigger: "~n", replacement: "!n!")
        let macro2 = ABCMacro(trigger: "~n", replacement: "!m!")

        #expect(macro1 != macro2)
    }

    @Test
    func inequality_differentTrigger() {
        let macro1 = ABCMacro(trigger: "~G2", replacement: "{A}G{F}G")
        let macro2 = ABCMacro(trigger: "~A2", replacement: "{A}G{F}G")

        #expect(macro1 != macro2)
    }

    @Test
    func init_storesProperties() {
        let macro = ABCMacro(trigger: "~G2", replacement: "{A}G{F}G")

        #expect(macro.trigger == "~G2")
        #expect(macro.replacement == "{A}G{F}G")
    }
}
