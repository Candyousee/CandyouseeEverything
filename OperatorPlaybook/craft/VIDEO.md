# VIDEO: trailers, TikToks, showcase clips, cinematics

Video has been a repeat weak spot. Several takes and one procedural cinematic were rejected. Follow this order strictly.

## 1. Choose the route at intake

| Want | Route |
|---|---|
| Show systems / gameplay (TikTok, store video) | **Real gameplay capture** with scripted cameras: the most reliable route |
| Product showcase (a kit, pets, gear) | A clean Baseplate or a simple stage, a turntable sway (front-facing), real interactions captured in Play |
| Story / anime / character cinematic | Needs hand-keyed or retargeted animation (craft/ANIMATION.md). Code-posed characters will be rejected. If that isn't feasible, tell the owner and offer a gameplay-based alternative |

## 2. Plan before recording

- **Hook in the first 1-2 seconds:** the most exciting moment first, then explain.
- **Shot list:** each shot gets a duration, a subject, framing (wide / medium / close), camera motion and a purpose. Keep 10-15 s TikToks to about 5-8 shots.
- **Format:**
  - vertical 1080x1920 for TikTok / Shorts;
  - horizontal 1920x1080 for trailers.
  - Prefer one horizontal take + a vertical crop over two separate shoots.
- **Clean scene:**
  - the prune sweep done;
  - no debug UI, cursor or tutorial hands;
  - CoreGui hidden;
  - a populated scene (fake players / NPCs) where an empty server would look dead.

## 3. Camera

- Scripted camera paths with eased motion; a lens (FOV) chosen per shot.
- **Clearance check:** raycast the whole camera path. Never fly through signs or skim walls.
- Compose with intent: thirds, the subject's direction of motion has room, the hero is the brightest and highest-contrast thing in frame.
- Wide shots must still read on a phone screen. If the action is small, go closer.

## 4. Record

- Studio focused (an unfocused window drops frames). Record at 60 fps if possible.
- Lighting stable from frame 1.
- Capture several takes of each shot. Pick the best per shot, not the best whole take.

## 5. Edit

- Cut on action; each shot is 1-2.5 s for TikTok.
- Text overlays: short (1-4 words), big, in the game's font style, inside the platform safe zones (top and bottom UI on TikTok).
- Music timed to cuts; SFX on impacts. If the operator can't hear the mix, flag it to the owner as "unheard".
- End card: the game name / logo + a clear call to action.
- ffmpeg for assembly; keep the master and the share copies.

## 6. Review before sending (no exceptions)

- Build a **frame contact sheet** (one frame every about 0.5 s) and review it at 2x:
  - [ ] no clipping through geometry, no wall skims;
  - [ ] no debug UI, cursor, stray hands or placeholder art;
  - [ ] the hero readable in every shot, nothing empty-looking (like a mostly empty leaderboard);
  - [ ] text inside safe zones, spelled right;
  - [ ] colour grade consistent across shots;
  - [ ] no frame drops or stutters (check the frame times).
- **Never send a video with a known flaw.** Fix it, or reshoot the shot.

## Traps (from real misses)

- A vertical TikTok flew through a sign and skimmed walls. It was sent with 2 known flaws and rejected.
- A pet showcase fly-by looked buggy because of the flying pets' motion. Showcase only behaviour that is polished.
- A 13-shot procedural anime clip (code-posed avatars) was rejected as "awful". The route couldn't reach the bar.
