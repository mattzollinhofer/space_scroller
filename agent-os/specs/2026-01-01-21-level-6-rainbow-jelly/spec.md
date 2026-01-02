# Specification: Level 6 - Rainbow Jelly Theme

## Goal

Add Level 6 with a rainbow jelly theme featuring a Jelly Monster Boss with unique attack patterns (up/down shooting, grow/shrink, rapid jelly attack) and Jelly Snail special enemies characterized by very slow movement and slow shooting.

## User Stories

- As a player, I want to play Level 6 with a rainbow jelly theme so that I have new challenging content after completing Level 5
- As a player, I want to face the Jelly Monster Boss with unique attacks so that the boss fight feels fresh and thematic

## Specific Requirements

**Level 6 selection and loading**

- Add Level 6 button to level select UI (following Level 5 button pattern)
- Add Level 6 path to GameState.LEVEL_PATHS: `6: "res://levels/level_6.json"`
- Create `level_6.json` with rainbow jelly theme structure
- Pink/magenta background modulate color: approximately `[1.0, 0.7, 0.9, 1.0]`
- Total distance: 24,000 pixels (consistent with Levels 4-5)
- Scroll speed multiplier: 1.40 (increase from Level 5's 1.35)
- Enemy zigzag speeds: 180-240 (increased from Level 5's 170-230)

**Level 6 sections with jelly/rainbow themed names**

- 6 sections with progressive difficulty
- Section names like: "Jelly Entrance", "Rainbow Passage", "Gelatinous Depths", "Slime Gardens", "Wobbling Wastes", "Jelly Kingdom"
- Enemy waves increasing in intensity through sections
- Jelly Snail enemies spawn via special_enemies config in sections 1-5

**Jelly Snail special enemy**

- New enemy type extending ShootingEnemy (same pattern as GhostEyeEnemy)
- Custom sprite: `jelly-snail-1.png`
- Custom projectile sprite: `weapon-jelly-1.png`
- 5 health points (survives 4 hits, more durable than Ghost Eye's 3 HP)
- SLOW zigzag speed: 60-80 (intentionally much slower than other enemies)
- SLOW fire rate: 6.0 seconds between shots (vs Ghost Eye's 1.0s)
- Added to EnemySpawner via `jelly_snail_enemy_scene` export
- Added to spawn_wave match statement and _try_spawn_special_enemy
- Target: 7-13 Jelly Snail enemies throughout level (10 +/- 3)

**Jelly Monster Boss configuration**

- Boss sprite: `res://assets/sprites/jelly-monster-1.png`
- Boss projectile sprite: `res://assets/sprites/weapon-jelly-1.png`
- Health: 24-25 HP (progression from Level 5's 22 HP)
- Scale: 1.5 (standard boss scale)
- Attack sequence: `[11, 12, 13]` for up/down shooting, grow/shrink, rapid attack cycle
- Attack cooldown: 1.0 seconds

**Up/Down Shooting attack (type 11)**

- Boss moves vertically across full screen height (Y_MIN to Y_MAX and back)
- Fires projectiles using weapon-jelly-1.png while moving vertically
- Similar sweep mechanics to existing vertical sweep (type 1) but continuous
- Add `_up_down_shooting_active` flag for state tracking
- Telegraph color: pink/jelly tint for warning

**Grow/Shrink attack (type 12)**

- Boss scales up to 4x size, then shrinks back to normal
- Visual intimidation phase - no projectiles fired
- Contact damage during enlarged state if easy to implement, otherwise visual only
- Add `_grow_shrink_active` flag for state tracking
- Scale collision shape proportionally during growth for contact damage

**Rapid Jelly Attack (type 13)**

- Fire 6 projectiles straight forward (left) simultaneously
- Uses weapon-jelly-1.png sprite for all projectiles
- Similar to horizontal barrage but with fixed 6 projectiles, no spread
- Add jelly-themed color constant if needed

## Visual Design

No mockups provided. Sprites exist in codebase:
- `assets/sprites/jelly-monster-1.png` - Jelly Monster Boss sprite
- `assets/sprites/jelly-snail-1.png` - Jelly Snail enemy sprite
- `assets/sprites/weapon-jelly-1.png` - Jelly projectile sprite (shared)

## Leverage Existing Knowledge

**Code, component, or existing logic found**

GhostEyeEnemy as template for JellySnailEnemy
- [@/Users/matt/dev/space_scroller/scripts/enemies/ghost_eye_enemy.gd:1-47] - Complete special enemy implementation
  - Extends ShootingEnemy class_name pattern (line 1-4)
  - Custom projectile texture loading in _ready() before super call (line 10-12)
  - Health, fire_rate, and zigzag_speed configuration (lines 17-23)
  - Override _fire_projectile() for custom texture application (lines 26-46)

GhostEyeEnemy scene structure for JellySnailEnemy scene
- [@/Users/matt/dev/space_scroller/scenes/enemies/ghost_eye_enemy.tscn:1-20] - Scene template
  - UID format and load_steps structure
  - Script and sprite external resources
  - CollisionShape2D size for special enemy
  - Sprite2D scale configuration

Level 5 JSON as template for Level 6 config
- [@/Users/matt/dev/space_scroller/levels/level_5.json:1-98] - Complete level structure
  - total_distance, enemy_config, metadata, sections format
  - scroll_speed_multiplier and background_modulate configuration
  - boss_config with health, scale, attacks array, projectile_sprite
  - special_enemies array with enemy_type, spawn_probability, allowed_sections

EnemySpawner special enemy support
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:25-26] - Ghost eye scene export pattern
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:199-202] - spawn_wave match for ghost_eye
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:253-259] - _try_spawn_special_enemy match for ghost_eye
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:311-317] - _spawn_ghost_eye_enemy function pattern

Boss attack implementation patterns
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:366-389] - Vertical sweep attack (reference for up/down shooting)
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:808-901] - Wall attack with projectile fanning
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:904-956] - Square movement attack pattern
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:1275-1284] - Configure attacks array handling
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:294-322] - _execute_attack match statement

