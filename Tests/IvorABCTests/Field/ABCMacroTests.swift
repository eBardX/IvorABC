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
    func inequality_differentTarget() {
        let macro1 = makeMacro("~G2", "{A}G{F}G")
        let macro2 = makeMacro("~A2", "{A}G{F}G")

        #expect(macro1 != macro2)
    }

    @Test
    func init_storesProperties() {
        let macro = makeMacro("~G2", "{A}G{F}G")

        #expect(macro.target == "~G2")
        #expect(macro.replacement == "{A}G{F}G")
    }

    @Test
    func init_nilOnEmptyTarget() {
        #expect(ABCMacro(target: "", replacement: "{A}G{F}G") == nil)
    }

    @Test
    func init_nilOnOverlongTarget() {
        #expect(ABCMacro(target: String(repeating: "~", count: 32), replacement: "{A}G{F}G") == nil)
    }

    @Test
    func init_nilOnEmptyReplacement() {
        #expect(ABCMacro(target: "~G2", replacement: "") == nil)
    }

    @Test
    func init_nilOnOverlongReplacement() {
        #expect(ABCMacro(target: "~G2", replacement: String(repeating: "G", count: 201)) == nil)
    }

    @Test
    func init_succeedsAtTargetBoundaries() {
        #expect(ABCMacro(target: "~", replacement: "G") != nil)
        #expect(ABCMacro(target: String(repeating: "~", count: 31), replacement: "G") != nil)
    }

    @Test
    func init_succeedsAtReplacementBoundaries() {
        #expect(ABCMacro(target: "~G2", replacement: "G") != nil)
        #expect(ABCMacro(target: "~G2", replacement: String(repeating: "G", count: 200)) != nil)
    }
}
