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
- [@/Users/matt/dev/space_scroller/scenes/pickups/ufo_friend.tscn:1-20] - Current pickup scene structure to rename/refactor
- [@/Users/matt/dev/space_scroller/scripts/pickups/ufo_friend.gd:1-138] - Existing zigzag movement and collection logic to preserve
- [@/Users/matt/dev/space_scroller/tests/test_score_ufo_friend.gd:1-158] - Test pattern for pickup collection

#### Tasks

- [ ] 1.1 Write integration test: player collects star_pickup and gains life
  - Load main scene, spawn star_pickup at player position
  - Verify player gains life and score bonus awarded
- [ ] 1.2 Run test, verify expected failure (star_pickup scene not found)
- [ ] 1.3 Rename ufo_friend.tscn to star_pickup.tscn
- [ ] 1.4 Rename ufo_friend.gd to star_pickup.gd, update class_name to StarPickup
- [ ] 1.5 Update star_pickup.tscn to reference renamed script
- [ ] 1.6 Update enemy_spawner.gd to load star_pickup scene
- [ ] 1.7 Run test, observe failure or success
- [ ] 1.8 Document result and update task list
- [ ] 1.9 Repeat 1.7-1.8 as necessary until test passes
- [ ] 1.10 Update test_score_ufo_friend.gd to use new scene/class names
- [ ] 1.11 Refactor if needed (keep tests green)
- [ ] 1.12 Commit working slice

**Acceptance Criteria:**
- Star pickup scene exists and uses sparkle-star-1.png sprite (already correct)
- Player gains extra life when collecting star pickup
- 500 bonus points awarded on collection
- Existing zigzag movement behavior preserved
- All references to old ufo_friend naming updated

---

### Slice 2: Player collects sidekick pickup and sidekick appears following player

**What this delivers:** Player can collect a new sidekick pickup and see a UFO sidekick companion appear that follows them around the screen with a position offset.

**Dependencies:** Slice 1 (pickup system infrastructure)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/pickups/ufo_friend.gd:1-138] - Pickup movement pattern to reuse for sidekick_pickup
- [@/Users/matt/dev/space_scroller/scripts/player.gd:99-163] - Player position and movement for follow behavior
- [@/Users/matt/dev/space_scroller/assets/sprites/friend-ufo-1.png] - UFO sprite to use for sidekick

#### Tasks

- [ ] 2.1 Write integration test: player collects sidekick_pickup and sidekick follows player
  - Spawn sidekick_pickup at player position
  - Verify sidekick appears after collection
  - Move player, verify sidekick follows with offset
- [ ] 2.2 Run test, verify expected failure
- [ ] 2.3 Create sidekick_pickup.tscn scene (Area2D, UFO sprite, collision)
- [ ] 2.4 Create sidekick_pickup.gd with zigzag movement (copy star_pickup pattern)
- [ ] 2.5 Create sidekick.tscn scene (Node2D with UFO sprite, smaller scale)
- [ ] 2.6 Create sidekick.gd with follow behavior (smooth lerp to player offset position)
- [ ] 2.7 Implement collection logic: spawn sidekick when pickup collected
- [ ] 2.8 Run test, observe failure or success
- [ ] 2.9 Document result and update task list
- [ ] 2.10 Repeat 2.7-2.9 as necessary
- [ ] 2.11 Verify sidekick position offset (slightly behind and above/below player)
- [ ] 2.12 Refactor if needed (keep tests green)
- [ ] 2.13 Commit working slice

**Acceptance Criteria:**
- Sidekick pickup spawns with UFO sprite and zigzag movement
- Collecting pickup spawns active sidekick companion
- Sidekick follows player with smooth lag and position offset
- Sidekick uses friend-ufo-1.png sprite at appropriate scale

---

### Slice 3: Sidekick shoots synchronized lasers when player fires

**What this delivers:** When player shoots, the sidekick simultaneously fires its own projectile, providing the promised extra firepower bonus.

