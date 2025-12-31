# Task Breakdown: Audio Integration

## Overview

Total Slices: 7
Each slice delivers incremental user value and is tested end-to-end.

## Task List

### Slice 1: Player hears background music during gameplay

**What this delivers:** When the player enters the main gameplay scene, upbeat background music starts playing automatically.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/autoloads/transition_manager.gd:1-79] - Autoload structure with CanvasLayer, process_mode, and tween animations
- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:1-40] - Autoload with private state and getter/setter methods
- [@/Users/matt/dev/space_scroller/project.godot:18-22] - Autoload registration in project.godot
- [commit:71be875] - TransitionManager autoload creation pattern

#### Tasks

- [x] 1.1 Write integration test that verifies music plays when entering main.tscn
- [x] 1.2 Run test, verify expected failure [AudioManager autoload not found] -> Created test
- [x] 1.3 Create AudioManager autoload script (scripts/autoloads/audio_manager.gd)
- [x] 1.4 Register AudioManager in project.godot autoloads section
- [x] 1.5 Create audio bus layout with Master, Music, and SFX buses (default_bus_layout.tres)
- [x] 1.6 Add AudioStreamPlayer nodes for music playback to AudioManager
- [x] 1.7 Implement play_music() method to start background music
- [x] 1.8 Source/create placeholder background music track (assets/audio/music/gameplay.wav)
- [x] 1.9 Call AudioManager.play_music() when main.tscn loads (in level_manager.gd)
- [x] 1.10 Run test, iterate as needed until music plays - Success
- [x] 1.11 Verify manually that music starts on gameplay entry (skipped - headless environment)
- [x] 1.12 Commit working slice - commit a602494

**Acceptance Criteria:**
- Background music starts when player enters main gameplay scene
- Music plays continuously during gameplay
- Integration test passes

---

### Slice 2: Music stops when leaving gameplay for menus

**What this delivers:** When the player returns to main menu (via pause menu, game over, or level complete), the music stops. Menu screens are silent.

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/pause_menu.gd] - Menu navigation patterns
- [@/Users/matt/dev/space_scroller/scripts/game_over_screen.gd] - Screen transition to menu

#### Tasks

- [x] 2.1 Write integration test verifying music stops when transitioning to menu
- [x] 2.2 Run test, verify expected failure [stop_music already implemented in Slice 1] -> Test passed
- [x] 2.3 Implement stop_music() method in AudioManager [already existed from Slice 1]
- [x] 2.4 Call AudioManager.stop_music() before scene transitions to menus
  - Added to pause_menu.gd _on_quit_button_pressed()
  - Added to game_over_screen.gd _on_main_menu_button_pressed()
  - Added to level_complete_screen.gd _on_main_menu_pressed()
- [x] 2.5 Ensure main_menu.tscn does not trigger music playback [already correct - no play_music call]
- [x] 2.6 Run test, iterate as needed - Success
- [x] 2.7 Verify music behavior on pause menu quit, game over return, and level complete transitions - All verified via test_audio_menu_transitions.gd
- [x] 2.8 Run slice 1 and 2 tests to verify no regressions - All passed
- [x] 2.9 Commit working slice - commit b07fab5

**Acceptance Criteria:**
- Music stops when returning to main menu
- No music plays on menu screens
- Previous slice functionality still works

---

### Slice 3: Boss battle music crossfades when boss spawns

**What this delivers:** When the boss spawns (at 100% progress), the gameplay music smoothly crossfades to an intense boss battle track specific to the current level.

**Dependencies:** Slice 1, Slice 2

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:36-40] - boss_spawned signal at line 512
- [@/Users/matt/dev/space_scroller/scripts/autoloads/transition_manager.gd:45-58] - Tween animation pattern for smooth transitions
- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:87-96] - Getting current level number

#### Tasks

- [x] 3.1 Write integration test that verifies boss music plays after boss_spawned signal
- [x] 3.2 Run test, verify expected failure - AudioManager methods not found
- [x] 3.3 Source/create 3 boss music tracks (assets/audio/music/boss_1.wav, boss_2.wav, boss_3.wav)
- [x] 3.4 Add second AudioStreamPlayer for boss music (enables crossfade) - _music_player_b
- [x] 3.5 Implement crossfade_to_boss_music(level_number: int) method with tween animation
- [x] 3.6 Track current music state (_is_boss_music_playing) in AudioManager
- [x] 3.7 Connect AudioManager to boss_spawned signal from LevelManager (via level_manager.gd call)
- [x] 3.8 Run test, iterate until crossfade works - Success
- [x] 3.9 Manually verify smooth crossfade (skipped - headless environment)
- [x] 3.10 Run all slice tests to verify no regressions - All 4 audio tests pass
- [x] 3.11 Commit working slice

