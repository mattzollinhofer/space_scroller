# Task Breakdown: Level 4 - Pepperoni Pizza Theme

## Overview

Total Slices: 5
Each slice delivers incremental user value and is tested end-to-end.

## Task List

### Slice 1: Player can select and start Level 4 with basic structure

**What this delivers:** Player sees Level 4 in the level select menu and can start a playable level with pizza-themed section names.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/levels/level_3.json:1-99] - Template for level JSON structure
- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:32-36] - LEVEL_PATHS dictionary to add level 4

#### Tasks

- [ ] 1.1 Write integration test verifying Level 4 can be selected and loaded via GameState
- [ ] 1.2 Run test, verify expected failure
- [ ] 1.3 Make smallest change possible to progress (add level 4 to LEVEL_PATHS)
- [ ] 1.4 Run test, observe failure or success
- [ ] 1.5 Create levels/level_4.json with total_distance: 24000, scroll_speed_multiplier: 1.3
- [ ] 1.6 Add 6 pizza-themed sections (Pizza Parlor Entry, Cheese Caverns, Pepperoni Pass, Garlic Grove, Mushroom Maze, Final Feast)
- [ ] 1.7 Configure enemy waves scaling from Level 3 values
- [ ] 1.8 Run test, observe success
- [ ] 1.9 Manually test level loads in game
- [ ] 1.10 Commit working slice

**Acceptance Criteria:**
- Player can select Level 4 from level select
- Level 4 loads with correct scroll speed (1.3x)
- All 6 sections have pizza-themed names
- Enemy waves spawn throughout the level

---

### Slice 2: Player encounters Pepperoni Pizza Boss with spread attack

**What this delivers:** When player reaches 100% progress in Level 4, the Pepperoni Pizza Boss appears and attacks with a three-pronged pepperoni spread.

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:303-340] - _attack_horizontal_barrage() for spread pattern
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:960-1010] - configure() for boss config
- [commit:e67e897] - Adding new boss attack pattern (Frozen Nova)

#### Tasks

- [ ] 2.1 Write integration test: Boss spawns with custom sprite and fires 3-projectile spread
- [ ] 2.2 Run test, verify expected failure
- [ ] 2.3 Add boss_sprite: pepperoni-pizza-boss-1.png and projectile_sprite: pepperoni-attack-1.png to level_4.json metadata
- [ ] 2.4 Add boss_config with health: 20, scale: 9 to level_4.json
- [ ] 2.5 Add attack index 7 (_attack_pepperoni_spread) to boss.gd _execute_attack() match
- [ ] 2.6 Implement _attack_pepperoni_spread(): 3 projectiles in 45-degree spread pattern
- [ ] 2.7 Add attacks array [7, 8] to boss_config (only using 7 until circle implemented)
- [ ] 2.8 Run test, observe result
- [ ] 2.9 Repeat 2.3-2.8 as necessary until test passes
- [ ] 2.10 Refactor if needed (keep tests green)
- [ ] 2.11 Run boss-related tests to verify no regressions
- [ ] 2.12 Commit working slice

**Acceptance Criteria:**
- Boss uses pepperoni-pizza-boss-1.png sprite
- Boss fires 3 pepperoni projectiles in spread pattern
- Boss has 20 HP and scale 9

---

### Slice 3: Pepperoni Pizza Boss performs alternating circle movement

**What this delivers:** Boss moves in a circle around the arena between spread attacks, alternating clockwise and counter-clockwise each cycle.

**Dependencies:** Slice 2

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:344-367] - _attack_vertical_sweep() tween movement pattern
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:499-524] - _attack_heat_wave() for sweep-style active attack

#### Tasks

- [ ] 3.1 Write integration test: Boss performs circle movement, alternates direction each cycle
- [ ] 3.2 Run test, verify expected failure
- [ ] 3.3 Add _circle_clockwise state variable to boss.gd
- [ ] 3.4 Add attack index 8 (_attack_circle_movement) to _execute_attack() match
- [ ] 3.5 Implement _attack_circle_movement() using tween to move in circular path
- [ ] 3.6 Toggle _circle_clockwise on each circle completion
- [ ] 3.7 Update level_4.json boss_config attacks array to [7, 8]
- [ ] 3.8 Run test, observe result
- [ ] 3.9 Repeat 3.3-3.8 as necessary until test passes
- [ ] 3.10 Verify boss attack sequence cycles: spread -> circle -> spread -> circle (alternating direction)
- [ ] 3.11 Run all boss tests to verify no regressions
- [ ] 3.12 Commit working slice

**Acceptance Criteria:**
- Boss moves in circle around battle area
- Circle direction alternates each cycle (CW, CCW, CW, CCW...)
- Attack sequence is: spread attack, circle movement, repeat

---

### Slice 4: Player encounters Garlic Man enemy with fast zigzag and projectiles

**What this delivers:** A new Garlic Man enemy appears in Level 4 with faster zigzag movement (240-280 speed), 3 HP, and shoots pizza projectiles at fire_rate 1.0.

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/shooting_enemy.gd:1-56] - ShootingEnemy base class
- [@/Users/matt/dev/space_scroller/scenes/enemies/shooting_enemy.tscn:1-20] - Scene structure
- [@/Users/matt/dev/space_scroller/tests/test_charger_enemy.gd:1-112] - Test pattern for new enemy type
- [commit:ef7024a] - Adding new enemy type to spawner

#### Tasks

