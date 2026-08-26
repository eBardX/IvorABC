// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCValidatorCheckerPendingAttachmentCountsTests {
}

// MARK: -

extension ABCValidatorCheckerPendingAttachmentCountsTests {
    @Test
    func init_defaultsToZero() {
        let counts = ABCValidator.Checker.PendingAttachmentCounts()

        #expect(counts.chordSymbols == 0)
        #expect(counts.graceNotes == 0)
    }

    @Test
    func mutation_incrementsIndependently() {
        var counts = ABCValidator.Checker.PendingAttachmentCounts()

        counts.chordSymbols += 1
        counts.chordSymbols += 1
        counts.graceNotes += 1

        #expect(counts.chordSymbols == 2)
        #expect(counts.graceNotes == 1)
    }
}
