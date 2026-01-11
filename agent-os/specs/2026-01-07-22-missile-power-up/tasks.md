# Task Breakdown: Missile Power-Up

## Overview

Total Slices: 5
Each slice delivers incremental user value and is tested end-to-end.

## Task List

### Slice 1: Player can collect missile pickup and see damage indicator

**What this delivers:** Player collects a fireball pickup and a damage boost indicator appears in the UI showing "x2" damage level.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/pickups/star_pickup.gd:8-15] - collection behavior pattern (emit signal, play sfx, animation)
- [@/Users/matt/dev/space_scroller/scripts/pickups/base_pickup.gd:1-139] - base class to extend
- [@/Users/matt/dev/space_scroller/scenes/pickups/star_pickup.tscn:1-20] - scene structure template
- [@/Users/matt/dev/space_scroller/scripts/ui/health_display.gd:19-50] - UI display pattern with player signal connection
- [@/Users/matt/dev/space_scroller/scenes/ui/health_display.tscn:1-43] - UI scene structure

#### Tasks

- [x] 1.1 Write integration test: missile pickup collection shows damage boost indicator
  - Spawn player, spawn MissilePickup at player position
  - Verify DamageBoostDisplay shows "x2" after collection
  - Verify pickup_collect sfx played
- [x] 1.2 Run test, verify expected failure
  - [missile_pickup.tscn not found] -> Created missile_pickup.gd and missile_pickup.tscn
- [x] 1.3 Make smallest change to progress (repeat until test passes)
  - [x] Iteration 1: [missile_pickup.tscn not found] -> Created missile_pickup.gd extending BasePickup, created missile_pickup.tscn with fireball-1.png sprite
  - [x] Iteration 2: [Pickup not collected - player lacks add_damage_boost()] -> Added _damage_boost, add_damage_boost(), get_damage_boost(), and damage_boost_changed signal to player.gd
  - [x] Iteration 3: [DamageBoostDisplay not found] -> Created damage_boost_display.gd and damage_boost_display.tscn, added to main.tscn
  - [x] Iteration 4: [Display not visible - could not find player] -> Fixed player lookup path by trying sibling first (get_parent().get_node_or_null("Player"))
  - [x] Iteration 5: Success - Test passes
- [x] 1.4 Document each red-green iteration in this task list
- [x] 1.5 Refactor if needed (keep tests green)
  - No refactoring needed
- [x] 1.6 Commit working slice
  - Committed in ae72722 (along with other changes)

**Acceptance Criteria:**
- [x] Collecting missile pickup increases player damage boost
- [x] UI shows fireball icon with "x2" label when damage boost is 1
- [x] Pickup plays collection sound and animation
- [x] Indicator hidden when damage boost is 0

---

### Slice 2: Player projectiles deal boosted damage to enemies

**What this delivers:** After collecting a missile pickup, the player's projectiles kill enemies faster (deal more damage per hit).

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/player.gd:211-230] - projectile instantiation, can set damage before add_child
- [@/Users/matt/dev/space_scroller/scripts/projectile.gd:9] - `@export var damage: int = 1` property
- [@/Users/matt/dev/space_scroller/scripts/projectile.gd:44] - `area.take_hit(damage)` call

#### Tasks

- [x] 2.1 Write integration test: boosted projectile deals extra damage
  - Spawn player, give 1 damage boost
  - Spawn enemy with 2 health
  - Player fires projectile
  - Verify enemy takes 2 damage (1 base + 1 boost)
- [x] 2.2 Run test, verify expected failure
  - [Enemy health: 1 remaining after hit] -> Projectile dealt only 1 damage (default) instead of 2 (boosted)
- [x] 2.3 Make smallest change to progress (repeat until test passes)
  - [x] Iteration 1: [Projectile damage not boosted] -> Added `projectile.damage = 1 + _damage_boost` in player.gd shoot() method after instantiation
  - [x] Success - Test passes
