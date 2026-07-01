# Plan: Implement `ABCScoreBuilderProposal.md`

## Context

`IvorABC` today exposes a four-stage pipeline over a syntactic `ABCTunebook` AST:
`ABCParser` → `ABCNormalizer` → `ABCValidator` → `ABCFormatter`. That AST is
deliberately faithful to the source (written lengths, `.omitted` accidentals,
un-expanded `m:` macros, discrete tuplet/broken-rhythm/shorthand symbols) so it
round-trips through `ABCFormatter`. A consumer that wants to *play* or *render* a
tune needs the opposite: absolute durations, explicit accidentals, expanded
macros/shorthands, and decorations aggregated onto the notes they modify.

A first attempt lives parked and disabled (`#if false`) in
`Sources/IvorABC/Resolver/` — it mutated the AST via an `isResolved` flag (now
removed from `ABCTunebook`) and covered only lengths and accidentals. This work
replaces it with a new terminal pipeline branch, `ABCScoreBuilder`, that converts
a **validated** `ABCTunebook` into a standalone, non-serializable playback/render
model, `[ABCScore]`, without disturbing the existing four stages or round-trip
fidelity.

```
… ─Validator─▶ Tunebook ─┬─ABCFormatter───▶ Data       (faithful original)
                         └─ABCScoreBuilder─▶ [ABCScore] (playback / render)
```

### Scope decisions (settled)

- **`.optimizeForPlayback` is deferred entirely.** The `Options` set declares the
  case, but its transforms (tie coalescing, repeat/variant-ending/parts
  expansion, bar-line/meter/key dropping, tempo normalization) are a follow-up.
  This matches the proposal's own phases 1–6.
- **No `K:` `transpose=`/`octave=` pitch folding in the first cut.** Because it was
  only needed under `.optimizeForPlayback`, resolved pitches stay as-written
  (accidental made explicit, but not transposed). Revisit when playback
  optimization lands.

---

## Output model — `Sources/IvorABC/ScoreBuilder/`

All value types `Equatable` + `Sendable`, matching the house style seen in
`Sources/IvorABC/Symbol/*` (copyright header, `// MARK:` sections, `_isValid`
guards on failable inits, conformances in separate extensions).

### `ABCScoreDuration.swift` — new rational duration type
An absolute fraction of a whole note with **arbitrary** reduced
numerator/denominator (`Equatable` + `Comparable` + `Sendable`). Required because
tuplets scale by factors like 2/3 that `ABCLength` cannot hold — `ABCLength`'s
denominator must be a power of 2 in 1…512 (`Sources/IvorABC/Symbol/ABCLength.swift`).
- Store reduced `numerator`/`denominator` (use `UInt.gcd` from XestiTools, exactly
  as `ABCLength.init` does). No existing rational type exists in the repo or
  XestiTools, so this is genuinely new.
- API: failable/for-sure init, `*(fraction)` / multiply-by-`(num,den)`, `+` (for
  future tie coalescing), `Comparable`. Provide a bridge
  `init(length: ABCLength)` and a helper to multiply an `ABCLength` (written) by
  an `ABCLength` (unit) into `ABCScoreDuration`.

### `ABCScore.swift`
```swift
public struct ABCScore { public let events: [ABCScoreEvent] }
```
Self-contained per tune: event stream starts with file-header-derived events
(duplicated into every score), then the tune-header-derived events, then the
body — all in source order. Optional `title`/`referenceNumber` accessors that
scan `events` are not required for the first cut.

### `ABCScoreEvent.swift`
One flat ordered stream carrying **both** structural/metadata and fully-resolved
musical events, so a mid-tune `K:`/`M:`/`L:` change lands at the right position.
- Metadata / structural cases: `.referenceNumber`, `.title`, `.composer`,
  `.key(ABCKeySignature)`, `.meter(ABCTimeSignature)`,
  `.unitNoteLength(ABCLength)`, `.tempo(ABCTempo)`, `.voice(…)`, `.part(…)`,
  `.barLine(ABCBarLine)`, `.variantEnding(ABCVariantEnding)`, plus a generic
  `.field(ABCField)` passthrough for remaining header/inline fields, and a
  `.directive(ABCDirective)` case emitted only when `.stripDirectives` is absent.
- Musical: `.note(ABCScoreNote, ABCScoreAttachments)`,
  `.rest(ABCScoreRest, ABCScoreAttachments)`,
  `.chord(ABCScoreChord, ABCScoreAttachments)`.