Level select UI patterns
- [@/Users/matt/dev/space_scroller/scripts/ui/level_select.gd:10-11] - Button reference pattern for Level 5
- [@/Users/matt/dev/space_scroller/scripts/ui/level_select.gd:20] - Button pressed signal connection
- [@/Users/matt/dev/space_scroller/scripts/ui/level_select.gd:42-43] - Button state update pattern
- [@/Users/matt/dev/space_scroller/scenes/ui/level_select.tscn:87-94] - Level 5 button node definition

GameState level paths
- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:32-38] - LEVEL_PATHS dictionary pattern

Test patterns for special enemies
- [@/Users/matt/dev/space_scroller/tests/test_ghost_eye_enemy.gd:1-110] - Complete enemy property test
  - Scene loading and instantiation
  - Health, fire_rate, zigzag_speed verification
  - Sprite texture path verification

Test patterns for boss attacks
- [@/Users/matt/dev/space_scroller/tests/test_boss_wall_attack.gd:1-101] - Boss attack test pattern
  - Configure boss with specific attack type
  - Set _entrance_complete = true for testing
  - Start attack cycle and wait for execution
  - Count spawned projectiles

Test patterns for level selection
- [@/Users/matt/dev/space_scroller/tests/test_level5_select.gd:1-87] - Level button test pattern
  - Load level select scene
  - Find button by name or text
  - Verify button is not disabled

**Git Commit found**

Ghost Eye enemy implementation commit
- [773b272:Add Ghost Eye enemy for Level 5 ghost theme] - Template for Jelly Snail implementation
  - Shows complete workflow: script, scene, enemy spawner updates, test
  - Files changed: ghost_eye_enemy.gd, ghost_eye_enemy.tscn, enemy_spawner.gd, test_ghost_eye_enemy.gd

Level 5 configuration commit
- [abff2cd:Add Level 5 ghost-themed level with selection and loading support] - Template for Level 6 setup
  - Level JSON creation, level select UI, GameState update, tests
  - Shows section structure and boss_config pattern

Wall Attack boss implementation commit
- [40e2eaf:Add Ghost Monster Boss Wall Attack (attack type 9) for Level 5] - Template for new boss attacks
  - Adding new attack type to boss.gd
  - State tracking with _wall_attack_active flag
  - Telegraph color selection

Square Movement attack commit
- [386aeba:Add Ghost Monster Boss Square Movement (attack type 10) for Level 5] - Movement attack pattern
  - Boss movement without projectiles (reference for grow/shrink visual phase)
  - Tween-based movement and state tracking

## Out of Scope

- New background theme or parallax layers (using modulate colors instead)
- New power-ups or collectibles specific to Level 6
- New player abilities or weapons
- Changes to existing game mechanics or enemy behaviors
- New audio/music tracks (use existing boss battle music pattern)
- Level progression/unlock system changes
- Difficulty scaling adjustments beyond what's in level config
- Mobile/touch control modifications
- Achievements or statistics tracking for Level 6
- Any features not explicitly discussed in requirements
