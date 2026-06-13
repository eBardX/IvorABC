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

        #expect(ctx.baseDuration == ABCDuration(1, 8))
    }

    @Test
    func baseDuration_unitNoteLengthOverridesMeter() throws {
        var ctx = ABCParseContext()

        try ctx.update(with: .meter(.standard(#require(ABCTimeSignature.StandardMeter(numerator: 3, denominator: 16)))))
        ctx.update(with: .unitNoteLength(ABCDuration(1, 4)))

        #expect(ctx.baseDuration == ABCDuration(1, 4))
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

        ctx.update(with: .key(.standard(.c, .major, [], nil)))

        #expect(ctx.accidentalsInKey.isEmpty)
    }

    @Test
    func update_key_gMajor_fSharp() {
        var ctx = ABCParseContext()

        ctx.update(with: .key(.standard(.g, .major, [], nil)))

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
    func update_meter_compoundTime_setsIsCompoundMeter() throws {
        var ctx = ABCParseContext()

        try ctx.update(with: .meter(.standard(#require(ABCTimeSignature.StandardMeter(numerator: 6, denominator: 8)))))

        #expect(ctx.isCompoundMeter)
    }

    @Test
    func update_meter_simpleTime_clearsIsCompoundMeter() throws {
        var ctx = ABCParseContext()

        try ctx.update(with: .meter(.standard(#require(ABCTimeSignature.StandardMeter(numerator: 4, denominator: 4)))))

        #expect(!ctx.isCompoundMeter)
    }

    @Test
    func update_meter_threeQuarterTime_baseDurationEighths() throws {
        var ctx = ABCParseContext()

        try ctx.update(with: .meter(.standard(#require(ABCTimeSignature.StandardMeter(numerator: 3, denominator: 4)))))

        #expect(ctx.baseDuration == ABCDuration(1, 8))
    }

    @Test
    func update_meter_threeSixteenthTime_baseDurationSixteenths() throws {
        var ctx = ABCParseContext()

        try ctx.update(with: .meter(.standard(#require(ABCTimeSignature.StandardMeter(numerator: 3, denominator: 16)))))

        #expect(ctx.baseDuration == ABCDuration(1, 16))
    }

    @Test
    func update_unrelatedField_hasNoEffect() {
        var ctx = ABCParseContext()

        ctx.update(with: .title("My Song"))

        #expect(ctx.accidentalsInKey.isEmpty)
        #expect(!ctx.isCompoundMeter)
        #expect(ctx.baseDuration == ABCDuration(1, 8))
    }
}
