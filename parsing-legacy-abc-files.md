# Parsing Legacy ABC Files

The `%abc-<version>` file identifier header was officially introduced in
**December 2011** with the release of the ABC Music Standard 2.1. 

It was added specifically to solve a growing problem with backward compatibility
as the format evolved from a simple text shorthand into a formalized digital
standard. 

## The Purpose: Strict vs. Loose Interpretation

The introduction of the version directive created a strict boundary line for how
modern ABC parsers must behave: 

- Loose Interpretation (Legacy): If an ABC file completely lacks the
  `%abc-<version>` header, or specifies a version **lower** than 2.1 (like
  `%abc-2.0`), the parser must use loose interpretation. This tells your
  software to ignore missing fields, tolerate deprecated syntax, handle old
  multi-line quirks (like the legacy `H:` field behavior — see below), and guess
  the intent without crashing.

  This **deprecated-syntax** tolerance covers forms that predate ABC 2.1 but
  remain common in the wild. This is a separate concern
  from version detection and character encoding (the two themes of this
  document), but a legacy-aware parser must accept it: examples from the ABC 1.6
  era include the notes-per-minute tempo forms `Q:120` and `Q:C=120`, lyrics
  using only the uppercase `W:` field (aligned lowercase `w:` came later), and
  chords written only as `[CEGc]` (the `+…+` decoration and `!` line-break
  dialects are ABC 2.0-era additions, not present in 1.6). A full treatment of
  deprecated syntax is out of scope here.

  The legacy `H:` (history) field is a concrete example. In ABC 1.6 the history
  field "can be used for multi-line stories/anecdotes, all of which will be
  ignored until the next field occurs" — that is, its content ran across
  multiple raw lines with **no field indicator**, continuing until the next
  field began. ABC 2.1 deprecates this and instead expects explicit `+:`
  continuation lines, so a loose parser must recognize the old indicator-less
  multi-line form.
- Strict Interpretation (Modern): If a file begins with `%abc-2.1` or higher, it
  forces the parser into strict interpretation mode. Any deviation from the ABC
  2.1 rules must be actively caught and reported to the user as a syntax error. 

## Implementation Rules for Your Parser

Because you are writing a custom parser, the `%abc` directive requires a few
unique regex and scanning considerations:

1. **First-Line Scanning**: The %abc file identifier is designed to appear at
   the very top of the `.abc` file. However, the 2.1 standard notes that your
   parser should actively look for and ignore a **Byte Order Mark (BOM)** if it
   is encountered before the identifier string. 
2. **The Default State**: If the token is missing, do not crash; default your
   parser's state machine to "Loose/Legacy" mode. 
3. **Mid-File Variance**: While the version is typically established at the
   absolute beginning of a file, the standard also allows a version field
   (`I:abc-version <value>`, e.g. `I:abc-version 2.0`) to be applied to
   individual tunes within a large compilation file (a tunebook) to switch
   behaviors on the fly. The field name is `I:abc-version` in ABC 2.1; the older
   ABC 2.0 equivalent was the stylesheet directive `%%abc-version` (see below).
   There is no field named `I:version`.

## Headers in the Wild

You **should not expect** to find `%abc-2.0` or `%abc-1.6` in files found in
the wild.

Because the `%abc-<version>` file header syntax did not exist prior to December
2011, authentic legacy files written during the ABC 1.6 or 2.0 eras **simply
leave the top of the file blank or start directly with a comment line or a `X:`
field.**

## What You Might See Instead

While you will almost never see `%abc-1.6` or `%abc-2.0`, you may occasionally
encounter two rare exceptions when parsing old or non-standard files:

- **Manually Retconned Files**: A modern user or script may have manually added
  `%abc-2.0` to an old file, mistakenly believing it was a required tag for all
  versions.
- **The `%%abc-version` Directive**: Before the standard settled on the `%abc-`
  file identifier (`%abc-2.1`), the ABC 2.0 standard (December 2010) defined a
  stylesheet-style directive using two percent signs: `%%abc-version 2.0`. It
  was a genuine, settled part of ABC 2.0, not merely a draft proposal, so you
  may legitimately encounter it in files exported by 2.0-era software.

## The Safe Parser Implementation Strategy

To make your parser highly robust against any file it encounters, implement the
following cascading fallback logic:

1. Check for Modern `%abc-` Header: Look for `%abc-2.1`, `%abc-2.2`, etc. If
   found, use modern strict parsing.
2. Check for the ABC 2.0 `%%abc-version` Directive: Look for `%%abc-version
   <number>`. If the number is less than 2.1, drop into legacy mode.
3. Default to Legacy/Loose Mode: If neither header is found—which is true for
   the vast majority of vintage files—automatically assume the file is a legacy
   file (ABC 2.0 or older) and apply loose parsing rules.

Whichever mode the steps above select, an `I:abc-version` field (in the file
header or an individual tune header) overrides that determination for its scope
— see **Mid-File Variance** above. The cascade establishes the file-level
default; `I:abc-version` refines it per tune.

## Summary Recommendation for Your Parser

