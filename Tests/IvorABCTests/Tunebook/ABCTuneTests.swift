// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCTuneTests {
}

// MARK: -

extension ABCTuneTests {
    @Test
    func equality() {
        let entries: [ABCEntry] = [.field(.title("My Tune"))]
        let a = ABCTune(entries: entries)
        let b = ABCTune(entries: entries)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a = ABCTune(entries: [.field(.title("Tune A"))])
        let b = ABCTune(entries: [.field(.title("Tune B"))])

        #expect(a != b)
    }

    @Test
    func init_storesEntries() {
        let entries: [ABCEntry] = [.field(.title("Test")),
                                   .field(.composer("J.S. Bach"))]
        let tune = ABCTune(entries: entries)

        #expect(tune.entries == entries)
        #expect(tune.entries.count == 2)
    }
}