**Dependencies:** Slice 2 (sidekick following player)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/player.gd:31] - projectile_fired signal for synchronization
- [@/Users/matt/dev/space_scroller/scripts/player.gd:166-184] - Projectile spawn pattern
- [@/Users/matt/dev/space_scroller/scenes/projectile.tscn:1-20] - Projectile scene structure

#### Tasks

- [ ] 3.1 Write integration test: sidekick fires when player fires
  - Spawn sidekick pickup, collect it
  - Trigger player shoot action
  - Verify two projectiles spawned (player + sidekick)
- [ ] 3.2 Run test, verify expected failure
- [ ] 3.3 Connect sidekick to player's projectile_fired signal
- [ ] 3.4 Implement sidekick shoot() method using projectile.tscn
- [ ] 3.5 Position sidekick projectile with slight Y offset from player projectile
- [ ] 3.6 Run test, observe failure or success
- [ ] 3.7 Document result and update task list
- [ ] 3.8 Repeat 3.5-3.7 as necessary
- [ ] 3.9 Verify projectile collision layers correct (layer 4, mask 2 - hits enemies)
- [ ] 3.10 Refactor if needed (keep tests green)
- [ ] 3.11 Commit working slice

**Acceptance Criteria:**
- Sidekick fires projectile when player fires (synchronized)
- Sidekick projectile uses same projectile.tscn scene
- Sidekick projectile spawns from sidekick's position
- Sidekick projectiles can hit and damage enemies

---

### Slice 4: Sidekick is destroyed when hit by enemy

**What this delivers:** The sidekick has vulnerability - when an enemy touches it, the sidekick is destroyed with visual feedback, creating risk/reward gameplay.

**Dependencies:** Slice 3 (sidekick shooting)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:71-79] - Body collision with player pattern
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:151-176] - Destruction animation pattern
- [@/Users/matt/dev/space_scroller/scenes/enemies/stationary_enemy.tscn:9-12] - Enemy collision layers

#### Tasks

- [ ] 4.1 Write integration test: sidekick destroyed on enemy contact
  - Spawn sidekick pickup, collect it
  - Spawn enemy at sidekick position
  - Verify sidekick is destroyed after collision
- [ ] 4.2 Run test, verify expected failure
- [ ] 4.3 Set sidekick collision layer 1 (player layer) to be hit by enemies
- [ ] 4.4 Set sidekick collision mask 2 (enemy layer) to detect enemy contact
- [ ] 4.5 Implement body_entered handler for enemy collision
- [ ] 4.6 Implement destruction animation (scale up, fade out like pickup)
- [ ] 4.7 Run test, observe failure or success
- [ ] 4.8 Document result and update task list
- [ ] 4.9 Repeat 4.6-4.8 as necessary
- [ ] 4.10 Verify sidekick cleanup: disconnect signals, remove from scene
- [ ] 4.11 Test that sidekick has NO invincibility (immediate destruction)
- [ ] 4.12 Refactor if needed (keep tests green)
- [ ] 4.13 Run all slice tests (1-4) to verify no regressions
- [ ] 4.14 Commit working slice

**Acceptance Criteria:**
- Sidekick takes damage from enemy contact
- Single hit destroys sidekick (no health system, no invincibility)
- Destruction plays visual animation (explosion or fade)
- Sidekick properly cleaned up after destruction

---

### Slice 5: Random pickup spawns every 5 enemy kills

**What this delivers:** Complete power-up system where players are rewarded for skilled play with random pickups (star OR sidekick) every 5 kills, with threshold doubling.

**Dependencies:** Slices 1-4 (both pickup types working)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:216-228] - Kill counting and threshold logic
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:231-261] - UFO spawn logic to modify

#### Tasks

- [ ] 5.1 Write integration test: kill 5 enemies, random pickup spawns
  - Kill 5 enemies in sequence
  - Verify a pickup spawns (either star or sidekick)
  - Verify kill counter resets and threshold doubles
- [ ] 5.2 Run test, verify expected failure
- [ ] 5.3 Add sidekick_pickup_scene export to enemy_spawner.gd
- [ ] 5.4 Modify _on_enemy_killed to randomly select pickup type (50/50)
- [ ] 5.5 Rename _spawn_ufo_friend to _spawn_random_pickup
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
