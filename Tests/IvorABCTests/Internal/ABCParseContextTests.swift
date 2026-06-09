// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCParseContextTests {
}

// MARK: -

extension ABCParseContextTests {
    @Test
    func baseDuration_defaultIsEighths() {
        let ctx = ABCParseContext()

        #expect(ctx.baseDuration == ABCDuration(numerator: 1,
                                                denominator: 8,
                                                reduce: false))
    }

    @Test
    func baseDuration_unitNoteLengthOverridesMeter() {
        var ctx = ABCParseContext()

        ctx.update(with: .meter(.explicit(ABCFraction(numerator: 3,
                                                      denominator: 16,
                                                      reduce: false))))
        ctx.update(with: .unitNoteLength(ABCDuration(numerator: 1,
                                                     denominator: 4,
                                                     reduce: false)))

        #expect(ctx.baseDuration == ABCDuration(numerator: 1,
                                                denominator: 4,
                                                reduce: false))
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
    func update_meter_compoundTime_setsIsCompoundMeter() {
        var ctx = ABCParseContext()

        ctx.update(with: .meter(.explicit(ABCFraction(numerator: 6,
                                                      denominator: 8,
                                                      reduce: false))))

        #expect(ctx.isCompoundMeter)
    }

    @Test
    func update_meter_simpleTime_clearsIsCompoundMeter() {
        var ctx = ABCParseContext()

        ctx.update(with: .meter(.explicit(ABCFraction(numerator: 4,
                                                      denominator: 4,
                                                      reduce: false))))

        #expect(!ctx.isCompoundMeter)
    }

    @Test
    func update_meter_threeQuarterTime_baseDurationEighths() {
        var ctx = ABCParseContext()

        ctx.update(with: .meter(.explicit(ABCFraction(numerator: 3,
                                                      denominator: 4,
                                                      reduce: false))))

        #expect(ctx.baseDuration == ABCDuration(numerator: 1,
                                                denominator: 8,
                                                reduce: false))
    }

    @Test
    func update_meter_threeSixteenthTime_baseDurationSixteenths() {
        var ctx = ABCParseContext()

        ctx.update(with: .meter(.explicit(ABCFraction(numerator: 3,
                                                      denominator: 16,
                                                      reduce: false))))

        #expect(ctx.baseDuration == ABCDuration(numerator: 1,
                                                denominator: 16,
                                                reduce: false))
    }

    @Test
    func update_unrelatedField_hasNoEffect() {
        var ctx = ABCParseContext()

        ctx.update(with: .title("My Song"))

        #expect(ctx.accidentalsInKey.isEmpty)
        #expect(!ctx.isCompoundMeter)
        #expect(ctx.baseDuration == ABCDuration(numerator: 1,
                                                denominator: 8,
                                                reduce: false))
    }
}
