# Task Breakdown: Score System

## Overview

Total Slices: 5
Each slice delivers incremental user value and is tested end-to-end.

## Task List

### Slice 1: Player sees their score displayed on screen during gameplay

**What this delivers:** Player can see a score counter in the top-right corner of the HUD that starts at zero

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/health_display.gd:1-46] - CanvasLayer-based HUD element pattern with _connect_to_player() and _update_display()
- [@/Users/matt/dev/space_scroller/scenes/ui/health_display.tscn:1-43] - Scene structure with layer=10 and Container positioning
- [commit:66d8b97] - HUD element creation pattern with signal connections

#### Tasks

- [ ] 1.1 Write integration test that verifies score is displayed on screen during gameplay
- [ ] 1.2 Run test, verify expected failure
- [ ] 1.3 Make smallest change possible to progress
- [ ] 1.4 Run test, observe failure or success
- [ ] 1.5 Document result and update task list
- [ ] 1.6 Repeat 1.3-1.5 as necessary (expect to create: score_display.gd, score_display.tscn, add to main.tscn)
- [ ] 1.7 Refactor if needed (keep tests green)
- [ ] 1.8 Commit working slice

**Acceptance Criteria:**
- Score label visible in top-right corner showing "SCORE: 0"
- Format includes comma-separated thousands (will show once score increases)
- CanvasLayer uses layer 10 to match other UI elements
- Score display is visible during gameplay

---

### Slice 2: Player earns points when destroying an enemy

**What this delivers:** Player sees their score increase by 100 points when they destroy a stationary enemy (1 HP), and by 200 points when they destroy a patrol enemy (2 HP)

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:156-158] - Enemy died signal connection pattern in _setup_enemy()
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:32-33] - died signal emission in BaseEnemy
- [@/Users/matt/dev/space_scroller/scripts/enemies/patrol_enemy.gd:1-10] - PatrolEnemy class_name for type identification

#### Tasks

- [ ] 2.1 Write integration test that verifies score increases when enemy is destroyed
- [ ] 2.2 Run test, verify expected failure
- [ ] 2.3 Make smallest change possible to progress
- [ ] 2.4 Run test, observe failure or success
- [ ] 2.5 Document result and update task list
- [ ] 2.6 Repeat 2.3-2.5 as necessary (expect to create: ScoreManager autoload or singleton, connect to enemy.died signals)
- [ ] 2.7 Refactor if needed (keep tests green)
- [ ] 2.8 Run all slice tests (1 and 2) to verify no regressions
- [ ] 2.9 Commit working slice
- [ ] 2.10 Write additional tests for patrol enemy giving 200 points vs stationary giving 100 points

**Acceptance Criteria:**
- Destroying a stationary enemy (1 HP) adds 100 points to score
- Destroying a patrol enemy (2 HP) adds 200 points to score
- Score display updates immediately when points are awarded
- Points awarded on enemy.died signal (death, not just damage)

---

### Slice 3: Player earns bonus points for collecting UFO Friend and completing level

**What this delivers:** Player receives 500 bonus points when collecting a UFO Friend pickup, and 5,000 bonus points when completing the level

**Dependencies:** Slice 2

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/pickups/ufo_friend.gd:30-31] - collected signal definition
- [@/Users/matt/dev/space_scroller/scripts/pickups/ufo_friend.gd:95-101] - collected.emit() after successful gain_life()
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:33-34] - level_completed signal definition

#### Tasks

- [ ] 3.1 Write integration test that verifies 500 points awarded when UFO Friend collected
- [ ] 3.2 Run test, verify expected failure
- [ ] 3.3 Make smallest change possible to progress
- [ ] 3.4 Run test, observe failure or success
- [ ] 3.5 Document result and update task list
- [ ] 3.6 Repeat 3.3-3.5 as necessary (connect ScoreManager to UfoFriend.collected signal)
- [ ] 3.7 Write integration test for level completion bonus (5,000 points)
- [ ] 3.8 Run test and iterate until passing
- [ ] 3.9 Refactor if needed (keep tests green)
- [ ] 3.10 Run all slice tests (1, 2, and 3) to verify no regressions
- [ ] 3.11 Commit working slice

**Acceptance Criteria:**
- Collecting UFO Friend adds 500 points to score
- Points only awarded if UFO was actually collected (life was gained)
- Level completion adds 5,000 points to score
- Bonus added before displaying on Level Complete screen

---

### Slice 4: Player sees their score on end screens (Game Over and Level Complete)

**What this delivers:** Player sees their final score displayed on both Game Over and Level Complete screens

