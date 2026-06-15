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
  software to ignore missing fields, tolerate archaic spacing, handle old
  multi-line quirks (like the legacy `H:` field behavior), and guess the intent
  without crashing. 
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
   absolute beginning of a file, the standard also allows a version field (e.g.,
   `I: version 2.0`) to be applied to individual tunes within a large
   compilation file (a tunebook) to switch behaviors on the fly. 

## Headers in the Wild

You **should not expect** to find `%abc-2.0` or `%abc-1.6**` in files found in
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
- **The `%%abc-version` Directive**: Before the standard settled on a single
  percent sign (`%abc-2.1`), draft versions of the ABC 2.0 standard proposed a
  stylesheet-style directive format using two percent signs: `%%abc-version
  2.0`.

## The Safe Parser Implementation Strategy

To make your parser highly robust against any file it encounters, implement the
following cascading fallback logic:

1. Check for Modern %abc- Header: Look for %abc-2.1, %abc-2.2, etc. If found,
   use modern strict parsing.
2. Check for Draft %%abc-version Directive: Look for %%abc-version <number>. If
   the number is less than 2.1, drop into legacy mode.
3. Default to Legacy/Loose Mode: If neither header is found—which is true for
   the vast majority of vintage files—automatically assume the file is a legacy
   file (ABC 2.0 or older) and apply loose parsing rules.

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
│   1990s – Mid-2000s      │     │      ABC 2.0 (2003)      │     │  ABC 2.1+ (2011–Present) │
│     Strict ASCII         │ ──> │   Latin-1 (ISO-8859-1)   │ ──> │     UTF-8 by Default     │
│   (Escapes for Accents)  │     │   Introducing `I:charset`│     │    BOM-aware Handling    │
└──────────────────────────┘     └──────────────────────────┘     └──────────────────────────┘
```

1. **The Early Era (1990s): Pure ASCII & TeX Macros**

   Originally, ABC notation was designed to be purely **7-bit ASCII-compliant**
   so it could be easily transmitted across 1990s Usenet groups and email lists.
   Because ASCII does not natively support accented characters (like `é` or `ø`)
   often found in traditional European folk tune titles, files relied heavily on
   **TeX-style macro escapes** for typography. 

   - **Example legacy formatting**: `T:The Maid of Thurn\'e`
   - **Parser impact**: Your parser should expect to see backslash escapes
     representing accents in very old files.

2. **The ABC 2.0 Era (2003 Drafts): Latin-1 Default**

   The ABC 2.0 draft standard shifted the global default encoding from ASCII to
   **Latin-1 (ISO-8859-1)** to easily accommodate Western European languages. 

   To handle multilingual files outside Western Europe, ABC 2.0 introduced a
   dedicated directive format: `I:charset <encoding>` (or `%%charset
   <encoding>`). 

   - **The Catch**: This instruction was allowed anywhere in the file header,
     meaning a parser had to read the file, encounter the token, and dynamically
     change its decoder mid-stream. 

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

1. **Check for `%abc-2.1` or higher**: If found, decode the rest of the stream
   strictly as **UTF-8**.
2. **Scan for `I:charset` or `%%charset`**: If a specific charset token is found
   in the header (e.g., `I:charset utf-8` or `I:charset CP1252`), immediately
   pivot the decoder to that type.
3. **Fallback Default**: If there is no version tag and no charset directive,
   fall back to decoding the byte stream as **ISO-8859-1 (Latin-1)**. Latin-1 is
   a safe baseline fallback because it maps every single incoming byte directly
   to a valid 8-bit character code point without crashing, protecting your
   parser from unhandled encoding exceptions. 
