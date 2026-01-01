# Specification: Level 5 - Ghost Theme

## Goal

Add Level 5 with a ghost theme featuring a Ghost Monster Boss with new attack patterns (wall attack and square movement) and Ghost Eye special enemies that spawn throughout the level.

## User Stories

- As a player, I want to play Level 5 so that I can experience new ghost-themed challenges after completing Level 4
- As a player, I want to fight a Ghost Monster Boss with unique attack patterns so that the boss fight feels fresh and challenging

## Specific Requirements

**Player can select and play Level 5**

- Add Level 5 button to level select UI (matching existing Level 1-4 button pattern)
- Add Level 5 path to GameState LEVEL_PATHS dictionary: `5: "res://levels/level_5.json"`
- Update level_select.gd to handle level 5 button connection and appearance
- Level 5 JSON follows Level 4 structure with ~24,000 total distance and 6 sections

**Ghost Eye special enemy spawns during level**

- New GhostEyeEnemy class extending ShootingEnemy (same pattern as GarlicEnemy)
- Custom sprite: `ghost-eye-enemy-1.png` at appropriate scale
- Custom projectile texture: `ghost-attack-1.png`
- 3 health points (survives 2 hits, like GarlicEnemy)
- Faster zigzag movement: 240-280 speed range
- Faster fire rate: 1.0 second (vs standard 4.0)
- Scene file: `ghost_eye_enemy.tscn` with collision shape sized for sprite

**Ghost Eye spawns via special enemies system**

- Add `ghost_eye_enemy_scene` export to EnemySpawner
- Add "ghost_eye" case to `_try_spawn_special_enemy()` match statement
- Add `_spawn_ghost_eye_enemy()` function following `_spawn_garlic_enemy()` pattern
- Level 5 metadata configures ~45% spawn probability in sections 1-5

**Ghost Monster Boss with Wall Attack (attack type 9)**

- 6 projectiles fan out vertically from boss position (3 up, 3 down)
- After fanning out, projectiles shoot horizontally toward player (left)
- Uses `ghost-attack-1.png` projectile sprite
- Add `_attack_wall()` function to boss.gd following existing attack patterns
- Add tracking flag `_wall_attack_active` for state management

**Ghost Monster Boss with Square Movement (attack type 10)**

- Boss moves in a square/rectangular path around the arena
- No projectiles fired during movement (like circle movement attack type 8)
- Use existing CIRCLE_RADIUS and tween patterns from `_attack_circle_movement()`
- Add `_attack_square_movement()` function with 4-point rectangular path
- Add tracking flag `_square_active` for state management

**Boss configuration for Level 5**

- Health: 22-25 (progression from Level 4's 20)
- Scale: 6 (same as Level 4)
- Attacks array: `[9, 10]` for wall attack -> square movement cycle
- Custom sprite: `ghost-boss-1.png`
- Custom projectile sprite: `ghost-attack-1.png`
- Explosion scale: 8 (same as Level 4)

**Level 5 section structure with ghost theme**

- 6 sections with spooky ghost-themed names
- Progressive difficulty with enemy waves (stationary, shooting, patrol, charger, ghost_eye)
- Ghost Eye enemies in enemy_waves for sections 2-6
- Background modulate color for spooky atmosphere (darker blues/purples or desaturated grays)

## Visual Design

No visual assets provided in planning/visuals - all sprites exist in codebase:

**Existing sprites to use:**

- `assets/sprites/ghost-boss-1.png` - Ghost Monster Boss sprite (apply via boss_config.boss_sprite)
- `assets/sprites/ghost-eye-enemy-1.png` - Ghost Eye enemy sprite (use in scene)
- `assets/sprites/ghost-attack-1.png` - Ghost projectile sprite (for both boss and enemy)

## Leverage Existing Knowledge

**Code, component, or existing logic found**

GarlicEnemy implementation template
- [@/Users/matt/dev/space_scroller/scripts/enemies/garlic_enemy.gd:1-47] - Complete special enemy extending ShootingEnemy
   - Extends ShootingEnemy with class_name declaration
   - Loads custom projectile texture in _ready() before calling super
   - Sets health=3, fire_rate=1.0, zigzag_speed=randf_range(240,280)
   - Overrides _fire_projectile() to apply custom texture and scale
   - Uses set_texture() and set_projectile_scale() methods on projectile

GarlicEnemy scene structure
- [@/Users/matt/dev/space_scroller/scenes/enemies/garlic_enemy.tscn:1-20] - Scene file template
   - Area2D root with collision_layer=2, collision_mask=5
   - Sprite2D child with scale and texture
   - CollisionShape2D with RectangleShape2D sized for sprite
   - Unique uid for scene registration

Level 4 JSON configuration template
- [@/Users/matt/dev/space_scroller/levels/level_4.json:1-97] - Complete level structure
   - total_distance, enemy_config, metadata, sections array structure
   - boss_config with health, scale, attacks, attack_cooldown, explosion_scale, projectile_sprite
   - special_enemies array with enemy_type, spawn_probability, allowed_sections
   - Section structure with name, start_percent, end_percent, obstacle_density, enemy_waves

Boss circle movement attack pattern
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:722-788] - Movement attack without projectiles
   - Uses _circle_active flag for state tracking
   - Creates tween with position keyframes around a path
   - Returns to _battle_position after movement completes
   - Calls _on_circle_complete() to reset state and transition to cooldown