Your parser should only ever strictly expect the `%abc-` prefix to be followed
by a version number of **2.1 or higher**. Treat any version number below 2.1 as
an explicit instruction to execute your legacy, loose-parsing fallback machine.

## Character Encoding in Legacy and Modern Versions

The shift in character encoding across different generations of the ABC notation
standard is a critical area for parser developers. Historically, handling
text-heavy fields (like title `T:`, words `W:`, and history `H:`) required
navigating shifting character sets. Misinterpreting these encodings easily
results in garbled text (mojibake). 

The evolution of character encoding in ABC notation occurred in three distinct
eras:

```
┌──────────────────────────┐     ┌──────────────────────────┐     ┌──────────────────────────┐
│      Early Era           │     │   ABC 2.0 (Dec 2010)     │     │  ABC 2.1+ (2011–Present) │
│  8-bit by convention     │ ──> │   Latin-1 (ISO-8859-1)   │ ──> │     UTF-8 by Default     │
│   (Mnemonic Escapes)     │     │    Adds %%abc-charset    │     │    BOM-aware Handling    │
└──────────────────────────┘     └──────────────────────────┘     └──────────────────────────┘
```

1. **The Early Era: Mnemonic Escapes**

   The early ABC standards (through ABC 1.6) did not formally specify a character
   set at all; in practice files were plain 8-bit text. Because there was no
   guaranteed way to transmit accented characters (like `é` or `ø`) often found
   in traditional European folk tune titles, files relied on **backslash
   mnemonic escapes** for accents. The ABC 2.1 standard notes that these
   mnemonics, based on TeX encodings, "have been available since the earliest
   days of abc and are widely used in legacy abc files."

   - **Example legacy formatting**: `T:The Maid of Thurn\'e`
   - **Parser impact**: Your parser should expect to see backslash mnemonic
     escapes representing accents in old files. Note that these escapes remain
     fully legal under strict ABC 2.1 (alongside named HTML entities and
     fixed-width Unicode), so you must handle them regardless of the file's
     declared version or encoding — see below.

2. **The ABC 2.0 Era (December 2010): Latin-1 Default**

   The ABC 2.0 standard set the global default encoding to **Latin-1
   (ISO-8859-1)**, chosen to accommodate Western European languages and to match
   the then-default charset of webpages.

   To handle multilingual files outside Western Europe, ABC 2.0 introduced a
   dedicated stylesheet directive: `%%abc-charset <encoding>` (two percent
   signs). In ABC 2.1 the equivalent is the instruction field `I:abc-charset
   <encoding>`.

   - **The Catch**: Under ABC 2.0 the charset could be changed partway through a
     file ("later occurrences of the charset field override earlier ones"),
     meaning a parser had to read the file, encounter the token, and dynamically
     change its decoder mid-stream. Note that ABC 2.1 reversed this: its
     `I:abc-charset` "may not be changed further on in the file."

3. **The Modern Era (ABC 2.1+): UTF-8 Standard**

   With the release of ABC 2.1, **UTF-8 became the strict default encoding** for
   all files. Modern renderers assume UTF-8 immediately unless an explicit
   legacy header overrides it. 

## How to Implement This in Your Parser

To build a bulletproof text scanner that safely bridges the gap between old and
new files, follow these two implementation rules:

### Rule A: Detect the UTF-8 Byte Order Mark (BOM)

Modern files encoded in UTF-8 occasionally begin with the 3-byte BOM sequence
(`0xEF, 0xBB, 0xBF`). Your parser must look for and discard the BOM before
evaluating whether the file begins with the modern %abc-2.1 string. Leaving the
BOM attached to the string will cause your regex match for %abc to fail. 

### Rule B: Use a Cascading Encoding Strategy

When loading an incoming stream or file of unknown origin, use this logic path
to determine how to decode bytes into characters:

1. **Check for `%abc-2.1` or higher**: If found, decode the stream as **UTF-8**,
   which is the 2.1 default. Note that UTF-8 is only the default: a conforming
   2.1 file may still declare a different encoding with an `I:abc-charset` field,
   so do not treat the `%abc-2.1` identifier as a guarantee of UTF-8 — still
   honor an explicit charset field per the next step.
2. **Scan for `I:abc-charset` or `%%abc-charset`**: If a specific charset token
   is found in the header (e.g., `I:abc-charset utf-8` or `%%abc-charset
   iso-8859-2`), pivot the decoder to that type — including when a `%abc-2.1`
   identifier is also present. The legal charset values are `iso-8859-1` through
   `iso-8859-10`, `us-ascii`, and `utf-8`.
3. **Fallback Default**: If there is no version tag and no charset directive,
   fall back to decoding the byte stream as **ISO-8859-1 (Latin-1)**. This
   matches ABC 2.0's own documented default ("when no charset is specified,
   iso-8859-1 is assumed"), and Latin-1 is a safe baseline because it maps every
   incoming byte directly to a valid 8-bit character code point without
   crashing, protecting your parser from unhandled encoding exceptions. The
   tradeoff is that a genuinely UTF-8 legacy file decoded as Latin-1 will yield
   mojibake rather than an error; if that matters for your inputs, consider
   attempting a strict UTF-8 decode first and falling back to Latin-1 only when
   it fails.
