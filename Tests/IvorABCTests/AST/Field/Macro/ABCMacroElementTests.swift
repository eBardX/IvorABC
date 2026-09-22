// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCMacroElementTests {
}

// MARK: -

extension ABCMacroElementTests {
    @Test
    func equality_placeholder() {
        let a = ABCMacro.Element.placeholder(diatonicOffset: 1, length: makeLength(1))
        let b = ABCMacro.Element.placeholder(diatonicOffset: 1, length: makeLength(1))

        #expect(a == b)
    }

    @Test
    func equality_symbol() {
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let a = ABCMacro.Element.symbol(.note(note))
        let b = ABCMacro.Element.symbol(.note(note))

        #expect(a == b)
    }

    @Test
    func inequality_differentDiatonicOffset() {
        let a = ABCMacro.Element.placeholder(diatonicOffset: 1, length: makeLength(1))
        let b = ABCMacro.Element.placeholder(diatonicOffset: 2, length: makeLength(1))

        #expect(a != b)
    }

    @Test
    func inequality_differentLength() {
        let a = ABCMacro.Element.placeholder(diatonicOffset: 1, length: makeLength(1))
        let b = ABCMacro.Element.placeholder(diatonicOffset: 1, length: makeLength(2))

        #expect(a != b)
    }

    @Test
    func inequality_placeholderVsSymbol() {
        let note = makeNote(makePitch(.c, .natural, 4), makeLength(1))
        let a = ABCMacro.Element.placeholder(diatonicOffset: 0, length: makeLength(1))
        let b = ABCMacro.Element.symbol(.note(note))

        #expect(a != b)
    }
}