- Final case list is confirmed against `ABCField` (`Sources/IvorABC/Field/ABCField.swift`)
  during phase 2; the shape above is the contract.

### `ABCScoreNote.swift` / `ABCScoreChord.swift` / `ABCScoreRest.swift`
- `ABCScoreNote` = resolved `ABCPitch` (explicit accidental, never `.omitted`) +
  `ABCScoreDuration` + `tie: ABCTie?` + slur start/end flags (`slurStart`/
  `slurEnd` bools, or a small enum — finalized in phase 2 from `ABCSlur`).
- `ABCScoreChord` = `[ABCScoreNote]` sharing one `ABCScoreDuration` + `tie`.
- `ABCScoreRest` = `ABCScoreDuration` + `isInvisible`. Multi-measure rests
  (`ABCRest.multiMeasure`) resolve to a concrete duration using the active meter.

### `ABCScoreGraceNotes.swift`
Resolved pitches + `ABCScoreDuration`s + `isSlashed`; ornamental (not part of the
main duration timeline).

### `ABCScoreAttachments.swift`
Aggregation payload folded onto the following note/chord/rest:
```swift
public struct ABCScoreAttachments {
    public let decorations: [ABCDecoration]      // incl. U:-resolved shorthands and .dot → staccato
    public let annotations: [ABCAnnotation]
    public let graceNotes: ABCScoreGraceNotes?
    public let chordSymbol: ABCChordSymbol?
}
```

---

## Producer — `ABCScoreBuilder`

### `ABCScoreBuilder.swift` (public façade)
Mirrors `ABCFormatter`/`ABCValidator` exactly (stateless `init()`, work delegated
to an internal worker seeded with the tunebook):
```swift
public struct ABCScoreBuilder: Sendable {
    public init() {}
    public func build(_ tunebook: ABCTunebook,
                      options: Options = []) throws -> [ABCScore]
}
```
Precondition mirrors `ABCFormatter.format` (`Sources/IvorABC/Formatter/ABCFormatter.swift:29`):
`guard tunebook.isValidated else { throw Error.notValidated }`, then
`Builder(tunebook:options:).buildScores()`.

### `ABCScoreBuilder.Options.swift`
`OptionSet` (extensible). First cut:
- `.ignoreErrors` — skip the offending event instead of throwing on a
  resolution/expansion failure.
- `.stripDirectives` — omit `.directive` events.
- `.optimizeForPlayback` — **declared but not yet implemented** (deferred). Either
  make `build` throw a clear "unsupported" error when set, or silently no-op;
  recommend throwing so the gap is explicit. (Confirm during phase 2.)

Deferred/anticipated (documented, not added): `.stripFileHeader`,
`.stripAnnotations`, `.stripDecorations`.

### `ABCScoreBuilder.Error.swift`
`EnhancedError` enum following `Sources/IvorABC/Validator/ABCValidator.Error.swift`
and `Sources/IvorABC/Parser/ABCParser.Error.swift` (category `"IvorABC"`,
`message`, `Equatable`, `Sendable`). Cases: `.notValidated`,
`.unrepresentableDuration(…)`, `.unresolvableMacro(…)` (associated `Substring`/
description as the parser errors do), and — if `.optimizeForPlayback` throws —
`.unsupportedOption`. Each throws unless `.ignoreErrors` is set (except
`.notValidated`, which always throws).

### `Internal/ABCScoreBuilder.Builder.swift` + running `State`
Salvage the traversal skeleton and unit-note-length defaulting from the parked
`Sources/IvorABC/Resolver/Internal/ABCResolver.Resolver.swift` — reuse
`_scanDefaults`, `_applyField`, `_effectiveUnitNoteLength`, `_unitNoteLength(from:)`
and the per-tune / per-body / per-symbol structure — but **emit events** instead of
rebuilding an AST, and drop the `isResolved` flag entirely.

Running `State` carries:
- `unitNoteLength: ABCLength?`, `meter: ABCTimeSignature?`,
  `keySignature: ABCKeySignature?` (seeded from file header, then tune header,
  exactly as the parked resolver does),
- an `ABCAccidentalContext` (reset on bar lines, rebuilt on any `K:` change),
- the active macro table (`m:` definitions in force),
- the active `U:` table (shorthand → `ABCUserSymbol.Definition`),
- pending **tuplet** scope (next *affectedCount* notes scaled by beat/note),
- pending **broken-rhythm** marker (adjusts the flanking pair),
- pending **attachments** (leading decorations/annotations/grace-notes/chord-
  symbols awaiting the next note/chord/rest).

