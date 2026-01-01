# Task Breakdown: Level 5 - Ghost Theme

## Overview

Total Slices: 4
Each slice delivers incremental user value and is tested end-to-end.

This implementation follows the established patterns from Level 4 implementation (commit 84281c9, cf63a47, cdbf6b5) for special enemies, enemy spawning, and boss attack patterns.

## Task List

### Slice 1: User can select and play Level 5 from the level select screen

**What this delivers:** Player can see a Level 5 button in the level select UI, click it, and load a basic ghost-themed level that plays to completion with a boss fight.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/levels/level_4.json:1-97] - Level JSON structure template
- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:32-37] - LEVEL_PATHS dictionary
- [@/Users/matt/dev/space_scroller/scenes/ui/level_select.tscn:52-86] - Level button node pattern
- [@/Users/matt/dev/space_scroller/scripts/ui/level_select.gd:6-38] - Button handling pattern
- [@/Users/matt/dev/space_scroller/tests/test_level4_load.gd:1-154] - Level load test template
- [@/Users/matt/dev/space_scroller/tests/test_level4_select.gd:1-87] - Level select test template

#### Tasks

- [x] 1.1 Write integration test for Level 5 selection (test_level5_select.gd)
  - Loads level_select.tscn
  - Finds Level5Button by name
  - Verifies button is enabled
- [x] 1.2 Run test, verify expected failure (Level 5 button not found) -> Success
- [x] 1.3 Add Level5Button node to level_select.tscn (following Level4Button pattern)
- [x] 1.4 Add @onready var _level5_button reference in level_select.gd
- [x] 1.5 Connect Level 5 button signal and update _update_button_states()
- [x] 1.6 Run test, verify passes -> Success
- [x] 1.7 Write integration test for Level 5 loading (test_level5_load.gd)
  - Verifies level 5 in GameState.LEVEL_PATHS
  - Loads and parses level_5.json
  - Checks total_distance = 24000, 6 sections, ghost-themed names
  - Verifies boss_config exists with attacks [9, 10]
- [x] 1.8 Run test, verify expected failure (level 5 not in LEVEL_PATHS) -> Success
- [x] 1.9 Add level 5 entry to GameState.LEVEL_PATHS: `5: "res://levels/level_5.json"`
- [x] 1.10 Run test, verify failure (JSON file doesn't exist) -> Success
- [x] 1.11 Create level_5.json with ghost theme structure:
  - total_distance: 24000
  - 6 sections with ghost-themed names (Haunted Entry, Phantom Passage, etc.)
  - boss_config with health: 22, scale: 6, attacks: [9, 10], projectile_sprite: ghost-attack-1.png
  - boss_sprite: ghost-boss-1.png in metadata
  - special_enemies config for ghost_eye (added in Slice 2)
  - Background modulate color for spooky atmosphere
- [x] 1.12 Run test, verify all level structure checks pass -> Success (fixed JSON float handling in test)
- [x] 1.13 Manually test: Start game, go to level select, click Level 5 -> Skipped (per task instructions)
  - Note: Boss attacks 9 and 10 not implemented yet - boss will default to attack 0
- [x] 1.14 Commit slice 1 changes

**Acceptance Criteria:**
- Level 5 button appears in level select UI
- Level 5 button is clickable and starts the game
- Level loads without errors and scrolls through 6 ghost-themed sections
- Boss spawns at end (uses fallback attack since types 9/10 not yet implemented)
- Both integration tests pass

---

### Slice 2: User encounters Ghost Eye enemies during Level 5

**What this delivers:** Ghost Eye enemies spawn during Level 5 gameplay, giving players a new enemy type to fight with unique ghost visuals and faster behavior.

**Dependencies:** Slice 1 (Level 5 must be playable)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/garlic_enemy.gd:1-47] - Special enemy script template
- [@/Users/matt/dev/space_scroller/scenes/enemies/garlic_enemy.tscn:1-20] - Special enemy scene template
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:7-24] - Enemy scene exports
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:229-257] - Special enemy spawn logic
- [commit:84281c9] - Garlic Man enemy implementation pattern

#### Tasks

- [x] 2.1 Write integration test for Ghost Eye enemy spawning (test_ghost_eye_enemy.gd)
  - Instantiate ghost_eye_enemy.tscn
  - Verify enemy has 3 health
  - Verify fire_rate is 1.0
  - Verify zigzag_speed is in range 240-280
  - Verify sprite texture is ghost-eye-enemy-1.png