**Acceptance Criteria:**
- Boss music starts when boss_spawned signal fires
- Transition is smooth crossfade (not abrupt)
- Correct boss track plays for each level (1, 2, or 3)
- Previous slice functionality still works

---

### Slice 4: Player hears high-priority combat sound effects

**What this delivers:** Player hears audio feedback for shooting, enemy hits, enemy destruction, taking damage, and dying.

**Dependencies:** Slice 1 (AudioManager exists)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/player.gd:29-32] - Player signals: projectile_fired, damage_taken, died
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:41-44] - Enemy signals: hit_by_projectile, died
- [@/Users/matt/dev/space_scroller/scripts/pickups/sidekick.gd:40-45] - Dynamic signal connection pattern

#### Tasks

- [ ] 4.1 Write integration test that verifies SFX play on player shooting
- [ ] 4.2 Run test, verify expected failure
- [ ] 4.3 Source/create high-priority SFX assets (WAV format):
  - assets/audio/sfx/player_shoot.wav
  - assets/audio/sfx/enemy_hit.wav
  - assets/audio/sfx/enemy_destroyed.wav
  - assets/audio/sfx/player_damage.wav
  - assets/audio/sfx/player_death.wav
- [ ] 4.4 Implement play_sfx(sfx_name: String) method in AudioManager
- [ ] 4.5 Add AudioStreamPlayer nodes for SFX playback (multiple for overlapping sounds)
- [ ] 4.6 Preload SFX resources in AudioManager._ready()
- [ ] 4.7 Connect player.projectile_fired signal to play player_shoot SFX
- [ ] 4.8 Connect player.damage_taken signal to play player_damage SFX
- [ ] 4.9 Connect player.died signal to play player_death SFX
- [ ] 4.10 Connect to enemy signals through EnemySpawner (or global approach)
- [ ] 4.11 Run test, iterate until SFX plays correctly
- [ ] 4.12 Run all tests to verify no regressions
- [ ] 4.13 Commit working slice

**Acceptance Criteria:**
- Player shooting produces sound effect
- Enemy being hit produces sound effect
- Enemy being destroyed produces sound effect
- Player taking damage produces sound effect
- Player death produces sound effect
- Previous slice functionality still works

---

### Slice 5: Player hears boss and progression sound effects

**What this delivers:** Player hears audio feedback for boss attacks, boss taking damage, level completion, and game over.

**Dependencies:** Slice 4 (SFX infrastructure)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:107-117] - Boss signals: attack_fired, health_changed
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:36-40] - level_completed signal
- [@/Users/matt/dev/space_scroller/scripts/game_over_screen.gd] - Game over screen visibility

#### Tasks

- [ ] 5.1 Write integration test that verifies boss attack SFX plays
- [ ] 5.2 Run test, verify expected failure
- [ ] 5.3 Source/create medium-priority SFX assets:
  - assets/audio/sfx/boss_attack.wav
  - assets/audio/sfx/boss_damage.wav
  - assets/audio/sfx/level_complete.wav
  - assets/audio/sfx/game_over.wav
- [ ] 5.4 Preload new SFX resources in AudioManager
- [ ] 5.5 Connect boss.attack_fired signal to play boss_attack SFX
- [ ] 5.6 Connect to boss damage (via take_hit or health_changed signal)
- [ ] 5.7 Connect level_manager.level_completed signal to play level_complete SFX
- [ ] 5.8 Trigger game_over SFX when game_over_screen becomes visible
- [ ] 5.9 Run test, iterate until SFX plays correctly
- [ ] 5.10 Run all tests to verify no regressions
- [ ] 5.11 Commit working slice

**Acceptance Criteria:**
- Boss attacks produce sound effect
- Boss taking damage produces sound effect
- Level completion produces sound effect
- Game over screen produces sound effect
- Previous slice functionality still works

---

### Slice 6: Player can mute all audio with persistent toggle

**What this delivers:** Player can mute both music and SFX with a single toggle. The mute state persists between game sessions.

**Dependencies:** Slice 1, Slice 4 (music and SFX exist)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:190-246] - ConfigFile persistence pattern
- [@/Users/matt/dev/space_scroller/tests/test_high_score_save_load.gd:1-119] - Testing ConfigFile persistence

#### Tasks

