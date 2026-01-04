# Game Creation Playbook

A guide for AI agents helping kids build side-scrolling (or vertical-scrolling) space shooter games.

---

## Agent: Start Here

You are collaborating with a kid (and possibly their parent) to build a custom video game. Your role:

**You are the builder. The kid is the creative director.**

### Your Approach

1. **Ask, don't assume** - The kid has ideas about what they want. Draw them out with questions before building.

2. **Show progress early and often** - Get something playable within the first session. A moving ship on screen is more exciting than a perfect architecture.

3. **Celebrate wins** - When something works, acknowledge it! "Your dragon ship is flying! Want to see it shoot?"

4. **Keep it fun** - This isn't a job. If the kid wants a pizza-shooting hamster fighting gummy bears, that's exactly what you build.

5. **Explain as you go** - When appropriate, briefly explain what you're doing. Kids learn by watching.

6. **Fail forward** - If something breaks, show them how you debug it. Problem-solving is part of the fun.

### Collaboration Workflow

```
1. DISCOVER   → Ask questions to understand their vision
2. ASSET JAM  → Help them create sprites, music, sounds using AI tools
3. BUILD      → Implement features incrementally (always keep it playable)
4. PLAYTEST   → Let them play, gather feedback
5. ITERATE    → Refine based on what they want to change
```

### Pacing Guidelines

| Session Goal | Duration | Milestone |
|--------------|----------|-----------|
| First playable | 30-60 min | Ship moves on screen |
| Core loop | 1-2 hours | Ship shoots, enemies appear |
| First level | 2-3 hours | Complete level with boss |
| Full game | Multiple sessions | 3-6 levels with progression |

### When Parents Are Involved

- Keep them informed of what tools you're using
- Explain any external services (image generation, audio tools)
- Respect any boundaries they set (content, time, complexity)

---

## What We're Building

A **side-scrolling shooter** (or vertical-scroller) where:
- Player controls a ship/character that moves around the screen
- The world scrolls automatically, bringing obstacles and enemies
- Player shoots to destroy enemies
- Levels end with boss battles
- Score tracking and progression between levels

**This playbook is based on "Solar System Showdown"** - a complete 6-level game built with this approach. The patterns here are battle-tested.

---

## Tech Stack

### Required Tools

| Tool | Purpose | Alternatives |
|------|---------|--------------|
| **Godot 4.3+** | Game engine | (Unity, GameMaker Studio 2) |
| **Claude Code** | AI development assistant | (Cursor, GitHub Copilot) |
| **Git** | Version control | (manual backups) |

### Asset Creation Tools

| Tool | Purpose | Alternatives |
|------|---------|--------------|
| **ChatGPT / DALL-E** | Sprite generation | (Midjourney, Stable Diffusion, Leonardo.ai) |
| **Suno** | Music generation | (Udio, AIVA, Soundraw) |
| **sfxr.me** | Retro sound effects | (Bfxr, ChipTone, ElevenLabs SFX) |

### File Formats

- **Sprites**: PNG (256x256 recommended, transparent background)
- **Music**: MP3 or OGG (loopable, 1-3 minutes)
- **Sound Effects**: WAV (short, punchy, under 1 second)

---

## Getting Started

### 1. Install Godot

