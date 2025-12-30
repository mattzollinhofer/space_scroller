# Specification: Basic Enemies

## Goal

Create two enemy types (stationary and patrol) with sprite-based visuals, health system, collision-based combat, and destruction animations that integrate with the existing obstacle spawning infrastructure.

## User Stories

- As a player, I want to encounter different enemy types so that gameplay has more variety and challenge beyond asteroids
- As a player, I want visual feedback when enemies are destroyed so that combat feels satisfying

## Specific Requirements

**Stationary Enemy appears and scrolls with the world**

- Area2D node with CollisionShape2D (similar to asteroid structure)
- Uses enemy.png sprite with original gold/black colors
- Scrolls left at world scroll speed (180 px/s, matching current asteroid speed)
- Fixed Y position after spawn (no vertical movement)
- Despawn when scrolled off left edge (x < -100)

**Patrol Enemy moves horizontally while scrolling**

- Same base structure as stationary enemy
- Uses enemy.png sprite with red/orange color tint via Sprite2D modulate property
- Oscillates back and forth within a fixed horizontal range (e.g., 200px)
- Patrol movement is relative to world position (still scrolls left overall)
- Movement should feel smooth with configurable patrol speed

**Health system prepares enemies for future shooting mechanic**

- Integer health property with configurable starting value
- Health setter that checks for death (health <= 0)
- Signal emitted when enemy dies (for future score system integration)
- Collision with player sets health to 0 (instant death on contact)

**Collision combat damages player and destroys enemy**

- Detect player collision via body_entered signal (like asteroids)
- Call player's existing take_damage() function on collision
- Set enemy health to 0 on same collision event
- Both effects occur in single collision handler

**Destroyed animation provides visual feedback**

- Play destruction effect when enemy health reaches 0
- Use Tween for simple scale/fade animation or particle burst
- Remove enemy from scene after animation completes
- Animation should be brief (0.3-0.5 seconds)

**Enemy spawner manages enemy lifecycle**

- Separate spawner from ObstacleSpawner (or extend existing pattern)
- Spawn from right edge (viewport_width + 100)
- Random Y position within playable range (140-1396, accounting for enemy size)
- Configurable spawn rates for each enemy type
- Connect to player died signal to stop spawning on game over
- Track active enemies for cleanup

## Visual Design

**`assets/sprites/raw/enemy.png`**

- Gold/black alien spacecraft with prominent eye design
- Pixel art style, facing left (appropriate for side-scroller)
- Has green background that needs transparency (process in image editor or use shader)
- Scale appropriately for gameplay visibility (likely 2-3x like player sprite)
- Stationary enemy: use sprite as-is with original colors
- Patrol enemy: apply Color(1.5, 0.6, 0.3) or similar red/orange modulate tint

## Leverage Existing Knowledge

**Code, component, or existing logic found**

Asteroid Area2D pattern

- [@/Users/matt/dev/space_scroller/scripts/obstacles/asteroid.gd:1-30] - Area2D setup with collision detection and body_entered signal
  - Enemy should extend Area2D with same collision layer (2) and mask (1) setup
  - Use body_entered.connect() pattern for player collision detection
  - Follow same _ready() initialization structure

Asteroid scrolling and despawn logic

- [@/Users/matt/dev/space_scroller/scripts/obstacles/asteroid.gd:35-42] - _process for leftward movement and despawn
  - Move left at scroll_speed in _process(delta)
  - Despawn condition: position.x < -100
  - Call queue_free() via _despawn() method

Asteroid scene structure

- [@/Users/matt/dev/space_scroller/scenes/obstacles/asteroid.tscn:1-15] - Area2D scene with CollisionShape2D
  - collision_layer = 2, collision_mask = 1
  - CircleShape2D child for collision (enemies can use similar or RectangleShape2D)
  - Script attached to root Area2D node

Obstacle spawner pattern

- [@/Users/matt/dev/space_scroller/scripts/obstacles/obstacle_spawner.gd:1-50] - Spawner initialization and constants
  - PLAYABLE_Y_MIN/MAX constants for spawn bounds
  - PackedScene export for scene to spawn
  - spawn_rate_min/max for random intervals
  - _rng for random number generation

Obstacle spawner spawn logic

- [@/Users/matt/dev/space_scroller/scripts/obstacles/obstacle_spawner.gd:83-105] - _spawn_asteroid method
  - Position at viewport_width + 100 (off right edge)
  - Random Y within playable range
  - add_child() to scene tree
  - Track in array and connect tree_exiting signal

Spawner player death connection

- [@/Users/matt/dev/space_scroller/scripts/obstacles/obstacle_spawner.gd:72-80] - Connect to player died signal
  - Find player via get_tree().root.get_node_or_null("Main/Player")
  - Connect died signal to stop spawning
  - Set _game_over flag to halt _process spawning

Player damage system

- [@/Users/matt/dev/space_scroller/scripts/player.gd:114-131] - take_damage() function
  - Checks invincibility before applying damage
  - Emits lives_changed and damage_taken signals
  - Enemies should call body.take_damage() same as asteroids

Player collision detection

- [@/Users/matt/dev/space_scroller/scripts/obstacles/asteroid.gd:135-138] - _on_body_entered handler
  - Check body.has_method("take_damage") before calling
  - Simple pattern to reuse in enemy collision handler

Player scene sprite setup

- [@/Users/matt/dev/space_scroller/scenes/player.tscn:12-14] - Sprite2D with scale and texture
  - scale = Vector2(3, 3) for visibility
  - texture as ExtResource
  - Enemies should follow same pattern with enemy.png texture

Main scene integration pattern

- [@/Users/matt/dev/space_scroller/scenes/main.tscn:65-68] - ObstacleSpawner integration
  - Node2D with script attached
  - PackedScene assigned via export property
  - Add as child of Main node

**Git Commit found**

Asteroid obstacle implementation

- [3227f29:Add asteroid obstacle with player collision and damage system] - Complete Area2D obstacle pattern
  - Shows how to create Area2D scene with collision detection
  - Implements body_entered signal connection
  - Adds collision layer/mask configuration
  - Enemy implementation should follow this same structure

Asteroid spawner implementation

- [86eeab2:Add asteroid spawner with continuous spawning and size variety] - Full spawner pattern
  - Demonstrates spawn timing with random intervals
  - Shows despawn logic and tracking active instances
  - Includes initial spawn for immediate gameplay
  - Enemy spawner should follow same pattern with modifications for enemy types

## Out of Scope

- Following/tracking enemy type that moves toward player (deferred to later)
- Enemy projectiles or shooting mechanics (roadmap item 5)
- Scoring for enemy kills (separate Score System spec)
- Complex spawn formations or wave patterns
- Sound effects for enemy spawn or destruction (Audio Integration spec)
- Multiple distinct enemy sprite assets (using color tints instead)
- Enemy health bars or damage indicators
- Boss enemies or special enemy variants
- Enemy-to-enemy collision detection
- Difficulty scaling of enemy spawn rates over time
