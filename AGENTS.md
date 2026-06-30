# Shapes — OpenSCAD 3D Printing Models

This repository contains parametric OpenSCAD shapes for 3D printing.

## Project Structure

- `*.scad` — OpenSCAD model files
- `images/` — Preview images for the README table of contents

## Build / Render

No lint or typecheck steps. Models are rendered in OpenSCAD.

The OpenSCAD binary path is configured in the **OpenSCAD VS Code extension**. Read it from VS Code settings:

```bash
OPENSCAD=$(jq -r '.["openscad.launchPath"] // empty' \
  ~/Library/Application\ Support/Code/User/settings.json)
OPENSCAD="${OPENSCAD:-$(which openscad)}"
```

## Generating README Preview Images

When adding or updating a model, regenerate its preview image for the README table of contents.

**Step 1 — Render the PNG from OpenSCAD:**

```bash
# Resolve OpenSCAD binary from VS Code extension config
OPENSCAD=$(jq -r '.["openscad.launchPath"] // empty' \
  ~/Library/Application\ Support/Code/User/settings.json)
OPENSCAD="${OPENSCAD:-$(which openscad)}"

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
