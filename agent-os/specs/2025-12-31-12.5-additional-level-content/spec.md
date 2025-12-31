# Specification: Additional Level Content

## Goal

Extend Level 1 from 9000 to 13500 pixels with 6 sections, add three distinct enemy types (shooting, non-shooting, charger), implement continuous filler enemy spawning between waves, and make the boss more aggressive with the boss-2.png sprite as primary visual.

## User Stories

- As a player, I want a longer level with more varied enemies so that gameplay feels more challenging and engaging
- As a player, I want enemies that shoot back so that I need to dodge while attacking

## Specific Requirements

**Player experiences extended gameplay with 6 distinct sections**

- Increase total_distance in level_1.json from 9000 to 13500 pixels
- Add 2 additional sections: "Ramping" (35-55%) and "Gauntlet" (75-90%)
- Gameplay time increases from ~50 seconds to ~75 seconds before boss (at 180px/s scroll speed)
- Each section has distinct obstacle density and enemy wave composition

**Player encounters shooting enemies that fire projectiles**

- Create ShootingEnemy class extending BaseEnemy with 1 HP
- Fire projectile every 4 seconds toward left (reuse boss_projectile pattern)
- Use enemy-2.png sprite (currently used by PatrolEnemy)
- Create enemy_projectile.tscn scene adapting boss_projectile.tscn
- Introduced in "Building" section (15-35% progress)

**Player encounters non-shooting enemies with 2 HP**

- PatrolEnemy already has 2 HP and zigzag movement - use as "tank" enemy
- Use enemy.png sprite (swap with shooting enemy)
- Update stationary_enemy.tscn to use enemy-2.png sprite
- Update patrol_enemy.tscn to use enemy.png sprite and remove orange modulate

**Player encounters fast charger enemies that rush toward them**

- Create ChargerEnemy class extending BaseEnemy with 1 HP
- Locks onto player Y position when spawned, then charges horizontally left
- Charge speed 2-3x faster than normal enemy scroll speed (360-540 px/s)
- Use enemy.png sprite with cyan/blue modulate tint for visual distinction
- Introduced in "Intense" section (55-75% progress)

**Player faces larger enemy waves in later sections**

- Opening (0-15%): 2 stationary enemies
- Building (15-35%): 2 stationary + 1 shooting enemy
- Ramping (35-55%): 2 patrol + 2 shooting enemies
- Intense (55-75%): 3 patrol + 1 charger enemy
- Gauntlet (75-90%): 2 shooting + 2 charger + 1 patrol enemy
- Final Push (90-100%): 3 charger + 2 patrol enemies

**Player encounters continuous filler enemies between waves**

- Add timer-based spawning in EnemySpawner (every 4-6 seconds)
- Enable filler spawning after first section (not during Opening)
- Random enemy type selection weighted toward basic enemies (60% stationary, 30% shooting, 10% charger)
- Disable filler spawning during boss fight

**Player experiences more aggressive boss attacks**

- Change boss sprite to use boss-2.png as primary frame (swap order in SpriteFrames)
- Reduce attack_cooldown from 2.0 to 1.3 seconds
- Reduce wind_up_duration from 0.5 to 0.35 seconds
- Increase boss projectile speed from 600 to 750 (25% increase)
- Keep boss health at 13 HP

**Bug fix: Enemy zigzag movement appears broken**

- Investigate why enemies appear stationary or barely moving
- Verify zigzag_speed (120.0) is being applied in _process
- Check if _is_destroying flag is blocking movement prematurely
- Ensure Y bounds (140-1396) allow sufficient movement range

## Visual Design

No visual mockups provided.

## Leverage Existing Knowledge

**Code, component, or existing logic found**

BaseEnemy class pattern for new enemy types
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:1-180] - Base class with health, zigzag movement, collision
   - Extend this class for ShootingEnemy and ChargerEnemy
   - Override _process for custom movement (charger)
   - Add timer for projectile firing (shooting enemy)
   - Use same collision layers (2) and masks (5)
   - Reuse _play_destruction_animation and _play_hit_flash methods

PatrolEnemy extending BaseEnemy
- [@/Users/matt/dev/space_scroller/scripts/enemies/patrol_enemy.gd:1-10] - Simple subclass setting 2 HP
   - Follow this minimal pattern for new enemy subclasses
   - Call super._ready() to inherit base behavior
   - Override only what's different (health, movement, shooting)

