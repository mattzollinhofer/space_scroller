# Specification: Audio Integration

## Goal

Add background music, boss battle tracks, and sound effects to enhance game
immersion with centralized audio control and mute persistence.

## User Stories

- As a player, I want to hear upbeat music during gameplay and intense music
  during boss battles so that the game feels more exciting and immersive
- As a player, I want to hear sound effects when shooting, hitting enemies, and
  taking damage so that I get clear audio feedback on my actions

## Specific Requirements

**Background music plays during gameplay levels**

- Single background track for all gameplay levels (upbeat electronic/synth)
- Music starts when entering main.tscn gameplay scene
- Music stops when returning to main menu or other UI screens
- No music on menu screens (main_menu, character_selection, level_select)
- Music format: OGG Vorbis per Godot best practices

**Boss battle music transitions smoothly when boss spawns**

- Three unique boss tracks (one per level number)
- Crossfade from gameplay music to boss music when `boss_spawned` signal fires
- Music transition should be smooth (not abrupt cutoff)
- Boss music continues until boss defeated or player returns to menu

**High-priority sound effects for core combat**

- Player shooting: trigger on `projectile_fired` signal from player.gd
- Enemy hit/destroyed: trigger on `hit_by_projectile` and `died` signals from
  base_enemy.gd
- Player damage: trigger on `damage_taken` signal from player.gd
- Player death: trigger on `died` signal from player.gd
- Sound effects format: WAV per Godot best practices

**Medium-priority sound effects for boss and progression**

- Boss attacks: trigger on `attack_fired` signal from boss.gd
- Boss damage: trigger when boss `take_hit` is called (health > 0 after hit)
- Level complete: trigger on `level_completed` signal from level_manager.gd
- Game over: trigger when game_over_screen becomes visible

**Lower-priority sound effects for UI and collectibles**

- Menu button clicks: trigger on button `pressed` signals in UI scripts
- Collectible pickups: trigger when pickup collection occurs
- Sidekick actions: trigger on sidekick shooting (via `projectile_fired` connect)

**AudioManager autoload provides centralized control**

- Single autoload following pattern from game_state.gd and transition_manager.gd
- Register in project.godot autoloads section
- Provide play_music(), play_sfx(), toggle_mute() public methods
- Track current music state to enable crossfade transitions

**Simple mute toggle persists between sessions**

- Single mute toggle affects both music and SFX
- Persist mute state using ConfigFile pattern from score_manager.gd
- Store in user://audio_settings.cfg
- Load mute state on AudioManager _ready()

**Audio bus configuration for future extensibility**

- Create separate Music and SFX audio buses in Godot
- Route music to Music bus, effects to SFX bus
- Master bus controls overall volume
- Enables future volume sliders without code changes

## Visual Design

No visual assets provided.

## Leverage Existing Knowledge

**Code, component, or existing logic found**

Autoload Pattern (game_state.gd)

- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:1-40] - Autoload
  structure with _ready, signals, private state
  - Follows Node extension pattern for autoloads
  - Uses private variables with getter/setter methods
  - Emits signals when state changes
  - Initialize to defaults in _ready()

Autoload Pattern (transition_manager.gd)

- [@/Users/matt/dev/space_scroller/scripts/autoloads/transition_manager.gd:1-79] -
  CanvasLayer autoload with tween animations
  - Uses Tween for smooth animations (crossfade pattern)
  - Sets process_mode for always-on behavior
  - Stores reference to current tween to cancel if needed

Signal Architecture (player.gd)

- [@/Users/matt/dev/space_scroller/scripts/player.gd:29-32] - Signal declarations
  for audio hooks
  - `damage_taken`, `lives_changed`, `died`, `projectile_fired` signals
  - Emit projectile_fired in shoot() method (line 208)
  - Emit damage_taken and died in take_damage() method (lines 220-224)

Signal Architecture (base_enemy.gd)

- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:41-44] - Enemy
  signals for audio hooks
  - `died` and `hit_by_projectile` signals defined
  - hit_by_projectile emitted in take_hit() (line 112)
  - died emitted in _on_health_depleted() (line 160)

Signal Architecture (boss.gd)

- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:107-117] - Boss
  signals for audio hooks
  - `boss_defeated`, `boss_entered`, `health_changed`, `attack_fired` signals
  - attack_fired emitted after projectile spawns (lines 249, 305)

Signal Architecture (level_manager.gd)

- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:36-40] - Level
  progression signals
  - `section_changed`, `level_completed`, `player_respawned`, `boss_spawned`
  - boss_spawned emitted after boss setup (line 512)
  - Use boss_spawned to trigger music transition

ConfigFile Persistence (score_manager.gd)

- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:190-246] - ConfigFile
  pattern for settings
  - _save_to_file() creates ConfigFile, sets values, calls save()
  - load_high_scores() loads ConfigFile, reads values with defaults
  - Uses HIGH_SCORE_PATH constant for file location

Signal Connection Pattern (sidekick.gd)

- [@/Users/matt/dev/space_scroller/scripts/pickups/sidekick.gd:40-45] - Connect
  to player signals dynamically
  - Check has_signal() before connecting
  - Store reference to connected node for cleanup
  - Disconnect signals in cleanup method (lines 117-122)

Test Pattern (test_score_display.gd)

- [@/Users/matt/dev/space_scroller/tests/test_score_display.gd:1-102] - Standard
  test structure
  - Load main scene, wait for frame, verify nodes exist
  - Use _pass() and _fail() with quit codes
  - Set timeout to prevent hanging tests

Test Pattern (test_high_score_save_load.gd)

- [@/Users/matt/dev/space_scroller/tests/test_high_score_save_load.gd:1-119] -
  Test ConfigFile persistence
  - Cleanup test file before and after test
  - Verify file creation with FileAccess.file_exists()
  - Test save and load round-trip

**Git Commit found**

Autoload Creation Pattern

- [71be875:Add smooth fade transitions between game screens] - TransitionManager
  autoload creation
  - Creates autoload script extending CanvasLayer
  - Registers in project.godot autoloads section
  - Provides public methods for scene-wide access
  - Includes integration test for functionality

Score System Autoload Pattern

- [55370f9:Award points when player destroys enemies] - ScoreManager autoload
  with signal connections
  - Creates autoload that connects to game events
  - EnemySpawner connects enemy died signals to ScoreManager
  - Pattern for connecting autoload to spawned entities

Sidekick Signal Connection Pattern

- [1fa9c22:Add synchronized shooting for sidekick companion] - Dynamic signal
  connection
  - Connect to existing signals (projectile_fired) dynamically
  - Handle signal disconnect on destruction
  - Pattern for audio manager connecting to game events

## Out of Scope

- Voice acting or narration
- Environmental/ambient sounds (space ambience, engine hum)
- Per-enemy-type unique sounds (all enemies share hit/death sounds)
- Volume sliders (mute toggle only)
- Per-level background music (single gameplay track for all levels)
- Menu background music (menus are silent)
- Positional audio (AudioStreamPlayer2D) - use non-positional for simplicity
- Dynamic music intensity (music does not change based on action density)
- Sound effect variations (each action plays same sound every time)
- Pause menu audio (no audio feedback in pause state)
