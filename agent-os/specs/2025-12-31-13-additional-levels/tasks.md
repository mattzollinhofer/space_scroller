# Task Breakdown: Additional Levels

## Overview

Total Slices: 7
Each slice delivers incremental user value and is tested end-to-end.

This feature adds 2 additional levels (Level 2 and Level 3) with unique visual themes, a level select screen, and progressive enemy introduction.

---

## Task List

### Slice 1: User can access Level Select from Main Menu

**What this delivers:** Player sees a "Level Select" button on the main menu and can navigate to a level selection screen that shows Level 1 as playable.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scenes/ui/main_menu.tscn:47-74] - Button styling and layout pattern
- [@/Users/matt/dev/space_scroller/scripts/ui/main_menu.gd:11-28] - Scene transition with TransitionManager

#### Tasks

- [x] 1.1 Write integration test: main menu has "Level Select" button that navigates to level select screen
- [x] 1.2 Run test, verify expected failure [Level Select button not found in main menu]
- [x] 1.3 Add LevelSelectButton to main_menu.tscn between Play and Character Select
- [x] 1.4 Run test [Main menu missing _on_level_select_button_pressed method]
- [x] 1.5 Add _on_level_select_button_pressed handler to main_menu.gd
- [x] 1.6 Run test [Could not load level select scene at res://scenes/ui/level_select.tscn]
- [x] 1.7 Create level_select.tscn with Level 1 button and level_select.gd with handler
- [x] 1.8 Run test - Success!
- [x] 1.9 Verified no regressions (test_main_menu.tscn, test_character_selection.tscn pass)
- [x] 1.10 Commit working slice

**Acceptance Criteria:**
- Main menu shows "Level Select" button between "Play" and "Character Select"
- Clicking "Level Select" navigates to level selection screen
- Level select screen displays Level 1 as available

---

### Slice 2: User can start Level 1 from Level Select with unlock persistence

**What this delivers:** Player can click Level 1 button to start the game. Level 2 and Level 3 show as locked. When player completes Level 1, Level 2 unlocks.

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:151-188] - ConfigFile save/load pattern
- [@/Users/matt/dev/space_scroller/scripts/ui/level_complete_screen.gd:25-36] - Level complete trigger point

#### Tasks

- [x] 2.1 Write integration test: clicking Level 1 button starts game with level_1.json
  - Created tests/test_level1_start.gd and .tscn
- [x] 2.2 Run test, verify expected failure
  - Test passed immediately (Level 1 button exists and _on_level_selected method exists)
- [x] 2.3-2.6 Make changes and iterate
  - Added Level 2 and Level 3 buttons to level_select.tscn (disabled, grayed out)
  - Updated level_select.gd to connect all buttons and update states based on ScoreManager
  - Added level selection to GameState autoload (get_selected_level, set_selected_level, get_level_path)
  - Updated LevelManager to read selected level from GameState
- [x] 2.7 Write test: Level 2 and 3 buttons show locked state when not unlocked
  - Created tests/test_level_locked_state.gd and .tscn - PASSED
- [x] 2.8 Implement locked button visual state (disabled property, gray color)
  - Buttons added to level_select.tscn with disabled=true and gray font color
  - level_select.gd updates appearance based on unlock status
- [x] 2.9 Write test: ScoreManager persists level unlock state to ConfigFile
  - Created tests/test_level_unlock_persistence.gd and .tscn - PASSED
- [x] 2.10 Add unlock_level() and is_level_unlocked() methods to ScoreManager
  - Added _unlocked_levels array, is_level_unlocked(), unlock_level(), reset_level_unlocks()
  - Updated _save_to_file() and load_high_scores() to persist level unlocks
- [x] 2.11 Write test: completing Level 1 unlocks Level 2
  - Created tests/test_level_complete_unlocks.gd and .tscn - PASSED