---

## Resolution semantics (per note/chord/rest, in order)

1. **Macro expansion** (first — macros before `U:`; see below).
2. **Shorthand resolution** — each `ABCShorthand` except `.dot` maps to its
   `ABCUserSymbol.Definition` (decoration or annotation) from the active `U:`
   table → pending attachments; `.dot` becomes the fixed staccato
   `ABCDecoration`. (`ABCShorthand`, `ABCUserSymbol`, `ABCUserSymbol.Definition`.)
3. **Accidental resolution** — **reuse `ABCAccidentalContext`**
   (`resolveAccidental(for:)` then `update(with:)` per note; `reset()` on bar
   lines). Produces an explicit `ABCPitch.Accidental` for every note (chords and
   grace notes included). *Relocate `ABCAccidentalContext.swift` from `Field/` into
   `ScoreBuilder/`* (plus its test file — see below).
4. **Length resolution** — base absolute = written length × effective unit note
   length, in `ABCScoreDuration` space (reuse the parked resolver's
   `_effectiveUnitNoteLength`/`_unitNoteLength(from:)` defaulting: explicit `L:`,
   else derive from `M:` — `1/16` when `standard.doubleValue < 0.75`, else `1/8`).
   Then:
   - **Tuplets** — reuse `ABCTuplet.resolve(meter:)`
     (`Sources/IvorABC/Symbol/ABCTuplet.swift`) to get
     `(noteCount, beatCount, affectedCount)`; scale each affected note by
     `beatCount / noteCount`. The `.tuplet` symbol is consumed (drives
     pending-tuplet state), not emitted.
   - **Broken rhythms** — a `.brokenRhythm` symbol adjusts the flanking pair.
     Reuse the factor/formula semantics from `ABCBrokenRhythm`
     (`resolve(left:right:)` / its `factor`) but compute in `ABCScoreDuration`
     space so the power-of-2 limitation disappears. (May add a
     `ABCScoreDuration`-returning variant rather than mutating the existing
     `ABCLength`-based method, to keep that symbol API untouched.)

---

## Macro expansion (single-pass, no up-front text rewrite)

Keep `ABCFormatter` round-tripping the original `m:` lines by **not** expanding
text up front. Instead pre-parse macros in the parser and expand symbol-wise in
the builder.

**Parser change (additive, internal)** — `Field/ABCMacro.swift` +
`Parser/Internal/ABCParseFunctions.swift` (`parseMacro`, line ~464):
- `ABCMacro` keeps its public `target`/`replacement` strings and its
  string-only `Equatable` (internal forms are a deterministic function of the
  strings, so consumers/formatter are unaffected). Add **internal** pre-parsed
  properties + an internal `ABCMacro.Kind` (static/transposing) and a template
  element type.
  - **Static** (target has no `n`): target → literal `[ABCSymbol]` subsequence to
    match; replacement → `[ABCSymbol]`.
  - **Transposing** (target ends with `n<length>`): target → match pattern with
    the `n` note-slot + required written length; replacement → template whose note
    slots are `(diatonicOffset, writtenLength)` placeholders. Needs a small
    **macro-aware fragment parser**, because the relative-pitch placeholder
    letters `h`–`z` are not valid ABC pitches; non-note constructs (grace braces,
    decorations, bar lines) parse via the existing functions.
- An un-parseable transposing replacement fails as today via
  `ABCParser.Error.invalidMacro`.

**Builder expansion** — while walking the body symbol stream, match each active
macro's target pattern against the symbol subsequence: static → splice the
pre-parsed replacement symbols; transposing → instantiate the template against the
matched note's pitch (apply each placeholder's `diatonicOffset` diatonically over
`ABCPitch.Letter`/`ABCPitch.Octave`). Spliced symbols then flow through
shorthand → accidental → length resolution normally.

---

## Aggregation

Leading `.decoration`, `.annotation`, `.graceNotes`, `.chordSymbol` symbols (and
`U:`-resolved shorthands, `.dot`) accumulate in pending attachments and are folded
onto the next `.note`/`.chord`/`.rest`, emitted as the second tuple element of the
musical event. `.slur`/`.beamBreak`/`.overlay` handling per phase-2 finalization
(slur flags onto notes; beam-break likely dropped or a structural event).

---

## File & folder layout

