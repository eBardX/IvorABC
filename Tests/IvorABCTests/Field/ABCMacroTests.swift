// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCMacroTests {
}

// MARK: -

extension ABCMacroTests {
    @Test
    func equality() {
        let macro1 = makeMacro("~G2", "{A}G{F}G")
        let macro2 = makeMacro("~G2", "{A}G{F}G")

        #expect(macro1 == macro2)
    }

    @Test
    func inequality_differentReplacement() {
        let macro1 = makeMacro("~n", "!n!")
        let macro2 = makeMacro("~n", "!m!")

        #expect(macro1 != macro2)
    }

    @Test
    func inequality_differentTrigger() {
        let macro1 = makeMacro("~G2", "{A}G{F}G")
        let macro2 = makeMacro("~A2", "{A}G{F}G")

        #expect(macro1 != macro2)
    }

    @Test
    func init_storesProperties() {
        let macro = makeMacro("~G2", "{A}G{F}G")

        #expect(macro.trigger == "~G2")
        #expect(macro.replacement == "{A}G{F}G")
    }
}
