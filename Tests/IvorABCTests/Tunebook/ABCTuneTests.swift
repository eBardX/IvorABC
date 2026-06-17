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
        let a = makeTune(entries)
        let b = makeTune(entries)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a = makeTune([.field(.title("Tune A"))])
        let b = makeTune([.field(.title("Tune B"))])

        #expect(a != b)
    }

    @Test
    func init_storesEntries() {
        let entries: [ABCEntry] = [.field(.title("Test")),
                                   .field(.composer("J.S. Bach"))]
        let tune = makeTune(entries)

        #expect(tune.entries == entries)
        #expect(tune.entries.count == 2)
    }
}