**Dependencies:** Slices 1-3

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/game_over_screen.gd:1-24] - Game over screen script with show_game_over()
- [@/Users/matt/dev/space_scroller/scenes/ui/game_over_screen.tscn:1-26] - VBoxContainer structure for labels
- [@/Users/matt/dev/space_scroller/scripts/ui/level_complete_screen.gd:1-24] - Level complete screen script
- [@/Users/matt/dev/space_scroller/scenes/ui/level_complete_screen.tscn:1-26] - Same VBoxContainer pattern

#### Tasks

- [ ] 4.1 Write integration test that verifies score is shown on Game Over screen
- [ ] 4.2 Run test, verify expected failure
- [ ] 4.3 Make smallest change possible to progress
- [ ] 4.4 Run test, observe failure or success
- [ ] 4.5 Document result and update task list
- [ ] 4.6 Repeat 4.3-4.5 as necessary (add ScoreLabel to game_over_screen.tscn, update show_game_over() to accept score)
- [ ] 4.7 Write integration test for Level Complete screen showing score
- [ ] 4.8 Run test and iterate until passing (add ScoreLabel to level_complete_screen.tscn)
- [ ] 4.9 Refactor if needed (keep tests green)
- [ ] 4.10 Run all slice tests to verify no regressions
- [ ] 4.11 Commit working slice

**Acceptance Criteria:**
- Game Over screen shows "SCORE: X,XXX" with player's final score
- Level Complete screen shows "SCORE: X,XXX" (includes level bonus)
- Score labels appear below the main title text
- Score uses same comma-separated thousands format as HUD

---

### Slice 5: Player's high scores persist across game sessions

**What this delivers:** Player sees their high score displayed on end screens, and the game remembers top scores between sessions

**Dependencies:** Slice 4

**Reference patterns:**
- Godot ConfigFile API for local file storage
- user://high_scores.cfg path for cross-platform compatibility

#### Tasks

- [ ] 5.1 Write integration test that verifies high score is saved and loaded between sessions
- [ ] 5.2 Run test, verify expected failure
- [ ] 5.3 Make smallest change possible to progress
- [ ] 5.4 Run test, observe failure or success
- [ ] 5.5 Document result and update task list
- [ ] 5.6 Repeat 5.3-5.5 as necessary (add high score loading/saving to ScoreManager using ConfigFile)
- [ ] 5.7 Write test for top 10 high scores list (sorted descending)
- [ ] 5.8 Run test and iterate until passing
- [ ] 5.9 Add HIGH SCORE label to Game Over screen
- [ ] 5.10 Add HIGH SCORE label to Level Complete screen
- [ ] 5.11 Add "NEW HIGH SCORE!" indicator when applicable
- [ ] 5.12 Refactor if needed (keep tests green)
- [ ] 5.13 Run all feature tests to verify everything works together
- [ ] 5.14 Commit working slice

**Acceptance Criteria:**
- High scores saved to user://high_scores.cfg using ConfigFile
- Top 10 high scores stored with score (int) and date (ISO string)
- Scores sorted descending, oldest duplicate scores dropped first
- Game Over screen shows "HIGH SCORE: X,XXX"
- Level Complete screen shows "HIGH SCORE: X,XXX"
- "NEW HIGH SCORE!" indicator appears when player achieves a new high score
- High scores persist across game sessions

---

## Implementation Notes

### ScoreManager Design

The ScoreManager should be an autoload (singleton) that:
- Tracks current score for the active game session
- Provides add_points(amount: int) method
- Emits score_changed signal for UI updates
- Handles high score loading/saving via ConfigFile
- Connects to enemy.died, UfoFriend.collected, and LevelManager.level_completed signals

### Signal Connections

ScoreManager needs to connect to:
1. Enemy died signals - via EnemySpawner (follow existing pattern in _setup_enemy)
2. UfoFriend.collected signal - when UFO friends are spawned
3. LevelManager.level_completed signal - for level completion bonus

### Point Values Reference

| Source | Points |
|--------|--------|
| Stationary enemy (BaseEnemy, 1 HP) | 100 |
| Patrol enemy (PatrolEnemy, 2 HP) | 200 |
| UFO Friend collected | 500 |
| Level completion bonus | 5,000 |

### File Structure

Expected new files:
- scripts/score_manager.gd - Autoload singleton for score tracking
- scripts/ui/score_display.gd - HUD score display script
- scenes/ui/score_display.tscn - HUD score display scene

Modified files:
- project.godot - Add ScoreManager autoload
- scenes/main.tscn - Add ScoreDisplay instance
- scripts/game_over_screen.gd - Add score display logic
- scenes/ui/game_over_screen.tscn - Add score labels
- scripts/ui/level_complete_screen.gd - Add score display logic
- scenes/ui/level_complete_screen.tscn - Add score labels
