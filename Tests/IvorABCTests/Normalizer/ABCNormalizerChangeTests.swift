// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCNormalizerChangeTests {
}

// MARK: -

extension ABCNormalizerChangeTests {
    @Test
    func equality() {
        let a = ABCNormalizer.Change.removedDirective(makeDirective("abc-charset", "utf-8"), 1)
        let b = ABCNormalizer.Change.removedDirective(makeDirective("abc-charset", "utf-8"), 1)

        #expect(a == b)
    }

    @Test
    func inequality_differentTuneIndex() {
        let a = ABCNormalizer.Change.removedDirective(makeDirective("abc-charset", "utf-8"), 0)
        let b = ABCNormalizer.Change.removedDirective(makeDirective("abc-charset", "utf-8"), 1)

        #expect(a != b)
    }

    @Test
    func message_clearedBeatMultiplier() {
        let tempo = makeTempo(1, 8, 120)
        let change = ABCNormalizer.Change.clearedBeatMultiplier(tempo, 0)

        #expect(change.message.contains("Tune 0"))
        #expect(change.message.contains("beat multiplier"))
    }

    @Test
    func message_convertedDecoration() {
        let change = ABCNormalizer.Change.convertedDecoration(makeDecoration("roll"), 2)

        #expect(change.message.contains("Tune 2"))
        #expect(change.message.contains("legacy"))
    }

    @Test
    func message_fileHeaderUsesFileHeaderLabel() {
        let change = ABCNormalizer.Change.removedDirective(makeDirective("abc-charset", "utf-8"), nil)

        #expect(change.message.contains("File header"))
    }

    @Test
    func message_removedDirective() {
        let change = ABCNormalizer.Change.removedDirective(makeDirective("abc-version", "2.0"), 0)

        #expect(change.message.contains("Tune 0"))
        #expect(change.message.contains("removed"))
    }

    @Test
    func message_replacedField() {
        let oldField = ABCField.information(ABCText("old"))
        let newField = ABCField.remark(ABCText("old"))
        let change = ABCNormalizer.Change.replacedField(oldField, newField, 1)

        #expect(change.message.contains("Tune 1"))
        #expect(change.message.contains("replaced"))
    }

    @Test
    func tuneIndex_forEachCase() {
        #expect(ABCNormalizer.Change.clearedBeatMultiplier(makeTempo("Allegro"), 3).tuneIndex == 3)
        #expect(ABCNormalizer.Change.convertedDecoration(makeDecoration("roll"), 3).tuneIndex == 3)
        #expect(ABCNormalizer.Change.removedDirective(makeDirective("abc-charset", "utf-8"), 3).tuneIndex == 3)
        #expect(ABCNormalizer.Change.replacedField(.information(ABCText("x")), .remark(ABCText("x")), 3).tuneIndex == 3)
    }

    @Test
    func tuneIndex_nilForFileHeader() {
        let change = ABCNormalizer.Change.removedDirective(makeDirective("abc-charset", "utf-8"), nil)

        #expect(change.tuneIndex == nil)
    }
}
