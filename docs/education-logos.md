# Education logo assets

Created from the four user-supplied images with the built-in `image_gen` tool,
using background-extraction edits and `transparent_background: true`.
The application renders the glass containers separately in Flutter.

| Education entry | Saved asset |
| --- | --- |
| Norton University | `assets/images/education_norton.png` |
| ISTAD | `assets/images/education_cstad.png` |
| ETEC Computer Center | `assets/images/education_etec.png` |
| Sastra Digital Solution | `assets/images/education_sastra.png` |

The three circular logos retain their internal artwork and colored fields;
only their surrounding rectangular backgrounds are removed. The Sastra asset
uses a black monochrome wordmark with its gradient background removed. Flutter
tints that wordmark to the theme's foreground color for contrast.

## Prompt set

Shared instructions for each separate edit:

> Use case: background-extraction. Asset type: original institution logo cutout
> for a Flutter portfolio education section. Edit only the specified target
> from the four attached images; the other three logos are not part of the
> output. Change background only. Preserve the supplied logo artwork,
> including all text and geometry; do not redesign, stylize or add anything.
> Output one isolated target logo as a PNG with real alpha transparency.
> No background, checkerboard, glass container, shadow, labels or other logos;
> glass is rendered separately in Flutter.

- **ETEC:** Remove only the white rectangular background outside the outer
  circular logo. Preserve the navy field, yellow circuit emblem, white
  elements, `ETEC Center` lettering, double circular outline and proportions.
  Keep the entire circular badge.
- **Norton:** Remove only the white rectangular background outside the
  circular seal. Preserve the gray metallic seal, rim, internal crest,
  numerals and original lettering.
- **CSTAD:** Remove only the black rectangular background outside the seal,
  or preserve its transparency if already transparent. Preserve the internal
  white areas, Khmer lettering, `CENTER OF SCIENCE AND TECHNOLOGY ADVANCED
  DEVELOPMENT`, `CSTAD`, blue/red/yellow colors, gold outer ring and entire
  circular badge. Do not redraw or translate characters.
- **Sastra:** Remove the entire purple/blue gradient background. Keep the
  original white circuit symbol, `Sastra` and `DIGITAL SOLUTION` lettering.
  Space between letters and circuit traces must be transparent. Preserve
  the layout, with modest transparent padding around the horizontal logo.
  No colored rectangle or extra badge.

Sastra cleanup pass: clean the alpha matte, remove stray white specks and
residue around the symbol and lettering, and fill accidental holes in solid
strokes. Preserve the circuit silhouette, `Sastra`, `DIGITAL SOLUTION`, and
their positions and proportions. Use smooth antialiased edges, solid white
interiors and fully transparent negative space. No outlines, texture, grain,
shadows, gradients or extra elements; retain a small transparent margin.

Final Sastra pass: rebuild the supplied lockup as a flat black monochrome logo
on transparent alpha, retaining the circuit silhouette, `Sastra` typography,
and `DIGITAL SOLUTION` tagline and their positions. Use clean filled black
strokes and letterforms, with transparent letter counters and open circuit
endpoints. Remove white specks, fragments, texture and grunge. Use smooth
antialiased edges and a modest transparent margin, with no backdrop, shadow,
gradient, border or extra illustration. Flutter applies the theme tint.
