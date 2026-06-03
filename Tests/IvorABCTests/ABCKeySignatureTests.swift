// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCKeySignatureTests {
}

// MARK: -

extension ABCKeySignatureTests {
    @Test
    func equality_empty() {
        #expect(ABCKeySignature.empty == .empty)
    }

    @Test
    func equality_highlandPipes() {
        #expect(ABCKeySignature.highlandPipes == .highlandPipes)
    }

    @Test
    func equality_highlandPipesPreset() {
        #expect(ABCKeySignature.highlandPipesPreset == .highlandPipesPreset)
    }

    @Test
    func equality_standard() {
        let sig = ABCKeySignature.standard(.g, .major, [])

        #expect(sig == .standard(.g, .major, []))
    }

    @Test
    func inequality() {
        #expect(ABCKeySignature.empty != .highlandPipes)
        #expect(ABCKeySignature.highlandPipes != .highlandPipesPreset)
        #expect(ABCKeySignature.standard(.g, .major, []) != .standard(.d, .major, []))
        #expect(ABCKeySignature.standard(.g, .major, []) != .standard(.g, .minor, []))
        #expect(ABCKeySignature.empty != .standard(.c, .major, []))
    }
}
