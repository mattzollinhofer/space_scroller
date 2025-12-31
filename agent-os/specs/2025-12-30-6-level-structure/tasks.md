# Task Breakdown: Level Structure

## Overview

Total Slices: 5
Each slice delivers incremental user value and is tested end-to-end.

This feature builds a complete first level with section-based progression. The key
user experiences are: seeing progress through the level, feeling difficulty changes
between sections, respawning at checkpoints instead of game over, and completing
the level.

## Task List

### Slice 1: Player sees level progress bar on screen

**What this delivers:** A minimal progress bar appears at the top of the screen showing
how far the player has progressed through the level (0-100%). This gives immediate
visual feedback that the level has structure.

**Dependencies:** None

**Reference patterns:**
- [@scenes/ui/game_over_screen.tscn:1-26] - CanvasLayer UI pattern with layer=10, CenterContainer anchors
- [@scripts/game_over_screen.gd:1-24] - CanvasLayer script with process_mode handling
- [@scripts/scroll_controller.gd:1-12] - scroll_offset.x for calculating distance traveled

#### Tasks

- [x] 1.1 Write integration test: verify progress bar exists and updates from 0% toward 100%
- [x] 1.2 Run test, verify expected failure [ProgressBar node not found] -> Created test
- [x] 1.3 Create `res://levels/level_1.json` with total_distance (e.g., 9000 pixels for ~50s)
- [x] 1.4 Create LevelManager script that loads level JSON and tracks progress
- [x] 1.5 Create progress_bar.tscn scene (CanvasLayer with ColorRect for bar background and fill)
- [x] 1.6 Create progress_bar.gd script with `set_progress(percent: float)` method
- [x] 1.7 Add ProgressBar and LevelManager to main.tscn
- [x] 1.8 Connect LevelManager to ScrollController to calculate progress percentage
- [x] 1.9 LevelManager updates ProgressBar each frame based on scroll_offset
- [x] 1.10 Run test, iterate until progress bar displays and updates - Success
- [x] 1.11 Refactor if needed (keep tests green) - No refactoring needed
- [x] 1.12 Commit working slice - Success

**Acceptance Criteria:**
- Progress bar visible at top of screen during gameplay
- Bar fills from left to right as player progresses through level
- Progress reaches 100% after approximately 45-60 seconds of gameplay

---

### Slice 2: Player feels difficulty increase through sections

**What this delivers:** As the player progresses, obstacle density changes noticeably
between sections. Early sections feel calm (fewer obstacles), later sections feel
intense (more obstacles). The player experiences distinct phases of difficulty.

**Dependencies:** Slice 1 (LevelManager, level JSON)

**Reference patterns:**
- [@scripts/obstacles/obstacle_spawner.gd:9-12] - spawn_rate_min/max exports
- [@scripts/obstacles/obstacle_spawner.gd:60-63] - Timer-based spawning with randomized intervals
- [@scripts/enemies/enemy_spawner.gd:1-158] - Similar spawner pattern for enemies

#### Tasks

- [x] 2.1 Write integration test: verify obstacle density changes when section changes
- [x] 2.2 Run test, verify expected failure [set_density method not found] -> Created test
- [x] 2.3 Extend level_1.json with sections array (4 sections with obstacle_density)
- [x] 2.4 Add `set_density(level: String)` method to ObstacleSpawner accepting "low"/"medium"/"high"
- [x] 2.5 LevelManager tracks current section based on progress percentage
- [x] 2.6 LevelManager emits `section_changed(section_index)` signal when entering new section
- [x] 2.7 Connect LevelManager to ObstacleSpawner, call set_density on section change
- [x] 2.8 Run test, iterate until density changes are detectable - Success
- [x] 2.9 Manual playtest: verify noticeable difficulty progression - Skipped (headless)
- [x] 2.10 Refactor if needed (keep tests green) - No refactoring needed
- [x] 2.11 Run all slice tests (1 and 2) to verify no regressions - Success
- [ ] 2.12 Commit working slice

**Acceptance Criteria:**
- Obstacles spawn slowly in early sections (6-9 second intervals)
- Obstacles spawn rapidly in later sections (2-4 second intervals)
- Transition between sections is noticeable during gameplay

---

### Slice 3: Player encounters enemy waves at section boundaries

**What this delivers:** Instead of random continuous enemy spawning, enemies appear
in deliberate waves at the start of sections. This creates memorable encounter moments
and makes the level feel designed rather than random.

**Dependencies:** Slice 2 (sections, section_changed signal)

**Reference patterns:**
- [@scripts/enemies/enemy_spawner.gd:83-106] - Existing spawn methods for enemy types
- [@scripts/enemies/enemy_spawner.gd:109-120] - _setup_enemy helper for positioning

#### Tasks

- [ ] 3.1 Write integration test: verify enemy wave spawns when new section starts
- [ ] 3.2 Run test, verify expected failure
- [ ] 3.3 Extend level_1.json sections with enemy_waves array (enemy_type, count per wave)
- [ ] 3.4 Add `spawn_wave(wave_config: Dictionary)` method to EnemySpawner
- [ ] 3.5 Add `set_continuous_spawning(enabled: bool)` to control random spawning
- [ ] 3.6 LevelManager disables continuous spawning at level start
- [ ] 3.7 LevelManager calls spawn_wave on section change based on section config
- [ ] 3.8 Run test, iterate until wave spawning works
- [ ] 3.9 Manual playtest: verify waves feel intentional and well-timed
- [ ] 3.10 Refactor if needed (keep tests green)
- [ ] 3.11 Run all slice tests (1, 2, and 3) to verify no regressions
- [ ] 3.12 Commit working slice

