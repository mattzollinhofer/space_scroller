# Task Breakdown: Sidekick Helper

## Overview

Total Slices: 5
Each slice delivers incremental user value and is tested end-to-end.

**Feature Summary:** Add a power-up system where every 5 enemy kills spawns a random pickup (star for extra life or UFO sidekick for extra firepower), with the sidekick following the player and shooting synchronized lasers until destroyed.

---

## Task List

### Slice 1: Player collects star pickup and gains extra life

**What this delivers:** Player can collect the renamed star pickup (refactored from current ufo_friend) and receive an extra life, preserving existing functionality with new visual identity.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scenes/pickups/star_pickup.tscn:1-20] - Star pickup scene (renamed from ufo_friend)
- [@/Users/matt/dev/space_scroller/scripts/pickups/star_pickup.gd:1-138] - Star pickup script with zigzag movement
- [@/Users/matt/dev/space_scroller/tests/test_star_pickup.gd:1-130] - New integration test for star pickup

#### Tasks

- [x] 1.1 Write integration test: player collects star_pickup and gains life
  - Load main scene, spawn star_pickup at player position
  - Verify player gains life and score bonus awarded
- [x] 1.2 Run test, verify expected failure (star_pickup scene not found)
  - [StarPickup class not declared] -> Test failed as expected
- [x] 1.3 Rename ufo_friend.tscn to star_pickup.tscn
- [x] 1.4 Rename ufo_friend.gd to star_pickup.gd, update class_name to StarPickup
- [x] 1.5 Update star_pickup.tscn to reference renamed script
- [x] 1.6 Update enemy_spawner.gd to load star_pickup scene
  - Renamed ufo_friend_scene to star_pickup_scene
  - Renamed _spawn_ufo_friend to _spawn_star_pickup
  - Updated main.tscn to use new property name
- [x] 1.7 Run test, observe failure or success
  - Success - test passes
- [x] 1.8 Document result and update task list
- [x] 1.9 Repeat 1.7-1.8 as necessary until test passes
  - Test passed on first run after all renames
- [x] 1.10 Update test_score_ufo_friend.gd to use new scene/class names
  - Updated to use StarPickup and star_pickup.tscn
- [x] 1.11 Refactor if needed (keep tests green)
  - All tests pass, no refactoring needed
- [x] 1.12 Commit working slice

**Acceptance Criteria:**
- [x] Star pickup scene exists and uses sparkle-star-1.png sprite (already correct)
- [x] Player gains extra life when collecting star pickup
- [x] 500 bonus points awarded on collection
- [x] Existing zigzag movement behavior preserved
- [x] All references to old ufo_friend naming updated

---

### Slice 2: Player collects sidekick pickup and sidekick appears following player

**What this delivers:** Player can collect a new sidekick pickup and see a UFO sidekick companion appear that follows them around the screen with a position offset.

**Dependencies:** Slice 1 (pickup system infrastructure)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/pickups/star_pickup.gd:1-138] - Pickup movement pattern to reuse for sidekick_pickup
- [@/Users/matt/dev/space_scroller/scripts/player.gd:99-163] - Player position and movement for follow behavior
- [@/Users/matt/dev/space_scroller/assets/sprites/friend-ufo-1.png] - UFO sprite to use for sidekick

#### Tasks

- [x] 2.1 Write integration test: player collects sidekick_pickup and sidekick follows player
  - Spawn sidekick_pickup at player position
  - Verify sidekick appears after collection
  - Move player, verify sidekick follows with offset
  - Created test_sidekick_pickup.gd and test_sidekick_pickup.tscn
- [x] 2.2 Run test, verify expected failure
  - [Could not load sidekick_pickup scene] -> Test failed as expected
- [x] 2.3 Create sidekick_pickup.tscn scene (Area2D, UFO sprite, collision)
  - Created with friend-ufo-1.png sprite, scale Vector2(3,3), collision layer 8, mask 1
- [x] 2.4 Create sidekick_pickup.gd with zigzag movement (copy star_pickup pattern)
  - Copied zigzag movement from star_pickup.gd
  - Added sidekick spawn logic on collection
- [x] 2.5 Create sidekick.tscn scene (Node2D with UFO sprite, smaller scale)
  - Created Area2D with friend-ufo-1.png sprite at scale Vector2(2,2)
  - Collision layer 1 (player), mask 2 (enemies) for future damage handling
- [x] 2.6 Create sidekick.gd with follow behavior (smooth lerp to player offset position)
  - Uses lerp with follow_speed for smooth following
  - Offset Vector2(-50, -30) positions behind and above player
- [x] 2.7 Implement collection logic: spawn sidekick when pickup collected
  - Pickup calls _spawn_sidekick() on player collision
  - Sidekick added to Main scene, not player
- [x] 2.8 Run test, observe failure or success
  - Initial run: physics query warning during spawn
