# AUDIO: SFX, music, voice, mixing

## The bar

- Every player action has a sound that confirms it, and the sound matches the action's weight and the art style.
- The mix is clean: nothing clips, nothing repeats annoyingly, music never drowns out feedback.
- Silence is used on purpose: before a big reveal, and in menus.

## Sources (free; record the source + licence for every file)

| Need | Source |
|---|---|
| UI clicks, pops, coins, whooshes | D:\AI\sfx (Kenney CC0), Sonniss GDC bundles (royalty-free commercial), Freesound CC0 |
| Impacts, foley, ambience | Sonniss GDC bundles, Freesound CC0, OpenGameArt CC0, Pixabay audio |
| Music | ACE-Step (local), CC0 libraries, Roblox's free audio library |
| Voice | Kokoro (local) |
| Editing / layering / batch | SoX, ffmpeg, Audacity |
| Gap filler only | code synthesis (simple blips / tones) |

Stable Audio Open is NOT available. Ignore any prompt that says to use it.

## Craft

1. **Layer the important sounds:**
   - a transient (the click / snap) + a body (the thump / whoosh) + a tail (a sparkle / reverb);
   - a premium reward gets a layer the common one doesn't (a chime, a choir pad, a rising sweep).
2. **Variation:**
   - 3-5 variants, or random pitch ±5-8%, on anything that repeats (footsteps, coins, hits);
   - for rapid repeats, pitch up a step per combo, then reset.
3. **Timing:**
   - align to the frame of the impact, not the start of the animation;
   - a reward sound starts with the visual pop;
   - anticipation sounds (charge, rise) lead into it.
4. **Music:**
   - loops seamless (a crossfade or a cut at the zero-crossing);
   - a separate track per mode (hub, action, shop) with a 1-2 s crossfade;
   - music ducks under big reward stingers.
5. **Spatial:**
   - world sounds are 3D (parented to a part or attachment) with `RollOffMode` + Min/Max distance tuned;
   - UI sounds are 2D (SoundService).

## In Roblox

- **Groups:** SoundGroups for Music / SFX / UI / Voice, with a volume setting per group for players.
- **Format:** OGG or MP3.
  - When converting with ffmpeg, add `-vn`: WAVs with cover art produce a video stream Roblox rejects.
  - Normalize loudness per category before upload (e.g. SFX peaks at about -3 dBFS, music lower).
- **Upload** with `oc_upload.ps1 -Type Audio` (`-GroupId` for group games). Never through Studio `upload_image` (it crashes).
  - Audio must be owned by the experience owner or have permission granted, or it plays silent live.
- **Preload** key sounds (`ContentProvider:PreloadAsync`) so the first play isn't late.
- **Throttle:** limit simultaneous instances of one sound (e.g. at most 4 coin sounds at once).

## Senses: what the ear must catch

- [ ] Every interaction has feedback: tap, buy, equip, error, reward, level up, purchase success / cancel.
- [ ] Nothing clips or distorts at max volume; there's no loudness jump between categories.
- [ ] Repetitive sounds aren't annoying after 50 repetitions (variants / pitch).
- [ ] Music loops without a click or gap; crossfades work.
- [ ] 3D sounds fade naturally with distance; nothing far away is too loud.
- [ ] All audio plays in a LIVE server (ownership), not only in Studio.
- [ ] If the operator can't hear the result, say so: list the sounds for the owner's ear-check rather than claiming they're good.

## Traps (from real misses)

- When the game moved to a group, the user-owned audio went silent live. Upload with `-GroupId`.
- An OGG made from a WAV with cover art was rejected (video stream). Use `-vn`.
- A trailer's music was sent unheard. Flag it to the owner as unheard.