**Acceptance Criteria:**
- Enemies spawn in groups at section boundaries
- Wave composition matches level JSON configuration
- No random enemy spawning between waves (level feels curated)

---

### Slice 4: Player respawns at checkpoint instead of game over

**What this delivers:** When the player dies after reaching a checkpoint (new section),
they respawn at that checkpoint instead of seeing game over. This reduces frustration
and lets players make progress even through difficult sections.

**Dependencies:** Slice 2 (sections, section_changed signal)

**Reference patterns:**
- [@scripts/player.gd:176-194] - take_damage and died signal emission
- [@scripts/game_over_screen.gd:14-17] - show_game_over connected to player.died
- [@scenes/main.tscn:94] - Signal connection from Player.died to GameOverScreen

#### Tasks

- [ ] 4.1 Write integration test: player dies in section 2, respawns at section 2 start (not game over)
- [ ] 4.2 Run test, verify expected failure (currently shows game over)
- [ ] 4.3 LevelManager stores checkpoint data on section_changed (section_index, player_y)
- [ ] 4.4 Disconnect player.died from GameOverScreen in main.tscn
- [ ] 4.5 Connect player.died to LevelManager._on_player_died
- [ ] 4.6 LevelManager checks if checkpoint exists; if yes, trigger respawn
- [ ] 4.7 Implement respawn: clear all enemies/obstacles, reset player position, reset lives to 1
- [ ] 4.8 Reset spawner timers and section progress to checkpoint state
- [ ] 4.9 If no checkpoint (section 0), emit signal to show game over
- [ ] 4.10 Run test, iterate until checkpoint respawn works
- [ ] 4.11 Write test: player dies in section 0 with no checkpoint, game over shown
- [ ] 4.12 Run regression test, verify game over still works for section 0
- [ ] 4.13 Manual playtest: die in section 2, verify respawn feels fair
- [ ] 4.14 Refactor if needed (keep tests green)
- [ ] 4.15 Run all slice tests (1-4) to verify no regressions
- [ ] 4.16 Commit working slice

**Acceptance Criteria:**
- Dying after section 0 respawns player at last checkpoint
- Screen is cleared of enemies and obstacles on respawn
- Dying in section 0 still shows game over
- Player can make incremental progress through the level

---

### Slice 5: Player sees "Level Complete" when finishing level

**What this delivers:** When the progress bar reaches 100%, the player sees a "Level Complete"
message, giving them a sense of accomplishment. The game pauses to let them appreciate
the victory.

**Dependencies:** Slice 1 (LevelManager, progress tracking)

**Reference patterns:**
- [@scripts/game_over_screen.gd:1-24] - Pause game and show overlay pattern
- [@scenes/ui/game_over_screen.tscn:1-26] - CanvasLayer UI scene structure

#### Tasks

- [ ] 5.1 Write integration test: progress reaches 100%, level_completed signal emitted, UI shown
- [ ] 5.2 Run test, verify expected failure
- [ ] 5.3 LevelManager emits `level_completed` signal when progress >= 100%
- [ ] 5.4 Create level_complete_screen.tscn scene (copy game_over_screen pattern)
- [ ] 5.5 Create level_complete_screen.gd with show_level_complete() method
- [ ] 5.6 Add LevelCompleteScreen to main.tscn
- [ ] 5.7 Connect LevelManager.level_completed to LevelCompleteScreen.show_level_complete
- [ ] 5.8 Stop spawners and player input on level complete
- [ ] 5.9 Run test, iterate until level complete screen appears
- [ ] 5.10 Manual playtest: play through entire level, verify satisfying completion moment
- [ ] 5.11 Refactor if needed (keep tests green)
- [ ] 5.12 Run all slice tests (1-5) to verify no regressions
- [ ] 5.13 Commit working slice

**Acceptance Criteria:**
- "Level Complete" message displays when progress reaches 100%
- Game pauses when level complete screen appears
- Signal emitted for future boss battle integration

---

## Level JSON Structure Reference

The level_1.json file will be built incrementally across slices:

```json
{
  "total_distance": 9000,
  "sections": [
    {
      "name": "Opening",
      "start_percent": 0,
      "end_percent": 20,
      "obstacle_density": "low",
      "enemy_waves": [
        { "enemy_type": "stationary", "count": 2 }
      ]
    },
    {
      "name": "Building",
      "start_percent": 20,
      "end_percent": 50,
      "obstacle_density": "medium",
      "enemy_waves": [
        { "enemy_type": "stationary", "count": 2 },
        { "enemy_type": "patrol", "count": 1 }
      ]
    },
    {
      "name": "Intense",
      "start_percent": 50,
      "end_percent": 80,
      "obstacle_density": "high",
      "enemy_waves": [
        { "enemy_type": "patrol", "count": 2 },
        { "enemy_type": "stationary", "count": 2 }
      ]
    },
    {
      "name": "Final Push",
      "start_percent": 80,
      "end_percent": 100,
      "obstacle_density": "high",
      "enemy_waves": [
        { "enemy_type": "patrol", "count": 3 }
      ]
    }
  ]
}
```

## Technical Notes

- Scroll speed: 180 px/s (from scroll_controller.gd)
- 50 second level = 9000 pixels total distance
- Viewport: 2048x1536 pixels
- Playable Y range: 80-1456 pixels (from obstacle_spawner.gd constants)
- Progress bar: ~500px wide, ~20px tall, centered at top of screen
- Density levels map to spawn intervals:
  - Low: 6.0-9.0 seconds
  - Medium: 4.0-7.0 seconds (current default)
  - High: 2.0-4.0 seconds