- [x] 2.9 Document result and update task list
- [x] 2.10 Repeat 2.7-2.9 as necessary
  - Fixed physics warning by using call_deferred for sidekick spawn
  - Test now passes cleanly without errors
- [x] 2.11 Verify sidekick position offset (slightly behind and above/below player)
  - Verified: offset is Vector2(-50, -30) - behind and above player
  - Sidekick smoothly lerps to follow player movement
- [x] 2.12 Refactor if needed (keep tests green)
  - All tests pass: test_sidekick_pickup, test_star_pickup, test_score_ufo_friend
- [x] 2.13 Commit working slice
  - Committed: 9dc0f56 "Add sidekick pickup that spawns UFO companion following player"

**Acceptance Criteria:**
- [x] Sidekick pickup spawns with UFO sprite and zigzag movement
- [x] Collecting pickup spawns active sidekick companion
- [x] Sidekick follows player with smooth lag and position offset
- [x] Sidekick uses friend-ufo-1.png sprite at appropriate scale

---

### Slice 3: Sidekick shoots synchronized lasers when player fires

**What this delivers:** When player shoots, the sidekick simultaneously fires its own projectile, providing the promised extra firepower bonus.

**Dependencies:** Slice 2 (sidekick following player)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/player.gd:31] - projectile_fired signal for synchronization
- [@/Users/matt/dev/space_scroller/scripts/player.gd:166-184] - Projectile spawn pattern
- [@/Users/matt/dev/space_scroller/scenes/projectile.tscn:1-20] - Projectile scene structure

#### Tasks

- [x] 3.1 Write integration test: sidekick fires when player fires
  - Spawn sidekick pickup, collect it
  - Trigger player shoot action
  - Verify two projectiles spawned (player + sidekick)
  - Created test_sidekick_shooting.gd and test_sidekick_shooting.tscn
- [x] 3.2 Run test, verify expected failure
  - [Expected 2 projectiles but only 1 was spawned] -> Test failed as expected
  - Player projectile spawned but sidekick had no shooting functionality
- [x] 3.3 Connect sidekick to player's projectile_fired signal
  - Added signal connection in setup() method
  - Connected to _on_player_projectile_fired handler
- [x] 3.4 Implement sidekick shoot() method using projectile.tscn
  - Loads projectile.tscn in _ready()
  - Instantiates and positions projectile at sidekick position + offset
  - Adds projectile to Main scene (parent)
- [x] 3.5 Position sidekick projectile with slight Y offset from player projectile
  - Sidekick offset Vector2(-50, -30) naturally provides Y offset
  - Projectile spawns at sidekick position + Vector2(80, 0)
  - Result: player projectile at (486, 768), sidekick at (436, 738)
- [x] 3.6 Run test, observe failure or success
  - Success - test passes on first run after implementation
- [x] 3.7 Document result and update task list
- [x] 3.8 Repeat 3.5-3.7 as necessary
  - No repetition needed - passed on first try
- [x] 3.9 Verify projectile collision layers correct (layer 4, mask 2 - hits enemies)
  - Confirmed: projectile.tscn has collision_layer=4, collision_mask=2
  - Sidekick projectiles can hit and damage enemies
- [x] 3.10 Refactor if needed (keep tests green)
  - No refactoring needed
  - All tests pass: test_sidekick_pickup, test_sidekick_shooting, test_star_pickup
- [x] 3.11 Commit working slice

**Acceptance Criteria:**
- [x] Sidekick fires projectile when player fires (synchronized)
- [x] Sidekick projectile uses same projectile.tscn scene
- [x] Sidekick projectile spawns from sidekick's position
- [x] Sidekick projectiles can hit and damage enemies

---

### Slice 4: Sidekick is destroyed when hit by enemy

**What this delivers:** The sidekick has vulnerability - when an enemy touches it, the sidekick is destroyed with visual feedback, creating risk/reward gameplay.

**Dependencies:** Slice 3 (sidekick shooting)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:71-79] - Body collision with player pattern
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:151-176] - Destruction animation pattern
- [@/Users/matt/dev/space_scroller/scenes/enemies/stationary_enemy.tscn:9-12] - Enemy collision layers

#### Tasks

- [x] 4.1 Write integration test: sidekick destroyed on enemy contact
  - Spawn sidekick pickup, collect it
  - Spawn enemy at sidekick position
  - Verify sidekick is destroyed after collision
  - Created test_sidekick_destruction.gd and test_sidekick_destruction.tscn
- [x] 4.2 Run test, verify expected failure
  - [Sidekick was NOT destroyed by enemy contact] -> Test failed as expected
  - Sidekick had no collision handling for enemies
- [x] 4.3 Set sidekick collision layer 1 (player layer) to be hit by enemies
  - Already set in sidekick.tscn: collision_layer = 1
