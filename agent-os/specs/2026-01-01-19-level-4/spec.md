# Specification: Level 4 - Pepperoni Pizza Theme

## Goal

Create Level 4 with a pepperoni pizza theme, featuring a new Pepperoni Pizza Boss with a unique circle movement attack pattern, and a special Garlic Man enemy with faster zig-zag movement and ranged attacks.

## User Stories

- As a player, I want to play Level 4 so that I can continue progressing through the game with new challenges
- As a player, I want to encounter the unique Garlic Man enemy so that gameplay feels fresh and varied in Level 4

## Specific Requirements

**Player can access and play Level 4**

- Add Level 4 entry in GameState.LEVEL_PATHS dictionary (key 4)
- Create levels/level_4.json with total_distance: 24000
- Set scroll_speed_multiplier: 1.3 in metadata
- Use 6 section structure matching previous levels (Opening, Building, Ramping, Intense, Gauntlet, Final Push)
- Configure appropriate enemy wave patterns scaling from previous levels

**Pepperoni Pizza Boss attacks player with unique sequence**

- Configure boss_config with health: 20, scale: 9 in level_4.json metadata
- Set boss_sprite to pepperoni-pizza-boss-1.png
- Set projectile_sprite to pepperoni-attack-1.png in boss_config
- Add new attack index 7 for three-pronged spread attack (3 projectiles in spread pattern)
- Add new attack index 8 for circle movement pattern
- Circle movement alternates clockwise/counter-clockwise on each cycle
- Boss attacks array should cycle: spread attack (7), circle movement (8), repeat

**Garlic Man enemy appears exclusively in Level 4**

- Create GarlicEnemy class extending ShootingEnemy for ranged attack capability
- Set health: 3 (tougher than shooting enemy's 1 HP)
- Override zigzag_speed to 240-280 range (faster than base 120 range)
- Set fire_rate: 1.0 (faster than ShootingEnemy's 4.0)
- Load pizza-attack-1.png as custom projectile texture
- Create garlic_enemy.tscn using pizza-garlic-enemy-1.png sprite

**Special enemy spawn system restricts Garlic Man to Level 4**

- Add special_enemies configuration in level JSON
- Each special enemy entry specifies: enemy_type, spawn_probability, allowed_sections
- Add garlic_enemy_scene @export to EnemySpawner
- Modify enemy spawner to check level metadata for special enemy config
- Garlic Man spawns only in sections 3-6 (Ramping through Final Push)
- Spawn probability: 15-20% per filler spawn opportunity

**Level 4 integrates with existing game flow**

- Level 3 completion unlocks Level 4
- Level select screen shows Level 4 button (locked until Level 3 complete)
- Persist Level 4 unlock state via existing SaveManager pattern

## Visual Design

No visual mockups provided. Sprites exist in assets/sprites/:

- pepperoni-pizza-boss-1.png - Use for boss AnimatedSprite2D texture
- pepperoni-attack-1.png - Use for boss projectile texture via boss_config.projectile_sprite
- pizza-garlic-enemy-1.png - Use for Garlic Man Sprite2D texture
- pizza-attack-1.png - Use for Garlic Man projectile texture

## Leverage Existing Knowledge

**Level JSON structure and section patterns**

- [@/Users/matt/dev/space_scroller/levels/level_3.json:1-86] - Template for level 4 JSON with 7 sections, enemy config, metadata
   - Copy structure and adjust total_distance to 24000
   - Set scroll_speed_multiplier to 1.3
   - Increase enemy counts in wave configs from level 3 values
   - Configure boss_config with health: 20, scale: 9
   - Add boss_sprite and projectile_sprite paths

**Boss configuration and attack patterns**

- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:960-1010] - configure() method handles boss_config from level metadata
   - Follow same pattern for new attack types
   - attacks array uses integer indices (0-6 currently defined)
   - New attacks need indices 7 (spread) and 8 (circle)
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:303-340] - _attack_horizontal_barrage() pattern for spread attack
   - Adapt for three projectiles with wider angle spread
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:344-367] - _attack_vertical_sweep() movement pattern
   - Use as reference for circle movement tween approach

**Enemy spawner wave system**

- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:160-177] - spawn_wave() handles enemy type matching
   - Add "garlic" case to match statement
   - Add _spawn_garlic_enemy() method
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:220-236] - _spawn_shooting_enemy() and _spawn_charger_enemy()
   - Follow same pattern for _spawn_garlic_enemy()
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:187-199] - _spawn_filler_enemy() with weighted random
   - Extend to check special enemy config from level metadata

**Shooting enemy with projectiles**

- [@/Users/matt/dev/space_scroller/scripts/enemies/shooting_enemy.gd:1-56] - ShootingEnemy extends BaseEnemy with fire_rate and projectile firing
   - GarlicEnemy should extend this class
   - Override fire_rate to 1.0
   - Override health to 3
   - Override zigzag_speed to random 240-280
- [@/Users/matt/dev/space_scroller/scenes/enemies/shooting_enemy.tscn:1-20] - Scene structure for shooting enemy
   - Copy structure for garlic_enemy.tscn with different sprite

**Base enemy zigzag movement**

- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:17-22] - zigzag_speed export and angle configuration
   - GarlicEnemy should set zigzag_speed in 240-280 range (vs default 120)
   - Can randomize in _ready() like charger_enemy

**GameState level management**

- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:32-36] - LEVEL_PATHS dictionary
   - Add entry for level 4 path
- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:125-132] - get_selected_level() and set_selected_level()
   - Will work automatically once LEVEL_PATHS updated

**Level manager boss spawning**

- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:442-516] - _spawn_boss() applies sprite, modulate, config
   - Existing code handles boss_config.projectile_sprite automatically
   - New attack types need implementation in boss.gd

**Test patterns for new enemies**

- [@/Users/matt/dev/space_scroller/tests/test_charger_enemy.gd:1-112] - Test structure for new enemy type
   - Create test_garlic_enemy.gd following same pattern
   - Verify health, speed, and projectile firing
- [@/Users/matt/dev/space_scroller/tests/test_spawn_wave_shooting.gd:1-91] - Test for wave spawning enemy type
   - Create test_spawn_wave_garlic.gd following same pattern

**Git Commit found**

Level creation and enemy type patterns

- [7090f27:Add Level 3 with Outer Solar System ice theme] - Pattern for creating new level JSON
   - Create level_4.json following level_3.json structure
   - Add boss_modulate, obstacle_modulate if desired for theme
   - Use appropriate section names (pizza-themed)
- [ef7024a:Add shooting and charger enemy types to wave spawner] - Adding new enemy type to spawner
   - Add garlic_enemy_scene @export to enemy_spawner.gd
   - Add "garlic" case to spawn_wave() match statement
   - Wire up scene in main.tscn EnemySpawner node
- [e67e897:Add Frozen Nova attack for Level 3 boss (Slice 4)] - Adding new boss attack pattern
   - Follow same approach for spread and circle attacks
   - Add attack indices 7 and 8 to boss.gd
   - Update _execute_attack() match statement

## Out of Scope

- Changes to Levels 1-3 (no modifications to existing level JSON files)
- New music tracks (use existing gameplay music)
- New UI elements beyond level select button
- Mobile-specific optimizations
- Ghost enemies for Level 5 (future roadmap item)
- Difficulty scaling for special enemies (Garlic Man stats remain fixed)
- Special enemy spawning in multiple levels (Garlic Man is Level 4 only for now)
- Boss damage scaling or new boss attack types beyond spread and circle
- Custom background theme (use existing theme or simple color modulate)
- Sidekick/pickup behavior changes