Download from [godotengine.org](https://godotengine.org). Use version 4.3 or newer.

### 2. Create Project Structure

```
my_game/
├── project.godot          # Godot project file
├── scripts/
│   ├── autoloads/         # Global managers (GameState, Audio, Score)
│   ├── enemies/           # Enemy behaviors
│   ├── pickups/           # Collectibles
│   └── ui/                # Menu and HUD scripts
├── scenes/
│   ├── main.tscn          # Main gameplay scene
│   ├── player.tscn        # Player ship
│   ├── enemies/           # Enemy prefabs
│   └── ui/                # Menu scenes
├── levels/                # Level configuration (JSON)
├── assets/
│   ├── sprites/           # All images
│   └── audio/
│       ├── music/         # Background tracks
│       └── sfx/           # Sound effects
└── tests/                 # Test scenes
```

### 3. Configure Project Settings

In Godot's Project Settings:
- **Display > Window**: Set viewport size (2048x1536 for tablet, or 1920x1080 for desktop)
- **Display > Window > Stretch > Mode**: `canvas_items`
- **Input Map**: Add actions for `move_up`, `move_down`, `move_left`, `move_right`, `fire`

### 4. Set Up Autoloads

Register these singletons in Project Settings > Autoload:
- `GameState` - Selected character, level, difficulty, lives
- `ScoreManager` - Current score, high scores
- `AudioManager` - Music and SFX playback

---

## Questions to Ask the Kid

Use these questions to discover what game they want to build. Ask them conversationally, not as a checklist.

### Theme & Setting

> "What kind of world is your game in?"

- Space (planets, stars, asteroids)
- Ocean (fish, submarines, coral)
- Sky (clouds, birds, airplanes)
- Fantasy (dragons, castles, magic)
- Food world (pizza, candy, vegetables)
- Custom mashup

> "What does your player character look like?"

Prompt them for specifics:
- Animal? Robot? Spaceship? Person?
- Colors?
- Special features? (wings, laser eyes, rocket boosters)

> "Who are the bad guys?"

- What do they look like?
- Are they silly or scary?
- Do they have a leader (the boss)?

### Gameplay Feel

> "How should your game feel - fast and exciting, or slower and strategic?"

This affects scroll speed, enemy count, fire rate.

> "What happens when you beat a level?"

- Unlock next level?
- Get stronger?
- New abilities?

> "What's the final boss like?"

- What does it look like?
- What attacks does it have?
- How do you defeat it?

### Personal Touches

> "What should collecting a power-up look like? Sound like?"

> "What music fits your game - epic orchestra, chiptune, chill beats?"

> "Any special features you've seen in other games you want?"

---

## Asset Creation Workflows

### Sprites with ChatGPT / DALL-E

**Process:**
1. Describe what you need
2. Generate image
3. Download PNG
4. Remove background if needed (Godot can use transparency)
5. Resize to 256x256 (consistent sizing helps)
6. Place in `assets/sprites/`

**Prompt Template:**
```
Create a [SUBJECT] for a 2D side-scrolling video game.
Style: [cartoon/pixel art/hand-drawn/cute/menacing]
View: side view, facing [left/right]
Background: transparent or solid [color] (easy to remove)
The character should look [adjectives: friendly, scary, silly, cool]
Include: [specific features]
```

**Example Prompts:**

*Player Ship:*
```
Create a cute cartoon dragon spaceship for a 2D side-scrolling video game.
Style: colorful cartoon, kid-friendly
View: side view, facing right
Background: transparent
The dragon should look friendly and determined, with small wings and a
glowing tail. Colors: purple and gold.
```

*Enemy:*
```
Create a grumpy gummy bear alien for a 2D side-scrolling video game.
Style: cartoon, slightly menacing but still cute
View: side view, facing left
Background: solid green (for easy removal)
The gummy bear should look squishy and translucent with angry eyebrows.
Colors: red and orange.
```

*Boss:*
```
Create a giant pizza boss monster for a 2D video game.
Style: cartoon, imposing but silly
View: front-facing or 3/4 view
Background: transparent
The pizza should have angry pepperoni eyes, cheese dripping like tentacles,
and look like it's ready to fight. Make it look powerful but funny.
```

*Projectile:*
```
Create a small glowing energy orb projectile for a 2D space shooter game.
Style: simple, glowing effect
View: any (it's round)
Background: transparent
Colors: bright cyan with white center glow
Size: small, will be scaled down in game
```

*Obstacle (Asteroid):*
```
Create a rocky space asteroid for a 2D space shooter game.
Style: semi-realistic with cartoon shading
View: any angle
Background: transparent
Gray and brown rocky texture with some craters.
```

### Music with Suno

**Process:**
1. Go to suno.com
2. Describe the music style
3. Generate (usually 1-2 minutes)
4. Download MP3
5. Test loop point (trim if needed)
6. Place in `assets/audio/music/`

**Prompt Template:**
```
[MOOD] [GENRE] music for a [CONTEXT].
[TEMPO] BPM, [ADDITIONAL DESCRIPTORS].
[INSTRUMENTAL/VOCALS], loopable, [DURATION].
```

**Example Prompts:**

*Gameplay Music:*
```
Upbeat electronic synth, retro arcade style, energetic space shooter theme.
Kid-friendly, 120-140 BPM, bright and exciting.
8-bit inspired but modern production, no vocals, loopable.
```

*Boss Battle Music:*
```
Intense electronic boss battle music for a space shooter game.
Dramatic synth, driving beat, urgent and threatening.
140-150 BPM, epic confrontation, loopable, no vocals.
```

*Menu Music:*
```
Calm, friendly electronic menu music for a kids video game.
Spacey synth pads, gentle melody, welcoming atmosphere.
90-100 BPM, loopable, no vocals.
```

*Victory/Level Complete:*
```
Short triumphant victory fanfare for completing a video game level.
Bright, celebratory, orchestral synth.
About 10-15 seconds, builds to a satisfying finish.
```

### Sound Effects with sfxr.me

**Process:**
1. Go to sfxr.me (or download BFXR)
2. Click category buttons to generate random sounds
3. Tweak parameters until it sounds right
4. Export as WAV
5. Place in `assets/audio/sfx/`

**Sound Categories to Create:**

| Sound | sfxr.me Preset | Tweaks |
|-------|----------------|--------|
| Player shoot | "Laser/Shoot" | Short, bright, not annoying (will repeat often) |
| Enemy hit | "Hit/Hurt" | Quick impact, satisfying |
| Enemy destroyed | "Explosion" | Small, punchy |
| Player damage | "Hit/Hurt" | Lower pitch, warning feel |
| Pickup collect | "Pickup/Coin" | Happy, bright chime |
| Boss attack | "Laser/Shoot" | Deeper, more powerful |
| Boss defeated | "Explosion" | Big, dramatic |
| Menu click | "Blip/Select" | Soft, UI-appropriate |
| Level complete | "Powerup" | Triumphant jingle |

**Tips:**
- Keep sounds SHORT (0.1-0.5 seconds for most)
- Player shoot sound will play constantly - make it quiet/pleasant
- Test sounds in-game early; some sound great alone but annoying in context

---

## Default Assets Needed

At minimum, you need these assets to have a playable game:

### Sprites (Required)

| Asset | Size | Notes |
|-------|------|-------|
| Player ship | 256x256 | Facing right (side-scroller) or up (vertical) |
| Enemy (basic) | 256x256 | Facing opposite of player |
| Boss | 256x256+ | Can be larger, will scale |
| Projectile (player) | 64x64 | Small, bright |
| Projectile (enemy) | 64x64 | Visually distinct from player's |
| Asteroid/Obstacle | 256x256 | 2-3 size variants nice to have |
| Explosion | 256x256 | Destruction effect |
| Health pickup | 128x128 | Heart or health symbol |
| Background tile | 512x512 | Tileable star field or theme |

### Audio (Required)

| Asset | Duration | Notes |
|-------|----------|-------|
| Gameplay music | 1-3 min | Loopable |
| Boss music | 1-2 min | Loopable, more intense |
| Player shoot | 0.1s | Will play frequently |
| Enemy destroyed | 0.2s | Satisfying |
| Player damage | 0.2s | Warning |
| Level complete | 0.5s | Celebration |

### Optional But Nice

- Multiple player characters to choose from
- Per-level boss music
- Pickup spawn sound
- Menu music
- Multiple explosion variants
- Parallax background layers (stars, nebulae, debris)

---

## Per-Level Customization

Each level can customize these elements through configuration:

### Level JSON Structure

```json
{
  "total_distance": 15000,
  "metadata": {
    "scroll_speed_multiplier": 1.2,
    "background_theme": "ice",
    "boss_sprite": "res://assets/sprites/boss-ice-dragon.png",
    "boss_config": {
      "health": 15,
      "scale": 1.5,
      "attacks": [0, 5, 6],
      "attack_cooldown": 1.5,
      "projectile_sprite": "res://assets/sprites/ice-shard.png"
    },
    "explosion_sprite": "res://assets/sprites/ice-explosion.png"
  },
  "enemy_config": {
    "zigzag_speed_min": 120,
    "zigzag_speed_max": 180,
    "zigzag_angle_min": 35,
    "zigzag_angle_max": 75
  },
  "sections": [
    {
      "name": "Opening",
      "start_percent": 0,
      "end_percent": 20,
      "obstacle_density": "low",
      "enemy_waves": [
        { "enemy_type": "stationary", "count": 3 }
      ]
    }
  ]
}
```

### What's Customizable Per Level

| Element | How to Customize |
|---------|------------------|
| **Length** | `total_distance` (10000-25000 pixels) |
| **Speed** | `scroll_speed_multiplier` (1.0 = normal, 1.5 = fast) |
| **Background** | `background_theme` + custom parallax assets |
| **Boss appearance** | `boss_sprite` path |
| **Boss difficulty** | `health`, `attack_cooldown`, `scale` |
| **Boss attacks** | `attacks` array of attack pattern IDs |
| **Boss projectiles** | `projectile_sprite` path |
| **Enemy difficulty** | `zigzag_speed_*`, `zigzag_angle_*` |
| **Pacing** | `sections` array with densities and waves |
| **Special enemies** | Custom enemy type for this level only |
| **Explosion effects** | `explosion_sprite` path |

### Difficulty Progression Example

| Level | Distance | Speed | Boss HP | Enemy Speed |
|-------|----------|-------|---------|-------------|
| 1 | 10000 | 1.0x | 10 | 100-140 |
| 2 | 14000 | 1.1x | 12 | 110-160 |
| 3 | 18000 | 1.2x | 15 | 120-180 |
| 4 | 22000 | 1.3x | 18 | 130-200 |
| 5 | 24000 | 1.35x | 20 | 140-220 |
| 6 | 24000 | 1.4x | 25 | 150-240 |

---

## Development Order

Build features in this order for the smoothest progression:

### Phase 1: Foundation (First Session Goal)

1. **Project Setup** - Godot project, folder structure, settings
2. **Player Character** - Ship on screen, moves with keyboard/touch
3. **Scrolling Background** - Parallax star field moving left
4. **Screen Boundaries** - Player can't leave play area

**Milestone: "I can fly my ship around!"**

### Phase 2: Core Combat

5. **Obstacles** - Asteroids spawn and scroll past
6. **Player Health** - Taking damage, lives system
7. **Basic Enemies** - Stationary and patrol enemies
8. **Player Shooting** - Projectiles that destroy enemies
9. **Enemy Spawner** - Continuous enemy generation

**Milestone: "I can shoot bad guys!"**

### Phase 3: Progression

10. **Level Structure** - Progress bar, sections, difficulty ramp
11. **Boss Battle** - End boss with health bar and attacks
12. **Score System** - Points for kills, high score tracking
13. **Game UI** - Main menu, pause, game over screens
14. **Level Complete** - Victory screen, next level

**Milestone: "I can beat a level!"**

### Phase 4: Polish

15. **Audio** - Music and sound effects
16. **Visual Juice** - Screen shake, particles, hit flashes
17. **Additional Levels** - More content with new themes
18. **Character Selection** - Multiple playable ships

**Milestone: "This feels like a real game!"**

### Phase 5: Release

19. **Web Export** - Playable in browser
20. **Mobile Export** - iOS/Android build (optional)

---

## Enemy Types Reference

Built-in enemy behaviors that can be mixed and matched:

| Type | Behavior | HP | Points | Best For |
|------|----------|-----|--------|----------|
| **Stationary** | Drifts left with scroll | 1 | 100 | Early levels, filler |
| **Patrol** | Zigzags up/down while drifting | 2 | 200 | Medium challenge |
| **Shooting** | Fires projectiles at player | 1 | 150 | Ranged threat |
| **Charger** | Pauses, then rushes at player | 1 | 200 | Surprise attacks |
| **Special** | Level-specific themed enemy | 3-5 | 300 | Level identity |

### Adding a New Enemy Type

1. Create sprite (facing left for side-scroller)
2. Create scene extending `base_enemy.tscn`
3. Add unique behavior in script
4. Register in `enemy_spawner.gd`
5. Add to level JSON waves

---

## Boss Attack Patterns Reference

Available attack pattern IDs for boss configuration:

| ID | Name | Description |
|----|------|-------------|
| 0 | Barrage | Spread of 6 projectiles |
| 1 | Sweep | Vertical sweep across screen |
| 2 | Charge | Lunge at player position |
| 3 | Solar Flare | Expanding orange pattern |
| 4 | Heat Wave | Rapid horizontal sweep |
| 5 | Ice Shards | Cyan projectile pattern |
| 6 | Frozen Nova | Circular ice pattern |
| 7 | Pepperoni Spread | Pizza-themed spread |
| 8 | Circle Movement | Boss circles, shoots outward |
| 9 | Wall Attack | Projectile wall pattern |
| 10 | Square Movement | Boss moves in square |
| 11 | Up/Down Shooting | Vertical attacks |
| 12 | Grow/Shrink | Boss scales during attack |
| 13 | Rapid Fire | Fast projectile spam |

### Creating a New Attack Pattern

1. Add new attack ID constant in `boss.gd`
2. Implement `_attack_pattern_[name]()` method
3. Add case to attack selector switch
4. Configure in level JSON `attacks` array

---

## Testing Your Game

### Running Tests

```bash
# Single test
timeout 10 godot --headless --path . tests/test_player_movement.tscn

# All tests
timeout 180 bash -c 'for t in tests/*.tscn; do timeout 10 godot --headless --path . "$t"; done'
```

### Test Structure

Each test is a standalone scene that:
1. Sets up the scenario
2. Simulates actions or waits for events
3. Checks expected outcomes
4. Exits with code 0 (pass) or 1 (fail)

### What to Test

| Feature | Test Cases |
|---------|------------|
| Player | Movement bounds, damage, invincibility |
| Enemies | Spawning, collision, destruction |
| Boss | Health, attacks, victory condition |
| Scoring | Points awarded, high score save |
| UI | Menu navigation, pause/resume |
| Audio | Music plays, SFX triggers |
| Levels | Progression, unlock system |

---

## Vertical Scroller Adaptation

To convert this system to a vertical scroller (player at bottom, scrolls up):

### Key Changes

| System | Side-Scroller | Vertical-Scroller |
|--------|---------------|-------------------|
| Player position | Left side | Bottom |
| Player faces | Right | Up |
| Scroll direction | Left | Down |
| Enemy spawn | Right edge | Top edge |
| Projectile direction | Right | Up |
| Boss position | Right side | Top |

### Code Changes Needed

1. **Player movement** - Swap X/Y constraints
2. **Scroll direction** - Change velocity from `(-speed, 0)` to `(0, speed)`
3. **Spawner positions** - Spawn at top (y = -100) instead of right
4. **Projectile velocity** - Fire up `(0, -speed)` instead of right
5. **Boss entrance** - Slide in from top instead of right
6. **Parallax** - Scroll vertically instead of horizontally

### Sprite Orientation

- Player faces UP (not right)
- Enemies face DOWN (not left)
- Projectiles oriented vertically

---

## Common Issues & Solutions

### "My sprite has a colored background"

Use an image editor or Godot shader to remove it. For solid color backgrounds, the `green_to_transparent.gdshader` pattern works.

### "The game feels too fast/slow"

Adjust these values:
- `scroll_speed` in level manager (default 180 px/s)
- `scroll_speed_multiplier` per level
- Player `SPEED` constant (default 600 px/s)

### "Enemies are too hard/easy"

Tune in level JSON:
- `zigzag_speed_min/max` - How fast they move
- `zigzag_angle_min/max` - How erratic the pattern
- Enemy wave counts in sections
- `obstacle_density` settings

### "Boss is impossible/too easy"

Adjust in level JSON `boss_config`:
- `health` - More HP = longer fight
- `attack_cooldown` - Lower = more attacks
- `attacks` array - More patterns = more variety

### "Audio is too loud/quiet"

In `audio_manager.gd`:
- Adjust `MUSIC_VOLUME_DB` (default -3)
- Per-SFX volume adjustments in `_play_sfx()` method

---

## Example: Building Level 4 (Pizza Theme)

Here's how a complete themed level came together:

### 1. Theme Discovery

> "What's your level about?"
> "PIZZA! A giant evil pizza boss!"

### 2. Asset Creation

**Boss Sprite Prompt:**
```
Create a giant pepperoni pizza boss monster for a 2D video game.
Cartoon style, menacing but silly. The pizza has angry eyes made of
pepperoni, cheese dripping like tentacles. Front-facing view.
Transparent background.
```

**Special Enemy Prompt:**
```
Create a garlic clove alien soldier for a 2D side-scrolling game.
Cartoon style, small and angry. White/cream colored with purple
accents. Facing left. Transparent background.
```

**Boss Music Prompt (Suno):**
```
Italian-inspired boss battle music, dramatic mandolin mixed with
electronic synth, fast-paced and intense, pizza parlor gone wrong
vibes, 150 BPM, loopable, no vocals.
```

### 3. Level Configuration

```json
{
  "total_distance": 24000,
  "metadata": {
    "scroll_speed_multiplier": 1.3,
    "boss_sprite": "res://assets/sprites/pepperoni-pizza-boss-1.png",
    "boss_config": {
      "health": 18,
      "scale": 2.0,
      "attacks": [7, 8],
      "attack_cooldown": 1.3,
      "projectile_sprite": "res://assets/sprites/weapon-pepperoni.png"
    }
  },
  "enemy_config": {
    "zigzag_speed_min": 130,
    "zigzag_speed_max": 200
  },
  "special_enemy": {
    "type": "garlic",
    "sprite": "res://assets/sprites/garlic-man.png",
    "health": 3,
    "spawn_count": 10
  }
}
```

### 4. Custom Attacks

Added two pizza-themed boss attacks:
- **Pepperoni Spread (ID 7)** - Red/orange projectiles in spread pattern
- **Circle Movement (ID 8)** - Boss circles arena while shooting

### 5. Polish

- Custom explosion effect (cheese splatter)
- Matching projectile sprites
- Themed section names ("Appetizer", "Main Course", "Dessert")

---

## Quick Reference: File Locations

| What | Where |
|------|-------|
| Add new level | `levels/level_N.json` |
| Add player character | `GameState.gd` + sprite in `assets/sprites/` |
| Add enemy type | `scripts/enemies/` + scene in `scenes/enemies/` |
| Add boss attack | `scripts/enemies/boss.gd` |
| Add music track | `assets/audio/music/` + `audio_manager.gd` |
| Add sound effect | `assets/audio/sfx/` + `audio_manager.gd` |
| Modify UI | `scripts/ui/` + scenes in `scenes/ui/` |
| Change game settings | `scripts/autoloads/game_state.gd` |
| Change scoring | `scripts/score_manager.gd` |
| Change sprite sizes | `scripts/sprite_sizes.gd` |

---

## Appendix: Commit History as Learning Path

The game was built in this order over ~300 commits. This sequence works:

1. Project setup and configuration
2. Player movement (keyboard + touch)
3. Camera and viewport
4. Parallax scrolling background
5. Screen boundaries
6. Asteroids with collision
7. Player health and lives
8. Game over screen
9. Basic enemies (stationary, patrol)
10. Player shooting
11. Enemy spawning system
12. Level progress bar
13. Section-based difficulty
14. Boss spawn and entrance
15. Boss health bar
16. Boss attacks
17. Score display
18. Main menu
19. Level complete screen
20. High score persistence
21. Character selection
22. Sidekick companion
23. Audio integration
24. Visual polish (particles, shake)
25. Additional levels
26. Web export

Each step built on the previous, keeping the game playable throughout.

---

## Remember

The goal isn't a perfect game. The goal is a game **they made** that **they're proud of**.

Keep it playable. Keep it fun. Ship it.
