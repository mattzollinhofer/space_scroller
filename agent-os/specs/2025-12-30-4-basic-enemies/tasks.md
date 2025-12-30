# Task Breakdown: Basic Enemies

## Overview

Total Slices: 4
Each slice delivers incremental user value and is tested end-to-end.

**Feature Goal:** Create two enemy types (stationary and patrol) with sprite-based visuals, health system, collision-based combat, and destruction animations that integrate with the existing obstacle spawning infrastructure.

---

## Task List

### Slice 1: Player can encounter and destroy a stationary enemy

**What this delivers:** A gold/black alien enemy appears on screen, scrolls left with the world, damages the player on collision, and is destroyed with visual feedback when hit.

**Dependencies:** None (builds on existing asteroid/player patterns)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/obstacles/asteroid.gd:1-30] - Area2D setup with collision detection
- [@/Users/matt/dev/space_scroller/scripts/obstacles/asteroid.gd:35-42] - _process for leftward movement and despawn
- [@/Users/matt/dev/space_scroller/scenes/obstacles/asteroid.tscn:1-15] - Scene structure with collision layers
- [@/Users/matt/dev/space_scroller/scripts/obstacles/asteroid.gd:135-138] - _on_body_entered handler
- [@/Users/matt/dev/space_scroller/scripts/player.gd:114-131] - take_damage() function
- [commit:3227f29] - Add asteroid obstacle with player collision and damage system

#### Tasks

- [x] 1.1 Write integration test: stationary enemy scrolls on screen, player collides, enemy destroyed with animation, player takes damage
- [x] 1.2 Run test, verify expected failure
- [x] 1.3 Make smallest change possible to progress
- [x] 1.4 Run test, observe failure or success
- [x] 1.5 Document result and update task list
- [x] 1.6 Repeat 1.3-1.5 as necessary (expected iterations):
  - [x] Create base_enemy.gd script extending Area2D
  - [x] Add Sprite2D child node using enemy.png asset
  - [x] Set sprite scale (2-3x for visibility)
  - [x] Add health property with setter that checks for death
  - [x] Add died signal for enemy death event
  - [x] Create stationary_enemy.tscn scene with CollisionShape2D
  - [x] Set up collision layer 2 (obstacle) and mask 1 (player)
  - [x] Add _process for leftward movement at 180 px/s scroll speed
  - [x] Add despawn check (x < -100)
  - [x] Add body_entered signal connection for player collision
  - [x] On collision: call player.take_damage() and set enemy health to 0
  - [x] Add destroy() method triggered when health <= 0
  - [x] Create destruction animation using Tween (scale/fade over 0.3-0.5s)
  - [x] Remove enemy from scene after animation completes
  - [x] Add test enemy instance to main.tscn for manual testing
  - [x] Add green-screen shader for sprite transparency
- [x] 1.7 Refactor if needed (keep tests green)
- [x] 1.8 Commit working slice

**Acceptance Criteria:**
- Stationary enemy displays with gold/black sprite facing left
- Enemy scrolls left at 180 px/s (world scroll speed)
- Player collision damages player (triggers take_damage)
- Player collision destroys enemy (health goes to 0)
- Destruction animation plays (scale/fade effect, 0.3-0.5s)
- Enemy removed from scene after animation
- Enemy despawns when scrolled off left edge (x < -100)

---

### Slice 2: Player can encounter patrol enemies that move horizontally

**What this delivers:** A red/orange tinted enemy appears, oscillates back and forth horizontally while scrolling left, providing a different visual and movement challenge from the stationary enemy.

**Dependencies:** Slice 1 (base enemy structure exists)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/obstacles/asteroid.gd:35-42] - _process movement pattern
- Slice 1 base_enemy.gd - extend for patrol behavior

#### Tasks

- [x] 2.1 Write integration test: patrol enemy oscillates horizontally while scrolling left, player collision works same as stationary
- [x] 2.2 Run test, verify expected failure
- [x] 2.3 Make smallest change possible to progress
- [x] 2.4 Run test, observe failure or success
- [x] 2.5 Document result and update task list
- [x] 2.6 Repeat 2.3-2.5 as necessary (expected iterations):
  - [x] Create patrol_enemy.gd extending base_enemy.gd (or duplicate with modifications)
  - [x] Create patrol_enemy.tscn scene
  - [x] Apply red/orange modulate tint to Sprite2D (e.g., Color(1.5, 0.6, 0.3))
  - [x] Add patrol_range variable (default 200px)
  - [x] Add patrol_speed variable (configurable, smooth movement)
  - [x] Track patrol center position (relative to world scroll)
  - [x] Implement oscillation: move back/forth within patrol_range
  - [x] Combine patrol movement with world scroll in _process
  - [x] Verify collision and destruction work same as stationary enemy
  - [x] Add test patrol enemy to main.tscn for manual testing
- [x] 2.7 Refactor if needed (keep tests green)
- [x] 2.8 Run all slice tests (1 and 2) to verify no regressions
- [ ] 2.9 Commit working slice

**Acceptance Criteria:**
- Patrol enemy displays with red/orange tinted sprite
- Enemy oscillates horizontally within 200px range
- Patrol movement is smooth and configurable
- Enemy still scrolls left overall (patrol relative to world position)
- Player collision damages player and destroys enemy
- Destruction animation plays same as stationary enemy
- Previous slice functionality still works

---

### Slice 3: Enemies spawn continuously from the right edge

