// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCMacroCallTests {
}

// MARK: -

extension ABCMacroCallTests {
    @Test
    func equality() {
        let a = makeMacroCall("~G2", [.beamBreak])
        let b = makeMacroCall("~G2", [.beamBreak])

        #expect(a == b)
    }

    @Test
    func inequality_differentExpansion() {
        let a = makeMacroCall("~G2", [])
        let b = makeMacroCall("~G2", [.beamBreak])

        #expect(a != b)
    }

    @Test
    func inequality_differentTrigger() {
        let a = makeMacroCall("~G2", [.beamBreak])
        let b = makeMacroCall("~A2", [.beamBreak])

        #expect(a != b)
    }

    @Test
    func init_storesProperties() {
        let call = makeMacroCall("~G2", [.beamBreak])

        #expect(call.trigger == "~G2")
        #expect(call.expansion == [.beamBreak])
    }
}
