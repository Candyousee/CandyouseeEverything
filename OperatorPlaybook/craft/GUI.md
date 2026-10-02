# GUI: HUD, shop, modals, icons, states, and the GUI gate

Every UI brief includes this whole file. No UI screenshot reaches the owner before it passes section 5 (the gate). The goal: a clean UI on the FIRST delivery, from just the concept.

## 1. The bar: a top front-page Roblox simulator, 9/10

**Style** (the owner's taste):
- cartoony simulator style;
- a chunky rounded font with a dark stroke;
- thick outside strokes;
- a 2-tone bevel gradient + a top highlight strip + an inner rim + a drop shadow;
- candy colours about 10% under first instinct.

**Life:**
- a periodic **sliding shine sweep** on every button, pill and card (never a static white wash over icons);
- spring hover / press on every button;
- idle life (bob / twinkle / pulse) on the 1-2 focal things per screen;
- celebratory purchase feedback.

**Hype:**
- offer ribbons and titles (BEST VALUE, EXCLUSIVE, NEW) are large, rainbow-gradient, bouncing and shining;
- monetization never goes down;
- labels are truthful.

**Streamlined:**
- few tabs;
- a hero banner;
- one clear price button per card;
- a product modal with a big front-facing preview and ONE buy button;
- obvious OWNED / EQUIP states;
- the balance always visible;
- at most 4-5 HUD buttons.

## 2. Icons

- Flat cartoon icons: a thick uniform dark outline, flat cel shading (base + one shadow + one small highlight), simple chunky shapes, cute faces where fitting.
- Readable at 48 px. One consistent set per project, made fresh.
- Made as vector SVG → PNG (Inkscape), or a cleaned image-gen output.
- **Never built from stacked Frames or rotated bars** in Studio: no check marks, arrows, X marks or fingers made of parts.
- **Icon buttons and chips** get a pastel background in their own icon's colour, never uniform grey or navy. The selected state is the brighter, saturated version.
- **Hero icons stand out** from their backdrop: strong contrast, plus a contrasting glow or burst behind them.

## 3. Build rules (prevent problems)

### Structure

- **One theme / component kit drives every screen:** tokens for palette, strokes, radii and motion; components for Button, Card, Pill, Tab, Modal, Bar and Toast. A restyle stays cheap.
- **Layers:** base HUD < modal scrim < modal < overlay (ribbons, badges, stickers, discount tags, pointers, toasts).
  - Overlay elements carry the attribute `Overlay=true`, get the top ZIndex, and are never inside a ClipsDescendants / ScrollingFrame parent.
- **Modals:**
  - hide or tween out the HUD while open;
  - scrim + blur to focus the view;
  - stay inside `GuiService:GetGuiInset()` + a 16 px margin, clear of the CoreGui top-right;
  - the close X sits inside the corner;
  - the height fits the content (no big empty bottom);
  - only one modal at a time (queue them; no popup chains).

### Layout

- **Mobile-first:**
  - Scale sizing + `UIAspectRatioConstraint` / `UIScale`;
  - respect the top bar and device safe areas (`ScreenGui.ScreenInsets`);
  - touch targets ≥ 44 px;
  - never cover the gameplay focus.
- **Grids** are centred and balanced: no orphan alone on a row; equal tiles (2x2, 3x2, 1x4); the scrollbar sits at the content edge.
- **Text never covered and never cramped:**
  - ribbons go in corners, not over titles;
  - every text block has its own area with padding (≥ 4 px from neighbours and button edges);
  - text ≥ 12 px tall on a phone.
- **Centring:** labels, titles, prices, ribbons and the icon + text pairs inside buttons and pills are actually centred. Verify at 2x zoom on EVERY card and tier, not one sample.

### Content

- **Card tints match their item:** a lighter shade of the item's own colour, never one generic background for all cards.
- **Bundles** show a 1-word label under each included item.
- **Strikethrough prices** strike only the number; the discount badge is aligned.
- **Bars:** one track + one inner fill, no double borders; the label is stroked so it's readable over both colours.
- **3D previews** (ViewportFrame) keep the front toward the viewer: a sway of ±25-30°, never a spin.
- **Dynamic text is always a TextLabel,** never baked into an image: prices, countdowns, counts, names. It can then update, localize and scale.
- **One clean piece per visual:** no stacked leftover frames, duplicate strokes or offset shadow copies. Delete experiments.

## 4. Every state, not just the happy path

Each interactive element is built and checked in every state that applies:

| Category | States |
|---|---|
| Interaction | idle, hover, pressed, selected / active, disabled |
| Ownership | locked, affordable, unaffordable, owned, equipped |
| Purchase | prompt open, **in flight (pending)**, success, cancelled, failed |
| Data | loading, empty, error / retry, offline / unavailable |
| Motion | mid-tween, interrupted tween (a new state arrives mid-animation) |

- **Hovered or growing elements draw ON TOP** of their neighbours (raise ZIndex while hovered). Growth is at most about 5% and never collides.
- **Rapid taps:** a double-tapped BUY never opens two prompts. Disable the button while a purchase is pending; debounce tabs.
- **Interrupted motion:** cancel the running tween before starting the next, so nothing ends in a half state.
- **Every screen at 1366x768 AND 844x390,** plus a real phone before release.

## 5. The GUI gate (detect problems)

### 5a. Automated: `ClaudePlugins/tools/gui_audit.luau`

Run it in Play for every screen and every state from section 4, at both sizes. The runner records the viewport size in the report header; a size that doesn't match the label is a failed run. Run `gui_audit_selftest.luau` once per Studio session first: a CLEAN control must give 0 findings, and every defect fixture must be caught.

| Id | Check |
|---|---|
| a | overlap |
| b | outside its parent / off-screen / inside the GUI inset or CoreGui zone |
| c | Overlay not on top or clipped |
| d | text doesn't fit, or is covered |
| e | HUD under an open modal |
| f | leftover / near-duplicate / double border |
| g | unbalanced grid / floating scrollbar |
| h | hover growth collides |
| i | empty modal space |
| j | stray pointer / tutorial hand, cursor in the shot |
| k | cramped text |
| m | text too small |
| p | label padding |
| s | oversized knob |
| w | static wash over an icon |

- Intentional overlaps go in the runner's `Approve` list, each with a written reason.
- Each report also lists approvals that matched nothing (stale) and approvals matching more than about 3 elements (too broad).
- **0 unapproved findings** before any screenshot goes to the owner.

### 5b. Human eye: 2x zoom crops (`gui_audit_crops.py`, `gui_zoom.py`)

The lane AND the operator look at a 2x crop of every hero element: headers, banners, ribbons, card corners, price pills, bars, the close X. Also check the side places. For each one ask: is anything cut, doubled, stuck on, crammed, misaligned, washed out, or peeking from behind?

### 5c. Whole-screen critique

- Is the most important thing the most visible?
- Is anything dark, heavy, empty, unlabeled, redundant or cluttered?
- Do modals focus the view?
- Would an 8-year-old know what to tap next?

## 6. Kits and GUI-only projects

- The demo place is a plain default Baseplate. All effort goes into the GUI.
- A demo controller exposes every screen and state, so the audit runner can drive them (see `gui_audit_runner_example.luau`).
- Ship it as one ScreenGui + one ModuleScript API + a README. Store packaging rules are in craft/CREATOR-STORE.md.

## Traps (from real misses)

- "Shine" meant the periodic sliding sweep, not a static gloss. The static gloss washed out the icons.
- A duplicate "-71%" sticker overlapped the buy button; HUD labels sat on top of their bars; leaderboard text peeked through a window. All were caught only at 2x zoom.
- Grey filter chips were rejected: chips get pastel colours matching their own icon.
- The owner kept finding overlap and leftovers in a GUI kit. This gate exists so the first delivery is clean.