**What this delivers:** Both enemy types spawn automatically from the right edge of the screen at configurable intervals, creating ongoing combat encounters for the player alongside the existing asteroids.

**Dependencies:** Slices 1-2 (enemy scenes exist)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/obstacles/obstacle_spawner.gd:1-50] - Spawner initialization
- [@/Users/matt/dev/space_scroller/scripts/obstacles/obstacle_spawner.gd:83-105] - _spawn_asteroid method
- [@/Users/matt/dev/space_scroller/scripts/obstacles/obstacle_spawner.gd:72-80] - Player died signal connection
- [commit:86eeab2] - Add asteroid spawner with continuous spawning and size variety

#### Tasks

- [ ] 3.1 Write integration test: after spawn interval, enemies appear from right edge at random Y positions
- [ ] 3.2 Run test, verify expected failure
- [ ] 3.3 Make smallest change possible to progress
- [ ] 3.4 Run test, observe failure or success
- [ ] 3.5 Document result and update task list
- [ ] 3.6 Repeat 3.3-3.5 as necessary (expected iterations):
  - [ ] Create enemy_spawner.gd script (modeled on obstacle_spawner.gd)
  - [ ] Add @export for stationary_enemy_scene and patrol_enemy_scene
  - [ ] Add configurable spawn rates for each enemy type
  - [ ] Set spawn position: x = viewport_width + 100
  - [ ] Set random Y within playable range (140-1396, accounting for enemy size)
  - [ ] Implement _spawn_stationary_enemy() method
  - [ ] Implement _spawn_patrol_enemy() method
  - [ ] Add spawn timer logic in _process
  - [ ] Randomly select enemy type on each spawn (or alternate)
  - [ ] Track active enemies in array
  - [ ] Connect to tree_exiting for cleanup tracking
  - [ ] Create enemy_spawner.tscn scene
  - [ ] Add EnemySpawner node to main.tscn
  - [ ] Connect to player.died signal to stop spawning on game over
- [ ] 3.7 Refactor if needed (keep tests green)
- [ ] 3.8 Run all slice tests (1-3) to verify no regressions
- [ ] 3.9 Commit working slice

**Acceptance Criteria:**
- Enemies spawn from right edge (x = viewport_width + 100)
- Spawn Y position varies within playable range (140-1396)
- Both enemy types spawn based on configurable rates
- Enemies despawn when off left edge
- Spawning stops on player death
- Active enemies tracked for cleanup
- Existing asteroid spawning unaffected
- Previous slice functionality still works

---

### Slice 4: Production polish and edge case handling

**What this delivers:** All enemy interactions are polished, edge cases are handled gracefully, and the feature is production-ready with clean integration into the existing game systems.

**Dependencies:** Slices 1-3

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/player.gd:114-131] - Invincibility handling
- Existing spawner patterns for game over cleanup

#### Tasks

- [ ] 4.1 Verify enemy collisions respect player invincibility (no damage during flash)
- [ ] 4.2 Run test, verify expected behavior
- [ ] 4.3 Handle edge cases:
  - [ ] Enemy destroyed during destruction animation (no double-free)
  - [ ] Multiple enemies colliding with player rapidly
  - [ ] Player dying while enemies are mid-animation
  - [ ] Patrol enemy at screen edge (clamp patrol range if needed)
- [ ] 4.4 Add initial enemy spawns at game start (optional, similar to asteroids)
- [ ] 4.5 Verify all enemies cleaned up on game over
- [ ] 4.6 Test sprite transparency/background (enemy.png green background)
  - [ ] If green background visible, apply shader or process sprite
- [ ] 4.7 Fine-tune spawn rates for balanced gameplay
- [ ] 4.8 Run all feature tests to verify everything works together
- [ ] 4.9 Remove test enemy instances from main.tscn (spawner handles spawning)
- [ ] 4.10 Final commit

**Acceptance Criteria:**
- Player invincibility respected (no damage during flash)
- No crashes or errors on rapid collisions
- Game over properly cleans up all enemies
- Spawn rates feel balanced with existing asteroids
- Enemy sprite displays without green background artifact
- Code follows existing patterns in codebase
- All user workflows from spec work correctly

---

## Summary of Deliverables

After all slices are complete:

1. **base_enemy.gd** - Base enemy script with health, collision, and destruction
2. **stationary_enemy.tscn / .gd** - Gold/black enemy that scrolls left
3. **patrol_enemy.tscn / .gd** - Red/orange enemy that oscillates while scrolling
4. **enemy_spawner.gd / .tscn** - Manages enemy spawning and lifecycle
5. **main.tscn modifications** - EnemySpawner node added

## Technical Notes

- **Collision Layers:** Enemies use layer 2 (obstacle), mask 1 (player) - same as asteroids
- **Scroll Speed:** 180 px/s (matching current asteroid scroll speed)
- **Playable Y Range:** 140 to 1396 pixels (accounting for enemy sprite size within 80-1456 boundaries)
- **Viewport:** 2048x1536 pixels
- **Enemy Sprite:** assets/sprites/raw/enemy.png - gold/black alien, may need green background removal
- **Sprite Scale:** 2-3x for gameplay visibility (match player sprite scaling approach)
- **Patrol Range:** 200px horizontal oscillation
- **Destruction Animation:** 0.3-0.5 seconds using Tween (scale down + fade out)
- **Health System:** Integer health property, setter checks <= 0 for death, died signal emitted
