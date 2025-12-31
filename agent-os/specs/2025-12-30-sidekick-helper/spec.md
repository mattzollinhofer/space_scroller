# Specification: Sidekick Helper

## Goal

Add a power-up system where every 5 enemy kills spawns a random pickup (star for extra life or UFO friend sidekick for extra firepower), with the sidekick following the player and shooting synchronized lasers until destroyed.

## User Stories

- As a player, I want to earn power-ups by defeating enemies so that skilled play is rewarded with helpful bonuses
- As a player, I want a sidekick companion that shoots alongside me so that I have increased firepower during difficult sections

## Specific Requirements

**Power-up spawn system triggers every 5 enemy kills**

- Modify `enemy_spawner.gd` kill tracking to spawn random pickup instead of always UFO friend
- Random selection between star power-up (extra life) and sidekick pickup (50/50 or weighted)
- Threshold doubles after each spawn (5, 10, 20...) - existing behavior to preserve
- Spawn from random edge with zigzag movement pattern - existing behavior

**Star power-up grants extra life when collected**

- Rename/refactor current `ufo_friend.tscn` to become `star_pickup.tscn`
- Keep all existing zigzag movement and collection behavior
- Uses new sparkle star sprite (already exists at `sparkle-star-1.png`)
- Grants one extra life via player's `gain_life()` method - existing behavior

**Sidekick pickup spawns collectible UFO friend**

- Create new `sidekick_pickup.tscn` scene for collectible pickup
- Uses existing `friend-ufo-1.png` sprite (resized appropriately)
- Zigzag movement from random edge matching star pickup behavior
- Collision layer 8, mask 1 to detect player body (matching existing ufo_friend)

**Sidekick follows player with position offset**

- Create `sidekick.gd` script for active sidekick behavior
- Position offset slightly behind and above/below player (configurable)
- Smooth following with slight lag for visual appeal
- Add as child of Main scene (not player) to persist independently

**Sidekick shoots laser synchronized with player**

- Connect to player's `projectile_fired` signal for synchronized shooting
- Spawn projectile from sidekick position using existing `projectile.tscn`
- Projectile uses same collision layer 4, mask 2 (hits enemies)
- Slight Y offset from player's projectile to avoid overlap

**Sidekick takes damage from enemies and is destroyed on first hit**

- Sidekick collision layer matches player (layer 1) to be hit by enemies (mask 1)
- Collision mask includes enemy layer 2 to detect enemy contact
- Single hit destroys sidekick with destruction animation
- No invincibility - immediate destruction on contact

**Only one sidekick active at a time**

- Track active sidekick reference in player or game state
- Collecting sidekick pickup when one already active: either ignore or replace
- Sidekick destroyed on player death (no persistence across respawn)

## Visual Design

No visual assets provided. Existing assets to be reused:

**`assets/sprites/friend-ufo-1.png`**

- Original UFO friend sprite to use for sidekick
- Scale down appropriately for sidekick role (smaller than player)
- Existing scale in pickup scene is Vector2(3, 3) - sidekick may use smaller

**`assets/sprites/sparkle-star-1.png`**

- Already in use by current ufo_friend.tscn for extra life pickup
- No changes needed - already correct

## Leverage Existing Knowledge

**Code, component, or existing logic found**

Pickup scene and movement pattern

- [@/Users/matt/dev/space_scroller/scenes/pickups/ufo_friend.tscn:1-20] - Pickup scene structure with Area2D, sprite, collision
   - Scene uses Area2D with collision_layer 8, collision_mask 1
   - Connects to player via body_entered signal
   - Already uses sparkle-star-1.png sprite - this becomes star pickup
   - RectangleShape2D collision at size Vector2(120, 70)

