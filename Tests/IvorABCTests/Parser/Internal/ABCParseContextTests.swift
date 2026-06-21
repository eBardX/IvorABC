// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCParseContextTests {
}

// MARK: -

extension ABCParseContextTests {
    @Test
    func baseDuration_defaultIsEighths() {
        let ctx = ABCParseContext()

        #expect(ctx.baseDuration == makeDuration(1, 8))
    }

    @Test
    func baseDuration_unitNoteLengthOverridesMeter() {
        var ctx = ABCParseContext()

        ctx.update(with: .meter(makeTimeSignature(3, 16)))
        ctx.update(with: .unitNoteLength(makeDuration(1, 4)))

        #expect(ctx.baseDuration == makeDuration(1, 4))
    }

    @Test
    func init_defaults() {
        let ctx = ABCParseContext()

        #expect(ctx.accidentalsInKey.isEmpty)
        #expect(!ctx.isCompoundMeter)
    }

    @Test
    func update_key_cMajor_noAccidentals() {
        var ctx = ABCParseContext()

        ctx.update(with: .key(makeKeySignature(.c, .major)))

        #expect(ctx.accidentalsInKey.isEmpty)
    }

    @Test
    func update_key_gMajor_fSharp() {
        var ctx = ABCParseContext()

        ctx.update(with: .key(makeKeySignature(.g, .major)))

        #expect(ctx.accidentalsInKey.count == 1)
        #expect(ctx.accidentalsInKey[.f] == .sharp)
    }

    @Test
    func update_key_highlandPipesPreset() {
        var ctx = ABCParseContext()

        ctx.update(with: .key(.highlandPipesPreset))

        #expect(ctx.accidentalsInKey.count == 3)
        #expect(ctx.accidentalsInKey[.c] == .sharp)
        #expect(ctx.accidentalsInKey[.f] == .sharp)
        #expect(ctx.accidentalsInKey[.g] == .natural)
    }

    @Test
    func update_meter_compoundTime_setsIsCompoundMeter() {
        var ctx = ABCParseContext()

        ctx.update(with: .meter(makeTimeSignature(6, 8)))

        #expect(ctx.isCompoundMeter)
    }

    @Test
    func update_meter_simpleTime_clearsIsCompoundMeter() {
        var ctx = ABCParseContext()

        ctx.update(with: .meter(makeTimeSignature(4, 4)))

        #expect(!ctx.isCompoundMeter)
    }

    @Test
    func update_meter_threeQuarterTime_baseDurationEighths() {
        var ctx = ABCParseContext()

        ctx.update(with: .meter(makeTimeSignature(3, 4)))

        #expect(ctx.baseDuration == makeDuration(1, 8))
    }

    @Test
    func update_meter_threeSixteenthTime_baseDurationSixteenths() {
        var ctx = ABCParseContext()

        ctx.update(with: .meter(makeTimeSignature(3, 16)))

        #expect(ctx.baseDuration == makeDuration(1, 16))
    }

    @Test
    func update_unrelatedField_hasNoEffect() {
        var ctx = ABCParseContext()

        ctx.update(with: .tuneTitle("My Song"))

        #expect(ctx.accidentalsInKey.isEmpty)
        #expect(!ctx.isCompoundMeter)
        #expect(ctx.baseDuration == makeDuration(1, 8))
    }
}