- [x] 2.4 Document each red-green iteration in this task list
- [x] 2.5 Run all slice tests (1 and 2) to verify no regressions
  - Both tests pass
- [x] 2.6 Refactor if needed (keep tests green)
  - No refactoring needed - single line change is clean
- [x] 2.7 Commit working slice

**Acceptance Criteria:**
- [x] Projectile damage = 1 + current damage boost
- [x] Enemy takes boosted damage from player projectiles
- [x] Stacking multiple pickups increases damage further (x2, x3, x4...)

---

### Slice 3: Damage boost resets when player loses a life

**What this delivers:** When player loses all health and uses a life, their damage boost resets to zero and the UI indicator disappears.

**Dependencies:** Slices 1, 2

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/player.gd:244-270] - life_lost signal emission, health reset pattern
- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:259-263] - clear_sidekick_state pattern

#### Tasks

- [x] 3.1 Write integration test: damage boost resets on life loss
  - Spawn player with 2 lives, give 2 damage boost
  - Damage player until life lost
  - Verify damage boost is now 0
  - Verify DamageBoostDisplay is hidden
  - Verify GameState.get_damage_boost() returns 0 (or note not yet implemented)
- [x] 3.2 Run test, verify expected failure
  - [Damage boost after life loss: 2] -> Expected damage boost to reset to 0 after life loss, got 2
- [x] 3.3 Make smallest change to progress (repeat until test passes)
  - [x] Iteration 1: [Damage boost not reset] -> Added reset_damage_boost() method to player.gd that sets _damage_boost = 0, emits damage_boost_changed(0), and calls GameState.clear_damage_boost() if available. Called reset_damage_boost() in take_damage() right after life_lost signal is emitted.
  - [x] Success - Test passes
- [x] 3.4 Document each red-green iteration in this task list
- [x] 3.5 Run all slice tests (1, 2, 3) to verify no regressions
  - All three tests pass
- [x] 3.6 Refactor if needed (keep tests green)
  - No refactoring needed - implementation is minimal and follows existing patterns
- [x] 3.7 Commit working slice

**Acceptance Criteria:**
- [x] Losing a life resets damage boost to 0
- [x] UI indicator disappears when boost is 0
- [x] GameState damage boost is cleared (implemented in Slice 4)
- [x] Player can collect new pickups after reset

---

### Slice 4: Damage boost persists across levels

**What this delivers:** When player completes a level with a damage boost, they start the next level with that same boost.

**Dependencies:** Slices 1, 2, 3

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/level_complete_screen.gd:79-105] - saving lives and sidekick state before level transition
- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:242-263] - sidekick state persistence pattern
- [@/Users/matt/dev/space_scroller/scripts/player.gd:67-79] - reading carried-over lives in _ready()

#### Tasks

- [x] 4.1 Write integration test: damage boost persists between levels
  - Set GameState.set_damage_boost(2)
  - Create new player instance (simulating level start)
  - Verify player._damage_boost == 2
  - Verify DamageBoostDisplay shows "x3"
- [x] 4.2 Run test, verify expected failure
  - [GameState does not have set_damage_boost() method] -> GameState needs damage boost persistence methods
- [x] 4.3 Make smallest change to progress (repeat until test passes)
  - [x] Iteration 1: [GameState does not have set_damage_boost() method] -> Added _damage_boost var, get_damage_boost(), set_damage_boost(), clear_damage_boost() to GameState
  - [x] Iteration 2: [Player should have damage boost of 2 from GameState, got 0] -> Modified player._ready() to read damage boost from GameState (similar to lives carryover pattern)
  - [x] Success - Test passes
- [x] 4.4 Document each red-green iteration in this task list
- [x] 4.5 Run all slice tests (1-4) to verify no regressions
  - All four tests pass
- [x] 4.6 Refactor if needed (keep tests green)
  - No refactoring needed - implementation follows existing patterns cleanly
