# Task Breakdown: Additional Level Content

## Overview

Total Slices: 7
Each slice delivers incremental user value and is tested end-to-end.

This feature extends Level 1 from 9000 to 13500 pixels, adds three distinct enemy types (shooting, non-shooting tank, charger), implements continuous filler enemy spawning between waves, and makes the boss more aggressive.

---

## Task List

### Slice 1: User sees enemies moving in zigzag pattern (Bug Fix)

**What this delivers:** Enemies visibly move up and down while scrolling left, making combat feel dynamic rather than static.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:48-68] - zigzag movement in _process
- [commit:c8d95fb] - Enemy behavior improvements showing expected zigzag

#### Tasks

- [x] 1.1 Write integration test that spawns enemy and verifies Y position changes over time
  - Test already existed in `tests/test_enemy_zigzag.gd`, created missing `.tscn` file
- [x] 1.2 Run test, verify expected failure (enemy Y position should change but may not)
  - Test PASSED: Enemy Y changed by 583.6 pixels over 5 seconds, zigzag is working correctly
- [x] 1.3-1.6 No changes needed - zigzag movement already implemented and working
  - Verified zigzag_speed=120.0 applies in _process
  - Enemy bounces off Y bounds correctly (140-1396)
  - Code in base_enemy.gd lines 55-64 handles zigzag properly
- [x] 1.7 Refactor if needed (keep tests green) - No refactoring needed
- [x] 1.8 Commit working slice

**Results:** Bug investigation complete - zigzag movement is working correctly. The perceived issue may have been due to enemies being destroyed quickly in gameplay or a misperception. Test confirms:
- Enemy Y position changed by ~584 pixels over 5 seconds
- Enemy stayed within Y bounds (140-1396)
- Zigzag speed of 120 px/s is being applied correctly

**Acceptance Criteria:**
- [x] Enemy Y position changes noticeably over 2-3 seconds
- [x] Enemy bounces off Y bounds (140-1396)
- [x] Test passes confirming zigzag movement works

---

### Slice 2: User encounters shooting enemies that fire projectiles

**What this delivers:** A new enemy type appears that shoots projectiles toward the player, adding ranged threat variety.

**Dependencies:** Slice 1 (enemies must move properly) - COMPLETED

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/patrol_enemy.gd:1-10] - Pattern for extending BaseEnemy
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss_projectile.gd:1-40] - Projectile movement pattern
- [@/Users/matt/dev/space_scroller/scenes/enemies/boss_projectile.tscn:1-22] - Scene structure template
- [commit:eb8a0d3] - Boss projectile creation approach

#### Tasks

- [x] 2.1 Write integration test: spawn ShootingEnemy, verify it fires projectile within 5 seconds
  - Created `tests/test_shooting_enemy.gd` and `tests/test_shooting_enemy.tscn`
- [x] 2.2 Run test, verify expected failure (class/scene does not exist)
  - Test failed: "Could not load shooting enemy scene" - as expected
- [x] 2.3 Make smallest change possible to progress
  - Created `scripts/enemies/shooting_enemy.gd` extending BaseEnemy with fire_rate=4.0, health=1
  - Created `scripts/enemies/enemy_projectile.gd` adapting boss_projectile with speed=400, enemy_projectiles group
  - Created `scenes/enemies/enemy_projectile.tscn` with green modulate (Color(0.5, 1, 0.3, 1))
  - Created `scenes/enemies/shooting_enemy.tscn` using enemy-2.png sprite
- [x] 2.4 Run test, observe failure or success
  - Test PASSED: "ShootingEnemy fired projectile within 2.007163 seconds"
- [x] 2.5 Document result and update task list - Success on first iteration after creating all files
- [x] 2.6 Repeat 2.3-2.5 as necessary - Not needed, passed first try
- [x] 2.7 Refactor if needed (keep tests green) - No refactoring needed
- [x] 2.8 Run zigzag test from Slice 1 to verify no regressions
  - All enemy tests passed: test_enemy_zigzag.tscn, test_enemy_waves.tscn
