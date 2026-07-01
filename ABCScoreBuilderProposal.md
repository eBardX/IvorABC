# Proposal: `ABCScore` + `ABCScoreBuilder`

## Context

`IvorABC` currently exposes a four-stage pipeline over an ABC tunebook —
`ABCParser` → `ABCNormalizer` → `ABCValidator` → `ABCFormatter` — all operating on
the same *syntactic* `ABCTunebook` AST (see `Sources/IvorABC/Parser`,
`Normalizer`, `Validator`, `Formatter`). That AST is deliberately faithful to the
ABC source: note/rest/chord lengths are *written* multipliers of the unit note
length, pitch accidentals are recorded exactly as written
(`ABCPitch.Accidental.omitted` when none appears), macros are preserved
un-expanded as `m:` fields, and shorthands/broken-rhythms/tuplets are kept as
discrete symbols. This is exactly what round-tripping through `ABCFormatter`
requires.

An external consumer that wants to *play* or *render* a tune needs the opposite:
a fully **resolved and expanded** form where every length is absolute, every
accidental is explicit, macros and shorthands are expanded, and the disparate
symbols that decorate a note are aggregated onto it. The repo already contains a
**parked** first attempt at this
(`Sources/IvorABC/Resolver/ABCResolver.swift`, disabled via `#if false`), but it
mutated the AST in place (`isResolved` flag) and covered only lengths and
accidentals — no macros, tuplets, broken rhythms, shorthands, or aggregation.

This proposal replaces that parked work with a new, standalone stage that
converts a **validated** `ABCTunebook` into a playback/render-ready model —
`ABCScore` — without disturbing the existing four stages or the AST's round-trip
fidelity.

The design below was settled collaboratively.

## Goals & scope

In scope for the first cut:

1. A new output model, **`ABCScore`** (one per tune), and a producer,
   **`ABCScoreBuilder`**, that takes a validated tunebook and returns
   `[ABCScore]`.
2. Full **note-length resolution** to absolute durations — notes, grace notes,
   rests, chords — including **broken rhythms** and **tuplets**.
3. **Accidental resolution** — every `.omitted` accidental resolved to an
   explicit accidental per the key signature and within-bar propagation.
4. **Shorthand resolution** — every shorthand except `.dot` resolved to the
   decoration/annotation it maps to (via `U:` / `ABCUserSymbol`).