- [x] 4.7 Commit working slice
  - Committed in 5602318

**Acceptance Criteria:**
- [x] Completing level saves damage boost to GameState
- [x] New level reads damage boost from GameState
- [x] UI shows correct indicator on level start
- [x] Returning to main menu clears damage boost

---

### Slice 5: Missile pickup spawns in random pickup pool

**What this delivers:** Missile pickups spawn naturally during gameplay as part of the kill-based pickup system, alongside star and sidekick pickups.

**Dependencies:** Slices 1-4

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:474-534] - _choose_pickup_type() and _spawn_random_pickup()
- [@/Users/matt/dev/space_scroller/scenes/main.tscn:17-20] - ext_resource for pickup scenes
- [@/Users/matt/dev/space_scroller/scenes/main.tscn:100-101] - EnemySpawner pickup scene wiring

#### Tasks

- [ ] 5.1 Write integration test: missile pickup spawns from enemy spawner
  - Configure EnemySpawner with missile_pickup_scene
  - Trigger pickup spawn (via kill threshold or direct call)
  - Verify MissilePickup can be spawned
- [ ] 5.2 Run test, verify expected failure
- [ ] 5.3 Make smallest change to progress (repeat until test passes)
  - Expected iterations: add `@export var missile_pickup_scene: PackedScene` to EnemySpawner
  - Modify `_choose_pickup_type()` to return pickup type enum/string (star/sidekick/missile)
  - Add logic: if has_sidekick AND full_health, prefer missile; else weighted random
  - Modify `_spawn_random_pickup()` to handle missile type
  - Wire missile_pickup.tscn in main.tscn EnemySpawner node
- [ ] 5.4 Document each red-green iteration in this task list
- [ ] 5.5 Run all slice tests (1-5) to verify no regressions
- [ ] 5.6 Refactor if needed (keep tests green)
- [ ] 5.7 Run full test suite to verify complete feature works
- [ ] 5.8 Commit working slice

**Acceptance Criteria:**
- EnemySpawner can spawn missile pickups
- Pickup selection considers player state (sidekick, health, boost)
- Missile pickup integrates with existing zigzag movement and spawn logic
- main.tscn wires missile_pickup_scene to EnemySpawner

---

## Files to Create

| File | Purpose |
|------|---------|
| `scripts/pickups/missile_pickup.gd` | Pickup script extending BasePickup |
| `scenes/pickups/missile_pickup.tscn` | Pickup scene with fireball-1.png sprite |
| `scripts/ui/damage_boost_display.gd` | UI script for damage indicator |
| `scenes/ui/damage_boost_display.tscn` | UI scene with icon + label |
| `tests/test_missile_pickup.tscn` | Integration tests for missile pickup |

## Files to Modify

| File | Changes |
|------|---------|
| `scripts/player.gd` | Add `_damage_boost`, signals, methods; modify `shoot()` |
| `scripts/autoloads/game_state.gd` | Add damage boost persistence methods |
| `scripts/enemies/enemy_spawner.gd` | Add missile pickup export; modify selection logic |
| `scripts/ui/level_complete_screen.gd` | Save damage boost on level transition |
| `scenes/main.tscn` | Add DamageBoostDisplay node; wire missile pickup to spawner |

## Test Strategy

Each slice includes an integration test that drives implementation:

1. **Slice 1 test**: Collection + UI indicator
2. **Slice 2 test**: Projectile damage modification
3. **Slice 3 test**: Reset on life loss
4. **Slice 4 test**: Level persistence
5. **Slice 5 test**: Spawn system integration

All tests should be runnable via:
```bash
timeout 10 godot --headless --path . tests/test_missile_pickup.tscn
timeout 10 godot --headless --path . tests/test_missile_damage_boost.tscn
timeout 10 godot --headless --path . tests/test_missile_damage_reset.tscn
timeout 10 godot --headless --path . tests/test_missile_damage_persist.tscn
```
