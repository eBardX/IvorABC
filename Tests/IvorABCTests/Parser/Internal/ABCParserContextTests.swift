// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCParserContextTests {
}

// MARK: -

extension ABCParserContextTests {
    @Test
    func baseDuration_defaultIsEighths() {
        let ctx = ABCParser.Context()

        #expect(ctx.baseDuration == makeDuration(1, 8))
    }

    @Test
    func baseDuration_unitNoteLengthOverridesMeter() {
        var ctx = ABCParser.Context()

        ctx.update(with: .meter(makeTimeSignature(3, 16)))
        ctx.update(with: .unitNoteLength(makeDuration(1, 4)))

        #expect(ctx.baseDuration == makeDuration(1, 4))
    }

    @Test
    func init_defaults() {
        let ctx = ABCParser.Context()

        #expect(ctx.accidentalsInKey.isEmpty)
        #expect(!ctx.inTune)
        #expect(!ctx.isCompoundMeter)
    }

    @Test
    func update_key_cMajor_noAccidentals() {
        var ctx = ABCParser.Context()

        ctx.update(with: .key(makeKeySignature(.c, .major)))

        #expect(ctx.accidentalsInKey.isEmpty)
    }

    @Test
    func update_key_gMajor_fSharp() {
        var ctx = ABCParser.Context()

        ctx.update(with: .key(makeKeySignature(.g, .major)))

        #expect(ctx.accidentalsInKey.count == 1)
        #expect(ctx.accidentalsInKey[.f] == .sharp)
    }

    @Test
    func update_key_highlandPipesPreset() {
        var ctx = ABCParser.Context()

        ctx.update(with: .key(.highlandPipesPreset))

        #expect(ctx.accidentalsInKey.count == 3)
        #expect(ctx.accidentalsInKey[.c] == .sharp)
        #expect(ctx.accidentalsInKey[.f] == .sharp)
        #expect(ctx.accidentalsInKey[.g] == .natural)
    }

    @Test
    func update_meter_compoundTime_setsIsCompoundMeter() {
        var ctx = ABCParser.Context()

        ctx.update(with: .meter(makeTimeSignature(6, 8)))

        #expect(ctx.isCompoundMeter)
    }

    @Test
    func update_meter_simpleTime_clearsIsCompoundMeter() {
        var ctx = ABCParser.Context()

        ctx.update(with: .meter(makeTimeSignature(4, 4)))

        #expect(!ctx.isCompoundMeter)
    }

    @Test
    func update_meter_threeQuarterTime_baseDurationEighths() {
        var ctx = ABCParser.Context()

        ctx.update(with: .meter(makeTimeSignature(3, 4)))

        #expect(ctx.baseDuration == makeDuration(1, 8))
    }

    @Test
    func update_meter_threeSixteenthTime_baseDurationSixteenths() {
        var ctx = ABCParser.Context()

        ctx.update(with: .meter(makeTimeSignature(3, 16)))

        #expect(ctx.baseDuration == makeDuration(1, 16))
    }

    @Test
    func update_unrelatedField_hasNoEffect() {
        var ctx = ABCParser.Context()

        ctx.update(with: .tuneTitle("My Song"))

        #expect(ctx.accidentalsInKey.isEmpty)
        #expect(!ctx.isCompoundMeter)
        #expect(ctx.baseDuration == makeDuration(1, 8))
    }

    @Test
    func resetTuneScope_clearsTuneUserSymbols() {
        var ctx = ABCParser.Context()

        ctx.update(with: .userDefined(makeUserSymbol(.hUpper, makeDecoration("trill"))))
        ctx.inTune = true
        ctx.update(with: .userDefined(makeUserSymbol(.hLower, makeDecoration("trill"))))

        ctx.resetTuneScope()

        #expect(ctx.userSymbolDefinition(for: .hLower) == nil)
        #expect(ctx.userSymbolDefinition(for: .hUpper) != nil)
    }

    @Test
    func resetTuneScope_revertsAccidentalsInKey() {
        var ctx = ABCParser.Context()

        ctx.inTune = true
        ctx.update(with: .key(makeKeySignature(.g, .major)))

        ctx.resetTuneScope()

        #expect(ctx.accidentalsInKey.isEmpty)
    }

    @Test
    func resetTuneScope_revertsDecorationDialect() {
        var ctx = ABCParser.Context()

        ctx.update(with: makeDirective(.decoration, "+"))   // file-header default: plus
        ctx.inTune = true
        ctx.update(with: makeDirective(.decoration, "!"))   // tune override: bang

        ctx.resetTuneScope()

        #expect(ctx.decorationDialect == .plus)
    }

    @Test
    func resetTuneScope_revertsIsCompoundMeter() {
        var ctx = ABCParser.Context()

        ctx.update(with: .meter(makeTimeSignature(4, 4)))  // file-header default: simple
        ctx.inTune = true
        ctx.update(with: .meter(makeTimeSignature(6, 8)))  // tune override: compound

        ctx.resetTuneScope()

        #expect(!ctx.isCompoundMeter)
    }

    @Test
    func resetTuneScope_revertsBaseDuration() {
        var ctx = ABCParser.Context()

        ctx.update(with: .unitNoteLength(makeDuration(1, 4)))  // file-header default
        ctx.inTune = true
        ctx.update(with: .unitNoteLength(makeDuration(1, 16))) // tune override

        ctx.resetTuneScope()

        #expect(ctx.baseDuration == makeDuration(1, 4))
    }

