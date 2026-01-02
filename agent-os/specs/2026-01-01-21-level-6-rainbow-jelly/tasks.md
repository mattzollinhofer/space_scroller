# Task Breakdown: Level 6 - Rainbow Jelly Theme

## Overview

Total Slices: 6
Each slice delivers incremental user value and is tested end-to-end.

## Task List

### Slice 1: Player can select and load Level 6 from the level select screen

**What this delivers:** Player sees Level 6 button in level select, can click it, and the game starts with Level 6 loaded (basic structure).

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/level_select.gd:10-11] - Level 5 button reference pattern
- [@/Users/matt/dev/space_scroller/scripts/ui/level_select.gd:20] - Button signal connection
- [@/Users/matt/dev/space_scroller/scenes/ui/level_select.tscn:87-94] - Level 5 button node definition
- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:32-38] - LEVEL_PATHS dictionary
- [@/Users/matt/dev/space_scroller/levels/level_5.json:1-98] - Template for level config
- [@/Users/matt/dev/space_scroller/tests/test_level5_select.gd:1-87] - Level select test pattern

#### Tasks

- [x] 1.1 Write integration test that verifies Level 6 button appears in level select and is enabled
- [x] 1.2 Run test, verify expected failure (no Level 6 button exists) -> Failed: "Level 6 button not found in level select"
- [x] 1.3 Add Level6Button node to level_select.tscn -> Failed: "Level 6 button should not be disabled"
- [x] 1.4 Add @onready reference and signal connection in level_select.gd, enable button in _update_button_states -> Failed: "Level 6 JSON file not found"
- [x] 1.5 Create level_6.json with pink/magenta background modulate [1.0, 0.7, 0.9, 1.0] and 6 jelly-themed sections -> Success
- [x] 1.6 Add Level 6 to GameState.LEVEL_PATHS dictionary -> Success
- [x] 1.7 Refactor if needed (keep tests green) -> No refactoring needed
- [x] 1.8 Run level-related tests to verify no regressions -> All 15 level tests pass
- [x] 1.9 Commit working slice

**Acceptance Criteria:**
- Level 6 button visible in level select screen
- Level 6 button is enabled and clickable
- Clicking Level 6 starts the game and loads level_6.json
- Level has pink/magenta background modulate and 6 themed sections

---

### Slice 2: Player encounters Jelly Snail enemies in Level 6

**What this delivers:** Player sees Jelly Snail enemies spawning during Level 6 with their distinctive slow movement, slow shooting, and jelly projectiles.

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/ghost_eye_enemy.gd:1-47] - Complete special enemy implementation
- [@/Users/matt/dev/space_scroller/scenes/enemies/ghost_eye_enemy.tscn:1-20] - Scene template
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:22-26] - Scene export pattern
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:199-202] - spawn_wave match for ghost_eye
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:253-259] - _try_spawn_special_enemy match
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:311-317] - _spawn_ghost_eye_enemy function
- [@/Users/matt/dev/space_scroller/tests/test_ghost_eye_enemy.gd:1-110] - Enemy property test pattern
- [commit:773b272] - Ghost Eye enemy implementation workflow

#### Tasks

- [x] 2.1 Write integration test that verifies Jelly Snail enemy has correct properties (5 HP, 6.0s fire rate, 60-80 zigzag speed, jelly-snail-1.png sprite) -> Created test_jelly_snail_enemy.gd/tscn
- [x] 2.2 Run test, verify expected failure (no jelly_snail_enemy.tscn exists) -> Failed: "Jelly Snail enemy scene does not exist"
- [x] 2.3 Create jelly_snail_enemy.gd extending ShootingEnemy with correct properties -> Success
- [x] 2.4 Create jelly_snail_enemy.tscn with jelly-snail-1.png sprite -> Success
- [x] 2.5 Run test, observe success -> All 5 property checks pass
- [x] 2.7 Write test that verifies Jelly Snail can be spawned via EnemySpawner -> Created test_jelly_snail_spawner.gd/tscn
- [x] 2.8 Run test, verify expected failure -> Failed: "EnemySpawner missing jelly_snail_enemy_scene export property"
- [x] 2.9 Add jelly_snail_enemy_scene export to EnemySpawner -> Success
- [x] 2.10 Add "jelly_snail" case to spawn_wave match statement -> Success
- [x] 2.11 Add "jelly_snail" case to _try_spawn_special_enemy match -> Success
- [x] 2.12 Add _spawn_jelly_snail_enemy function -> Success
- [x] 2.13 Update main.tscn to reference jelly_snail_enemy_scene -> Success
- [x] 2.14 Run spawner test, verify success -> All checks pass
- [x] 2.15 level_6.json already has jelly_snail in special_enemies config (from Slice 1) -> Already configured
- [x] 2.16 Run enemy-related tests to verify no regressions -> All 11 enemy tests pass
- [x] 2.17 Commit working slice

