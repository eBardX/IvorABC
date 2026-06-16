In ABC notation v2.1, modifying or explicit accidentals in the key signature
command (`K:`) interact with different clefs based on a simple rule: **the pitch
absolute value determines the visual line or space on the staff, adapting
automatically to the active clef.**

Even though you use standard ABC pitch letters (like uppercase `F` or lowercase
`f`) to specify the position, the software calculates its _absolute musical
pitch value_ (e.g., F4 or F5) and positions the accidental symbol onto whatever
line or space corresponds to that pitch in the chosen clef.

## 1. Clef-Relative Visual Placement

When you define custom accidentals in `K:`, uppercase letters represent the
octave starting at Middle C (C4 to B4), and lowercase letters represent the
octave above (C5 to B5).

When you change the clef using `clef=bass` or `clef=alto`, the software maps
those exact absolute pitches to their new physical locations on that specific
staff format:

- **Treble Clef (`clef=treble`):**

  - `^F` (F4) lands on the first space from the bottom.
  - `^f` (F5) lands on the fifth line at the top.
  
- **Bass Clef (`clef=bass`):**

  - `^F` (F4) lands on the third ledger line above the staff.
  - `^f` (F5) lands far above the staff on a high ledger line.
  - _To put a sharp on the standard Bass Clef line for F (F3, fourth line from
    bottom), you must use the octave comma modifier: `^F,`._
  
- **Alto Clef (`clef=alto`):**

  - `^F` (F4) lands on the fourth line from the bottom.
  - `^f` (F5) lands on the ledger line above the staff.

## 2. Suffixing Octave Modifiers `,` and `'`

To place explicit accidentals on lower or higher lines in bass or alto clef, you
can append commas `,` or apostrophes `'` to the note letters exactly as you
would in the body of the music.

 Desired Staff Position        | Clef Target | ABC Spec Example | Absolute Pitch
:----------------------        |:----------- |:---------------- |:--------------        
 Treble Clef Top Line          | Treble      | `K:D exp ^f`     | F5
 Bass Clef 4th Line            | Bass        | `K:D exp ^F,`    | F3
 Bass Clef 2nd Space           | Bass        | `K:D exp _C,`    | C3
 Alto Clef 3rd Line (Middle C) | Alto        | `K:C exp =C`     | C4

## 3. Syntax Rules for Mixing Keys and Clefs

You can combine explicit accidentals and clef assignments inside a single `K:`
field. The clef definition can be placed either before or after the explicit
accidentals:

```
% Bass Clef with Klezmer-style explicit modifications adjusted for lower register
K:D Phr clef=bass ^F,

% Explicit key notation completely customized for an Alto Clef
K:D exp clef=alto _B =C ^F
```

If you are using multi-voice music (`V:`), it is highly recommended to declare
the clef in the voice field (`V:`) and the specific accidentals in the key field
(`K:`) to ensure clean rendering.

---

A number of shorthand decoration symbols are available:

```
.       staccato mark
~       Irish roll
H       fermata
L       accent or emphasis
M       lowermordent
O       coda
P       uppermordent
S       segno
T       trill
u       up-bow
v       down-bow
```

The standard set of definitions (if you do not redefine them) is:

```
U: ~ = !roll!
U: H = !fermata!
U: L = !accent!
U: M = !lowermordent!
U: O = !coda!
U: P = !uppermordent!
U: S = !segno!
U: T = !trill!
U: u = !upbow!
U: v = !downbow!
```

## Questions:

- Is `.` _not_ allowed to be redefined with `U:`?

  **Answer:** Correct. `.` _cannot_ be overridden by `U:`.

- If a shorthand/shortcut is de-assigned (with !nil! or !none!) with `U:`, does
  it fall back to the predefined value? In  For example, does `U: T = !nil!`
  revert to `T` being defined as `!trill!`?

  **Answer:* No. It becomes undefined. Attempting to use it thereafter should be
  a parser error.
  
  **Follow up:** If `U:` is defined in the _file_ header, its scope is _all_
  tunes in the tunebook. If `U:` is defined in a _tune_ header, its scope is
  _only_ for that tune. The same scoping rule holds true for `m:`.