- [x] 2.9 Commit working slice
- [x] 2.10 Add narrower tests: projectile damages player, projectile despawns off-screen
  - Created `tests/test_enemy_projectile_damage.gd/.tscn` - PASSED
  - Created `tests/test_enemy_projectile_despawn.gd/.tscn` - PASSED

**Files created:**
- `scripts/enemies/shooting_enemy.gd` - ShootingEnemy class extending BaseEnemy (1 HP, fires every 4 seconds)
- `scripts/enemies/enemy_projectile.gd` - EnemyProjectile class (speed 400, damages player, despawns off-screen)
- `scenes/enemies/shooting_enemy.tscn` - Scene using enemy-2.png sprite
- `scenes/enemies/enemy_projectile.tscn` - Projectile scene with green tint
- `tests/test_shooting_enemy.gd` + `.tscn` - Integration test for shooting enemy
- `tests/test_enemy_projectile_damage.gd` + `.tscn` - Test for projectile damaging player
- `tests/test_enemy_projectile_despawn.gd` + `.tscn` - Test for projectile despawning

**Acceptance Criteria:**
- [x] ShootingEnemy spawns and moves with zigzag (inherits from BaseEnemy)
- [x] ShootingEnemy fires projectile every 4 seconds toward left (fire_rate=4.0, initial delay=2.0)
- [x] ShootingEnemy has 1 HP
- [x] Enemy projectile damages player on contact (tested in test_enemy_projectile_damage)
- [x] Enemy projectile despawns when off-screen left (tested in test_enemy_projectile_despawn)

---

### Slice 3: User encounters fast charger enemies that rush toward them

**What this delivers:** A new enemy type that locks onto the player's Y position and charges horizontally, adding urgency and requiring quick dodges.

**Dependencies:** Slice 1 (base enemy movement)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:306-343] - Charge attack targeting player Y
- [@/Users/matt/dev/space_scroller/scripts/enemies/patrol_enemy.gd:1-10] - Subclass pattern

#### Tasks

- [ ] 3.1 Write integration test: spawn ChargerEnemy at player Y, verify it moves left faster than scroll speed
- [ ] 3.2 Run test, verify expected failure (class/scene does not exist)
- [ ] 3.3 Make smallest change possible to progress
- [ ] 3.4 Run test, observe failure or success
- [ ] 3.5 Document result and update task list
- [ ] 3.6 Repeat 3.3-3.5 as necessary
- [ ] 3.7 Refactor if needed (keep tests green)
- [ ] 3.8 Run all previous slice tests to verify no regressions
- [ ] 3.9 Commit working slice
- [ ] 3.10 Add narrower tests: charger damages player on contact, charger despawns off-screen

**Files to create:**
- `scripts/enemies/charger_enemy.gd` - ChargerEnemy class extending BaseEnemy
- `scenes/enemies/charger_enemy.tscn` - Scene using enemy.png with cyan modulate

**Acceptance Criteria:**
- ChargerEnemy spawns and locks onto player Y position
- ChargerEnemy moves left at 360-540 px/s (2-3x normal scroll speed)
- ChargerEnemy has 1 HP
- ChargerEnemy damages player on contact
- ChargerEnemy has cyan/blue tint for visual distinction

---

### Slice 4: User sees new enemy types spawning in waves

**What this delivers:** The enemy spawner can spawn shooting and charger enemies as part of level waves, enabling varied combat encounters.

**Dependencies:** Slice 2 (ShootingEnemy), Slice 3 (ChargerEnemy)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:106-118] - spawn_wave() method
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:128-143] - spawn methods pattern
- [commit:05fd0d6] - Wave-based spawning implementation

#### Tasks