**Acceptance Criteria:**
- Jelly Snail enemy has 5 HP, 6.0s fire rate, 60-80 zigzag speed
- Jelly Snail uses jelly-snail-1.png sprite and weapon-jelly-1.png projectiles
- Jelly Snail spawns during Level 6 via special_enemies config
- 7-13 Jelly Snails spawn throughout the level

---

### Slice 3: Player faces Jelly Monster Boss with Up/Down Shooting attack (type 11)

**What this delivers:** Player encounters the Jelly Monster Boss at the end of Level 6. Boss performs the Up/Down Shooting attack - moving vertically while firing jelly projectiles.

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:366-389] - Vertical sweep attack (template for up/down shooting)
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:294-322] - _execute_attack match statement
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:115-119] - Attack index and count tracking
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:1275-1284] - Configure attacks array handling
- [@/Users/matt/dev/space_scroller/tests/test_boss_wall_attack.gd:1-101] - Boss attack test pattern
- [commit:40e2eaf] - Wall Attack implementation workflow

#### Tasks

- [ ] 3.1 Write integration test that verifies boss with attack type 11 moves vertically while spawning projectiles
- [ ] 3.2 Run test, verify expected failure (attack type 11 not recognized)
- [ ] 3.3 Make smallest change possible to progress
- [ ] 3.4 Run test, observe failure or success
- [ ] 3.5 Document result and update task list
- [ ] 3.6 Repeat 3.3-3.5 as necessary (expected: add _up_down_shooting_active flag, add case 11 to _execute_attack, implement _attack_up_down_shooting with vertical movement + continuous projectile firing, add _on_up_down_shooting_complete callback)
- [ ] 3.7 Add COLOR_JELLY constant for pink/jelly telegraph color
- [ ] 3.8 Update telegraph color logic for attack types 11-13
- [ ] 3.9 Update _on_health_depleted to reset _up_down_shooting_active
- [ ] 3.10 Add is_up_down_shooting() helper for testing
- [ ] 3.11 Refactor if needed (keep tests green)
- [ ] 3.12 Run boss-related tests to verify no regressions
- [ ] 3.13 Commit working slice

**Acceptance Criteria:**
- Boss with attack type 11 configured moves vertically across screen
- Boss fires jelly projectiles continuously during vertical movement
- Attack has pink/jelly telegraph color warning
- Boss returns to battle position after attack completes

---

### Slice 4: Player faces Jelly Monster Boss with Grow/Shrink attack (type 12)

**What this delivers:** Player sees the Jelly Monster Boss perform an intimidating grow/shrink animation, scaling to 4x size then back to normal.

**Dependencies:** Slice 3

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:904-956] - Square movement attack (visual movement without projectiles)
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:1286-1298] - Scale configuration in configure()
- [commit:386aeba] - Square Movement attack (movement pattern without projectiles)

#### Tasks

- [ ] 4.1 Write integration test that verifies boss with attack type 12 scales to 4x then returns to normal
- [ ] 4.2 Run test, verify expected failure (attack type 12 not recognized)
- [ ] 4.3 Make smallest change possible to progress
- [ ] 4.4 Run test, observe failure or success
- [ ] 4.5 Document result and update task list
- [ ] 4.6 Repeat 4.3-4.5 as necessary (expected: add _grow_shrink_active flag, add case 12 to _execute_attack, implement _attack_grow_shrink with tween-based scale animation, add _on_grow_shrink_complete callback)
- [ ] 4.7 Scale collision shape proportionally during growth (for contact damage)
- [ ] 4.8 Update _on_health_depleted to reset _grow_shrink_active
- [ ] 4.9 Add is_grow_shrinking() helper for testing
- [ ] 4.10 Refactor if needed (keep tests green)
- [ ] 4.11 Run boss-related tests to verify no regressions
- [ ] 4.12 Commit working slice

**Acceptance Criteria:**
- Boss with attack type 12 configured scales up to 4x original size
- Boss shrinks back to normal size after growing
- Collision shape scales proportionally for contact damage during growth
- Attack has pink/jelly telegraph color warning
- No projectiles fired during grow/shrink phase

---

### Slice 5: Player faces Jelly Monster Boss with Rapid Jelly Attack (type 13)

**What this delivers:** Player sees the Jelly Monster Boss fire 6 jelly projectiles straight forward in a rapid burst.

**Dependencies:** Slice 3

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:325-364] - _attack_horizontal_barrage (similar projectile firing pattern)
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:808-901] - Wall attack (spawning multiple projectiles)

#### Tasks

- [ ] 5.1 Write integration test that verifies boss with attack type 13 fires 6 projectiles straight forward
- [ ] 5.2 Run test, verify expected failure (attack type 13 not recognized)
- [ ] 5.3 Make smallest change possible to progress
- [ ] 5.4 Run test, observe failure or success
- [ ] 5.5 Document result and update task list
- [ ] 5.6 Repeat 5.3-5.5 as necessary (expected: add case 13 to _execute_attack, implement _attack_rapid_jelly that fires 6 projectiles with direction Vector2(-1, 0))
- [ ] 5.7 Refactor if needed (keep tests green)
- [ ] 5.8 Run boss-related tests to verify no regressions
- [ ] 5.9 Commit working slice

