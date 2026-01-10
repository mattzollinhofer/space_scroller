# Specification: Missile Power-Up

## Goal

Add a collectible missile power-up that stacks damage boost (+1 per pickup) on the player's projectiles, persists across levels but resets on life loss, and displays a UI indicator showing the current damage boost level.

## User Stories

- As a player, I want to collect missile power-ups to increase my projectile damage so that I can defeat enemies faster
- As a player, I want to see my current damage boost level on screen so that I know how powerful my attacks are

## Specific Requirements

**Player collects missile pickup and gains damage boost**

- Create MissilePickup extending BasePickup with `_on_collected()` implementation
- When collected, call `player.add_damage_boost()` to increase damage by +1
- Emit `collected` signal, play `pickup_collect` sfx, and run `_play_collect_animation()`
- Use `fireball-1.png` sprite for the pickup visual (fiery theme matches damage boost)
- Spawn floating damage indicator animation toward UI (similar to star pickup floating heart)

**Player projectiles deal boosted damage**

- Add `_damage_boost: int = 0` property to player.gd
- Add `get_damage_boost() -> int` method to player.gd
- Add `add_damage_boost()` method that increments `_damage_boost` by 1
- Add `damage_boost_changed(new_boost: int)` signal to player.gd
- Modify `shoot()` in player.gd to set projectile damage after instantiation
- Set `projectile.damage = 1 + get_damage_boost()` before adding to scene

**Damage boost persists across levels**

- Add `_damage_boost: int = 0` to GameState autoload
- Add `get_damage_boost()`, `set_damage_boost(value)`, `clear_damage_boost()` methods to GameState
- Player reads damage boost from GameState on `_ready()` (similar to lives carryover pattern)
- LevelCompleteScreen saves player's damage boost to GameState before level transition

**Damage boost resets on life loss**

- Add `reset_damage_boost()` method to player.gd that sets `_damage_boost = 0`
- Connect player's `life_lost` signal to call `reset_damage_boost()` internally
- Call `GameState.clear_damage_boost()` when damage boost resets
- Emit `damage_boost_changed(0)` signal when reset occurs

**UI indicator displays current damage boost**

- Create DamageBoostDisplay as CanvasLayer (pattern from HealthDisplay)
- Position below health display (offset_top around 90, same offset_left as hearts)
- Show fireball icon with "x2", "x3" etc label when boost is active
- Connect to player's `damage_boost_changed` signal for reactive updates
- Hide entire display when damage boost is 0 (no visual clutter at start)

**Missile pickup spawns in random pickup pool**

- Add `@export var missile_pickup_scene: PackedScene` to EnemySpawner
- Wire up missile_pickup.tscn in main.tscn EnemySpawner node
- Modify `_choose_pickup_type()` to return pickup type enum/string instead of bool
- Smart selection: if player has sidekick AND full health, prefer missile pickup
- Otherwise use weighted random: ~40% star, ~40% sidekick, ~20% missile

## Visual Design

No mockups provided. Design notes:

- Use `fireball-1.png` (red/orange swirling fireball) for pickup sprite
- Scale at 0.75 (consistent with star/sidekick pickups)
- CollisionShape2D with RectangleShape2D size Vector2(120, 70)
- DamageBoostDisplay: fireball icon (small) + "x2", "x3" text label
- Position below hearts row to avoid overlap
- Collection animation: inherited scale-up fade-out from BasePickup

## Leverage Existing Knowledge

**Pickup base class and collection pattern**

- [@/Users/matt/dev/space_scroller/scripts/pickups/base_pickup.gd:1-139] - Base class with movement, collision, animation
  - Extend BasePickup class to inherit zigzag movement and despawn logic
  - Override `_on_collected(body)` method for missile-specific behavior
  - Use `_play_collect_animation()` for scale-up fade-out effect
  - Use `_play_sfx("pickup_collect")` for audio feedback
  - `collected` signal already defined for external listeners

**Star pickup collection implementation**

- [@/Users/matt/dev/space_scroller/scripts/pickups/star_pickup.gd:8-30] - Pattern for collection behavior
  - Pattern: check condition, emit signal, play sfx, spawn visual effect, play animation
  - `_award_bonus_points()` via ScoreManager for bonus points
  - `_spawn_floating_heart()` for animated feedback toward UI area

**Player damage and health tracking**