- [ ] 6.1 Write integration test that verifies mute state persists across sessions
- [ ] 6.2 Run test, verify expected failure
- [ ] 6.3 Implement toggle_mute() method in AudioManager
- [ ] 6.4 Implement is_muted() getter in AudioManager
- [ ] 6.5 Mute implementation: set Music and SFX bus volumes to -80db (silent) when muted
- [ ] 6.6 Create _save_settings() method using ConfigFile (user://audio_settings.cfg)
- [ ] 6.7 Create _load_settings() method to restore mute state on AudioManager._ready()
- [ ] 6.8 Add mute toggle UI button to pause menu (optional: main menu too)
- [ ] 6.9 Connect mute button to AudioManager.toggle_mute()
- [ ] 6.10 Run test, iterate until persistence works
- [ ] 6.11 Manually verify mute persists after closing and reopening game
- [ ] 6.12 Run all tests to verify no regressions
- [ ] 6.13 Commit working slice

**Acceptance Criteria:**
- toggle_mute() silences all audio
- toggle_mute() again restores audio
- Mute state persists after closing and reopening game
- Mute toggle is accessible from pause menu
- Previous slice functionality still works

---

### Slice 7: Lower-priority UI and collectible sound effects

**What this delivers:** Player hears audio feedback for menu button clicks, collectible pickups, and sidekick shooting.

**Dependencies:** Slice 4 (SFX infrastructure)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/main_menu.gd] - Button press handlers
- [@/Users/matt/dev/space_scroller/scripts/pickups/sidekick.gd:77-80] - Sidekick shooting

#### Tasks

- [ ] 7.1 Source/create lower-priority SFX assets:
  - assets/audio/sfx/button_click.wav
  - assets/audio/sfx/pickup_collect.wav
  - assets/audio/sfx/sidekick_shoot.wav (or reuse player_shoot.wav)
- [ ] 7.2 Preload new SFX resources in AudioManager
- [ ] 7.3 Add button click SFX to menu button pressed signals (main_menu, pause_menu, etc.)
- [ ] 7.4 Add pickup collection SFX to pickup scripts
- [ ] 7.5 Add sidekick shooting SFX (could be same as player shoot or unique)
- [ ] 7.6 Manually verify all lower-priority SFX work
- [ ] 7.7 Run full test suite to verify no regressions
- [ ] 7.8 Final cleanup and code review
- [ ] 7.9 Commit working slice

**Acceptance Criteria:**
- Menu button clicks produce sound effect
- Collecting pickups produces sound effect
- Sidekick shooting produces sound effect
- All previous functionality still works
- All audio features complete per spec

---

## Notes

### Audio File Organization

```
assets/
  audio/
    music/
      gameplay.ogg      # Background music for all levels
      boss_1.ogg        # Level 1 boss battle music
      boss_2.ogg        # Level 2 boss battle music
      boss_3.ogg        # Level 3 boss battle music
    sfx/
      player_shoot.wav
      enemy_hit.wav
      enemy_destroyed.wav
      player_damage.wav
      player_death.wav
      boss_attack.wav
      boss_damage.wav
      level_complete.wav
      game_over.wav
      button_click.wav
      pickup_collect.wav
      sidekick_shoot.wav (optional, may reuse player_shoot)
```

### AudioManager Structure

```gdscript
extends Node

# Audio buses
const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

# Settings persistence
const AUDIO_SETTINGS_PATH := "user://audio_settings.cfg"

# Music players (two for crossfade)
var _music_player_a: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer
var _active_music_player: AudioStreamPlayer

# SFX players (pool for overlapping sounds)
var _sfx_players: Array[AudioStreamPlayer]

# State
var _is_muted: bool = false
var _is_boss_music_playing: bool = false

# Public API
func play_music(stream: AudioStream) -> void
func stop_music() -> void
func crossfade_to_boss_music(level: int) -> void
func play_sfx(sfx_name: String) -> void
func toggle_mute() -> void
func is_muted() -> bool
```

### Signal Connection Strategy

The AudioManager will need to connect to various game signals. Strategy options:

1. **Direct connection in game scenes** - Scenes call AudioManager methods directly
2. **Global signal bus** - AudioManager listens to centralized signals
3. **Scene-based connection** - AudioManager connects when scenes load

Recommended: Mix of approaches
- Player signals: Connect directly in AudioManager._ready() or when main scene loads
- Enemy signals: Connect through EnemySpawner when enemies spawn (like ScoreManager pattern)
- Boss signals: Connect when boss is spawned via level_manager
- UI signals: Direct calls from button press handlers

### Testing Audio

Audio tests are inherently difficult to automate. Focus on:
1. Verifying AudioManager methods exist and can be called
2. Verifying audio buses are configured
3. Verifying signal connections are established
4. Manual testing for actual audio playback quality
