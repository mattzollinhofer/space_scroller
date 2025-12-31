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
- [ ] 1.10 Commit working slice

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

- [ ] 2.1 Write integration test: clicking Level 1 button starts game with level_1.json
- [ ] 2.2 Run test, verify expected failure
- [ ] 2.3 Make smallest change possible to progress
- [ ] 2.4 Run test, observe failure or success
- [ ] 2.5 Document result and update task list
- [ ] 2.6 Repeat 2.3-2.5 as necessary
- [ ] 2.7 Write test: Level 2 and 3 buttons show locked state when not unlocked
- [ ] 2.8 Implement locked button visual state (disabled property, gray color)
- [ ] 2.9 Write test: ScoreManager persists level unlock state to ConfigFile
- [ ] 2.10 Add unlock_level() and is_level_unlocked() methods to ScoreManager
- [ ] 2.11 Write test: completing Level 1 unlocks Level 2
- [ ] 2.12 Update level_complete_screen.gd to call unlock_level() for next level
- [ ] 2.13 Run all slice tests to verify no regressions
- [ ] 2.14 Refactor if needed (keep tests green)
- [ ] 2.15 Commit working slice

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

- [ ] 3.1 Write integration test: starting Level 2 loads level_2.json and shows "Level 2" indicator
- [ ] 3.2 Run test, verify expected failure
- [ ] 3.3 Create levels/level_2.json with 5-6 sections, 15000-18000 distance
  - Include scroll_speed, background_theme, boss_sprite, obstacle_modulate metadata
  - Add shooting enemy waves alongside stationary/patrol
- [ ] 3.4 Run test, observe failure or success
- [ ] 3.5 Document result and update task list
- [ ] 3.6 Repeat as necessary to wire level selection to LevelManager
- [ ] 3.7 Write test: Level 2 background uses red/orange theme colors
- [ ] 3.8 Add theme_preset export to star_field.gd with "default" and "inner_solar" presets
- [ ] 3.9 Add theme_preset export to nebulae.gd with red/orange/amber colors
- [ ] 3.10 Add theme_preset export to debris.gd with reddish-brown colors
- [ ] 3.11 Update LevelManager to read background_theme from JSON and pass to background nodes
- [ ] 3.12 Write test: Level 2 spawns shooting enemies
- [ ] 3.13 Add shooting_enemy_scene export to enemy_spawner.gd
- [ ] 3.14 Extend spawn_wave() to handle "shooting" enemy_type
- [ ] 3.15 Write test: Level 2 scroll speed is 10-15% faster than Level 1
- [ ] 3.16 Add scroll_speed reading from JSON metadata in LevelManager
- [ ] 3.17 Write test: Level 2 boss uses boss-2.png sprite
- [ ] 3.18 Add boss_sprite reading from JSON, apply to boss instantiation
- [ ] 3.19 Write test: Level 2 asteroids have reddish-brown tint
- [ ] 3.20 Add obstacle_modulate reading from JSON, apply in ObstacleSpawner
- [ ] 3.21 Run all slice tests (1, 2, 3) to verify no regressions
- [ ] 3.22 Refactor if needed (keep tests green)
- [ ] 3.23 Commit working slice

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

- [ ] 4.1 Write integration test: starting Level 3 loads level_3.json and shows "Level 3" indicator
- [ ] 4.2 Run test, verify expected failure
- [ ] 4.3 Create levels/level_3.json with 6-7 sections, 18000-22000 distance
  - Include scroll_speed (20-25% faster), background_theme: "outer_solar"
  - Add charger enemy waves alongside all previous types
  - Include boss_modulate for ice-blue tint on placeholder boss
- [ ] 4.4 Run test, observe failure or success
- [ ] 4.5 Document result and update task list
- [ ] 4.6 Repeat as necessary
- [ ] 4.7 Write test: Level 3 background uses blue/cyan/ice theme colors
- [ ] 4.8 Add "outer_solar" preset to star_field.gd (cooler star colors)
- [ ] 4.9 Add "outer_solar" preset to nebulae.gd (blue/cyan/purple icy hues)
- [ ] 4.10 Add "outer_solar" preset to debris.gd (blue-gray icy tones)
- [ ] 4.11 Write test: Level 3 spawns charger enemies
- [ ] 4.12 Add charger_enemy_scene export to enemy_spawner.gd
- [ ] 4.13 Extend spawn_wave() to handle "charger" enemy_type
- [ ] 4.14 Write test: Level 3 scroll speed is 20-25% faster than Level 1
- [ ] 4.15 Verify scroll_speed metadata reading works for Level 3
- [ ] 4.16 Write test: Level 3 boss uses boss-1.png with ice-blue modulation
- [ ] 4.17 Add boss_modulate reading from JSON, apply Color modulation to boss sprite
- [ ] 4.18 Write test: Level 3 asteroids have blue-gray ice tint
- [ ] 4.19 Verify obstacle_modulate works for Level 3 JSON values
- [ ] 4.20 Run all slice tests (1-4) to verify no regressions
- [ ] 4.21 Refactor if needed (keep tests green)
- [ ] 4.22 Commit working slice

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

- [ ] 5.1 Write integration test: progress bar shows "Level 2" when playing Level 2
- [ ] 5.2 Run test, verify expected failure
- [ ] 5.3 Add level_number property to LevelManager
- [ ] 5.4 Update LevelManager to call progress_bar.set_level() in _setup_references()
- [ ] 5.5 Run test, observe failure or success
- [ ] 5.6 Document result and update task list
- [ ] 5.7 Write test: progress bar shows "Level 3" when playing Level 3
- [ ] 5.8 Verify level indicator works for all levels
- [ ] 5.9 Run all slice tests (1-5) to verify no regressions
- [ ] 5.10 Refactor if needed (keep tests green)
- [ ] 5.11 Commit working slice

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
