# Parser Implementation Plan

This plan covers the parser-facing work needed to handle legacy ABC files as
described in `parsing-legacy-abc-files.md`. It is the agreed starting point;
broader formatter work and public-API polish follow from it. (Normalization and
validation — `normalized()` / `validated()` — are specified here in Phase 4.)

The current public API is not fixed. This plan already settles several changes:
the `ABCParser.Strictness` model is retired (Phase 3), `migrate()` becomes
`normalized()`, `validate()` becomes a throwing `validated()` returning a
`(ABCTunebook, [ABCValidationIssue])` pair, `ABCTunebook` gains `isNormalized` /
`isValidated` guarantee tokens, and `ABCTunebook.version` becomes optional.

## Goals: Two Use Cases

The parser must serve two distinct uses of an arbitrary input file. **Use case
(1) takes precedence over use case (2): the strict-2.1 guarantee must never be
compromised to preserve legacy detail.**

1. **Normalized** — Parsing yields an absolutely strict, 2.1-conformant model.
   This implies strict interpretation for 2.1-versioned files and loose
   interpretation for older-versioned or unversioned files. Any legacy syntax is
   converted to its 2.1 equivalent.

2. **Faithful** — Parsing yields a model that preserves legacy syntax and
   semantics well enough that an external dump program (built on IvorABC) can
   output a reasonable semblance of the original file. Legacy decoration syntax,
   deprecated fields, and the like **are** preserved. Comments and whitespace
   are **not** preserved.

## Two Orthogonal Axes

The two use cases are not points on a single strict-to-loose scale. They are a
second axis, independent of interpretation:

| Axis | Values | Controlled by | Decides |
|---|---|---|---|
| **Interpretation** | strict / loose | version (derived) | malformed input → *error* vs *recover* |
| **Fidelity** | normalized / faithful | the two use cases above | legacy constructs → *converted to 2.1* vs *preserved* |

Interpretation is derived from the detected version in both use cases: a 2.1 file
is read strictly and a 1.6/2.0/unversioned file loosely, regardless of which
fidelity is wanted. The axes only diverge on legacy input; for clean 2.1 input,
normalized and faithful produce the same model.

Interpretation is **not overridable** in the initial design (see *Deferred:
Interpretation Override* below).

## Architecture: Faithful Parse + Normalize

- **The parser always produces a faithful, version-tagged model** — preserving
  deprecated fields (`E:`, 1.6 `I:`), legacy decoration dialect (`+…+`), and
  legacy (bare / `C=`) tempo, tagged with the detected version. This is use case
  (2)'s output directly.
- **A normalization operation transforms that faithful model into a *legacy-free
  2.1* model** — converting every legacy construct to its 2.1 equivalent.
  **`validated()`** then confirms structural validity, producing the fully
  strict-2.1-conformant (`isValidated`) result.

So **use case 1 = parse → normalized() → validated(); use case 2 = parse.**

This split (rather than a `fidelity:` flag on the parser) is chosen because:

- It makes the precedence enforceable as a single design rule: **the parser may
  only preserve a legacy construct if normalization knows how to convert it.** If
  a construct cannot be normalized, it is not preserved — which is exactly how
  "(1) takes precedence over (2)" is honored.
- Normalization gives a *legacy-free 2.1* model; structural validity is a
  *separate* check (`validated()`). The full strict-2.1-conformance guarantee is
  `isNormalized && isValidated` (see Phase 4) — `normalized()` alone does not
  guarantee validity.
- It keeps the parser single-purpose and composable. A thin convenience wrapper
  over the `parse → normalized() → validated()` pipeline can sit on top if desired.

**Model representation:** one `ABCTunebook` type throughout, with maintained
invariants (and the guarantee tokens below) rather than a type-level split
between "faithful" and "2.1-only" models.

## Design Decisions

- **Interpretation derived from version, not overridable.** It follows the spec
  rule (≥ 2.1 ⇒ strict; ≤ 2.0 or unversioned ⇒ loose) with no public knob. Both
  use cases pin interpretation to this derived value, so an override is not
  required (see *Deferred: Interpretation Override*).
- **Parser owns the full encoding cascade** from `Data`: strip BOM, honor the
  `%abc` version and `abc-charset` directive, fall back to Latin-1. Supports the
  full spec set: `iso-8859-1` through `iso-8859-10`, `us-ascii`, `utf-8`.
- **Unversioned input** → loose "legacy union" stance: accept the union of legacy
  and modern syntax and recover liberally. The model records this as a `nil`
  version (see below) rather than a pinned number.
- **One model type** (`ABCTunebook`). `version` becomes optional (`ABCVersion?`),
  where `nil` denotes an unversioned file; `ABCVersion` itself stays a concrete
  struct. Maintained invariant: an `isNormalized` tunebook always has a non-`nil`
  version (2.1).