**Acceptance Criteria:**
- Boss with attack type 13 configured fires exactly 6 projectiles
- All 6 projectiles travel straight left (no spread angle)
- Projectiles use weapon-jelly-1.png texture
- Attack has pink/jelly telegraph color warning

---

### Slice 6: Level 6 boss configuration complete with full attack cycle

**What this delivers:** Complete Level 6 experience with Jelly Monster Boss using all three new attacks in sequence (11 -> 12 -> 13 -> repeat).

**Dependencies:** Slices 1, 3, 4, 5

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/levels/level_5.json:14-21] - boss_config structure

#### Tasks

- [ ] 6.1 Update level_6.json boss_config with jelly-monster-1.png sprite
- [ ] 6.2 Configure boss attacks array: [11, 12, 13]
- [ ] 6.3 Set boss health to 24-25 HP
- [ ] 6.4 Set projectile_sprite to weapon-jelly-1.png
- [ ] 6.5 Write integration test that loads Level 6 and verifies boss has correct sprite and attack sequence
- [ ] 6.6 Run test, verify it passes
- [ ] 6.7 Manually verify full Level 6 playthrough (optional but recommended)
- [ ] 6.8 Run all Level 6 related tests together
- [ ] 6.9 Run full test suite to verify no regressions
- [ ] 6.10 Commit final Level 6 implementation

**Acceptance Criteria:**
- Level 6 boss uses jelly-monster-1.png sprite
- Boss has 24-25 HP
- Boss cycles through attacks: Up/Down Shooting -> Grow/Shrink -> Rapid Jelly Attack
- Boss projectiles use weapon-jelly-1.png sprite
- Player can complete Level 6 from start to boss defeat
- All existing tests continue to pass

---

## Test Commands Reference

### During Development (run feature-specific tests)

```bash
# Level-related tests:
for t in tests/test_level*.tscn; do timeout 10 godot --headless --path /Users/matt/dev/space_scroller "$t" || exit 1; done

# Enemy-related tests:
for t in tests/test_*enemy*.tscn; do timeout 10 godot --headless --path /Users/matt/dev/space_scroller "$t" || exit 1; done

# Boss-related tests:
for t in tests/test_boss*.tscn; do timeout 10 godot --headless --path /Users/matt/dev/space_scroller "$t" || exit 1; done
```

### After Completing Each Slice (run full suite once)

```bash
timeout 180 bash -c 'failed=0; for t in tests/*.tscn; do echo "=== $t ==="; timeout 10 godot --headless --path /Users/matt/dev/space_scroller "$t" || ((failed++)); done; echo "Failed: $failed"; exit $failed'
```

## Files to Create/Modify

### New Files
- `levels/level_6.json` - Level 6 configuration
- `scripts/enemies/jelly_snail_enemy.gd` - Jelly Snail enemy script
- `scenes/enemies/jelly_snail_enemy.tscn` - Jelly Snail enemy scene
- `tests/test_level6_select.gd` - Level 6 select test
- `tests/test_level6_select.tscn` - Level 6 select test scene
- `tests/test_jelly_snail_enemy.gd` - Jelly Snail enemy test
- `tests/test_jelly_snail_enemy.tscn` - Jelly Snail enemy test scene
- `tests/test_boss_up_down_shooting.gd` - Up/Down Shooting attack test
- `tests/test_boss_up_down_shooting.tscn` - Up/Down Shooting attack test scene
- `tests/test_boss_grow_shrink.gd` - Grow/Shrink attack test
- `tests/test_boss_grow_shrink.tscn` - Grow/Shrink attack test scene
- `tests/test_boss_rapid_jelly.gd` - Rapid Jelly attack test
- `tests/test_boss_rapid_jelly.tscn` - Rapid Jelly attack test scene

### Modified Files
- `scripts/autoloads/game_state.gd` - Add Level 6 to LEVEL_PATHS
- `scripts/ui/level_select.gd` - Add Level 6 button reference and handler
- `scenes/ui/level_select.tscn` - Add Level 6 button node
- `scripts/enemies/enemy_spawner.gd` - Add jelly_snail support
- `scripts/enemies/boss.gd` - Add attack types 11, 12, 13
- `scenes/main.tscn` - Add jelly_snail_enemy_scene export reference to EnemySpawner (if needed)

## Existing Assets (Already in Codebase)

- `assets/sprites/jelly-monster-1.png` - Jelly Monster Boss sprite
- `assets/sprites/jelly-snail-1.png` - Jelly Snail enemy sprite
- `assets/sprites/weapon-jelly-1.png` - Jelly attack/projectile sprite