- [ ] 4.1 Write integration test: GarlicEnemy has 3 HP, fast zigzag (240-280), fires projectiles at rate 1.0
- [ ] 4.2 Run test, verify expected failure
- [ ] 4.3 Create scripts/enemies/garlic_enemy.gd extending ShootingEnemy
- [ ] 4.4 Override _ready() to set health = 3, fire_rate = 1.0, zigzag_speed = random 240-280
- [ ] 4.5 Load pizza-attack-1.png as custom projectile texture
- [ ] 4.6 Create scenes/enemies/garlic_enemy.tscn with pizza-garlic-enemy-1.png sprite
- [ ] 4.7 Run test, observe result
- [ ] 4.8 Repeat 4.3-4.7 as necessary until test passes
- [ ] 4.9 Add garlic_enemy_scene @export to enemy_spawner.gd
- [ ] 4.10 Add "garlic" case to spawn_wave() match statement
- [ ] 4.11 Add _spawn_garlic_enemy() method following existing pattern
- [ ] 4.12 Wire up garlic_enemy.tscn in main.tscn EnemySpawner node
- [ ] 4.13 Run enemy-related tests to verify no regressions
- [ ] 4.14 Commit working slice

**Acceptance Criteria:**
- Garlic Man has 3 HP (survives 2 hits)
- Garlic Man moves with faster zigzag (240-280 vs normal 120)
- Garlic Man shoots pizza projectiles every 1.0 seconds
- Uses pizza-garlic-enemy-1.png sprite

---

### Slice 5: Garlic Man spawns exclusively in Level 4 sections 3-6

**What this delivers:** Garlic Man only appears in Level 4, in sections 3-6 (Pepperoni Pass through Final Feast), with 15-20% spawn probability per filler spawn opportunity.

**Dependencies:** Slices 1, 4

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:187-199] - _spawn_filler_enemy() weighted random
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:155-161] - Level metadata and enemy config loading

#### Tasks

- [ ] 5.1 Write integration test: Garlic spawns only in Level 4 sections 3-6, with correct probability
- [ ] 5.2 Run test, verify expected failure
- [ ] 5.3 Add special_enemies configuration to level_4.json metadata
- [ ] 5.4 Define garlic entry: enemy_type: "garlic", spawn_probability: 0.18, allowed_sections: [3, 4, 5, 6]
- [ ] 5.5 Modify enemy_spawner.gd to track current section and level metadata
- [ ] 5.6 Add set_special_enemy_config(config: Dictionary) method to enemy_spawner.gd
- [ ] 5.7 Modify _spawn_filler_enemy() to check special enemy config
- [ ] 5.8 If in allowed section, roll for special enemy spawn before normal filler
- [ ] 5.9 Update level_manager.gd to pass special_enemies config to enemy spawner
- [ ] 5.10 Run test, observe result
- [ ] 5.11 Repeat 5.3-5.10 as necessary until test passes
- [ ] 5.12 Add garlic waves to level_4.json sections 3-6 enemy_waves arrays
- [ ] 5.13 Run all level and spawner tests to verify no regressions
- [ ] 5.14 Commit working slice

**Acceptance Criteria:**
- Garlic Man only spawns in Level 4 (not other levels)
- Garlic Man only appears in sections 3-6
- Approximately 15-20% of filler spawns in those sections are Garlic Men
- Special enemy system is extensible for future levels

---

### Slice 6: Full integration and polish

**What this delivers:** Complete Level 4 experience: player progresses through 6 sections, encounters Garlic Men in later sections, defeats Pepperoni Pizza Boss, and level completion unlocks properly.

**Dependencies:** Slices 1-5

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:1-200] - Level completion and progression flow

#### Tasks

- [ ] 6.1 Write end-to-end test: Play through Level 4 from start to boss defeat
- [ ] 6.2 Verify level 3 completion unlocks level 4 in save data
- [ ] 6.3 Verify level select shows Level 4 button (locked until Level 3 complete)
- [ ] 6.4 Play through Level 4 manually, verify:
  - Scroll speed feels faster (1.3x)
  - Garlic Men appear only in later sections
  - Boss uses spread + circle attack pattern correctly
  - Boss circle direction alternates properly
- [ ] 6.5 Tune any difficulty imbalances (enemy counts, boss timing)
- [ ] 6.6 Run full test suite to verify no regressions
- [ ] 6.7 Commit final polish

**Acceptance Criteria:**
- Complete Level 4 experience is playable
- Level 3 completion unlocks Level 4
- All new features work together seamlessly
- No regressions in existing levels

---

## Test Commands

### During Development (run frequently)

```bash
# Level-related tests
for t in tests/test_level*.tscn; do timeout 10 godot --headless --path . "$t" || exit 1; done

# Enemy-related tests
for t in tests/test_*enemy*.tscn; do timeout 10 godot --headless --path . "$t" || exit 1; done

# Boss-related tests
for t in tests/test_boss*.tscn; do timeout 10 godot --headless --path . "$t" || exit 1; done

# Spawner tests
for t in tests/test_spawn*.tscn; do timeout 10 godot --headless --path . "$t" || exit 1; done
```

### After Completing Each Slice (run once)

```bash
timeout 180 bash -c 'failed=0; for t in tests/*.tscn; do timeout 10 godot --headless --path . "$t" || ((failed++)); done; echo "Failed: $failed"; exit $failed'
```

## Notes

- The special enemy system in Slice 5 is designed to be extensible for Level 5 ghost enemies (roadmap item 20)
- Boss attack indices 7 and 8 are added to boss.gd, following the pattern of existing attacks 0-6
- The GarlicEnemy class extends ShootingEnemy to reuse projectile firing logic
- Circle movement uses tweens similar to existing vertical sweep attack