- [ ] 4.1 Write integration test: call spawn_wave with "shooting" type, verify ShootingEnemy spawns
- [ ] 4.2 Run test, verify expected failure (spawn_wave doesn't handle "shooting")
- [ ] 4.3 Make smallest change possible to progress
- [ ] 4.4 Run test, observe failure or success
- [ ] 4.5 Document result and update task list
- [ ] 4.6 Repeat 4.3-4.5 as necessary
- [ ] 4.7 Add test for "charger" enemy type in spawn_wave
- [ ] 4.8 Run all previous slice tests to verify no regressions
- [ ] 4.9 Commit working slice

**Files to modify:**
- `scripts/enemies/enemy_spawner.gd` - Add shooting_enemy_scene and charger_enemy_scene exports, spawn methods

**Acceptance Criteria:**
- spawn_wave([{"enemy_type": "shooting", "count": 2}]) spawns 2 ShootingEnemies
- spawn_wave([{"enemy_type": "charger", "count": 1}]) spawns 1 ChargerEnemy
- Existing "stationary" and "patrol" types still work

---

### Slice 5: User encounters filler enemies between waves

**What this delivers:** Random enemies spawn periodically between section waves, keeping combat continuous and filling long gaps.

**Dependencies:** Slice 4 (spawner supports all enemy types)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:74-83] - Timer-based spawning
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:120-125] - _spawn_random_enemy

#### Tasks

- [ ] 5.1 Write integration test: enable filler spawning, verify enemies spawn every 4-6 seconds
- [ ] 5.2 Run test, verify expected failure (no filler spawning mechanism)
- [ ] 5.3 Make smallest change possible to progress
- [ ] 5.4 Run test, observe failure or success
- [ ] 5.5 Document result and update task list
- [ ] 5.6 Repeat 5.3-5.5 as necessary
- [ ] 5.7 Add test for weighted random selection (60% stationary, 30% shooting, 10% charger)
- [ ] 5.8 Run all previous slice tests to verify no regressions
- [ ] 5.9 Commit working slice

**Files to modify:**
- `scripts/enemies/enemy_spawner.gd` - Add filler spawning timer separate from continuous spawning

**Acceptance Criteria:**
- Filler enemies spawn every 4-6 seconds when enabled
- Random type selection: 60% stationary, 30% shooting, 10% charger
- Filler spawning can be enabled/disabled independently
- Filler spawning disabled during boss fight

---

### Slice 6: User plays extended level with 6 sections and varied enemy waves

**What this delivers:** Level 1 is 50% longer with 6 distinct sections, each with unique enemy wave compositions that escalate in difficulty.

**Dependencies:** Slice 4 (spawner supports all types), Slice 5 (filler spawning)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/levels/level_1.json:1-43] - Current section structure
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd] - Section processing

#### Tasks

- [ ] 6.1 Write integration test: load level, verify total_distance is 13500 and 6 sections exist
- [ ] 6.2 Run test, verify expected failure (level has 4 sections, 9000 pixels)
- [ ] 6.3 Update level_1.json with new structure
- [ ] 6.4 Run test, observe failure or success
- [ ] 6.5 Document result and update task list
- [ ] 6.6 Swap patrol_enemy.tscn to use enemy.png (remove modulate)
- [ ] 6.7 Swap stationary_enemy.tscn to use enemy-2.png
- [ ] 6.8 Run full test suite to verify no regressions
- [ ] 6.9 Commit working slice

**Files to modify:**
- `levels/level_1.json` - Extend to 13500px, add 2 sections, update enemy_waves
- `scenes/enemies/patrol_enemy.tscn` - Use enemy.png, remove orange modulate
- `scenes/enemies/stationary_enemy.tscn` - Use enemy-2.png

