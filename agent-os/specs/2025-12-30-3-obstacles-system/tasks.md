# Task Breakdown: Obstacles System

## Overview

Total Slices: 5
Each slice delivers incremental user value and is tested end-to-end.

**Feature Goal:** Add static asteroid obstacles that scroll with the world, with collision detection that damages the player and a lives system that triggers game over when all lives are lost.

---

## Task List

### Slice 1: Player can collide with a single asteroid and see visual feedback

**What this delivers:** Player collides with an on-screen asteroid, loses a life, and sees a flashing effect indicating damage was taken.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/background/asteroid_boundaries.gd:88-98] - Irregular polygon vertex generation (5-8 vertices)
- [@/Users/matt/dev/space_scroller/scripts/background/asteroid_boundaries.gd:66-85] - Rocky brown/gray color palette
- [@/Users/matt/dev/space_scroller/scripts/background/asteroid_boundaries.gd:115-132] - Draw polygon with darkened outline
- [@/Users/matt/dev/space_scroller/scenes/player.tscn:6-7] - RectangleShape2D collision setup
- [@/Users/matt/dev/space_scroller/scripts/player.gd:35-56] - Player physics process pattern
- [commit:a9b9b21] - StaticBody2D collision setup and layer patterns

#### Tasks

- [x] 1.1 Write integration test: player moves into asteroid, takes damage, flashes visually
- [x] 1.2 Run test, verify expected failure
- [x] 1.3 Make smallest change possible to progress
- [x] 1.4 Run test, observe failure or success
- [x] 1.5 Document result and update task list
- [x] 1.6 Repeat 1.3-1.5 as necessary (expected iterations):
  - [x] Create asteroid.gd script with procedural drawing (vertices, color, outline)
  - [x] Create asteroid.tscn scene with Area2D and CollisionShape2D
  - [x] Set up obstacle collision layer (separate from boundary layer)
  - [x] Add asteroid instance to main.tscn for testing
  - [x] Add lives tracking to player.gd (starts with 3)
  - [x] Add damage handling on Area2D body_entered signal
  - [x] Add invincibility timer (1.5 seconds)
  - [x] Add flashing effect (toggle visibility every 0.1s during invincibility)
  - [x] Add damage_taken signal to player
- [x] 1.7 Refactor if needed (keep tests green)
- [x] 1.8 Commit working slice

**Acceptance Criteria:**
- Single asteroid displays on screen with rocky procedural visuals
- Player collision with asteroid triggers damage
- Player loses 1 life on collision
- Player flashes for 1.5 seconds after taking damage
- Player cannot take damage again while flashing
- Flashing stops clearly when invincibility ends

---

### Slice 2: Player can lose all lives and see game over screen

**What this delivers:** After losing all 3 lives from repeated asteroid collisions, player sees a "Game Over" message and the game stops.

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scenes/main.tscn:69-71] - UILayer CanvasLayer for UI elements
- [@/Users/matt/dev/space_scroller/scripts/player.gd] - Player script to add died signal

#### Tasks

- [x] 2.1 Write integration test: player collides with asteroid 3 times, game over screen appears
- [x] 2.2 Run test, verify expected failure
- [x] 2.3 Make smallest change possible to progress
- [x] 2.4 Run test, observe failure or success
- [x] 2.5 Document result and update task list
- [x] 2.6 Repeat 2.3-2.5 as necessary (expected iterations):
  - [x] Add lives_changed signal to player.gd (done in Slice 1)
  - [x] Add died signal to player.gd (done in Slice 1)
  - [x] Create game_over_screen.tscn with CanvasLayer and centered "Game Over" label
  - [x] Add GameOverScreen to main.tscn (initially hidden)
  - [x] Connect player.died signal to show game over screen
  - [x] Pause game tree on game over
- [x] 2.7 Refactor if needed (keep tests green)
- [x] 2.8 Run all slice tests (1 and 2) to verify no regressions
- [x] 2.9 Commit working slice

**Acceptance Criteria:**
- Lives counter starts at 3
- Each collision reduces lives by 1
- When lives reach 0, "Game Over" text displays on screen
- Game stops (pause or freeze) after game over
- Previous slice functionality still works

---

### Slice 3: Asteroids spawn from the right edge and scroll across the screen

**What this delivers:** New asteroids continuously appear from the right side of the screen and scroll left at the world speed (120 px/s), providing ongoing obstacles for the player to navigate.

**Dependencies:** Slice 1 (asteroid scene exists)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/scroll_controller.gd:6] - scroll_speed = 120.0 pixels/second
- [@/Users/matt/dev/space_scroller/scripts/background/asteroid_boundaries.gd:55-63] - Asteroid data generation pattern

#### Tasks