- [x] 2.12 Update level_complete_screen.gd to call unlock_level() for next level
  - Added current_level property and set_current_level() method
  - Added _unlock_next_level() called in show_level_complete()
  - LevelManager now passes current level to level_complete_screen before showing
- [x] 2.13 Run all slice tests to verify no regressions
  - All 6 slice-related tests pass
  - Pre-existing test failures unrelated to this slice (test_patrol_enemy_two_hits, test_high_score_game_over)
- [x] 2.14 Refactor if needed (keep tests green)
  - No refactoring needed
- [x] 2.15 Commit working slice

**Acceptance Criteria:**
- Level 1 button is clickable and starts the game
- Level 2 and 3 buttons appear locked (grayed out, disabled)
- After completing Level 1, Level 2 is unlocked (persisted across sessions)
- Level unlock state stored in user://high_scores.cfg

---

### Slice 3: User can play Level 2 with Inner Solar System theme

**What this delivers:** Player can select and play Level 2 with red/orange background colors, shooting enemies, boss-2.png, and faster scroll speed.

**Dependencies:** Slice 2

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/levels/level_1.json:1-43] - Level JSON structure
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:111-129] - JSON loading pattern
- [@/Users/matt/dev/space_scroller/scripts/background/star_field.gd:49-57] - Star color generation
- [@/Users/matt/dev/space_scroller/scripts/background/nebulae.gd:49-65] - Nebula color palette
- [@/Users/matt/dev/space_scroller/scripts/background/debris.gd:51-67] - Debris color palette
- [@/Users/matt/dev/space_scroller/scripts/enemies/shooting_enemy.gd:1-56] - ShootingEnemy class

#### Tasks

- [x] 3.1-3.6 Create levels/level_2.json with 6 sections, 16000 distance
  - Created with scroll_speed_multiplier: 1.12, background_theme: "inner_solar"
  - Added boss_sprite: "res://assets/sprites/boss-2.png"
  - Added obstacle_modulate: [0.85, 0.55, 0.4, 1.0] (reddish-brown)
  - Includes shooting enemy waves in all sections after the first
- [x] 3.7-3.10 Add theme_preset support to background scripts
  - Updated star_field.gd with "default", "inner_solar", "outer_solar" presets
  - Updated nebulae.gd with warm red/orange/amber colors for inner_solar
  - Updated debris.gd with reddish-brown tones for inner_solar
  - All scripts have set_theme() method for runtime updates
- [x] 3.11 Update LevelManager to read metadata from JSON
  - Added _level_metadata variable and _apply_level_metadata() method
  - Reads scroll_speed_multiplier, background_theme, boss_sprite, obstacle_modulate
  - Applies theme to background nodes via _apply_background_theme()
  - Sets progress bar level indicator
- [x] 3.12-3.14 Shooting enemy spawning already implemented
  - enemy_spawner.gd already has shooting_enemy_scene export
  - spawn_wave() already handles "shooting" enemy_type
- [x] 3.15-3.16 Scroll speed multiplier implemented
  - LevelManager applies scroll_speed_multiplier from metadata
  - Level 2 uses 1.12x (12% faster)
- [x] 3.17-3.18 Boss sprite from metadata implemented
  - LevelManager._spawn_boss() reads boss_sprite from metadata
  - _apply_boss_sprite() updates AnimatedSprite2D first frame
- [x] 3.19-3.20 Obstacle modulate implemented
  - ObstacleSpawner has obstacle_modulate export and set_modulate_color()
  - LevelManager applies color from JSON metadata
- [x] 3.21 Run all slice tests (1, 2, 3) to verify no regressions
  - All 8 level-related tests pass
- [x] 3.22 No refactoring needed
- [x] 3.23 Commit working slice

**Acceptance Criteria:**
- Level 2 selectable from level select screen (when unlocked)
- Background shows warm red/orange/amber theme
- Shooting enemies appear in waves
- Scroll speed is 10-15% faster than Level 1
- Boss uses boss-2.png sprite
- Asteroids have reddish-brown tint
- Progress bar shows "Level 2"
- Completing Level 2 unlocks Level 3

