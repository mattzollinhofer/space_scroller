# Specification: Player Combat

## Goal

Add player shooting mechanics that allow the player to fire projectiles that damage and destroy enemies, with visual hit feedback and audio placeholder hooks for future integration.

## User Stories

- As a player, I want to shoot projectiles at enemies so that I can destroy them before they reach me
- As a player, I want visual feedback when I hit an enemy so that I know my shots are landing

## Specific Requirements

**Player can fire projectiles continuously**

- Auto-fire when holding fire button (spacebar keyboard, touch anywhere on screen)
- Fire rate cooldown: 0.1-0.15 seconds between shots (fast, responsive)
- Projectiles spawn from player's current position
- Add "shoot" input action to InputMap for keyboard (spacebar already exists in project.godot)
- Track cooldown timer in player script using delta accumulation

**Projectiles travel and despawn correctly**

- Move left-to-right at 800-1000 px/s (faster than 180 px/s scroll speed)
- Despawn when leaving screen on right edge (x > 2048 + margin)
- Use Area2D for projectile collision detection
- Projectile scene: `scenes/projectile.tscn` with Sprite2D and CollisionShape2D
- Use existing `assets/sprites/laser-bolt.png` for visual

**Projectiles collide with enemies only**

- Projectile collision_layer = 4 (new layer for projectiles)
- Projectile collision_mask = 2 (enemies only, not obstacles on layer 2)
- Enemy collision_mask must include layer 4 to detect projectile hits
- Projectile destroyed on contact (1 projectile = 1 hit)
- Projectiles pass through asteroids without interaction

**Enemy health varies by type**

- Stationary Enemy: 1 HP (one-shot kill, current default)
- Patrol Enemy: 2 HP (requires two hits)
- Set health via @export in scene or override in patrol_enemy.gd _ready()
- Existing health setter in base_enemy.gd already triggers death at 0

**Red flash effect on enemy hit**

- When enemy takes damage but survives (health > 0): apply red tint flash
- Use Sprite2D.modulate property set to Color(1.5, 0.3, 0.3, 1.0) for red
- Flash duration: 0.1-0.15 seconds via tween
- Tween modulate back to original color (Color.WHITE or existing tint)
- Add `take_hit(damage: int)` method to BaseEnemy for projectile damage

**Enemy death uses existing explosion animation**

- Death animation already implemented in BaseEnemy._play_destruction_animation()
- Triggers automatically when health setter detects health <= 0
- No changes needed to death animation system

**Audio placeholder hooks for future integration**

- Player emits `projectile_fired` signal when shooting
- BaseEnemy emits `hit_by_projectile` signal when damaged by projectile
- Signals have no connected handlers yet (placeholders for Audio Integration spec)

**Touch input for firing**

- Add fire button Control node in UILayer (right side of screen)
- Similar pattern to VirtualJoystick: detect InputEventScreenTouch
- Player script checks fire button state in _physics_process
- Alternative: tap anywhere outside joystick area to fire

## Visual Design

No visual mockups provided. Use existing sprite assets:

- `assets/sprites/laser-bolt.png` for projectile sprite
- `assets/sprites/explosion.png` already used for enemy death

## Leverage Existing Knowledge

**Player input and physics pattern**

- [@/Users/matt/dev/space_scroller/scripts/player.gd:62-98] - _physics_process handles input and movement
  - Input.get_vector() pattern for keyboard input
  - Combine keyboard and virtual joystick inputs
  - Delta-based timer patterns for invincibility flashing
  - Can add Input.is_action_pressed("shoot") check here
  - Cooldown timer follows same pattern as _invincibility_timer

**Enemy health system and death**

- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:7-11] - Health setter with auto-death
  - Setting health property automatically triggers _on_health_depleted when <= 0
  - No need to manually call death - just reduce health value
  - Pattern for take_hit method: `health -= damage` triggers the setter

**Enemy destruction animation with tweens**

- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:63-88] - Tween-based explosion
  - Creates tween with create_tween()
  - set_parallel(true) for concurrent property animations
  - tween_property for modulate and scale changes
  - chain().tween_callback for cleanup after animation
  - Same pattern works for red flash effect

**Area2D collision detection pattern**

- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:23-25] - body_entered signal connection
  - Connect signal in _ready()
  - Use area_entered for Area2D-to-Area2D detection (projectile-enemy)
  - Check for specific methods with has_method() pattern

**Collision layer configuration**

- [@/Users/matt/dev/space_scroller/scenes/enemies/stationary_enemy.tscn:9-11] - Enemy collision setup
  - Enemies use collision_layer = 2, collision_mask = 1 (player)
  - Need to add mask = 4 for enemies to detect projectiles
  - Projectiles: layer = 4, mask = 2 (enemies only)

**Patrol enemy color tint via modulate**

- [@/Users/matt/dev/space_scroller/scenes/enemies/patrol_enemy.tscn:15] - Sprite modulate property
  - modulate = Color(1.5, 0.6, 0.3, 1) creates orange tint
  - Store original modulate before red flash, restore after
  - Red flash: Color(1.5, 0.3, 0.3, 1.0) similar pattern

**Touch input handling pattern**

- [@/Users/matt/dev/space_scroller/scripts/ui/virtual_joystick.gd:47-57] - _input event handling
  - InputEventScreenTouch for touch press/release
  - InputEventMouseButton for desktop testing
  - Track _is_active state for held detection
  - Expose method for player to query state

**Entity spawning from player position**

- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:109-120] - Entity instantiation
  - PackedScene.instantiate() to create instances
  - Set position before adding to scene tree
  - add_child() to add to scene
  - Connect to tree_exiting for cleanup tracking

**Despawn when off-screen pattern**

- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:36-37] - Left-edge despawn check
  - Check position.x against threshold in _process
  - Call queue_free() to remove from scene
  - For projectiles: check right edge (x > viewport_width + margin)

**Git Commit found**

Stationary enemy with health and destruction

- [8615a26:Add stationary enemy with health system and destruction animation] - Area2D enemy pattern
  - BaseEnemy class with health setter auto-triggering death
  - Tween-based destruction animation pattern
  - Signal connection in _ready() for collision
  - Scene structure: Area2D root, Sprite2D child, CollisionShape2D child

Patrol enemy with modulate tinting

- [0f816b2:Add patrol enemy with horizontal oscillation movement] - Enemy inheritance pattern
  - Extends BaseEnemy, calls super._ready()
  - Scene uses modulate for color tinting
  - Override _process for custom movement
  - Same collision/death behavior inherited

Enemy spawner lifecycle management

- [369e20d:Add enemy spawner with continuous enemy generation] - Spawner pattern
  - PackedScene instantiation and positioning
  - tree_exiting signal for cleanup tracking
  - Connect to player.died to stop spawning
  - Could reference for projectile pooling if needed

Player damage system with invincibility

- [3227f29:Add asteroid obstacle with player collision and damage system] - Player damage pattern
  - Added signals: damage_taken, lives_changed, died
  - Timer-based invincibility with flashing effect
  - Delta accumulation for cooldown timing
  - Same pattern applies to fire rate cooldown

## Out of Scope

- Multiple weapon types or projectile variations
- Charged shots or special attacks
- Limited ammo or ammo pickups
- Projectile-obstacle interactions (cannot shoot asteroids)
- Actual audio implementation (deferred to Audio Integration spec)
- Power-ups or weapon upgrades
- Enemy projectiles or enemies shooting back
- Scoring for kills (handled in Score System spec)
- Projectile pooling/optimization (simple instantiate/queue_free for now)
- Diagonal or multi-directional shooting
