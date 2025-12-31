# Audio Generation Prompts

Prompts for generating production-quality audio assets using AI tools like Suno,
ElevenLabs Sound Effects, or similar services.

## Current State

The game currently uses placeholder sine-wave audio files. This document provides
prompts to generate proper game audio that matches the space shooter aesthetic.

## Music Tracks

### Gameplay Background Music

**File:** `assets/audio/music/gameplay.ogg`

**Suno Prompt:**
```
Upbeat electronic synth, retro arcade style, energetic space shooter theme,
kid-friendly, loopable, 120-140 BPM, bright and exciting, 8-bit inspired but
modern production, no vocals
```

**Notes:**
- Should loop seamlessly
- Energetic but not overwhelming
- Kid-friendly tone (no dark/scary elements)

---

### Boss Battle - Level 1

**File:** `assets/audio/music/boss_1.ogg`

**Suno Prompt:**
```
Intense electronic boss battle music, space shooter game, dramatic synth,
driving beat, urgent and threatening, 140-150 BPM, epic confrontation,
loopable, no vocals
```

**Notes:**
- Default space theme boss
- Establishes the boss battle feel

---

### Boss Battle - Level 2

**File:** `assets/audio/music/boss_2.ogg`

**Suno Prompt:**
```
Aggressive electronic boss theme, faster tempo, inner solar system heat,
fiery synth pads, pounding drums, menacing and intense, 150-160 BPM,
loopable, no vocals
```

**Notes:**
- Inner solar system (red/orange visual theme)
- More aggressive than Level 1

---

### Boss Battle - Level 3

**File:** `assets/audio/music/boss_3.ogg`

**Suno Prompt:**
```
Epic final boss music, icy electronic synth, outer space atmosphere,
climactic showdown, orchestral synth elements, most intense of the three,
145-155 BPM, loopable, no vocals
```

**Notes:**
- Outer solar system (ice/blue visual theme)
- Final boss - most epic and climactic

---

## Sound Effects

For SFX, consider using dedicated tools like:
- ElevenLabs Sound Effects
- Soundraw
- Freesound.org (for base sounds to modify)
- BFXR/SFXR (retro game sounds)

### Combat SFX

| File | Duration | Prompt |
|------|----------|--------|
| `player_shoot.wav` | 0.1s | Short laser shot sound effect, sci-fi blaster, bright and punchy |
| `enemy_hit.wav` | 0.15s | Impact hit sound, metallic ping, enemy damage feedback |
| `enemy_destroyed.wav` | 0.3s | Small explosion, spaceship destroyed, satisfying pop |
| `player_damage.wav` | 0.2s | Warning alert sound, player hurt, low buzz |
| `player_death.wav` | 0.5s | Ship explosion, defeat sound, dramatic low boom |

### Boss SFX

| File | Duration | Prompt |
|------|----------|--------|
| `boss_attack.wav` | 0.3s | Heavy laser cannon, deep bass shot, powerful boss attack |
| `boss_damage.wav` | 0.25s | Boss hurt sound, metallic crunch, heavy impact |

### Progression SFX

| File | Duration | Prompt |
|------|----------|--------|
| `level_complete.wav` | 0.5s | Victory fanfare, short triumphant jingle, success chime |
| `game_over.wav` | 0.8s | Defeat sound, low somber tone, game over jingle |

### UI/Collectible SFX

| File | Duration | Prompt |
|------|----------|--------|
| `button_click.wav` | 0.08s | UI click, soft button press, menu selection |
| `pickup_collect.wav` | 0.15s | Collectible pickup, bright chime, reward sound, coin-like |
| `sidekick_shoot.wav` | 0.08s | Secondary laser, lighter pew sound, helper ship firing |

---

## Technical Requirements

### Music Files
- Format: OGG Vorbis (Godot preferred)
- Sample Rate: 44.1 kHz
- Ensure seamless looping (check loop points)
- Normalize audio levels consistently across tracks

### SFX Files
- Format: WAV (uncompressed for short sounds)
- Sample Rate: 44.1 kHz
- Keep files short and punchy
- Avoid long tails/reverb that might overlap

### Testing
After replacing placeholder audio:
1. Test all audio in-game
2. Verify volume balance between music and SFX
3. Check that mute toggle still works
4. Ensure crossfade transitions sound smooth

---

## Related

- **Spec:** `agent-os/specs/2025-12-31-15-audio-integration/`
- **AudioManager:** `scripts/autoloads/audio_manager.gd`
- **Roadmap Item:** 18 (Audio Polish)