5. Full **macro expansion** — static *and* transposing — driven by fragments the
   parser pre-parses into internal `ABCMacro` properties (see
   [Macro expansion](#macro-expansion)).
6. **Aggregation** — decorations, annotations, grace notes, and chord symbols
   that precede a note/chord/rest are folded onto it.

Explicitly **not** in scope (and why):

- No changes to `ABCParser`'s public API, nor to `ABCNormalizer`,
  `ABCValidator`, or `ABCFormatter` behaviour. The only parser change is
  additive and internal (pre-parsing macro fragments; see below).
- `ABCScore` is **not** re-serializable and has no relationship to
  `ABCFormatter`. The AST remains the single source of truth for formatting.

## Pipeline placement

```
Data ─ABCParser─▶ Tunebook ─Normalizer─▶ Tunebook ─Validator─▶ Tunebook ─┬─ABCFormatter──▶ Data      (faithful original)
                                                                          └─ABCScoreBuilder▶ [ABCScore] (playback / render)
```

`ABCScoreBuilder` is a **terminal branch** off the *validated* tunebook, a sibling
of `ABCFormatter`. A single pass through the pipeline yields both a faithful
normalized/validated copy of the original *and* a score — no double-pass, no
"tainted" data. `ABCScoreBuilder` requires `tunebook.isValidated == true` and
throws otherwise, mirroring `ABCFormatter`'s precondition.

## Output model

New value types, all `Equatable` + `Sendable`, living in
`Sources/IvorABC/ScoreBuilder/`.

### `ABCScore`

One resolved tune. Self-contained: its event stream starts with the
file-header-derived events (duplicated into every score, unless
`.stripDirectives` and future strip options remove them), followed by the tune's
own header-derived events, then the body — all in **source order**.

```swift
public struct ABCScore {
    public let events: [ABCScoreEvent]
}
```

(Optional convenience computed accessors such as `title` / `referenceNumber` may
scan `events`; not required for the first cut.)

### `ABCScoreEvent`

A single flat, ordered stream carrying **both** structural/metadata concepts and
fully-resolved musical events, so a mid-tune `K:`/`M:`/`L:` change or inline
field lands at the correct position. Proposed cases (music-affecting and
structural concepts get dedicated cases; remaining metadata fields fall through
a generic case to keep the enum manageable):

- Metadata / structural: `.referenceNumber`, `.title`, `.composer`,
  `.key(ABCKeySignature)`, `.meter(ABCTimeSignature)`,
  `.unitNoteLength(ABCLength)`, `.tempo(ABCTempo)`, `.voice(…)`, `.part(…)`,
  `.barLine(ABCBarLine)`, `.variantEnding(ABCVariantEnding)`,
  `.field(ABCField)` (generic passthrough for other header/inline fields).
  `%%directive` events are emitted only when `.stripDirectives` is absent.
- Musical (resolved + aggregated): `.note(ABCScoreNote, ABCScoreAttachments)`,
  `.rest(ABCScoreRest, ABCScoreAttachments)`,
  `.chord(ABCScoreChord, ABCScoreAttachments)`.

The exact case list is a detail to finalize during implementation; the shape
above is the contract.

### `ABCScoreNote`, `ABCScoreChord`, `ABCScoreRest`

- `ABCScoreNote` = resolved `ABCPitch` (explicit accidental, never `.omitted`) +
  `ABCScoreDuration` + `tie` + slur start/end flags.
- `ABCScoreChord` = `[ABCScoreNote]` sharing one `ABCScoreDuration` + `tie`.
- `ABCScoreRest` = `ABCScoreDuration` + `isInvisible`. Multi-measure rests are
  resolved to a concrete duration using the active meter.

### `ABCScoreAttachments`

The aggregation payload folded onto the following note/chord/rest:

```swift
public struct ABCScoreAttachments {
    public let decorations: [ABCDecoration]     // includes shorthands resolved via U:, and .dot → staccato
    public let annotations: [ABCAnnotation]
    public let graceNotes: ABCScoreGraceNotes?  // resolved pitches + durations; ornamental
    public let chordSymbol: ABCChordSymbol?
}
```

### `ABCScoreDuration`

A **new rational duration type** — an absolute fraction of a whole note with an
**arbitrary** numerator/denominator (reduced), `Equatable` + `Comparable` +
`Sendable`. This is required because tuplets scale durations by factors such as
2/3, which `ABCLength` **cannot** represent (its denominator must be a power of
2, 1–512; see `Sources/IvorABC/Symbol/ABCLength.swift`). `ABCScoreDuration`
supports the rational arithmetic (multiply by a fraction) the builder needs to
combine written length × unit note length × broken-rhythm factor × tuplet
factor.

## Producer: `ABCScoreBuilder`

Public façade mirrors the established pattern (stateless `init()`, work delegated
to an internal worker initialized with the tunebook — as `ABCNormalizer` /
`ABCValidator` do, and as the parked `ABCResolver.Resolver` did):

```swift
public struct ABCScoreBuilder: Sendable {
    public init() {}
    public func build(_ tunebook: ABCTunebook,
                      options: Options = []) throws -> [ABCScore]
}
```

### `ABCScoreBuilder.Options`

An `OptionSet` (extensible by design). First cut:

- `.ignoreErrors` — continue past resolution/expansion problems (e.g. an
  unrepresentable duration, an unresolvable macro) instead of throwing, skipping
  the offending event.
- `.stripDirectives` — omit `%%directive` events from each score.
- `.optimizeForPlayback` — post-process the resolved event stream into a
  **flattened, literal, time-linear** form suited to an *unsophisticated*
  playback consumer — think of feeding an `ABCScore` to a MIDI-sequence
  generator that knows nothing of notation. The transform assumes the player
  understands only sounding events (notes, rests, durations) in strict temporal
  order, so everything that exists purely for notation or navigation is either
  discarded or resolved away:
  - **Tied notes coalesced** — a note tied to the following note (matching
    pitch, `tie` set) is merged into a single `.note` whose `ABCScoreDuration`
    is the sum of the tied durations.
  - **Repeats expanded** — repeat sections are unrolled inline so each repeated
    pass appears literally in the stream (no repeat bar lines remain).
  - **Variant endings expanded** — variant endings (`|1`, `|2`, …) are resolved
    into the correct concrete sequence across passes.
  - **Parts sequence applied** — an explicit `P:` parts ordering is flattened
    into the literal concatenation of its referenced parts.
  - **Bar lines and beam breaks dropped** — bar lines and beam-break markers
    carry no sounding effect and are removed.
  - **Key signature dropped** — the key signature is a resolution *input*,
    fully consumed upstream by accidental resolution: every note's accidental is
    already explicit, so pitches are fully determined and a literal player (which
    works in absolute pitches) has no use for a residual `K:`. *Caveat:* a `K:`
    may also carry `transpose=` / `octave=` modifiers that shift **sounding**
    pitch; those must be applied to the pitches before the event is dropped, or
    playback pitch is wrong (see [Open / deferred items](#open--deferred-items)).
  - **Meter / time signature dropped** — likewise a resolution input, consumed
    when the builder resolves tuplets (`ABCTuplet.resolve(meter:)`) and
    multi-measure rests into absolute durations. Once durations are absolute and
    bar lines are gone, a literal player has no use for the meter.
  - **Tempo retained, normalized** — tempo is the one piece of metadata a
    literal player genuinely needs, since it maps abstract durations to
    wall-clock time; it does **not** depend on the meter. It *does* depend on a
    reference note length: `Q:1/4=120` is self-contained, but the bare form
    `Q:120` is defined relative to the unit note length (`L:`), which this pass
    drops. So each tempo is normalized to an explicit `refLength=bpm` form,
    removing its dependency on the (now-absent) `L:`. Mid-tune tempo changes stay
    in stream position.

  The exact set is finalized during implementation; the guiding principle is
  that the result must be *maximally literal* — the player is assumed to do no
  interpretation of its own.

(Deferred but anticipated: `.stripFileHeader`, `.stripAnnotations`,
`.stripDecorations`. The `OptionSet` is trivially grown later.)

### `ABCScoreBuilder.Error`

An `EnhancedError` enum following `ABCParser.Error` /
`Sources/IvorABC/Validator/ABCValidator.Error.swift`. At minimum
`.notValidated`, plus resolution/expansion failures such as
`.unrepresentableDuration(…)` and `.unresolvableMacro(…)`. Each throws unless
`.ignoreErrors` is set.

### Internal worker + running state

`ABCScoreBuilder.Builder(tunebook:options:)` walks each tune, closely following
the parked `ABCResolver.Resolver` traversal
(`Sources/IvorABC/Resolver/Internal/ABCResolver.Resolver.swift`) — reuse its
`_scanDefaults` / `_applyField` / per-tune / per-body / per-symbol structure —
extended with the additional resolution passes. Running `State` carries:

- `unitNoteLength: ABCLength?`, `meter: ABCTimeSignature?`,
  `keySignature: ABCKeySignature?` (seeded from the file header, then the tune
  header, exactly as the parked resolver does),
- an `ABCAccidentalContext` (reset on bar lines, rebuilt on any `K:` change),
- the active macro table (`m:` definitions in force),
- pending **tuplet** scope ("next *affectedCount* notes are scaled"),
- pending **broken-rhythm** marker (adjusts the flanking pair),
- pending **attachments** (leading decorations/annotations/grace-notes/chord-
  symbols awaiting the next note/chord/rest).

## Resolution semantics

Applied per note/chord/rest, in this order:

1. **Macro expansion** (first, per spec §9 ordering — macros before `U:`). See
   [below](#macro-expansion).
2. **Shorthand resolution** — each `ABCShorthand` except `.dot` is mapped to its
   `ABCUserSymbol.Definition` (decoration or annotation) from the active `U:`
   table and added to the pending attachments; `.dot` becomes the fixed staccato
   decoration.
3. **Accidental resolution** — **reuse `ABCAccidentalContext`**
   (`Sources/IvorABC/Field/ABCAccidentalContext.swift`): `resolveAccidental(for:)`
   then `update(with:)` per note, `reset()` on bar lines. Produces an explicit
   `ABCPitch.Accidental` for every note (chords and grace notes included).
   *Relocate `ABCAccidentalContext` from `Field/` into `ScoreBuilder/` as a
   resolution helper.*
4. **Length resolution** — base absolute duration = written length × effective
   unit note length (reuse the parked resolver's `_effectiveUnitNoteLength` /
   `_unitNoteLength(from:)` defaulting rules), computed in `ABCScoreDuration`
   space. Then:
   - **Tuplets** — reuse `ABCTuplet.resolve(meter:)`
     (`Sources/IvorABC/Symbol/ABCTuplet.swift`) to obtain
     `(noteCount, beatCount, affectedCount)`; scale each affected note by
     `beatCount / noteCount`. The `.tuplet` symbol itself is consumed (not
     emitted as an event) and drives the pending-tuplet state.
   - **Broken rhythms** — a `.brokenRhythm` symbol adjusts the durations of the
     flanking pair. Move this computation under the builder and perform it in
     `ABCScoreDuration` space, reusing the
     factor/formula semantics from
     `Sources/IvorABC/Symbol/ABCBrokenRhythm.swift` (`resolve(left:right:)`);
     the rational type removes that method's power-of-2 limitation.

## Macro expansion

Per ABC 2.1 §9, macros are conceptually a text search-and-replace performed
*before* parsing and *before* `U:` expansion. To keep the pipeline single-pass
and preserve `ABCFormatter` round-tripping of the original `m:` lines, we do
**not** expand text up front. Instead:

**Parser change (additive, internal).** Extend `parseMacro`
(`Sources/IvorABC/Parser/Internal/ABCParseFunctions.swift`) so that, alongside
the verbatim public `target`/`replacement` strings, `ABCMacro`
(`Sources/IvorABC/Field/ABCMacro.swift`) also stores **internal** pre-parsed
forms:

- **Static macro** (target contains no `n`): target parsed to a literal symbol
  subsequence to match; replacement parsed to `[ABCSymbol]`.
- **Transposing macro** (target concludes with `n<length>`): target parsed to a
  match pattern identifying the `n` note-slot and its required written length;
  replacement parsed by a small **macro-aware fragment parser** into a
  *template* whose note slots are `(diatonicOffset, writtenLength)` placeholders
  (the letters `h`–`z` are relative-pitch placeholders, **not** valid ABC
  pitches, so the normal note parser cannot handle them). Non-note constructs
  (grace braces, decorations, bar lines) parse normally.

`ABCMacro`'s public API and `Equatable` stay defined **only** by the two strings
(the internal forms are a deterministic function of them), so consumers and the
formatter are unaffected. Introduce internal supporting types, e.g.
`ABCMacro.Kind` (static/transposing) and a template element type. An
un-parseable transposing replacement (e.g. one using accidentals, which the spec
disallows) fails as today via `ABCParser.Error.invalidMacro`.

**Builder expansion.** While walking the body symbol stream, the builder matches
each active macro's target pattern against the symbol subsequence: static →
splice in the pre-parsed replacement symbols; transposing → instantiate the
template against the matched note's pitch (each placeholder's `diatonicOffset`
applied diatonically). The spliced symbols then flow through shorthand →
accidental → length resolution normally (macros-before-`U:` ordering preserved).

## File & folder layout

New folder `Sources/IvorABC/ScoreBuilder/`:

- `ABCScore.swift`, `ABCScoreEvent.swift`, `ABCScoreNote.swift`,
  `ABCScoreChord.swift`, `ABCScoreRest.swift`, `ABCScoreGraceNotes.swift`,
  `ABCScoreAttachments.swift`, `ABCScoreDuration.swift`
- `ABCScoreBuilder.swift`, `ABCScoreBuilder.Options.swift`,
  `ABCScoreBuilder.Error.swift`
- `Internal/ABCScoreBuilder.Builder.swift` (+ any macro/tuplet/broken-rhythm
  helper files)
- `ABCAccidentalContext.swift` (relocated from `Field/`)

Touched existing files: `Field/ABCMacro.swift` (internal pre-parsed properties),
`Parser/Internal/ABCParseFunctions.swift` (`parseMacro` + macro-aware fragment
parse).

## Disposition of the parked resolver

The parked `ABCResolver` is superseded and should be **removed**:
`Sources/IvorABC/Resolver/` (both files) and
`Tests/IvorABCTests/Resolver/ABCResolverTests.swift`. Salvage the traversal
skeleton and the unit-note-length defaulting helpers into the new
`ABCScoreBuilder.Builder` before deleting. (Note: the parked code references an
`isResolved` flag that no longer exists on `ABCTunebook`; the new design does not
reintroduce it — the score is a separate model, not a flagged AST.)

## Testing

Swift Testing (`import Testing`, `@testable import IvorABC`), new folder
`Tests/IvorABCTests/ScoreBuilder/` mirroring the source layout. Follow the existing
conventions: `struct XTests {}` + an extension of `@Test` methods, reuse the
`make*` factories in `Tests/IvorABCTests/TestHelpers/HelperFunctions.swift`
(adding `make*` factories for the new score types), and honor the project's test
naming convention (no `test_` prefix; qualify with `IvorABC.` only when a method
name collides with a global function).

Coverage to add:

- `ABCScoreDuration` arithmetic and reduction, incl. non-power-of-2 denominators.
- Length resolution: plain notes, broken rhythms, tuplets (esp. 3-in-2 giving
  1/12 durations), multi-measure rests.
- Accidental resolution end-to-end (leaning on existing
  `ABCAccidentalContextTests` behaviour after relocation).
- Shorthand → decoration/annotation via `U:`; `.dot` → staccato.
- Macro expansion: static and transposing (round several note lengths and
  pitches); confirm the formatter still emits the **original** `m:` lines from
  the same tunebook (round-trip untouched).
- Aggregation: leading decorations/annotations/grace-notes/chord-symbols fold
  onto the following note/chord/rest.
- Options: `.ignoreErrors` (skips vs throws) and `.stripDirectives`.
- `build` throws `.notValidated` for a non-validated tunebook.

## Verification

Run `make lint` and `make test` (the `spm-validate` skill). Both must pass with
no new warnings. For an end-to-end smoke check, parse → normalize → validate a
small tunebook containing a tuplet, a broken rhythm, an omitted accidental, a
`U:`-defined shorthand, and both a static and a transposing macro, then assert
the resulting `[ABCScore]` events have absolute durations, explicit accidentals,
expanded macros, and correct aggregation — while a parallel `ABCFormatter` call
on the same tunebook reproduces the original source.

## Suggested implementation phases

1. `ABCScoreDuration` + the `ABCScore`/`ABCScoreEvent`/note/chord/rest/attachment
   model types (+ test helpers).
2. `ABCScoreBuilder` skeleton (API, `Options`, `Error`, `notValidated`
   precondition) + `Builder` traversal salvaged from the parked resolver,
   emitting structural/metadata events and un-resolved musical events.
3. Length resolution: absolute durations, tuplets, broken rhythms.
4. Accidental resolution (relocate `ABCAccidentalContext`) + shorthand
   resolution + aggregation.
5. Macro pre-parsing in the parser (`ABCMacro` internals + macro-aware fragment
   parse) and builder-side expansion (static, then transposing).
6. Remove the parked `Resolver` sources/tests; final `make lint && make test`.

## Open / deferred items

- Exact final `ABCScoreEvent` case list and the precise field composition of
  `ABCScoreNote` / `ABCScoreAttachments` (slur/tie representation in particular)
  — settle during phase 1–2.
- Additional strip options (`.stripFileHeader`, `.stripAnnotations`,
  `.stripDecorations`) — deferred; `OptionSet` is designed to grow.
- The precise set of transforms performed by `.optimizeForPlayback` (beyond the
  listed tied-note coalescing, repeat/variant-ending/parts expansion, and bar
  line/beam-break dropping) — finalize during implementation.
- **`K:` `transpose=` / `octave=` and sounding pitch.** These modifiers shift
  the pitch actually heard, so `.optimizeForPlayback` cannot simply drop the
  `K:` event without first folding them into the resolved pitches. Open decision:
  whether pitch resolution should apply `transpose`/`octave` **always** (the
  score's pitches are then the true sounding pitches for every consumer) or
  **only** under `.optimizeForPlayback` (leaving the un-optimized score's pitches
  as written, closer to the notation). Settle before implementing the playback
  optimizations.