- [x] 3.1 Write integration test: after 3 seconds, new asteroid appears from right edge and moves left
- [x] 3.2 Run test, verify expected failure
- [x] 3.3 Make smallest change possible to progress
- [x] 3.4 Run test, observe failure or success
- [x] 3.5 Document result and update task list
- [x] 3.6 Repeat 3.3-3.5 as necessary (expected iterations):
  - [x] Create obstacle_spawner.gd script
  - [x] Add Timer for spawn interval (2-4 seconds random)
  - [x] Spawn asteroids at x = viewport_width + 100 (off right edge)
  - [x] Spawn at random y position within playable area (y=80 to y=1456)
  - [x] Add _process movement to asteroid.gd (move left at 120 px/s)
  - [x] Add ObstacleSpawner node to main.tscn
  - [x] Track active asteroids in array
- [x] 3.7 Refactor if needed (keep tests green)
- [x] 3.8 Run all slice tests (1, 2, and 3) to verify no regressions
- [ ] 3.9 Commit working slice

**Acceptance Criteria:**
- Asteroids spawn from right edge at random intervals (2-4 seconds)
- Spawned asteroids move left at 120 pixels per second
- Asteroids spawn at varied Y positions within playable area
- Player can collide with moving asteroids (damage still works)
- Previous slice functionality still works

---

### Slice 4: Asteroids despawn when they scroll off-screen and game starts with initial asteroids

**What this delivers:** Memory is managed properly as asteroids are removed when no longer visible, and the game starts with some asteroids already on screen for immediate gameplay.

**Dependencies:** Slice 3 (spawner exists)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/project.godot:19-20] - Viewport 2048x1536 pixels
- [@/Users/matt/dev/space_scroller/scripts/background/asteroid_boundaries.gd:42-52] - Initial generation pattern

#### Tasks

- [x] 4.1 Write integration test: asteroid scrolls off left edge and is removed from scene
- [x] 4.2 Run test, verify expected failure
- [x] 4.3 Make smallest change possible to progress
- [x] 4.4 Run test, observe failure or success
- [x] 4.5 Document result and update task list
- [x] 4.6 Repeat 4.3-4.5 as necessary (expected iterations):
  - [x] Add despawn check in asteroid.gd _process (when x < -100)
  - [x] Call queue_free() and notify spawner on despawn
  - [x] Remove asteroid reference from spawner's active array
  - [x] Add initial asteroid spawning in obstacle_spawner.gd _ready()
  - [x] Spawn 3-5 asteroids at random positions on screen at game start
  - [x] Make initial_count configurable via @export
- [x] 4.7 Refactor if needed (keep tests green)
- [x] 4.8 Run all slice tests (1-4) to verify no regressions
- [ ] 4.9 Commit working slice

**Acceptance Criteria:**
- Asteroids are removed from scene when x position < -100
- Spawner no longer tracks despawned asteroids
- Game starts with 3-5 asteroids already on screen
- Initial asteroids are positioned within playable area
- Memory does not grow unbounded over time
- Previous slice functionality still works

---

### Slice 5: Asteroid size variety and production polish

**What this delivers:** Asteroids come in varied sizes (60-120px) creating visual variety and gameplay interest, with all edge cases handled gracefully.

**Dependencies:** Slices 1-4

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/background/asteroid_boundaries.gd:55-63] - Size variation pattern in asteroid data

#### Tasks

- [x] 5.1 Write integration test: spawned asteroids have varied sizes within range
- [x] 5.2 Run test, verify expected failure
- [x] 5.3 Make smallest change possible to progress
- [x] 5.4 Run test, observe failure or success
- [x] 5.5 Document result and update task list
- [x] 5.6 Repeat 5.3-5.5 as necessary (expected iterations):
  - [x] Add size parameter to asteroid.gd (60-120 px range)
  - [x] Scale collision shape to match visual size
  - [x] Update spawner to pass random size on instantiation
  - [x] Add spawn_rate_min and spawn_rate_max @export variables
  - [x] Stop spawning when game is over
  - [x] Verify all edge cases handled (rapid collisions, screen edges)
- [x] 5.7 Refactor if needed (keep tests green)
- [x] 5.8 Run all feature tests (slices 1-5) to verify everything works together
- [ ] 5.9 Final commit

**Acceptance Criteria:**
- Asteroids spawn with varied diameters (60-120 pixels)
- Collision shapes match visual size
- Spawn rate is configurable
- Spawning stops on game over
- All edge cases handled gracefully
- Code follows existing patterns in codebase

---

## Summary of Deliverables

After all slices are complete:

1. **asteroid.tscn / asteroid.gd** - Procedurally drawn asteroid with collision detection
2. **obstacle_spawner.gd** - Manages asteroid spawning and lifecycle
3. **game_over_screen.tscn** - Placeholder game over UI
4. **player.gd modifications** - Lives system, damage handling, invincibility, signals
5. **main.tscn modifications** - ObstacleSpawner node, GameOverScreen in UILayer

## Technical Notes

- **Collision Layers:** Use a dedicated obstacle layer (separate from boundary layer 1)
- **Scroll Speed:** 120 px/s matching scroll_controller.gd
- **Playable Y Range:** 80 to 1456 pixels (between asteroid belt boundaries)
- **Viewport:** 2048x1536 pixels
- **Player Collision Shape:** 144x144 pixels