**New — `Sources/IvorABC/ScoreBuilder/`:**
`ABCScore.swift`, `ABCScoreEvent.swift`, `ABCScoreNote.swift`,
`ABCScoreChord.swift`, `ABCScoreRest.swift`, `ABCScoreGraceNotes.swift`,
`ABCScoreAttachments.swift`, `ABCScoreDuration.swift`, `ABCScoreBuilder.swift`,
`ABCScoreBuilder.Options.swift`, `ABCScoreBuilder.Error.swift`,
`Internal/ABCScoreBuilder.Builder.swift` (+ macro/tuplet/broken-rhythm helper
files as needed), and `ABCAccidentalContext.swift` (relocated from `Field/`).

**Touched existing:** `Field/ABCMacro.swift` (internal pre-parsed props +
`Kind`/template types), `Parser/Internal/ABCParseFunctions.swift` (`parseMacro`
+ macro-aware fragment parse).

**Removed (parked resolver, superseded):**
`Sources/IvorABC/Resolver/ABCResolver.swift`,
`Sources/IvorABC/Resolver/Internal/ABCResolver.Resolver.swift`,
`Tests/IvorABCTests/Resolver/ABCResolverTests.swift`. Also remove the parked
`#if false` `resolve(unitNoteLength:)` block in `Symbol/ABCNote.swift`
(lines ~39–62). Salvage first, delete last.

Apply the **jgp-copyright** skill's header (`© 2026 John Gary Pusey (see
LICENSE.md)`) to every new source file.

---

## Testing — `Tests/IvorABCTests/ScoreBuilder/`

Swift Testing (`import Testing`, `@testable import IvorABC`), mirroring source
layout. Follow project conventions: `struct XTests {}` + an `extension` of `@Test`
methods, **no `test_` prefix**, qualify with `IvorABC.` only on a name collision.
Reuse and extend the `make*`/`expect*` factories in
`Tests/IvorABCTests/TestHelpers/HelperFunctions.swift`, adding `make*` factories
for the new score types. Use American spellings in doc comments.

Coverage:
- `ABCScoreDuration` arithmetic + reduction incl. non-power-of-2 denominators.
- Length resolution: plain notes, broken rhythms, tuplets (esp. 3-in-2 giving
  1/12), multi-measure rests.
- Accidental resolution end-to-end (relocate `ABCAccidentalContextTests`
  alongside its type; keep its behaviour green).
- Shorthand → decoration/annotation via `U:`; `.dot` → staccato.
- Macro expansion: static and transposing (several note lengths/pitches); confirm
  `ABCFormatter` still emits the **original** `m:` lines from the same tunebook.
- Aggregation: leading decorations/annotations/grace-notes/chord-symbols fold onto
  the following note/chord/rest.
- Options: `.ignoreErrors` (skip vs throw), `.stripDirectives`, and (if it throws)
  `.optimizeForPlayback` → `.unsupportedOption`.
- `build` throws `.notValidated` for a non-validated tunebook.

---

## Suggested implementation phases

1. `ABCScoreDuration` + the model types (`ABCScore`/`ABCScoreEvent`/note/chord/
   rest/grace/attachments) + test helpers.
2. `ABCScoreBuilder` skeleton (API, `Options`, `Error`, `notValidated`
   precondition) + `Builder` traversal salvaged from the parked resolver, emitting
   structural/metadata events and un-resolved musical events. Finalize the exact
   `ABCScoreEvent` case list and note/attachments field composition here.
3. Length resolution: absolute durations, tuplets, broken rhythms.
4. Accidental resolution (relocate `ABCAccidentalContext` + its tests) + shorthand
   resolution + aggregation.
5. Macro pre-parsing in the parser (`ABCMacro` internals + macro-aware fragment
   parse) and builder-side expansion (static, then transposing).
6. Remove the parked `Resolver` sources/tests and parked `ABCNote` block; final
   `make lint && make test`.

(`.optimizeForPlayback` transforms and `transpose=`/`octave=` pitch folding are a
deferred follow-up beyond these phases.)

---

## Verification

- Run `make lint` and `make test` (the **spm-validate** skill). Both must pass with
  no new warnings.
- End-to-end smoke check: parse → normalize → validate a small tunebook containing
  a tuplet, a broken rhythm, an omitted accidental, a `U:`-defined shorthand, and
  both a static and a transposing macro; assert the resulting `[ABCScore]` events
  have absolute durations, explicit accidentals, expanded macros, and correct
  aggregation — while a parallel `ABCFormatter` call on the **same** tunebook
  reproduces the original source (round-trip untouched).