- [x] 4.4 Set sidekick collision mask 2 (enemy layer) to detect enemy contact
  - Already set in sidekick.tscn: collision_mask = 2
- [x] 4.5 Implement area_entered handler for enemy collision
  - Connected area_entered signal in _ready()
  - Handler checks for enemy via take_hit method or health property
  - Calls _destroy() when enemy detected
- [x] 4.6 Implement destruction animation (scale up, fade out like pickup)
  - Added _play_destruction_animation() with tween
  - Scales sprite up 2x and fades to 0 alpha over 0.3 seconds
  - queue_free() called after animation completes
- [x] 4.7 Run test, observe failure or success
  - Success - test passes on first run after implementation
- [x] 4.8 Document result and update task list
- [x] 4.9 Repeat 4.6-4.8 as necessary
  - No repetition needed - passed on first try
- [x] 4.10 Verify sidekick cleanup: disconnect signals, remove from scene
  - _destroy() disconnects player's projectile_fired signal
  - Disables monitoring/monitorable via set_deferred
  - queue_free() removes sidekick after animation
- [x] 4.11 Test that sidekick has NO invincibility (immediate destruction)
  - Created test_sidekick_no_invincibility.gd and .tscn
  - Verifies sidekick has no health property
  - Confirms single hit destruction with no grace period
  - Test passes
- [x] 4.12 Refactor if needed (keep tests green)
  - No refactoring needed
  - Added _is_destroying flag to prevent double-processing
  - Added guards in shoot() and _process() for destruction state
- [x] 4.13 Run all slice tests (1-4) to verify no regressions
  - All 6 tests pass: test_star_pickup, test_sidekick_pickup, test_sidekick_shooting,
    test_sidekick_destruction, test_sidekick_no_invincibility, test_score_ufo_friend
- [x] 4.14 Commit working slice

**Acceptance Criteria:**
- [x] Sidekick takes damage from enemy contact
- [x] Single hit destroys sidekick (no health system, no invincibility)
- [x] Destruction plays visual animation (explosion or fade)
- [x] Sidekick properly cleaned up after destruction

---

### Slice 5: Random pickup spawns every 5 enemy kills

**What this delivers:** Complete power-up system where players are rewarded for skilled play with random pickups (star OR sidekick) every 5 kills, with threshold doubling.

**Dependencies:** Slices 1-4 (both pickup types working)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:216-228] - Kill counting and threshold logic
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:231-261] - Star pickup spawn logic to extend

#### Tasks

- [ ] 5.1 Write integration test: kill 5 enemies, random pickup spawns
  - Kill 5 enemies in sequence
  - Verify a pickup spawns (either star or sidekick)
  - Verify kill counter resets and threshold doubles
- [ ] 5.2 Run test, verify expected failure
- [ ] 5.3 Add sidekick_pickup_scene export to enemy_spawner.gd
- [ ] 5.4 Modify _on_enemy_killed to randomly select pickup type (50/50)
- [ ] 5.5 Rename _spawn_star_pickup to _spawn_random_pickup
- [ ] 5.6 Implement random selection between star and sidekick pickup
- [ ] 5.7 Run test, observe failure or success
- [ ] 5.8 Document result and update task list
- [ ] 5.9 Repeat 5.6-5.8 as necessary
- [ ] 5.10 Verify threshold doubling preserved (5, 10, 20, 40...)
- [ ] 5.11 Update Main scene to assign sidekick_pickup_scene to spawner
- [ ] 5.12 Test edge case: collecting sidekick when one already active
  - [ ] 5.12.1 Decide behavior: ignore pickup or replace existing sidekick
  - [ ] 5.12.2 Implement chosen behavior
- [ ] 5.13 Test edge case: sidekick destroyed on player death
- [ ] 5.14 Refactor if needed (keep tests green)
- [ ] 5.15 Run all feature tests (1-5) to verify everything works together
- [ ] 5.16 Commit working slice

**Acceptance Criteria:**
- Every 5 enemy kills triggers pickup spawn
- Random selection between star (extra life) and sidekick pickup
- Threshold doubles after each spawn (5, 10, 20...)
- Only one sidekick active at a time
- Sidekick destroyed when player dies

---

## Final Integration

### Post-Slice Cleanup

- [ ] 6.1 Manual playtesting of full feature flow
- [ ] 6.2 Verify all test files updated with correct scene references
- [ ] 6.3 Clean up any dead code from refactoring
- [ ] 6.4 Final commit with all feature work complete

**Final Acceptance Criteria:**
- Player can earn random pickups by killing enemies
- Star pickup grants extra life (existing functionality preserved)
- Sidekick pickup grants UFO companion that shoots with player
- Sidekick follows player, shoots synchronized, destroyed on enemy contact
- Only one sidekick active at a time
- All edge cases handled gracefully
