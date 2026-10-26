---
name: bs-launchmotion-cta-brush-wipe-sunset
description: "A ragged paint brush sweeps a fjord clip away to reveal a painted sky, where a wordmark paints in, two paint swipes carry the tagline and link, and a frog mascot pops up. Rewrite every line, drop in your own logo and pictures, pick a blue, black-and-white, orange or brand-color theme, and render a 8.6-second MP4 in 1080p or 4K on your own machine."
---

# Brush Wipe Finale

A ragged paint brush sweeps a fjord clip away to reveal a painted sky, where a wordmark paints in, two paint swipes carry the tagline and link, and a frog mascot pops up. One editable HyperFrames project, 8.6 s, 1920×1080 canvas, renders at 1080p (default) or 4K, 30 fps, light scene.

## 1. Start from the user's own material

Before writing any text, collect what the user already has. Their real product always beats a default.

- **Website link.** Open the site first, in a browser tool if you have one (otherwise fetch the HTML). Collect:
  the product name and one-line pitch; three to five features in the site's own words; real numbers
  (users, speed, price) only as stated; the logo (SVG or PNG, else `apple-touch-icon` or the favicon);
  the main brand color (primary buttons, links, logo); and screenshots of the hero and the key product
  sections at 1920 px wide (2x if you can). Save everything in `./brand/` with a short `brand.json`
  (name, pitch, features, numbers, colors, file list). Never invent numbers, customers or quotes.
- **Reference video.** Extract one frame per shot (`ffmpeg -i ref.mp4 -vf "select='gt(scene,0.3)'" -vsync vfr ref-%03d.png`),
  transcribe any speech, and write down what each shot says, how long it holds and which words it uses.
  Match its message, order and pacing. If it shows the user's own product, cut short clips for footage slots.
- **Nothing given.** Ask for the product name and one sentence about it, or keep the defaults.

Then fill the text slots from that material, put the user's logo and screenshots into the picture slots,
and offer the brand color as the theme.

## 2. Theme and font

Ask which look the user wants unless they already said:

- `--theme blue` (default), `--theme mono` (black and white), `--theme orange`, or
- `--accent "#RRGGBB"` for the brand color (for example the one collected from their website).

Backgrounds stay white or clear glass in every theme; the accent only colors buttons, highlighted words,
icons and selection rings. This is a light scene with a white background.
Headlines use Smiley Sans (Deyi Hei) and small interface text uses Inter. `--font inter` keeps Inter
everywhere; `--font path/to/font.woff2` (or .ttf/.otf) uses the user's own headline font.

## 3. Text slots

All visible text is in named slots. Defaults live in `references/defaults.json`; keep each value within its character limit.

| Slot | Default | Max chars |
| --- | --- | --- |
| `previous-caption` | Your next trip starts here | 32 | caption on the outgoing clip
| `brand` | drift | 8 | painted wordmark (Agbalumo), paints in glyph by glyph
| `tagline` | Trips planned while you sleep. | 34 |
| `url` | drift.travel | 18 |

## 4. Picture slots

Pass `--media name=path`. For a slot with several items, pass a comma-separated list or a folder; files are used in order and repeat if there are fewer. Prefer the user's real screenshots for `screenshot` slots and their logo for `logo` slots. Match the aspect ratio or the picture is cropped to fill.

| Slot | Kind | Aspect | Shows |
| --- | --- | --- | --- |
| `previous-footage` | footage | 16:9 | full-frame clip of the previous scene that the brush wipes away (0-2.6 s) |
| `previous-poster` | photo | 16:9 | poster frame under the clip |
| `painted-canvas` | photo | 2040:1160 | painterly backdrop revealed by the brush; shown as a faint grayscale texture on white so the background stays white in every theme |
| `mascot` | avatar | 1:1 | round mascot badge that pops up next to the wordmark |

## 5. Create and render

```bash
node scripts/create.mjs --out ./launch-scene --theme blue --set "previous-caption=Your line here"
npx hyperframes preview ./launch-scene
npx hyperframes render ./launch-scene --output ./launch-scene.mp4 --fps 30 --quality high --resolution 1080p
# 4K: --resolution 4k
```

`--set key=value` can repeat; wrap one phrase in `[[ ]]` to keep the slot's highlight style. `--data content.json` accepts an object of slot values. `node scripts/create.mjs --help` lists every slot.

## Resolution

Before rendering, ask the user whether they want 1080p or 4K. If they do not say, render 1080p. For 4K add
`--resolution 4k` (3840×2160): the scene and its timing stay the same, Chrome renders it at twice the pixel
density, and the render takes longer.

## Style rules

- Never add large color areas: no full-screen color washes, colored panels or tinted backgrounds.
- Cards follow a frosted-glass system: floating controls are glass, large content cards use a thicker
  material, and only the main button is tinted with the accent. Do not add more glass.
- Third-party logos come from the LobeHub icon set in their original colors. Never recolor a logo.
  When the user features their own product, put their logo in the logo slot instead.
- Keep the timeline intact: change words, pictures and the theme, not timings. Keep each value within
  its character limit.

## Check

Inspect the frames at the start, the middle and the final hold. Fix any clipped or wrapping line by shortening the text, and any badly cropped picture by choosing a closer aspect ratio, then render again.