- [@/Users/matt/dev/space_scroller/scripts/player.gd:232-270] - Damage/health/lives system
  - Follow pattern for `_health` with getter/setter methods
  - `life_lost` signal at line 248 - connect here for damage boost reset
  - `reset_health()` and `reset_lives()` patterns for reset method

**Player projectile spawning**

- [@/Users/matt/dev/space_scroller/scripts/player.gd:211-230] - Projectile instantiation
  - Projectile created at line 222, properties can be set before add_child
  - Set `projectile.damage = 1 + get_damage_boost()` after instantiate

**Projectile damage property**

- [@/Users/matt/dev/space_scroller/scripts/projectile.gd:9] - Export damage variable
  - `@export var damage: int = 1` can be modified after instantiation
  - Line 44: `area.take_hit(damage)` passes damage to enemy

**Enemy spawner pickup logic**

- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:476-493] - Pickup type selection
  - Current binary logic checks sidekick existence and health
  - Extend to return one of three types (star, sidekick, missile)
  - Add missile to selection when both sidekick exists and health is full

**Enemy spawner pickup spawning**

- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:498-533] - Spawn pickup from edge
  - Add handling for missile pickup type
  - Instantiate from `missile_pickup_scene` export

**GameState persistence pattern**

- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:242-263] - Sidekick state persistence
  - `set_sidekick_state()` / `has_sidekick()` / `clear_sidekick_state()` pattern
  - Use same approach for damage boost with get/set/clear methods

**GameState lives persistence**

- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:226-239] - Lives carryover
  - `_current_lives` pattern for cross-level persistence
  - Player reads in `_ready()` at lines 72-79

**Health display scene structure**

- [@/Users/matt/dev/space_scroller/scenes/ui/health_display.tscn:1-43] - CanvasLayer UI template
  - layer = 10 for UI visibility above game
  - Container with offset_left=20, offset_top=10
  - TextureRect for icon display with expand_mode and stretch_mode

**Lives display signal connection**

- [@/Users/matt/dev/space_scroller/scripts/ui/lives_display.gd:38-46] - Deferred player connection
  - `call_deferred("_connect_to_player")` pattern
  - Connect to signal, get initial value, call update method

**Pickup scene template**

- [@/Users/matt/dev/space_scroller/scenes/pickups/star_pickup.tscn:1-20] - Scene structure
  - Area2D root with collision_layer=8, collision_mask=1
  - Sprite2D child with scale=Vector2(0.75, 0.75)
  - CollisionShape2D with RectangleShape2D size=Vector2(120, 70)

**Main scene pickup wiring**

- [@/Users/matt/dev/space_scroller/scenes/main.tscn:17-20] - Pickup scene ext_resources
  - Add ext_resource for missile_pickup.tscn similarly
  - Wire to EnemySpawner node's missile_pickup_scene export

**Git Commit found**

Pickup base class refactoring

- [64448f5:Reduce pickup code duplication with shared base class] - BasePickup extraction
  - Shows how StarPickup and SidekickPickup were refactored to extend BasePickup
  - MissilePickup should follow same minimal override pattern

Sidekick persistence between levels

- [5cabbea:Preserve sidekick between levels and add buddy-specific weapons] - State persistence
  - GameState additions for sidekick state
  - Pattern for saving state on level complete, restoring on level start

Pickup spawning system

- [8d37715:Random pickup spawns every 5 enemy kills with sidekick or star] - Spawn system
  - Shows kill threshold logic and pickup type selection
  - Test files show how to verify pickup behavior

Star pickup health restore

- [1c7bdd5:Change star pickup to restore health instead of extra life] - Player state change
  - Shows pickup modifying player state
  - Test updates for verifying behavior

Pickup audio integration

- [42ddcc2:Add pickup spawn audio and balance sound effects] - Audio feedback
  - `pickup_spawn` and `pickup_collect` sfx already exist
  - BasePickup already plays spawn sound in `_ready()`

## Out of Scope

- Different projectile types or visuals based on damage level (no flame projectiles)
- Time-limited damage boost (boost is permanent until life lost)
- Maximum cap on damage stacking (can stack infinitely)
- Visual changes to player sprite when boosted (no glow effect)
- Achievement or stat tracking for damage boosts collected
- Damage boost affecting sidekick projectiles (player only)
- Boss-specific damage scaling or immunity to boosted damage
- Sound variation based on damage boost level
- Particle effects on boosted projectile hits
- Damage boost indicator on the projectile itself
