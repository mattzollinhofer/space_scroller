# Audio Assets

## Sound Effects (sfx/)

Sound effects are created with [jsfxr](https://sfxr.me), a browser-based retro game sound generator.

### File Structure

Each sound has two files:
- `.wav` - The audio file used by the game
- `.json` - The jsfxr parameters (for tweaking/regenerating)

### Categories

| Folder | Purpose | Examples |
|--------|---------|----------|
| `weapons/` | Shooting, missiles, attacks | player laser, boss attacks |
| `impacts/` | Hits, collisions, damage taken | enemy hit, collision |
| `explosions/` | Destruction effects | enemy destroyed, boss death |
| `ui/` | Menu and interface sounds | button clicks, menu navigation |
| `feedback/` | Game events and player feedback | pickups, level complete, life lost |

### Naming Convention

Files use the pattern: `{description}-{variant}.{ext}`

Examples:
- `explosion-1.wav`, `explosion-2.wav` (variants for variety)
- `boss-attack-1.wav`

### How to Tweak a Sound

1. Go to [sfxr.me](https://sfxr.me)
2. Click the folder icon (top-left) to load the `.json` file
3. Adjust parameters using the sliders
4. Click "Export" to download a new `.wav`
5. Save the updated `.json` using the disk icon

### How to Create New Sounds

1. Go to [sfxr.me](https://sfxr.me)
2. Use the category buttons (Pickup, Laser, Explosion, etc.) as starting points
3. Randomize or tweak until you like it
4. Export both `.wav` and `.json` files
5. Place in the appropriate category folder with a numbered suffix

---

## Music (music/)

### Gameplay Music

- **File:** `gameplay.mp3`
- **Source:** [Suno](https://suno.com) (free tier)
- **Prompt used:**
  ```
  upbeat electronic space shooter, synthwave, retro 80s, driving beat,
  energetic, loopable instrumental, no vocals, arcade game music
  ```

### Boss Music

Boss tracks are per-level. Currently silent placeholders pending replacement.

| File | Level | Suggested Prompt |
|------|-------|------------------|
| `boss_1.wav` | 1 | intense boss battle music, electronic, dramatic tension, space combat, heavy synth bass, urgent rhythm, instrumental, no vocals |
| `boss_2.wav` | 2 | epic boss fight, aggressive electronic, faster tempo, sci-fi atmosphere, pulsing synths, climactic, instrumental, no vocals |
| `boss_3.wav` | 3 | final boss battle, cinematic electronic, intense orchestral synths, highest energy, epic climax, dark space theme, instrumental, no vocals |

### How to Create Music with Suno

1. Go to [suno.com](https://suno.com) and sign up (free tier: 50 credits/day)
2. Paste the prompt for the track you want
3. Generate and pick the best result
4. Download as MP3 or WAV
5. Place in `music/` folder with the correct filename

### Volume

Music volume is controlled in `scripts/autoloads/audio_manager.gd`:
```gdscript
const MUSIC_VOLUME_DB := -3.0  # Adjust as needed
```

---

## Supported Formats

The audio manager supports these formats (checked in order):
- **Music:** MP3, OGG, WAV
- **SFX:** WAV, OGG