- [@/Users/matt/dev/space_scroller/scripts/pickups/ufo_friend.gd:1-138] - Zigzag movement and collection logic
   - SpawnEdge enum for LEFT, RIGHT, TOP, BOTTOM edge spawning
   - setup() configures movement direction based on spawn edge
   - Zigzag movement bounded by Y_MIN (140) and Y_MAX (1396)
   - collected signal emitted when player gains life
   - _play_collect_animation() for scale up and fade out effect
   - This script becomes star_pickup.gd with minimal changes

Player shooting and signals

- [@/Users/matt/dev/space_scroller/scripts/player.gd:31] - projectile_fired signal for audio hook
   - Sidekick should connect to this signal to synchronize shots
   - Signal emitted in shoot() method after projectile spawned

- [@/Users/matt/dev/space_scroller/scripts/player.gd:166-184] - Projectile spawn pattern
   - Loads projectile_scene, instantiates, positions with offset
   - Adds to parent (Main scene) so projectile persists independently
   - Sidekick should follow same pattern but different position offset

- [@/Users/matt/dev/space_scroller/scenes/projectile.tscn:1-20] - Projectile scene structure
   - Area2D with collision_layer 4, collision_mask 2
   - Sprite2D at scale Vector2(2, 2) with laser-bolt.png
   - RectangleShape2D collision at size Vector2(32, 8)

Enemy spawner kill tracking

- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:216-228] - Kill counting and UFO spawn trigger
   - _kill_count tracks enemy deaths, _next_ufo_threshold is target
   - Calls _spawn_ufo_friend() when threshold reached
   - Modify to randomly choose between star and sidekick pickup

- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:231-261] - UFO friend spawn logic
   - Random edge selection with spawn position calculation
   - setup() call with spawn edge enum
   - Add to Main scene via get_parent().add_child()
   - Adapt this pattern for both pickup types

Enemy collision patterns

- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:71-79] - Body collision with player
   - body_entered signal connected in _ready()
   - Checks body.has_method("take_damage") to identify player
   - Sidekick should be damaged when enemies collide with it

- [@/Users/matt/dev/space_scroller/scenes/enemies/stationary_enemy.tscn:9-12] - Enemy collision layers
   - collision_layer 2 (enemies), collision_mask 5 (player + projectiles)
   - Sidekick needs layer 1 (player) and mask 2 (enemies) to take damage

Score manager integration

- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:61-63] - UFO friend bonus points
   - award_ufo_friend_bonus() awards 500 points
   - Star pickup should call this when collected (preserve bonus)
   - Sidekick pickup may award different or same bonus

Test patterns

- [@/Users/matt/dev/space_scroller/tests/test_score_ufo_friend.gd:1-158] - Integration test pattern
   - Load main scene, find player, disable spawners
   - Spawn pickup at player position for immediate collection
   - Connect to signals, verify score changes
   - Use for testing star pickup and sidekick pickup

**Git Commit found**

UFO friend implementation

- [72f59d3:Reward skilled players with extra lives from UFO friends] - Complete pickup system implementation
   - Added pickup scene structure, movement script, sprite asset
   - Enemy spawner kill tracking with threshold doubling
   - Player gain_life() integration
   - Reference for creating sidekick pickup variant

- [ef997d4:Add character sprites and update UFO friend visual] - Visual asset update
   - Changed UFO friend to use sparkle-star-1.png
   - Demonstrates scene sprite swap pattern
   - Star pickup already uses correct sprite

Enemy scoring integration

- [55370f9:Award points when player destroys enemies] - ScoreManager integration pattern
   - Added autoload singleton for score tracking
   - Enemy spawner connects to died signals
   - Pattern for sidekick score bonus if desired

## Out of Scope

- Sidekick upgrades or leveling system
- Multiple simultaneous sidekicks
- Sidekick persistence across levels or player deaths
- Sidekick customization options
- Sidekick shield or defensive abilities
- Sidekick collecting pickups for player
- Independent sidekick AI or targeting
- Different sidekick types or variants
- Sidekick health bar or damage indicators
- Power-up duration timers (sidekick lasts until destroyed, not timed)