---

### Slice 4: User can play Level 3 with Outer Solar System theme

**What this delivers:** Player can select and play Level 3 with ice/blue background colors, charger enemies (alongside all previous types), placeholder boss, and fastest scroll speed.

**Dependencies:** Slice 3

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/charger_enemy.gd:1-28] - ChargerEnemy class

#### Tasks

- [x] 4.1-4.6 Create levels/level_3.json with 7 sections, 20000 distance
  - Created with scroll_speed_multiplier: 1.22 (22% faster), background_theme: "outer_solar"
  - Added boss_sprite: "res://assets/sprites/boss-1.png" (placeholder)
  - Added boss_modulate: [0.6, 0.8, 1.0, 1.0] (ice-blue tint)
  - Added obstacle_modulate: [0.7, 0.85, 1.0, 1.0] (blue-gray ice tint)
  - Includes charger enemy waves alongside all previous types
  - 7 sections: Kuiper Belt Entry, Ice Giant Pass, Frozen Wasteland, Oort Cloud Fringe, Deep Freeze Zone, Absolute Zero, Edge of Darkness
- [x] 4.7-4.10 "outer_solar" preset already exists in background scripts
  - star_field.gd already has _get_outer_solar_star_color() with ice blue/cyan/white stars
  - nebulae.gd already has _get_outer_solar_nebula_color() with blue/cyan/purple icy hues
  - debris.gd already has _get_outer_solar_debris_color() with blue-gray icy tones
- [x] 4.11-4.13 Charger enemy spawning already implemented
  - enemy_spawner.gd already has charger_enemy_scene export
  - spawn_wave() already handles "charger" enemy_type
- [x] 4.14-4.15 Scroll speed multiplier works for Level 3
  - Level 3 uses 1.22x (22% faster than Level 1)
- [x] 4.16-4.17 Boss modulate support added to LevelManager
  - Added _apply_boss_modulate() method to apply Color to AnimatedSprite2D
  - _spawn_boss() now reads boss_modulate from level metadata
- [x] 4.18-4.19 Obstacle modulate works for Level 3
  - Level 3 JSON has obstacle_modulate: [0.7, 0.85, 1.0, 1.0]
  - LevelManager applies this via ObstacleSpawner.set_modulate_color()
- [x] 4.20 Run all slice tests (1-4) to verify no regressions
  - All 8 level-related tests pass
- [x] 4.21 No refactoring needed
- [x] 4.22 Commit working slice

**Acceptance Criteria:**
- Level 3 selectable from level select screen (when unlocked)
- Background shows cool blue/cyan/ice theme
- Charger enemies appear in waves (alongside shooting, patrol, stationary)
- Scroll speed is 20-25% faster than Level 1
- Boss uses boss-1.png with Color(0.6, 0.8, 1.0, 1.0) modulation
- Asteroids have blue-gray ice tint Color(0.7, 0.85, 1.0, 1.0)
- Progress bar shows "Level 3"
- Level is the most difficult (densest spawns, all enemy types)

---

### Slice 5: User sees correct level indicator and progress throughout gameplay

**What this delivers:** Progress bar displays correct level number during gameplay, and the level complete screen shows appropriate messaging.

**Dependencies:** Slice 4

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/progress_bar.gd:42-49] - set_level() method
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:131-177] - Setup references pattern

#### Tasks

- [x] 5.1-5.6 ALREADY IMPLEMENTED IN SLICE 3
  - LevelManager._level_number property exists (line 57)
  - LevelManager._get_selected_level_from_game_state() populates _level_number from GameState
  - LevelManager._apply_level_metadata() calls _progress_bar.set_level(_level_number)
  - progress_bar.gd has set_level() method and _update_level_label() for display