Boss attack state machine and telegraph system
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:283-308] - Attack execution dispatch
   - Uses _enabled_attacks array and _current_pattern index
   - Match statement routes to specific attack functions by index
   - Attack types 0-8 already implemented, 9 and 10 are next
   - Telegraph color can be customized per attack type

EnemySpawner special enemy system
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:229-257] - Special enemy spawn logic
   - Checks _special_enemies_config array from level metadata
   - Validates current section against allowed_sections
   - Rolls against spawn_probability to decide spawn
   - Match statement routes to specific spawn functions

EnemySpawner scene exports and spawn functions
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:7-24] - Export pattern for enemy scenes
   - @export var for each enemy scene type
   - Corresponding _spawn_*_enemy() functions that instantiate and call _setup_enemy()

GameState level paths dictionary
- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:32-37] - LEVEL_PATHS constant
   - Dictionary mapping level number to JSON path
   - Used by get_level_path() and get_selected_level_path()
   - Add entry 5 for Level 5

Level select UI and script
- [@/Users/matt/dev/space_scroller/scenes/ui/level_select.tscn:52-86] - Button node pattern
   - Level buttons in LevelGrid HBoxContainer
   - Each button has custom_minimum_size, theme overrides, disabled state
- [@/Users/matt/dev/space_scroller/scripts/ui/level_select.gd:6-18] - Button handling pattern
   - @onready var for each button
   - Connect pressed signal with level number bind
   - _update_button_states() enables all buttons

ShootingEnemy base class
- [@/Users/matt/dev/space_scroller/scripts/enemies/shooting_enemy.gd:1-62] - Base class for ranged enemies
   - Extends BaseEnemy, has fire_rate export
   - Loads projectile scene in _ready()
   - _fire_projectile() method to override for custom behavior

**Git Commit found**

Level 4 implementation commits provide patterns for Level 5

Add Garlic Man enemy for Level 4
- [84281c9:Add Garlic Man enemy for Level 4] - Special enemy implementation pattern
   - Created garlic_enemy.gd extending ShootingEnemy
   - Created garlic_enemy.tscn with proper collision setup
   - Added garlic_enemy_scene export to enemy_spawner.gd
   - Added _spawn_garlic_enemy() and spawn_wave "garlic" case

Add special enemy spawn system for level-specific enemies
- [cf63a47:Add special enemy spawn system for level-specific enemies] - Extensible spawn system
   - Added special_enemies array to level metadata
   - Added _try_spawn_special_enemy() to enemy_spawner.gd
   - Added set_special_enemies_config() and set_current_section() methods
   - LevelManager passes config to spawner and tracks sections

Add circle movement attack for Level 4 boss
- [cdbf6b5:Add circle movement attack for Level 4 boss] - Movement attack pattern
   - Added attack type 8 (circle movement)
   - Uses tween with position keyframes
   - No projectiles during movement
   - Alternating direction each cycle

Add Level 4 with pepperoni pizza theme
- [f1dd1df:Add Level 4 with pepperoni pizza theme] - Level addition pattern
   - Created level_4.json with complete section structure
   - Added Level 4 button to level_select.tscn
   - Added level 4 path to GameState LEVEL_PATHS
   - Added button handling in level_select.gd
   - Created test files for level load and selection

## Out of Scope

- New background theme artwork (using modulate colors on existing backgrounds instead)
- New power-ups or collectibles beyond what exists
- New player abilities or mechanics
- Changes to existing level 1-4 balancing
- New audio or music tracks (use existing boss battle music pattern)
- Additional enemy types beyond Ghost Eye
- Additional boss attacks beyond Wall Attack and Square Movement
- Changes to the core game loop or progression system
- Mobile/touch controls or other platform-specific features
- Achievement or unlock systems