- **Two guarantee tokens.** Public read-only `ABCTunebook.isNormalized` and
  `ABCTunebook.isValidated`, both `false` by default (manual construction *and*
  parsing). `isNormalized` ⇒ *legacy-free 2.1* (set by `normalized()` or the
  parser). `isValidated` ⇒ *structurally valid* (set by `validated()`), and it
  **requires** `isNormalized`, so `isValidated ⇒ isNormalized`. Together,
  `isValidated == true` is the single full strict-2.1-conformance token (use case
  1's output). See Phase 4.
- **Normalization is `normalized()`** — a non-mutating method returning a new,
  legacy-free-2.1 `ABCTunebook` (the rename of today's `migrate()`), which returns
  `self` when the input is already `isNormalized`.
- **Validation is `validated()`** — `throws -> (ABCTunebook, [ABCValidationIssue])`;
  throws `ABCValidationError.notNormalized` (its only error) if the receiver is not
  normalized. See Phase 4.

## Gap Analysis (Document vs. Current Parser)

1. **Encoding cascade is absent — the biggest gap.** `_parse` does
   `String(data:encoding:.utf8)` and throws `dataConversionFailed` on anything
   else (`ABCParser.swift:168`). A Latin-1 legacy file — the document's central
   case — is invalid UTF-8, so the parser cannot read legacy files at all today.
   No BOM strip, no `abc-charset` honoring, no Latin-1 fallback.
2. **BOM is not stripped before the file-ID match.** `\u{feff}` is only flagged
   non-visible (`Character+Extensions.swift:57`); the first-line
   `hasPrefix("%abc")` in `_resolveFileID` still fails when a BOM precedes it.
3. **`%%abc-version` is ignored for version detection.** The directive name
   exists (`ABCDirective.Name.swift:33`) and it parses as a directive, but
   `_resolveFileID` only looks for the `%abc-` file ID.
4. **A file-header `I:abc-version` does not affect parsing.** `version` is
   resolved once up front from the `%abc` line only, so an `I:abc-version` in the
   file header never changes syntax acceptance. (Per-tune `I:abc-version`
   variance is a separate, deferred concern — see *Deferred: Per-Tune Version
   Variance*.)
5. **Missing-version defaults to 2.1, not loose/legacy.** Lenient mode assumes
   `ABCVersion.current` (`ABCParser.swift:483`), contradicting the spec's
   "missing ⇒ loose."
6. **`Strictness` and version are independent, but the spec couples them**
   (≥ 2.1 ⇒ strict, ≤ 2.0 ⇒ loose).

Groundwork already present: the `abc-charset` / `abc-version` directive names
exist; the faithful model already captures several legacy constructs
(`legacyBeatMultiple` on tempo, `.elemskip` / `.information` fields, decoration
dialect); and `migrate()` (to be renamed `normalized()`) is effectively the
use-case-1 normalizer today.

## Phased Plan

### Phase 1 — Input preprocessing

Highest-value unblock; self-contained and independently testable. Today a Latin-1
file throws `dataConversionFailed`, so the parser cannot read legacy files at all.

This phase owns **all pre-parse input preparation**: decoding raw bytes to text,
detecting the file-level version, and producing the ready-to-parse lines. It
absorbs the line splitting and continuation-joining (`_joinContinuationLines`)
that `_parse` does today, leaving `_parse` as a pure line → model step.

**Restructure (shared pre-scan).** The header pre-scan that finds the charset also
finds the version — it is one scan over one provisional decode, and both
directives are pure ASCII, so they read identically in Latin-1 and in the final
encoding. The pre-scan therefore yields *both*. The version-resolution cascade
(Phase 2) lives here; Phase 2 shrinks to threading the resulting optional version
through the model.

**Component.** A free function `preprocess(_:)` in a new file
`Parser/Internal/ABCPreprocessFunctions.swift` (kept separate from the already
oversized `ABCParseFunctions.swift`; any further preprocessing helpers live in the
new file too):

```swift
func preprocess(_ data: Data) throws
    -> (lines: [Substring], version: ABCVersion?, diagnostics: [ABCParser.Diagnostic])
```

`preprocess` throws only the existing `Error.dataConversionFailed` on the SD4
strict path; every other path resolves to lines plus diagnostics.

`_parse` calls `preprocess` instead of `String(data:encoding:.utf8)` +
`_joinContinuationLines`, then parses the returned `lines` with the returned
`version`. The resolved charset is internal — the model does not record it.

The returned `lines` exclude the consumed `%abc` file-ID line (the analog of
today's `_resolveFileID` `dropFirst()`): the BOM and a leading `%abc` line are
stripped. The `%%abc-version` / `I:abc-version` directive lines, by contrast,
**remain** — the pre-scan only reads them — so they become ordinary model
directives (which Phase 4 normalization later drops). Besides the charset
diagnostics listed below, `preprocess` also emits the version diagnostics
introduced in Phase 2 (`malformedVersion`, `unrecognizedVersion`), since the
version cascade runs inside its pre-scan.

**Algorithm.**

1. **Strip BOM.** If the bytes begin with `EF BB BF`, drop them and note "UTF-8
   BOM seen." Only the UTF-8 BOM is handled; a UTF-16/32 BOM falls through to the
   Latin-1 fallback with an `ignoredByteOrderMark` diagnostic (SD3).
2. **Provisional decode** the whole (post-BOM) buffer as ISO-8859-1 — cannot fail,
   every byte maps.
3. **Pre-scan** the provisional lines in order, stopping at the first music/symbols
   line (charset and version are header-only). Collect: the line-1 `%abc-M.m`; the
   first `%%abc-version` / `I:abc-version`; the first `%%abc-charset` /
   `I:abc-charset`.
4. **Resolve version** via the cascade: `%abc-M.m` → `%%abc-version` →
   file-header `I:abc-version` → `nil` (unversioned).
5. **Resolve charset** via the cascade: UTF-8 BOM ⇒ UTF-8 (overrides a conflicting
   charset directive, with a diagnostic); else explicit `abc-charset` ⇒ that; else
   version ≥ 2.1 ⇒ UTF-8; else ISO-8859-1.
6. **Final decode.** If the resolved charset is ISO-8859-1, reuse the provisional
   text. Otherwise re-decode the post-BOM bytes with the resolved encoding; on
   failure see SD4.
7. **Strip the file-ID line** (drop the leading `%abc` line, if present).
8. **Split into lines** (on `\n` / `\r\n` / `\r`) and **join continuation lines**
   — relocating today's `_joinContinuationLines`. The result is the returned
   `lines`.

**Charset name handling.**

- Normalize before lookup: lower-case, strip spaces, accept common aliases
  (`latin1`, `iso8859-1`, `iso-8859-1`, `8859-1`, `utf8`, `ascii` / `us-ascii`).
- Charset → Swift encoding, including the non-obvious ISO numbering trap:

  | ABC charset | Swift mapping |
  |---|---|
  | `utf-8` | `.utf8` |
  | `us-ascii` | `.ascii` |
  | `iso-8859-1` | `.isoLatin1` |
  | `iso-8859-2` | `.isoLatin2` |
  | `iso-8859-3` | `CFStringEncodings.isoLatin3` |
  | `iso-8859-4` | `.isoLatin4` |
  | `iso-8859-5` | `.isoLatinCyrillic` |
  | `iso-8859-6` | `.isoLatinArabic` |
  | `iso-8859-7` | `.isoLatinGreek` |
  | `iso-8859-8` | `.isoLatinHebrew` |
  | `iso-8859-9` | `.isoLatin5` |
  | `iso-8859-10` | `.isoLatin6` |

  Trap: ISO-8859-**9** maps to isoLatin**5**, and 8859-**10** to isoLatin**6**.
  The 8859-3..10 cases resolve via
  `String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.X.rawValue)))`
  (Foundation is already imported).

**Edge-case decisions.**

- **SD1 — single file-level charset:** the first `abc-charset` wins and applies to
  the whole file. A later/duplicate charset directive is ignored *for decoding*
  (it remains in the model) and emits `duplicateCharset`. No mid-stream
  re-decoding.
- **SD2 — unknown declared charset:** emit `unrecognizedCharset` and fall back to
  ISO-8859-1 (preserves bytes); never throw for this.
- **SD3 — non-UTF-8 BOM:** handle only the UTF-8 BOM; diagnose-and-Latin-1 for a
  UTF-16/32 BOM.
- **SD4 — declared/implied UTF-8 that fails to decode** (e.g. `%abc-2.1` or
  `abc-charset utf-8` but the bytes are not valid UTF-8): in **strict** stance
  (≥ 2.1) throw the existing `Error.dataConversionFailed`; in **loose** stance
  fall back to ISO-8859-1 with an `invalidUTF8` diagnostic. `preprocess` knows the
  resolved version, so it is stance-aware.

**New diagnostics.** (Each charset/encoding case falls back to ISO-8859-1; the
distinct cases tell the user *why*.)

- `Diagnostic.unrecognizedCharset(String)` — declared charset name not known
  (SD2). Joins the `unrecognizedLine` / `unrecognizedVersion` family.
- `Diagnostic.duplicateCharset(String)` — a later charset directive was ignored
  (SD1).
- `Diagnostic.ignoredByteOrderMark` — a non-UTF-8 BOM was ignored (SD3).
- `Diagnostic.invalidUTF8` — loose path: declared/implied UTF-8 but invalid bytes
  (SD4 loose).

**No new errors.** SD4 strict reuses the existing `Error.dataConversionFailed`
(its meaning — "bytes→string failed" — fits exactly, and the case would otherwise
go dead once `preprocess` owns decoding). The version diagnostics
(`malformedVersion`, `unrecognizedVersion`) are introduced in Phase 2.

**Test matrix.**

- BOM + UTF-8 accented title.
- No-BOM Latin-1 accented title (today's failing case).
- `%abc-2.1` + `I:abc-charset iso-8859-1` override.
- `%%abc-charset` (2.0 form).
- Unknown charset → fallback + diagnostic.
- `%abc-2.1` with invalid UTF-8: strict throws `dataConversionFailed`; loose falls
  back with `invalidUTF8`.
- Empty file; BOM-only file.
- Charset alias spellings.
- ISO-8859-9 round-trip (the isoLatin5 trap).
- Later/duplicate charset ignored + diagnostic.
- Continuation joining still works post-relocation (a `\`-continued music line and
  a `+:` field continuation), including over a non-UTF-8 encoding.

**Touches.** New `Parser/Internal/ABCPreprocessFunctions.swift` housing
`preprocess(_:)` and its helper free functions; `_parse` calls `preprocess`
instead of `String(data:encoding:.utf8)` + `_joinContinuationLines` (which moves
out of `ABCParser`); new cases on `ABCParser.Diagnostic` and `ABCParser.Error`.

### Phase 2 — Optional version + model threading

Scope: a single, **file-level** version. The resolution *cascade* is implemented
in Phase 1's shared pre-scan (`preprocess` returns `version: ABCVersion?`);
Phase 2 pins down that cascade's parsing rules, retires `_resolveFileID`, and
threads the result through the model. These rules only produce the right
`ABCVersion?` — how that value drives strict/loose and which legacy syntax is
accepted is Phase 3. Per-tune `I:abc-version` variance is out of scope (see
*Deferred: Per-Tune Version Variance*).

Represent "unversioned" by making `ABCTunebook.version` optional (`ABCVersion?`),
with `nil` denoting an unversioned file. `ABCVersion` itself stays concrete.

**Cascade parsing rules.**

- **`%abc-M.m`** (line 1 only): parse `M`/`m` as major/minor. If present and
  well-formed, authoritative for the file.
- **`%%abc-version M.m` / file-header `I:abc-version M.m`**: same `M.m` parse;
  consulted only when the `%abc` line is absent or versionless.
- **Precedence:** `%abc` → `%%abc-version` → file-header `I:abc-version` → `nil`.
  The first found, in that order, wins.

**Resolution decisions.**

- **Bare `%abc` (no `-M.m`)** → `nil` (unversioned ⇒ loose). A file ID is present
  but declares no version, which the spec allows. (Today `_parseFileID` throws on
  this — `ABCParser.swift:407`; that throw is removed.)
- **Malformed version** (`%abc-2`, `%abc-2.x`, `%abc-2.1.3`) → `nil` plus a
  `malformedVersion` diagnostic. A stance cannot be derived from a version that
  did not parse, so this downgrades to unversioned/loose and notes it rather than
  failing over a typo'd identifier.
- **Well-formed but unrecognized version** (`%abc-2.2`, `%abc-1.9`, `%abc-3.0`) →
  **accept-and-diagnose**: keep the declared version and emit an
  `unrecognizedVersion(ABCVersion)` diagnostic. `≥ 2.1 ⇒ strict`, `< 2.1 ⇒ loose`
  still governs the stance (Phase 3); the exact versions 1.6/2.0/2.1 stay
  "recognized" only to unlock their specific syntax quirks. This removes the hard
  `Error.unsupportedVersion` rejection and the gatekeeping role of
  `ABCVersion.supported`.

**Diagnostics shift.** Under accept-and-diagnose, an unrecognized version is a
*note*, not a rejection, so it is emitted regardless of stance. This ends the old
invariant that a strict parse produces no diagnostics: diagnostics are now "notes
that may accompany any parse," while errors remain hard stops. `parse()` still
discards diagnostics; `parseWithDiagnostics()` surfaces them.

**Removed / changed cases.**

- `Error.missingFileID` and `Diagnostic.missingFileID` — removed; a missing `%abc`
  is now normal (`nil` ⇒ loose), not an error in any stance.
- `Error.unsupportedVersion` — removed (accept-and-diagnose).
- `Diagnostic.unsupportedVersion` — renamed `unrecognizedVersion(ABCVersion)`.
- New: `Diagnostic.malformedVersion(String)`.

**Work items.**

- Make `ABCTunebook.version` an `ABCVersion?`; update `init?`, `Equatable`, and
  every read site to handle `nil`.
- Delete `_resolveFileID` and its strict/lenient branching; the parser takes the
  version from `preprocess`. The `%abc` line is now stripped inside `preprocess`
  (see Phase 1), so `_parseFileIDLine` and the `.fileID` `Line` case become dead
  code and are removed.
- Thread `ABCVersion?` to `makeTunebook`; internal parse threading becomes
  `ABCVersion?` (Phase 3 defines how `nil` and each version gate syntax).
- `ABCVersion.supported` is no longer a gate; keep it (or an equivalent) only as
  the set of versions whose specific quirks the parser knows. `ABCVersion.current`
  remains the normalization target; the parser no longer seeds it as a default.
- Confirm the formatter's `version == .current` guard (`ABCFormatter.Writer.swift:39`)
  refuses a `nil`-version faithful tunebook until it is normalized — consistent
  with use case 1 > 2. (That guard will later be replaced by an `isValidated`
  gate — see Phase 4's *Formatter gate*.)

**Test matrix.**

- `%abc-2.1` / `-2.0` / `-1.6` → exact version.
- Bare `%abc` → `nil`; no `%abc` at all → `nil`.
- `%%abc-version 2.0` (no `%abc`) → 2.0; file-header `I:abc-version 2.0` → 2.0.
- `%abc-2.1` + `I:abc-version 2.0` → 2.1 (`%abc` wins).
- Malformed `%abc-2` / `%abc-x.y` → `nil` + `malformedVersion`.
- `%abc-2.2` → 2.2 + `unrecognizedVersion` (strict stance); `%abc-1.9` → 1.9 +
  `unrecognizedVersion` (loose stance).
- Version round-trips through `normalized()` → 2.1.

### Phase 3 — Interpretation model

Replace the independent `strictness` knob and the scattered `version` checks with
two concepts derived from the resolved `ABCVersion?`, computed once and threaded
through the parser as an internal `ABCInterpretation` value:

- **`stance`: strict | loose** — strict iff `version != nil && version >= 2.1`;
  else loose. (`nil`, 1.6, 2.0, and unrecognized `< 2.1` are loose; 2.1 and
  unrecognized `≥ 2.1` are strict.)
- **`iFieldIsFreeText`: Bool** — true iff `version == 1.6` exactly.

**Organizing principle.** Two things are tangled in today's code and get
separated here:

1. **Stance gates structural errors only** — the throw-vs-recover decision for
   genuine deviations: unparseable line, missing `X:`, missing `K:`, misplaced
   field, orphaned continuation. Strict throws; loose recovers + diagnoses. A
   mechanical re-key: every `strictness == .strict` → `stance == .strict`, every
   `.lenient` → loose.
2. **Deprecated forms are accepted regardless of stance, with a diagnostic** —
   and normalized away in Phase 4. The version no longer gates them. This fixes a
   current divergence: a strict 2.1 file with `Q:120` *throws* today
   (`ABCParser.swift:351`), but the spec says "programs should accept it" — and
   use case 1 must handle the many real 2.1 files that use deprecated tempo.

**Specific rules.**

- **Stance** drives the five structural-error sites above (re-key only).
- **Deprecated tempo** (`Q:120` bare, `Q:C=rate`): accepted in *all* stances,
  always diagnosed, normalized later. Removes the `version != .current` / lenient
  special-case and the strict throw. `Q:C=rate` becomes universal (today 1.6-only),
  matching the spec listing both forms together as deprecated-but-acceptable.
  Bare `Q:rate` is parsed into the *same* representation as `Q:C=rate` —
  `legacyBeatMultiple = 1` with `durations` resolved from `context.baseDuration`
  at parse time — since the two are semantically identical ("play *rate*
  unit-note-lengths per minute"). This makes Phase 4 normalization uniform and
  needs no `L:`-tracking at normalize time. Consequence: bare and `C=` are
  indistinguishable in the faithful model, so dump renders one canonical legacy
  form for both (an acceptable "reasonable semblance").
- **`E:` (elemskip):** routed to elemskip parsing in **loose** stance (preserved
  faithfully + diagnosed); in **strict** it is an invalid 2.1 field handled by the
  stance machinery (throws). Generalizes today's 1.6-only handling to all loose
  versions.
- **`I:` mode:** free-text info iff `version == 1.6`; **instruction otherwise** —
  including `nil`/unversioned. Since the meaning changed across versions (1.6 info
  ↔ 2.x instruction) and `ABCDirective.Name` is open (any letter-led token is a
  valid name), instruction-default loses the least: a real `I:linebreak !` keeps
  its semantics, while a genuine 1.6 free-text `I:This tune…` degrades to an inert
  directive named "This" that still round-trips textually for dump. True 1.6 files
  get correct info treatment because they are version 1.6, not `nil`.

**Deferred — `\` continuation version nuance.** The spec has a real version
difference (2.0 allowed `\` as a general continuation; 1.6/2.1 restrict it to
line-break suppression). The parser handles `\` uniformly in
`_joinContinuationLines`; that uniform handling is retained for now and the
version-dependent behavior is deferred.

**API + mechanical changes.**

- Delete `ABCParser.Strictness` and `init(strictness:)`; `ABCParser.init()` takes
  no arguments. (Breaking, expected.)
- Remove the strict throw path for deprecated tempo; `Error.invalidTempo` remains
  only for genuinely unparseable tempo.
- Generalize `Diagnostic.bareTempoRate` into a single `deprecatedTempo(ABCTempo)`
  case covering both forms (now that bare and `C=` share one representation). The
  `ABCTempo` payload mirrors `misplacedField(ABCField)` and carries the form.

**Test matrix.**

- 2.1 missing `K:` throws; 2.0 and `nil` recover + diagnose.
- 2.1 `Q:120` accepted + diagnosed (not thrown); `Q:C=120` accepted across
  1.6 / 2.0 / `nil`.
- 1.6 `I:foo` → info; 2.0 / 2.1 / `nil` `I:linebreak !` → instruction; `nil`
  `I:Some prose` → instruction named "Some".
- 2.1 `E:7` throws; loose `E:7` → elemskip + diagnose.
- Unrecognized line: strict throws; loose diagnoses.

### Phase 4 — Faithful-model completeness + normalization

Use case 1's guarantee. Rename `migrate()` to `normalized()` — non-mutating,
returns a new `ABCTunebook` with `version == .current` (2.1) and every legacy
construct converted.

**Construct-driven, not version-gated.** A `version == 2.1` tunebook is *not*
necessarily clean: deprecated constructs (tempo, plus-dialect decorations, stale
directives) are accepted even under strict 2.1 and tagged with the declared
version, so `normalized()` must walk such a model and **must not** short-circuit
on `version == .current`. The short-circuit is keyed on `isNormalized` instead
(below), which only a producer can set.

**Audit — every faithful legacy construct and its conversion:**

| Construct (faithful model) | Normalization | Status |
|---|---|---|
| version 1.6 / 2.0 / `nil` / unrecognized | set `version = .current` | exists (update for optional `nil`) |
| `E:` elemskip | → `remark` | exists |
| 1.6 `I:` free-text (`.information`) | → `remark` | exists |
| `Q:Cn=rate` legacy beat (`legacyBeatMultiple` set) | clear flag, keep resolved durations | exists |
| bare `Q:120` | same as `Q:C=rate` (`legacyBeatMultiple == 1`), so same path | closed by Phase 3 representation |
| `+…+` decoration (`.dialect == .plus`) | → `.bang`; drop `decoration +` directive | **gap to close** |
| stale `%%abc-charset` / `I:abc-charset` directive | drop (output is UTF-8) | **gap to close** |
| stale `%%abc-version` / `I:abc-version` directive | drop (`version` is authoritative) | **gap to close** |

Because bare tempo now shares the `Q:C=rate` representation (Phase 3 amendment),
the normalizer needs **no `L:`-tracking** — the existing "clear
`legacyBeatMultiple`, keep durations" path covers both.

**Stale directives.** `abc-charset` and `abc-version` directives are *dropped* on
normalization: the text is already decoded (so charset is moot) and
`tunebook.version` is authoritative (so an `abc-version` directive would be
redundant or contradictory in a 2.1 model).

**`validated()` — the validity inspector.** `validate()` is renamed `validated()`
and becomes the *separate* validity check (normalization handles legacy syntax;
validation handles structural correctness). It returns a guarantee token:

```swift
func validated() throws -> (ABCTunebook, [ABCValidationIssue])
```

- **Requires `isNormalized`.** `validated()` throws `ABCValidationError.notNormalized`
  (its **only** thrown error) when the receiver is not normalized — validating a
  faithful legacy model is meaningless, since its legacy constructs would all read
  as errors. This enforces `isValidated ⇒ isNormalized` and collapses the token
  lattice to three states `(F,F)`, `(T,F)`, `(T,T)`; it also makes the
  normalize-vs-validate ordering moot (every validated tunebook is already
  normalized, so `normalized()` short-circuits on it — nothing to re-derive). A
  thrown error means "called wrong"; content problems are *reported*, not thrown.
- **`isValidated` token.** A public read-only `ABCTunebook.isValidated: Bool`,
  `false` by default (manual and parsed). Set `true` only by `validated()`, via
  the same internal-initializer mechanism as `isNormalized`. `isValidated == true`
  ⟺ validated with **zero error-severity** issues (warnings do not block it);
  combined with the precondition, it is the single full strict-2.1-conformance
  token.
- **Return.** If any **error**-severity issue → returns `(self, issues)`,
  `isValidated` stays `false`. If only warnings (or none) → returns a copy with
  `isValidated = true` plus the issues. Short-circuits to `(self, [])` when the
  receiver is already `isValidated`.
- **Preserves `isNormalized`.** `validated()` never changes content, so it carries
  `isNormalized` through unchanged. The canonical pipeline is `parse → normalized()
  → validated()`, yielding `(T,T)`.
- **What it checks.** Structural validity that normalization never touches —
  required/ordered fields (`X:`/`K:`), legal field placement, defined shorthands,
  decoration-dialect consistency — *plus* a defensive re-check that the
  audit-table legacy constructs are absent (catching a `normalized()` bug, since
  `isNormalized` is trusted, not re-derived). Today's checks cover only
  decoration-dialect mismatches and undefined shorthands; Phase 4 adds the
  legacy-construct re-check and the minimum structural checks above. A full
  hardening pass (the separate "ABCFormatter cannot emit invalid ABC" effort) is
  out of scope here.
- **Equality.** Like `isNormalized`, `isValidated` is **excluded** from
  `Equatable` / `Hashable` (content-based equality).
- **New type.** `ABCValidationError` (standalone, parallel to `ABCValidationIssue`),
  one case `.notNormalized`, conforming to `EnhancedError` for message/category.
- **Formatter gate (future).** `ABCFormatter` will format *only* an `isValidated`
  tunebook — superseding today's `version == .current` guard
  (`ABCFormatter.Writer.swift:39`), which `isValidated` subsumes
  (`isValidated ⇒ isNormalized ⇒ version == .current`). So the canonical output
  path is `parse → normalized() → validated() → format`, and a non-validated
  tunebook is not formattable. The formatter change itself is out of scope for
  this parser-focused plan.

**`isNormalized` marker.** `ABCTunebook` gains a public read-only
`isNormalized: Bool` marking a *legacy-free 2.1* model — no audit-table
constructs, `version == .current`. It is **not** a validity marker (that is
`isValidated`, below); `false` means `normalized()` may still have work to do.

- **Producers only.** The public `init?` always sets *both* tokens to `false` — a
  manually built tunebook is never normalized, and `init?` does **not** walk the
  model to self-assess (that would both add a per-construction cost and, worse,
  open a public path to `true`, breaking the guarantee). A single *internal*
  initializer carries both `isNormalized` and `isValidated` and is the only way to
  set either `true`: `normalized()` sets `isNormalized` (with `isValidated` left
  `false`), the parser sets `isNormalized` per its optimization, and `validated()`
  sets `isValidated` while preserving `isNormalized`.
- **Invariant.** `isNormalized == true` implies `version == .current` (2.1) and
  no audit-table legacy constructs. It does **not** imply structural validity —
  a normalized model can still have, e.g., an undefined shorthand or a `K:`-less
  tune left by loose recovery (these are `validated()`'s concern). The flag is
  *trusted*, upheld by its two producers — not re-validated at construction (an
  optional debug-only assertion may check it).
- **`normalized()` short-circuit.** Returns `self` when `isNormalized` is already
  `true` (this is what makes it idempotent — `normalized(normalized(x))` is the
  same instance). Otherwise it walks, converts per the audit table, and returns a
  new tunebook with `isNormalized = true`. Consequence: a manually built but
  already-clean 2.1 tunebook (`isNormalized == false`) is still walked and yields
  a *new* content-identical value, not `self`.
- **Parser optimization.** When assembling the tunebook, the parser sets
  `isNormalized = (version == .current) && noLegacyConstructEncountered`;
  otherwise `false`. Conservative — when in doubt, `false`, and a later
  `normalized()` verifies by walking. Because `isNormalized == true` requires
  `version == .current`, the parser can only set it for a `%abc-2.1` file with no
  audit-table constructs; a clean 2.0 / 1.6 / `nil` / 2.2 file is *not*
  normalized (its version would still be set to 2.1).
- **Equality.** `isNormalized` is **excluded** from `Equatable` / `Hashable`
  (content-based equality), so a manually built tunebook and its `normalized()`
  form with identical content compare equal. This needs a custom `==` / `hash`
  in place of the synthesized conformances.

Design rule throughout: **the parser only preserves a legacy construct if
normalization can convert it** — so the audit table above must stay closed (every
faithful legacy construct has a row).

**Test matrix.**

- 1.6 file with `E:` / `I:`-info / `Q:C=rate` → `normalized()` yields remark /
  remark / cleared-flag tempo, `version == .current`, and (after `validated()`)
  zero error-severity issues.
- 2.1 file with `I:decoration +` and `+trill+` → normalized to `!trill!`; the
  `decoration` directive dropped.
- Stale `%%abc-charset` / `I:abc-version` directives → dropped on normalize.
- `isNormalized`: manually built clean-2.1 tunebook → `isNormalized == false`;
  `normalized()` returns a *new* content-equal value with `isNormalized == true`.
- `isNormalized`: `normalized()` on an `isNormalized == true` tunebook returns the
  same instance (`self`).
- `isNormalized`: parser on a clean `%abc-2.1` file → tunebook `isNormalized ==
  true`; on a `%abc-2.1` file with `Q:120` → `isNormalized == false`, and
  `normalized()` then yields `isNormalized == true`.
- `isNormalized`: parser on a clean `%abc-2.0` file → `isNormalized == false`
  (version not current, despite being construct-clean).
- `validated()` on an `isNormalized == false` tunebook **throws**
  `ABCValidationError.notNormalized`.
- `validated()` on a normalized, structurally-valid tunebook → `(copy, [])` with
  `isValidated == true`, and `isNormalized` preserved (`(T,T)`).
- `validated()` on a normalized tunebook with an undefined shorthand →
  `(self, [error])`, `isValidated == false`.
- `validated()` with warnings-only issues → `isValidated == true`, issues carry
  the warnings.
- `validated()` on an already-`isValidated` tunebook → `(self, [])`.
- Canonical pipeline `parse → normalized() → validated()` → `(T,T)`.
- Equality: a manually built clean-2.1 tunebook `==` its `normalized()` form, and
  a normalized tunebook `==` its `validated()` form (both flags excluded from `==`).

### Sequencing

1 → 2 → 3 → 4. Phase 1 (preprocessing) is landable on its own, but because
`preprocess` also returns an `ABCVersion?` that only Phase 2 fully consumes (the
model's `version` is still non-optional until then), landing Phase 1 alone
requires a temporary `nil → .current` bridge in `_parse`, removed in Phase 2.
Phases 1–3 are the parser core; Phase 4 is the parse/normalize boundary.

## Settled Naming / Representation Calls

1. **Unversioned** is modeled by `ABCTunebook.version: ABCVersion?`, with `nil`
   meaning the file declared no version. `ABCVersion` stays a concrete struct.
   Rationale: `nil` is the honest representation of "no version," keeps
   `ABCVersion` (and its `Comparable`/`major`/`minor`) clean, and yields the
   invariant that a normalized tunebook is always non-`nil` (2.1). The internal
   parser stance for the legacy union is a separate concern, not this optional.
2. **`migrate()` → `normalized()`** — non-mutating, returns a new legacy-free-2.1
   `ABCTunebook`. Rationale: the operation canonicalizes (dialects, tempos, …),
   not merely bumps a version number, and the past-participle name obeys the
   Swift API Design Guidelines for a non-mutating transform.

## Deferred: Interpretation Override

Both use cases pin interpretation to the version-derived value, so the initial
design exposes no override. The ABC 2.1 spec (§12.2, "Recommendation 2 for
developers") suggests that applications let users toggle between strict and loose
interpretation — but that recommendation targets end-user apps (it cites a
command-line switch or GUI checkbox), not the library itself.

An override would serve two scenarios the derived default cannot express:

1. **Force strict on a ≤ 2.0 / unversioned file** — the spec's own example:
   surfacing how many strict errors a legacy file would need fixed to reach 2.1
   (a lint / upgrade-assistant use).
2. **Force loose on a `%abc-2.1` file** — a file that declares 2.1 but contains
   mistakes, where a consumer wants recover-and-report instead of a thrown error.

Adding an optional `interpretation:` argument later is a non-breaking, additive
change, so this is deferred until a concrete need (most likely scenario 2)
arises.

## Deferred: Per-Tune Version Variance

The spec allows an `I:abc-version` in an individual tune header so that tunes in
one tunebook can conform to different standards (the "Mid-File Variance" of
`parsing-legacy-abc-files.md`). Phase 2 resolves only a single file-level
version, so a tune-header `I:abc-version` is parsed as an inert directive and
does not change that tune's syntax acceptance.

This is deferred because it is allowed-but-rare in practice and would require
giving each tune its own resolved version and re-deriving interpretation per
tune (a substantial extension of Phase 3). The current behavior — the file-level
version governs every tune — is an acceptable status quo until a concrete need
arises.

## Deferred: Old Multi-Line `H:`

In ABC 1.6 the history field could run over several lines with no field
indicator, each continuation line simply following the `H:` line until the next
field (the legacy `H:` behavior in `parsing-legacy-abc-files.md`). The current
parser does not handle this: a subsequent indicator-less line is parsed as music
symbols or an unrecognized line, not as a continuation of the history.

This surfaced during the Phase 4 audit. It is a Phase 3 *loose-parsing* feature,
not a normalization gap, and it is niche and orthogonal to the version/encoding
core, so it is deferred rather than folded into Phase 3 now. (Once handled at
parse time, the normalized output would emit it with `+:` continuation, which is
the formatter's concern.)