- [x] 2.2 Run test, verify expected failure (scene doesn't exist) -> Success (scene not found)
- [x] 2.3 Create ghost_eye_enemy.gd extending ShootingEnemy:
  - class_name GhostEyeEnemy
  - Load ghost-attack-1.png projectile texture
  - Set health = 3, fire_rate = 1.0
  - Set zigzag_speed = randf_range(240.0, 280.0)
  - Override _fire_projectile() to apply custom texture
- [x] 2.4 Create ghost_eye_enemy.tscn:
  - Area2D root with collision_layer=2, collision_mask=5
  - Sprite2D with ghost-eye-enemy-1.png and appropriate scale
  - CollisionShape2D with RectangleShape2D sized for sprite
  - Attach ghost_eye_enemy.gd script
- [x] 2.5 Run test, verify Ghost Eye properties are correct -> Success
- [x] 2.6 Add ghost_eye_enemy_scene export to enemy_spawner.gd
- [x] 2.7 Add _spawn_ghost_eye_enemy() function following _spawn_garlic_enemy() pattern
- [x] 2.8 Add "ghost_eye" case to spawn_wave() match statement
- [x] 2.9 Add "ghost_eye" case to _try_spawn_special_enemy() match statement
- [x] 2.10 Update level_5.json:
  - Add special_enemies config: ghost_eye with 0.45 probability, sections [1,2,3,4,5] -> Already done in Slice 1
  - Add ghost_eye to enemy_waves in sections 2-6 -> Already done in Slice 1
- [x] 2.11 Skip manual test (will verify in final slice)
- [x] 2.12 Commit slice 2 changes

**Acceptance Criteria:**
- Ghost Eye enemy scene loads without errors
- Ghost Eye has 3 HP, 1.0s fire rate, 240-280 zigzag speed
- Ghost Eye spawns during Level 5 sections (via waves and special spawn system)
- Ghost Eye fires ghost-attack-1.png projectiles
- Integration test passes
- Previous slice functionality still works

---

### Slice 3: User experiences Ghost Monster Boss Wall Attack

**What this delivers:** When fighting the Level 5 boss, the Ghost Monster Boss performs its signature Wall Attack - projectiles fan out vertically then shoot horizontally toward the player.

**Dependencies:** Slices 1-2 (Level 5 playable with Ghost Eye enemies)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:283-308] - Attack dispatch in _execute_attack()
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:310-348] - _attack_horizontal_barrage() as projectile pattern template
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:461-503] - _attack_solar_flare() as radial pattern reference
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:233-269] - Telegraph color system

#### Tasks

- [x] 3.1 Write integration test for Wall Attack (test_boss_wall_attack.gd)
  - Instantiate boss scene
  - Configure with attacks: [9]
  - Start attack cycle
  - Wait for attack to execute
  - Verify projectiles spawn (6 projectiles expected)
- [x] 3.2 Run test, verify expected failure (attack type 9 not implemented) -> Success (0 projectiles spawned)
- [x] 3.3 Add _wall_attack_active tracking variable to boss.gd
- [x] 3.4 Add case 9 to _execute_attack() match statement, calling _attack_wall()
- [x] 3.5 Add wall attack telegraph color (ghost purple/blue tint) to _play_attack_telegraph()
- [x] 3.6 Implement _attack_wall() function:
  - Create 6 projectiles at boss position
  - 3 projectiles fan upward (evenly spaced angles)
  - 3 projectiles fan downward (evenly spaced angles)
  - Each projectile uses tween: move vertically for 0.5s, then change direction to horizontal left
  - Apply ghost-attack texture via _apply_projectile_texture()
  - Set _wall_attack_active = true
  - Create tween with callback to _on_wall_attack_complete()
- [x] 3.7 Implement _on_wall_attack_complete():
  - Set _wall_attack_active = false
  - Transition to COOLDOWN state
- [x] 3.8 Update _process_attack_state() to check _wall_attack_active (like _sweep_active)
- [x] 3.9 Update stop_attack_cycle() to reset _wall_attack_active
- [x] 3.10 Update _on_health_depleted() to reset _wall_attack_active
- [x] 3.11 Run test, verify Wall Attack executes correctly -> Success (6 projectiles spawned)
- [x] 3.12 Skip manual test (will verify in final slice)
- [x] 3.13 Commit slice 3 changes

**Acceptance Criteria:**
- Boss attack type 9 (Wall Attack) is implemented
- Wall Attack spawns 6 projectiles that fan vertically then shoot horizontally
- Telegraph shows ghost-themed color before Wall Attack
- Attack properly transitions to cooldown after completion
- Integration test passes
- Previous slices still work (Level 5 loads, Ghost Eyes spawn)

---

### Slice 4: User experiences Ghost Monster Boss Square Movement Attack

**What this delivers:** The Ghost Monster Boss performs a Square Movement attack, moving in a rectangular path around the arena without firing, creating a dynamic dodging challenge for the player.

**Dependencies:** Slices 1-3 (Level 5 with Ghost Eyes and Wall Attack)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:722-788] - _attack_circle_movement() as movement attack template
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:777-782] - _on_circle_complete() state transition
- [commit:cdbf6b5] - Circle movement attack implementation