    @Test
    func init_predefinedUserSymbols_areAvailable() {
        let ctx = ABCParser.Context()

        #expect(ctx.userSymbolDefinition(for: .tilde) == .decoration(makeDecoration("roll")))
        #expect(ctx.userSymbolDefinition(for: .hUpper) == .decoration(makeDecoration("fermata")))
        #expect(ctx.userSymbolDefinition(for: .lUpper) == .decoration(makeDecoration("accent")))
        #expect(ctx.userSymbolDefinition(for: .mUpper) == .decoration(makeDecoration("lowermordent")))
        #expect(ctx.userSymbolDefinition(for: .oUpper) == .decoration(makeDecoration("coda")))
        #expect(ctx.userSymbolDefinition(for: .pUpper) == .decoration(makeDecoration("uppermordent")))
        #expect(ctx.userSymbolDefinition(for: .sUpper) == .decoration(makeDecoration("segno")))
        #expect(ctx.userSymbolDefinition(for: .tUpper) == .decoration(makeDecoration("trill")))
        #expect(ctx.userSymbolDefinition(for: .uLower) == .decoration(makeDecoration("upbow")))
        #expect(ctx.userSymbolDefinition(for: .vLower) == .decoration(makeDecoration("downbow")))
        #expect(ctx.userSymbolDefinition(for: .nUpper) == nil)
    }

    @Test
    func update_annotation_isRetrievable() {
        var ctx = ABCParser.Context()
        let annotation = makeAnnotation(.above, "col legno")

        ctx.update(with: .userDefined(makeUserSymbol(.nUpper, annotation)))

        #expect(ctx.userSymbolDefinition(for: .nUpper) == .annotation(annotation))
    }

    @Test
    func deassignment_predefinedShorthand_makesItUndefined() {
        var ctx = ABCParser.Context()

        ctx.update(with: .userDefined(makeUserSymbol(.tUpper)))   // de-assign without any prior explicit definition

        #expect(ctx.userSymbolDefinition(for: .tUpper) == nil)
        #expect(ctx.isShorthandDeassigned(.tUpper))
    }

    @Test
    func tuneScope_override_predefinedShorthand_revertsAfterReset() {
        var ctx = ABCParser.Context()

        ctx.inTune = true
        ctx.update(with: .userDefined(makeUserSymbol(.tUpper, makeDecoration("mordent"))))

        #expect(ctx.userSymbolDefinition(for: .tUpper) == .decoration(makeDecoration("mordent")))

        ctx.resetTuneScope()

        #expect(ctx.userSymbolDefinition(for: .tUpper) == .decoration(makeDecoration("trill")))
    }

    @Test
    func deassignment_global_makesShorthandUndefined() {
        var ctx = ABCParser.Context()

        ctx.update(with: .userDefined(makeUserSymbol(.tUpper, makeDecoration("trill"))))
        ctx.update(with: .userDefined(makeUserSymbol(.tUpper)))   // de-assign

        #expect(ctx.userSymbolDefinition(for: .tUpper) == nil)
        #expect(ctx.isShorthandDeassigned(.tUpper))
    }

    @Test
    func deassignment_global_doesNotFallBackToPriorDefinition() {
        var ctx = ABCParser.Context()

        ctx.update(with: .userDefined(makeUserSymbol(.tUpper, makeDecoration("trill"))))
        ctx.update(with: .userDefined(makeUserSymbol(.tUpper)))   // de-assign

        ctx.inTune = true
        ctx.resetTuneScope()   // simulate new tune

        #expect(ctx.isShorthandDeassigned(.tUpper))
    }

    @Test
    func deassignment_tuneScope_shadowsGlobalDefinition() {
        var ctx = ABCParser.Context()

        ctx.update(with: .userDefined(makeUserSymbol(.tUpper, makeDecoration("trill"))))

        ctx.inTune = true
        ctx.update(with: .userDefined(makeUserSymbol(.tUpper)))   // de-assign at tune scope

        #expect(ctx.userSymbolDefinition(for: .tUpper) == nil)
        #expect(ctx.isShorthandDeassigned(.tUpper))
    }

    @Test
    func deassignment_tuneScope_clearedByResetTuneScope() {
        var ctx = ABCParser.Context()

        ctx.inTune = true
        ctx.update(with: .userDefined(makeUserSymbol(.tUpper)))   // de-assign at tune scope
        ctx.resetTuneScope()

        #expect(!ctx.isShorthandDeassigned(.tUpper))
        #expect(ctx.userSymbolDefinition(for: .tUpper) == .decoration(makeDecoration("trill")))
    }

    @Test
    func deassignment_reassignment_clearsDeassigned() {
        var ctx = ABCParser.Context()

        ctx.update(with: .userDefined(makeUserSymbol(.tUpper)))                          // de-assign
        ctx.update(with: .userDefined(makeUserSymbol(.tUpper, makeDecoration("trill")))) // re-assign

        #expect(!ctx.isShorthandDeassigned(.tUpper))
        #expect(ctx.userSymbolDefinition(for: .tUpper) != nil)
    }
}
