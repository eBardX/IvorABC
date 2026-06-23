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
        #expect(!ctx.hasMacros)
        #expect(!ctx.inTune)
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
    func update_macro_notInTune_persistsAfterReset() {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(makeMacro("~G2", "GHG")))
        ctx.inTune = true
        ctx.resetTuneScope()

        #expect(ctx.macro(for: "~G2") != nil)
    }

    @Test
    func update_macro_inTune_clearedByReset() {
        var ctx = ABCParseContext()

        ctx.inTune = true
        ctx.update(with: .macro(makeMacro("~G2", "GHG")))

        #expect(ctx.hasMacros)

        ctx.resetTuneScope()

        #expect(ctx.macro(for: "~G2") == nil)
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

    @Test
    func macro_forTrigger_tuneOverridesGlobal() {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(makeMacro("~G2", "global")))
        ctx.inTune = true
        ctx.update(with: .macro(makeMacro("~G2", "tune")))

        #expect(ctx.macro(for: "~G2")?.replacement == "tune")
    }

    @Test
    func macro_forTrigger_fallsBackToGlobal() {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(makeMacro("~G2", "global")))
        ctx.inTune = true

        #expect(ctx.macro(for: "~G2")?.replacement == "global")
    }

    @Test
    func macro_forTrigger_missingReturnsNil() {
        let ctx = ABCParseContext()

        #expect(ctx.macro(for: "~G2") == nil)
    }

    @Test
    func resetTuneScope_clearsTuneMacrosAndUserSymbols() {
        var ctx = ABCParseContext()

        ctx.update(with: .macro(makeMacro("~G2", "global")))
        ctx.update(with: .userDefined(makeUserSymbol(.hUpper, makeDecoration("trill"))))
        ctx.inTune = true
        ctx.update(with: .macro(makeMacro("~A2", "tune")))
        ctx.update(with: .userDefined(makeUserSymbol(.hLower, makeDecoration("trill"))))

        ctx.resetTuneScope()

        #expect(ctx.macro(for: "~A2") == nil)
        #expect(ctx.macro(for: "~G2") != nil)
        #expect(ctx.userSymbolDefinition(for: .hLower) == nil)
        #expect(ctx.userSymbolDefinition(for: .hUpper) != nil)
    }

    @Test
    func resetTuneScope_revertsAccidentalsInKey() {
        var ctx = ABCParseContext()

        ctx.inTune = true
        ctx.update(with: .key(makeKeySignature(.g, .major)))

        ctx.resetTuneScope()

        #expect(ctx.accidentalsInKey.isEmpty)
    }

    @Test
    func resetTuneScope_revertsDecorationDialect() {
        var ctx = ABCParseContext()

        ctx.update(with: makeDirective(.decoration, "+"))   // file-header default: plus
        ctx.inTune = true
        ctx.update(with: makeDirective(.decoration, "!"))   // tune override: bang

        ctx.resetTuneScope()

        #expect(ctx.decorationDialect == .plus)
    }

    @Test
    func resetTuneScope_revertsIsCompoundMeter() {
        var ctx = ABCParseContext()

        ctx.update(with: .meter(makeTimeSignature(4, 4)))  // file-header default: simple
        ctx.inTune = true
        ctx.update(with: .meter(makeTimeSignature(6, 8)))  // tune override: compound

        ctx.resetTuneScope()

        #expect(!ctx.isCompoundMeter)
    }

    @Test
    func resetTuneScope_revertsBaseDuration() {
        var ctx = ABCParseContext()

        ctx.update(with: .unitNoteLength(makeDuration(1, 4)))  // file-header default
        ctx.inTune = true
        ctx.update(with: .unitNoteLength(makeDuration(1, 16))) // tune override

        ctx.resetTuneScope()

        #expect(ctx.baseDuration == makeDuration(1, 4))
    }
}