#### Tasks

- [ ] 4.1 Write integration test for Square Movement (test_boss_square_movement.gd)
  - Instantiate boss scene
  - Configure with attacks: [10]
  - Record initial position
  - Start attack cycle
  - Wait for attack to complete (longer timeout for movement)
  - Verify boss position changed during attack
  - Verify boss returns to battle position after
- [ ] 4.2 Run test, verify expected failure (attack type 10 not implemented)
- [ ] 4.3 Add _square_active tracking variable to boss.gd
- [ ] 4.4 Add case 10 to _execute_attack() match statement, calling _attack_square_movement()
- [ ] 4.5 Update _process_attack_state() to check _square_active (alongside _circle_active)
- [ ] 4.6 Implement _attack_square_movement() function:
  - Similar structure to _attack_circle_movement()
  - Define 4 corner positions for rectangular path
  - Use CIRCLE_RADIUS for movement distance
  - Create tween moving through corners sequentially
  - No projectiles fired during movement
  - Return to _battle_position after completing rectangle
  - Call _on_square_complete() when done
- [ ] 4.7 Implement _on_square_complete():
  - Set _square_active = false
  - Transition to COOLDOWN state
- [ ] 4.8 Add is_square_moving() helper method for testing
- [ ] 4.9 Update stop_attack_cycle() to reset _square_active
- [ ] 4.10 Update _on_health_depleted() to reset _square_active
- [ ] 4.11 Run test, verify Square Movement executes correctly
- [ ] 4.12 Run all Level 5 tests to verify no regressions:
  ```bash
  for t in tests/test_level5*.tscn tests/test_ghost*.tscn tests/test_boss_wall*.tscn tests/test_boss_square*.tscn; do timeout 10 godot --headless --path . "$t" || exit 1; done
  ```
- [ ] 4.13 Manually test complete Level 5 experience:
  - Select Level 5 from menu
  - Play through ghost-themed sections
  - Fight Ghost Eye enemies
  - Battle Ghost Monster Boss with Wall Attack and Square Movement cycle
  - Verify boss attack sequence: Enter -> Wall Attack -> Square Move -> repeat
- [ ] 4.14 Run full test suite to verify no regressions:
  ```bash
  timeout 180 bash -c 'failed=0; for t in tests/*.tscn; do timeout 10 godot --headless --path . "$t" || ((failed++)); done; echo "Failed: $failed"; exit $failed'
  ```
- [ ] 4.15 Commit slice 4 changes

**Acceptance Criteria:**
- Boss attack type 10 (Square Movement) is implemented
- Boss moves in rectangular path without firing projectiles
- Boss returns to battle position after movement completes
- Complete boss attack cycle works: Wall Attack -> Square Movement -> repeat
- All new tests pass
- Full test suite passes with no regressions
- User can complete entire Level 5 experience

---

## Files Summary

### Files to Create:
- `levels/level_5.json` - Level configuration (Slice 1)
- `scripts/enemies/ghost_eye_enemy.gd` - Ghost Eye enemy script (Slice 2)
- `scenes/enemies/ghost_eye_enemy.tscn` - Ghost Eye enemy scene (Slice 2)
- `tests/test_level5_select.gd` - Level 5 selection test (Slice 1)
- `tests/test_level5_select.tscn` - Level 5 selection test scene (Slice 1)
- `tests/test_level5_load.gd` - Level 5 load test (Slice 1)
- `tests/test_level5_load.tscn` - Level 5 load test scene (Slice 1)
- `tests/test_ghost_eye_enemy.gd` - Ghost Eye enemy test (Slice 2)
- `tests/test_ghost_eye_enemy.tscn` - Ghost Eye enemy test scene (Slice 2)
- `tests/test_boss_wall_attack.gd` - Wall Attack test (Slice 3)
- `tests/test_boss_wall_attack.tscn` - Wall Attack test scene (Slice 3)
- `tests/test_boss_square_movement.gd` - Square Movement test (Slice 4)
- `tests/test_boss_square_movement.tscn` - Square Movement test scene (Slice 4)

### Files to Modify:
- `scripts/autoloads/game_state.gd` - Add level 5 to LEVEL_PATHS (Slice 1)
- `scenes/ui/level_select.tscn` - Add Level5Button node (Slice 1)
- `scripts/ui/level_select.gd` - Add level 5 button handling (Slice 1)
- `scripts/enemies/enemy_spawner.gd` - Add ghost_eye support (Slice 2)
- `scripts/enemies/boss.gd` - Add attack types 9, 10 (Slices 3-4)

### Existing Assets (no changes needed):
- `assets/sprites/ghost-boss-1.png` - Ghost Monster Boss sprite
- `assets/sprites/ghost-eye-enemy-1.png` - Ghost Eye enemy sprite
- `assets/sprites/ghost-attack-1.png` - Ghost projectile sprite