Boss projectile pattern for enemy projectiles
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss_projectile.gd:1-40] - Projectile with direction and speed
   - Adapt for enemy projectiles (same direction logic)
   - Reduce speed for enemy projectiles (400-500 vs 600)
   - Keep same collision pattern with player body_entered

Boss projectile scene structure
- [@/Users/matt/dev/space_scroller/scenes/enemies/boss_projectile.tscn:1-22] - Scene with red-tinted laser sprite
   - Use as template for enemy_projectile.tscn
   - Keep collision_layer 8, collision_mask 1 (hits player only)
   - Use different modulate color (green/yellow) to distinguish from boss

Level JSON structure for sections
- [@/Users/matt/dev/space_scroller/levels/level_1.json:1-43] - Section definitions with enemy_waves
   - Add new enemy types: "shooting", "charger"
   - Increase wave counts in enemy_waves arrays
   - Add two new sections between existing ones

Enemy spawner wave system
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:106-118] - spawn_wave() processes enemy_type and count
   - Add cases for "shooting" and "charger" enemy types
   - Add @export for shooting_enemy_scene and charger_enemy_scene
   - Add _spawn_shooting_enemy() and _spawn_charger_enemy() methods

Enemy spawner continuous spawning
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:74-83] - Timer-based spawning with _continuous_spawning flag
   - Repurpose for "filler" enemy spawning between waves
   - Add new flag _filler_spawning_enabled separate from _continuous_spawning
   - Modify _spawn_random_enemy to include new enemy types with weights

Stationary enemy scene for sprite reference
- [@/Users/matt/dev/space_scroller/scenes/enemies/stationary_enemy.tscn:1-20] - Uses enemy.png, no modulate
   - Swap to use enemy-2.png for shooting enemy distinction
   - Keep collision shape and layers identical

Patrol enemy scene with modulate
- [@/Users/matt/dev/space_scroller/scenes/enemies/patrol_enemy.tscn:1-21] - Uses enemy-2.png with orange modulate
   - Swap to use enemy.png (plain) for "tank" role
   - Remove modulate tint, rely on sprite difference

Boss scene with animated sprite
- [@/Users/matt/dev/space_scroller/scenes/enemies/boss.tscn:1-37] - Uses boss-1.png then boss-2.png in animation
   - Swap frame order so boss-2.png is first/primary
   - Keep all other properties unchanged

Boss attack parameters
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:52-56] - Exported attack_cooldown and wind_up_duration
   - Modify values in boss.tscn or create boss_aggressive.tscn
   - attack_cooldown: 2.0 -> 1.3
   - wind_up_duration: 0.5 -> 0.35

Boss projectile speed
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss_projectile.gd:6] - speed: float = 600.0
   - Increase to 750.0 for more aggressive feel

**Git Commit found**

Wave-based spawning implementation
- [05fd0d6:Add wave-based enemy spawning at section boundaries] - Pattern for spawn_wave and continuous toggle
   - Follow same pattern for adding new enemy type handling
   - Shows how to extend enemy_spawner.gd cleanly
   - Level JSON schema extension pattern

Boss projectile attack implementation
- [eb8a0d3:Add boss horizontal barrage attack with player damage] - Projectile scene and script creation
   - Use same approach for enemy_projectile.tscn/gd
   - Collision layer/mask configuration
   - Direction-based movement pattern

Boss attack patterns
- [ea034a1:Add vertical sweep and charge attacks to boss battle] - Charge attack targets player Y position
   - Charger enemy can use similar player tracking logic
   - Shows how to find player reference in scene tree

Enemy behavior improvements
- [c8d95fb:Improve enemy behavior and visual feedback] - Zigzag movement implementation
   - Reference for debugging movement bug
   - Shows expected zigzag behavior

## Out of Scope

- Creating new sprite assets (use existing sprites with modulate for variation)
- Adding new pickup types beyond star and sidekick
- Modifying scoring system or point values
- Adding sound effects or music
- Creating additional levels beyond Level 1 enhancement
- Adding new boss attack patterns beyond parameter tuning
- Implementing enemy AI pathfinding or advanced targeting
- Adding particle effects or visual polish
- Mobile control adjustments
- Difficulty settings or easy/hard modes
