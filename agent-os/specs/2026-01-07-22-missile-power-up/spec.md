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
- Modify projectile.gd to query player's damage boost when spawned
- Apply damage as `base_damage + player.get_damage_boost()` when hitting enemies

**Damage boost persists across levels**

- Add `_damage_boost: int = 0` to GameState autoload
- Add `get_damage_boost()`, `set_damage_boost(value)`, `add_damage_boost()` methods to GameState
- Player reads damage boost from GameState on `_ready()` (similar to lives carryover pattern)
- LevelCompleteScreen saves player's damage boost to GameState before level transition

**Damage boost resets on life loss**

- Add `reset_damage_boost()` method to player.gd that sets `_damage_boost = 0`
- Connect player's `life_lost` signal to call `reset_damage_boost()`
- Add `clear_damage_boost()` to GameState, called on life loss and new game start
- Emit `damage_boost_changed` signal when boost changes for UI updates

**UI indicator displays current damage boost**

- Create DamageBoostDisplay as CanvasLayer (pattern from HealthDisplay/LivesDisplay)
- Position near health display but not overlapping (top-left area, below hearts)
- Show damage boost icon (fireball sprite) with numeric label showing current level
- Connect to player's `damage_boost_changed` signal for reactive updates
- Hide indicator when damage boost is 0 (no visual clutter at start)

**Missile pickup spawns in random pickup pool**

- Add `missile_pickup_scene: PackedScene` export to EnemySpawner
- Wire up missile_pickup.tscn in main.tscn EnemySpawner node
- Modify `_choose_pickup_type()` to include missile as third option
- Smart selection: if player has sidekick AND full health, prefer missile pickup
- Otherwise use weighted random: 40% star, 40% sidekick, 20% missile

## Visual Design

No mockups provided. Design notes:

- Use `fireball-1.png` (53KB, red/orange swirling fireball) for pickup sprite
- Scale at 0.75 (consistent with star/sidekick pickups)
- DamageBoostDisplay should show fireball icon + "x2", "x3" etc. text
- Collection animation: scale up and fade out (inherited from BasePickup)
- Consider spawning floating fireball toward UI display on collection

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
   - Projectile created at line 222, need to pass damage boost value
   - Can set projectile.damage property before adding to scene

**Projectile damage application**

- [@/Users/matt/dev/space_scroller/scripts/projectile.gd:1-83] - Projectile with damage property
   - `@export var damage: int = 1` at line 9 - this is the base damage
   - `area.take_hit(damage)` at line 44 - damage passed to enemy
   - Need to query player's boost and add to damage on spawn

**Enemy spawner pickup logic**

- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:474-534] - Pickup spawning
   - `_choose_pickup_type()` at line 476 - add missile to selection logic
   - `_spawn_random_pickup()` at line 498 - add missile_pickup_scene handling
   - Kill threshold triggers pickup at `_next_pickup_threshold`

**GameState persistence pattern**

- [@/Users/matt/dev/space_scroller/scripts/autoloads/game_state.gd:226-263] - Lives/sidekick persistence
   - `_current_lives` pattern for cross-level persistence
   - `set_sidekick_state()` / `has_sidekick()` / `clear_sidekick_state()` pattern
   - Use same approach for `_damage_boost` state

**UI display scene structure**

- [@/Users/matt/dev/space_scroller/scenes/ui/health_display.tscn:1-43] - CanvasLayer UI template
   - layer = 10 for UI visibility
   - Container with offset positioning
   - TextureRect for icon display

**Lives display reactive pattern**

- [@/Users/matt/dev/space_scroller/scripts/ui/lives_display.gd:38-46] - Signal connection pattern
   - `_connect_to_player()` with deferred call
   - Connect to signal, get initial value, update display

**Pickup scene template**

- [@/Users/matt/dev/space_scroller/scenes/pickups/star_pickup.tscn:1-20] - Scene structure
   - Area2D root with collision_layer=8, collision_mask=1
   - Sprite2D child with scale=0.75
   - CollisionShape2D with RectangleShape2D size=Vector2(120, 70)

**Git Commit found**

Pickup base class refactoring

- [64448f5:Reduce pickup code duplication with shared base class] - BasePickup extraction
   - Shows how StarPickup and SidekickPickup were refactored to extend BasePickup
   - MissilePickup should follow same pattern for consistency

Sidekick persistence between levels

- [5cabbea:Preserve sidekick between levels and add buddy-specific weapons] - State persistence
   - GameState additions for `_has_sidekick` and `_sidekick_sprite`
   - Pattern for saving state on level complete, restoring on level start
   - Same approach needed for damage boost persistence

Pickup spawning system

- [8d37715:Random pickup spawns every 5 enemy kills with sidekick or star] - Spawn system
   - Shows kill threshold logic and pickup type selection
   - `_choose_pickup_type()` selection logic to extend

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
