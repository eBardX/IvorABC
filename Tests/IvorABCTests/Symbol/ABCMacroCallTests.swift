// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCMacroCallTests {
}

// MARK: -

extension ABCMacroCallTests {
    @Test
    func equality() {
        let a = ABCMacroCall(trigger: "~G2", expansion: [.beamBreak])
        let b = ABCMacroCall(trigger: "~G2", expansion: [.beamBreak])

        #expect(a == b)
    }

    @Test
    func inequality_differentExpansion() {
        let a = ABCMacroCall(trigger: "~G2", expansion: [])
        let b = ABCMacroCall(trigger: "~G2", expansion: [.beamBreak])

        #expect(a != b)
    }

    @Test
    func inequality_differentTrigger() {
        let a = ABCMacroCall(trigger: "~G2", expansion: [.beamBreak])
        let b = ABCMacroCall(trigger: "~A2", expansion: [.beamBreak])

        #expect(a != b)
    }

    @Test
    func init_storesProperties() {
        let call = ABCMacroCall(trigger: "~G2", expansion: [.beamBreak])

        #expect(call.trigger == "~G2")
        #expect(call.expansion == [.beamBreak])
    }
}
