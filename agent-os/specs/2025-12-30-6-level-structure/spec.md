# Specification: Level Structure

## Goal

Build a complete first level with section-based progression, density-controlled obstacle spawning, wave-based enemy spawning, automatic checkpoints, and a minimal progress indicator.

## User Stories

- As a player, I want the level to have distinct sections with varying difficulty so that I feel a sense of progression
- As a player, I want to respawn at checkpoints when I die so that I do not lose all my progress

## Specific Requirements

**Player sees level progress on screen**

- Display a minimal progress bar at the top of the screen
- Show progress through the current level (not just section)
- Use CanvasLayer for UI overlay similar to existing game_over_screen.tscn
- Keep styling minimal (white/gray bar, simple design)

**Level flows through 3-5 defined sections**

- Create LevelManager script to orchestrate level flow
- Load level data from JSON file in `res://levels/` directory
- Track current section index and progress within section
- Each section has configurable duration (total level: 45-60 seconds)
- Emit signals when entering new sections and completing level

**Obstacles spawn at density defined by current section**

- Extend ObstacleSpawner to accept dynamic spawn rate parameters
- Add `set_density(density_level)` method accepting "low", "medium", "high"
- Low density: spawn_rate_min=6.0, spawn_rate_max=9.0 seconds
- Medium density: spawn_rate_min=4.0, spawn_rate_max=7.0 seconds (current)
- High density: spawn_rate_min=2.0, spawn_rate_max=4.0 seconds
- LevelManager updates spawner density when section changes

**Enemies spawn in waves at defined points**

- Extend EnemySpawner to support wave-based spawning
- Add `spawn_wave(wave_config)` method for on-demand spawning
- Wave config defines: enemy_type ("stationary" or "patrol"), count
- Waves trigger at section start or at progress percentage thresholds
- Disable continuous spawning when in wave mode (controlled by LevelManager)

**Player respawns at checkpoint on death**

- Checkpoint saved automatically when player enters a new section
- Store checkpoint data: section_index, player_y_position
- On player death, respawn at last checkpoint instead of game over
- Clear all enemies and obstacles on respawn
- Reset spawner timers and section progress to checkpoint state
- Game over only triggers if player dies in section 0 with no checkpoint

**Level ends when all sections complete**

- LevelManager emits `level_completed` signal when final section ends
- Signal can be connected to boss battle system (future roadmap item 7)
- For now, show simple "Level Complete" message or transition state

## Visual Design

No visual mockups provided. Level layout defined through JSON data files.

**Progress Bar (to be implemented)**

- Thin horizontal bar at top of screen
- Shows overall level progress (0-100%)
- Minimal styling: white fill on dark/transparent background
- Width: ~400-600 pixels, centered horizontally
- Height: ~20-30 pixels

## Leverage Existing Knowledge

**Spawner patterns and state management**

[@scripts/obstacles/obstacle_spawner.gd:1-127] - Obstacle spawner with configurable rates
   - Uses @export for spawn_rate_min, spawn_rate_max configuration
   - Tracks active instances in _active_asteroids array
   - Connects to player.died signal to stop spawning on game over
   - Has _game_over boolean to pause spawning
   - Uses _spawn_timer and _next_spawn_time for randomized intervals

[@scripts/enemies/enemy_spawner.gd:1-158] - Enemy spawner with multiple types
   - Supports stationary_enemy_scene and patrol_enemy_scene selection
   - Uses patrol_spawn_chance for probability-based type selection
   - Same timer-based spawning pattern as obstacle spawner
   - _spawn_random_enemy(), _spawn_stationary_enemy(), _spawn_patrol_enemy() methods
   - Can extend with spawn_wave() method for controlled wave spawning

**Scroll controller for progress tracking**

[@scripts/scroll_controller.gd:1-12] - Scroll speed and offset tracking
   - scroll_speed = 180.0 px/s is the world movement rate
   - scroll_offset.x tracks total distance scrolled
   - Can use scroll_offset.x to calculate level progress percentage
   - 45-60 second level = 8100-10800 pixels total scroll distance

**Player signals and state for checkpoint integration**

[@scripts/player.gd:24-28] - Player signals
   - died signal already used by game_over_screen
   - LevelManager can intercept died signal before game over
   - lives_changed signal available for checkpoint state

[@scripts/player.gd:176-194] - Player damage and death handling
   - take_damage() reduces lives and emits died when lives <= 0
   - Checkpoint system needs to prevent game over and trigger respawn

**Game over screen pattern for UI overlays**

[@scripts/game_over_screen.gd:1-24] - CanvasLayer UI pattern
   - Extends CanvasLayer, starts hidden
   - Uses PROCESS_MODE_ALWAYS to work when game paused
   - show_game_over() makes visible and pauses tree
   - Same pattern can be used for progress bar and level complete UI

[@scenes/ui/game_over_screen.tscn:1-26] - UI scene structure
   - Layer 10 for overlay above game content
   - CenterContainer with anchors for centering
   - theme_override_font_sizes for large text
   - Reuse this pattern for level complete screen

**Scene structure and node connections**

[@scenes/main.tscn:69-82] - Spawner integration in main scene
   - ObstacleSpawner and EnemySpawner are children of Main node
   - LevelManager should be added at same level to orchestrate spawners
   - Can reference spawners via get_node() or @export NodePath

[@scenes/main.tscn:83-94] - Player and UILayer structure
   - Player at Main/Player path for signal connections
   - UILayer is CanvasLayer containing UI elements
   - Progress bar should be added to UILayer

**Test patterns for integration testing**

[@tests/test_player_shooting.gd:1-104] - Integration test pattern
   - Extends Node2D for test scene root
   - _test_passed, _test_failed, _failure_reason tracking
   - _timer and _test_timeout for async validation
   - Connect to signals to verify behavior
   - _pass() and _fail() methods with get_tree().quit()

**Git Commit found**

Spawner creation patterns

- [369e20d:Add enemy spawner with continuous enemy generation] - Spawner modeled on ObstacleSpawner
   - Shows how to create spawner with configurable rates
   - Demonstrates tracking active instances and cleanup
   - Pattern for connecting to player.died signal

- [86eeab2:Add asteroid spawner with continuous spawning] - Original spawner implementation
   - Timer-based spawn intervals with randomization
   - Despawn handling when entities leave screen
   - Initial spawn for immediate gameplay

UI overlay patterns

- [e6ac740:Add game over screen displayed when player loses] - UI CanvasLayer pattern
   - CanvasLayer with centered content
   - Pause game tree on show
   - Signal connection from player.died

Signal and collision patterns

- [7ebb7ad:Add player shooting to destroy enemies] - Signal-based communication
   - Shows audio placeholder signals pattern
   - Enemy take_hit() method for external damage
   - Integration test verifying end-to-end behavior

## Out of Scope

- Branching paths or alternate routes through the level
- Power-up placements (deferred to later roadmap item)
- Boss battle implementation (roadmap item 7, uses level_completed signal)
- Polished UI styling and animations (Game UI spec, item 9)
- Additional levels beyond Level 1 (roadmap item 10)
- Audio feedback for section changes or checkpoints (roadmap item 13)
- Restart button or menu after level complete (Game UI spec)
- Lives display or HUD elements beyond progress bar (Game UI spec)
- Difficulty scaling or player-selectable difficulty
- Save/load checkpoint to disk (checkpoints are session-only)