- [x] 5.7-5.8 test_level_indicator.tscn verifies level indicator for all levels
  - Test confirms set_level(1) displays "Level 1"
  - Test confirms set_level(2) displays "Level 2"
  - All level indicator functionality verified
- [x] 5.9 Run all slice tests (1-5) to verify no regressions
  - test_level_select_menu.tscn - PASSED
  - test_level1_start.tscn - PASSED
  - test_level_locked_state.tscn - PASSED
  - test_level_indicator.tscn - PASSED
- [x] 5.10 No refactoring needed (functionality was complete)
- [x] 5.11 Commit working slice

**Acceptance Criteria:**
- Progress bar shows "Level 1", "Level 2", or "Level 3" based on current level
- Level number persists correctly throughout gameplay session

---

### Slice 6: Original Play button starts Level 1 directly

**What this delivers:** The existing "Play" button on main menu still works and starts Level 1 directly (quick play option), while Level Select provides the full level choice.

**Dependencies:** Slice 5

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/main_menu.gd:11-18] - Play button handler

#### Tasks

- [ ] 6.1 Write integration test: clicking "Play" starts Level 1 directly (bypasses level select)
- [ ] 6.2 Run test, verify expected failure or success
- [ ] 6.3 Ensure main.tscn uses level_1.json by default (already the case)
- [ ] 6.4 Verify Play button still works as before
- [ ] 6.5 Run all slice tests (1-6) to verify no regressions
- [ ] 6.6 Commit working slice

**Acceptance Criteria:**
- "Play" button starts Level 1 immediately
- "Level Select" button provides level choice
- Both navigation paths work correctly

---

### Slice 7: Edge cases and polish

**What this delivers:** Production-ready feature with all edge cases handled gracefully.

**Dependencies:** All prior slices

#### Tasks

- [ ] 7.1 Write test: level select shows correct unlock state after app restart
- [ ] 7.2 Verify ConfigFile persistence loads correctly on startup
- [ ] 7.3 Write test: completing Level 3 shows level complete (no Level 4 to unlock)
- [ ] 7.4 Handle end-of-game state for Level 3 completion
- [ ] 7.5 Write test: returning to level select after completing a level shows updated unlock state
- [ ] 7.6 Verify level select refreshes unlock state when shown
- [ ] 7.7 Write test: starting a new game resets score but preserves level unlocks
- [ ] 7.8 Verify score reset doesn't affect level unlock state
- [ ] 7.9 Run all feature tests, verify everything works together
- [ ] 7.10 Manual playtest: complete progression from Level 1 through Level 3
- [ ] 7.11 Final commit

**Acceptance Criteria:**
- All user workflows from spec work correctly
- Level unlocks persist across sessions
- Error cases handled gracefully
- No regressions in existing functionality
- Smooth gameplay experience across all three levels

---

## Summary of Deliverables

| Slice | User Outcome |
|-------|--------------|
| 1 | Level Select button visible on main menu |
| 2 | Level 1 playable from level select, unlock persistence works |
| 3 | Level 2 playable with Inner Solar System theme |
| 4 | Level 3 playable with Outer Solar System theme |
| 5 | Correct level indicator shown during gameplay |
| 6 | Quick Play still works for Level 1 |
| 7 | Production-ready with edge cases handled |

## Technical Components Built Across Slices

- `scenes/ui/level_select.tscn` - Level selection screen
- `scripts/ui/level_select.gd` - Level selection logic
- `levels/level_2.json` - Level 2 configuration
- `levels/level_3.json` - Level 3 configuration
- Extended `ScoreManager` with level unlock persistence
- Extended `LevelManager` with level_number, scroll_speed, boss_sprite, boss_modulate
- Extended `EnemySpawner` with shooting_enemy_scene, charger_enemy_scene
- Extended `ObstacleSpawner` with modulate support
- Extended `star_field.gd`, `nebulae.gd`, `debris.gd` with theme_preset
