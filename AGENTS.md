# Agent Instructions

OpenSCAD shapes for 3D printing. See [README.md](README.md) for more detail.

## Project Structure

- `*.scad` — OpenSCAD model files
- `images/` — Preview images for the README table of contents

## Build / Render

No lint or typecheck steps. Models are rendered in OpenSCAD.

## Generating README Preview Images

When adding or updating a model at some point its preview image for the README table of contents needs to be regenerated, but this doesn't need to happen before commit. In other words don't regenerate images during iterations unless it is for demonstrative purposes.

**Step 1 — Render the PNG from OpenSCAD:**

```bash
OPENSCAD="$(which openscad)"

"$OPENSCAD" --autocenter --viewall --render \
  --imgsize=200,200 --projection=perspective \
  -o images/<model>.png <model>.scad
```

**Step 2 — Strip the background (make it transparent) with ImageMagick:**

```bash
magick images/<model>.png -fuzz 5% -transparent "srgb(255,255,229)" images/<model>.png
```

The Cornfield colorscheme (default) uses `srgb(255,255,229)` as the background color. If you change the colorscheme, sample a corner pixel with `magick <file> -format "%[pixel:p{0,0}]" info:` and adjust the `-transparent` value accordingly.

**Step 3 — Add a row to the `## Models` table in `README.md`** using the same markdown table format as the existing entries.