**New section structure:**
```json
{
  "total_distance": 13500,
  "sections": [
    { "name": "Opening", "start_percent": 0, "end_percent": 15, "enemy_waves": [{"enemy_type": "stationary", "count": 2}] },
    { "name": "Building", "start_percent": 15, "end_percent": 35, "enemy_waves": [{"enemy_type": "stationary", "count": 2}, {"enemy_type": "shooting", "count": 1}] },
    { "name": "Ramping", "start_percent": 35, "end_percent": 55, "enemy_waves": [{"enemy_type": "patrol", "count": 2}, {"enemy_type": "shooting", "count": 2}] },
    { "name": "Intense", "start_percent": 55, "end_percent": 75, "enemy_waves": [{"enemy_type": "patrol", "count": 3}, {"enemy_type": "charger", "count": 1}] },
    { "name": "Gauntlet", "start_percent": 75, "end_percent": 90, "enemy_waves": [{"enemy_type": "shooting", "count": 2}, {"enemy_type": "charger", "count": 2}, {"enemy_type": "patrol", "count": 1}] },
    { "name": "Final Push", "start_percent": 90, "end_percent": 100, "enemy_waves": [{"enemy_type": "charger", "count": 3}, {"enemy_type": "patrol", "count": 2}] }
  ]
}
```

**Acceptance Criteria:**
- Level is 13500 pixels (75 seconds at 180px/s scroll)
- 6 sections with progressive difficulty
- Sprite swap: PatrolEnemy uses enemy.png, StationaryEnemy uses enemy-2.png
- All enemy types spawn correctly in their designated sections
- Filler spawning activates after Opening section

---

### Slice 7: User experiences more aggressive boss attacks

**What this delivers:** The boss attacks faster with quicker projectiles, using the boss-2.png sprite as primary visual.

**Dependencies:** None (can be done independently)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scenes/enemies/boss.tscn:7-19] - SpriteFrames animation
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:52-56] - Attack parameters
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss_projectile.gd:6] - Projectile speed

#### Tasks

- [ ] 7.1 Write integration test: spawn boss, verify attack_cooldown is 1.3s and projectile speed is 750
- [ ] 7.2 Run test, verify expected failure (cooldown is 2.0s, speed is 600)
- [ ] 7.3 Update boss.tscn with new parameters (attack_cooldown: 1.3, wind_up_duration: 0.35)
- [ ] 7.4 Update boss_projectile.gd speed to 750
- [ ] 7.5 Run test, observe failure or success
- [ ] 7.6 Swap sprite frame order in boss.tscn so boss-2.png is first
- [ ] 7.7 Run all boss-related tests to verify no regressions
- [ ] 7.8 Run full test suite
- [ ] 7.9 Commit working slice

**Files to modify:**
- `scenes/enemies/boss.tscn` - Swap frame order, update attack_cooldown and wind_up_duration
- `scripts/enemies/boss_projectile.gd` - Update speed from 600 to 750

**Acceptance Criteria:**
- Boss uses boss-2.png as primary sprite frame
- attack_cooldown reduced from 2.0 to 1.3 seconds
- wind_up_duration reduced from 0.5 to 0.35 seconds
- Projectile speed increased from 600 to 750 (25% faster)
- Boss health remains at 13 HP
- All existing boss tests still pass

---

## Implementation Notes

### File Structure Summary

**New files to create:**
- `scripts/enemies/shooting_enemy.gd`
- `scripts/enemies/charger_enemy.gd`
- `scripts/enemies/enemy_projectile.gd`
- `scenes/enemies/shooting_enemy.tscn`
- `scenes/enemies/charger_enemy.tscn`
- `scenes/enemies/enemy_projectile.tscn`

**Existing files to modify:**
- `scripts/enemies/enemy_spawner.gd`
- `scripts/enemies/boss_projectile.gd`
- `scenes/enemies/boss.tscn`
- `scenes/enemies/patrol_enemy.tscn`
- `scenes/enemies/stationary_enemy.tscn`
- `levels/level_1.json`

### Testing Strategy

Each slice includes integration tests that verify user-facing behavior. Tests follow the existing pattern in `/Users/matt/dev/space_scroller/tests/`:
- Standalone scene files (.tscn) that run test scripts
- Exit code 0 for pass, 1 for fail
- 10-second timeout per test

Run tests with:
```bash
timeout 10 godot --headless --path . tests/test_[name].tscn
```

### Collision Layer Reference
- Layer 1: Player
- Layer 2: Enemies
- Layer 4: Player projectiles
- Layer 5: Player mask for enemies
- Layer 8: Enemy/boss projectiles (hits player only)
