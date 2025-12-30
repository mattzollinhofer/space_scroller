# Spec Requirements: Basic Enemies

## Initial Description

Create 2-3 enemy types with simple movement patterns (stationary, horizontal patrol, following) and collision-based combat. Theme: "bad aliens"

## Requirements Discussion

### First Round Questions

**Q1:** I found an existing enemy sprite (`assets/sprites/raw/enemy.png`) - a gold/black alien ship with a prominent eye. Should all 2-3 enemy types use this same sprite (perhaps with color variations or scaling), or do you want distinct visual designs for each type? I'm assuming we can start with this sprite for at least one enemy type.
**Answer:** User asked if color variations of the existing enemy sprite are possible, or if they should provide more sprites.

**Q2:** For the three movement patterns you mentioned:
- Stationary: I assume these hover in fixed Y position while scrolling left with the world (like asteroids). Correct?
- Horizontal Patrol: I'm thinking these move back and forth within a horizontal range while also scrolling left. Should they patrol a fixed distance (e.g., 200px range), or should they patrol between specific Y bounds?
- Following: I assume these track the player's Y position but don't move toward the player on X-axis (so they still scroll left). Should they follow immediately, or with some delay/smoothing? And should they respect some maximum chase speed?
**Answer:** Only do stationary and horizontal patrol - NOT following. So 2 enemy types, not 3.

**Q3:** For collision-based combat: I assume enemies damage the player on contact (using the existing `take_damage()` system) similar to asteroids. Should enemies also be destroyed when they collide with the player, or survive like asteroids do? And should the player destroy enemies on contact (mutual destruction)?
**Answer:** Yes, use take_damage() for player. Enemies ARE destroyed on collision with player.

**Q4:** Since Player Combat (shooting) comes in the next roadmap item, I assume enemies in this spec are indestructible - they can only damage the player, not be killed. Is that correct, or should we add a health system now that shooting can use later?
**Answer:** Add health system, but collisions send enemy health to 0 (instant kill on contact).

**Q5:** For spawning, I'm thinking enemies should spawn similarly to asteroids (from the right edge, within playable Y range 80-1456). Should enemies spawn alongside asteroids using the same timing, or have separate spawn waves/patterns? I'm assuming separate spawn logic with configurable rates.
**Answer:** Same as asteroids is fine for now. User wants to add a new roadmap item to consider redoing spawn logic later.

**Q6:** Should enemies have any visual feedback when they damage the player (flash, sound placeholder, etc.), or just the existing player damage feedback (invincibility flashing)?
**Answer:** Create a destroyed animation for when enemies die.

**Q7:** Is there anything specific you want to exclude from this enemies system? For example: enemy health/destruction, scoring, spawn formations, or enemy projectiles?
**Answer:** Nothing special, just what was discussed above.

### Existing Code to Reference

**Similar Features Identified:**

- Feature: Asteroid obstacle system - Path: `scripts/obstacles/asteroid.gd`
  - Area2D with collision detection, spawning from right edge, leftward scrolling, despawning
  - Procedural drawing with `_draw()` method
  - Uses `body_entered` signal to detect player collision and call `take_damage()`
- Feature: Obstacle spawner - Path: `scripts/obstacles/obstacle_spawner.gd`
  - Spawns from right edge within playable Y range (80-1456)
  - Configurable spawn rates, tracks active instances, despawns when off-screen
  - Connects to player `died` signal to stop spawning
- Feature: Player damage system - Path: `scripts/player.gd`
  - `take_damage()` function with invincibility and flashing
  - Signals: `damage_taken`, `lives_changed`, `died`
- Feature: Main scene structure - Path: `scenes/main.tscn`
  - Shows how ObstacleSpawner is integrated into scene tree
- Feature: Enemy sprite asset - Path: `assets/sprites/raw/enemy.png`
  - Gold/black alien spacecraft with prominent eye, green background (needs transparency)

### Follow-up Questions

**Follow-up 1:** Regarding color variations of the existing enemy sprite - yes, I can apply color tinting/modulation in Godot to create variants from the single sprite. For example: Stationary enemy with original gold/black colors, Patrol enemy tinted red/orange or blue/purple to visually distinguish behavior. Is this approach acceptable?
**Answer:** Color tinting approach is great. Use red/orange tint for the patrol enemy (stationary keeps original gold/black colors).

## Visual Assets

### Files Provided:

No visual assets provided in the planning/visuals folder.

### Visual Insights:

- Existing enemy sprite found at `assets/sprites/raw/enemy.png`
- Gold/black alien spacecraft design with a large prominent eye
- Pixel art style, facing left (appropriate for side-scroller enemies)
- Has green background that will need to be made transparent or removed
- Fidelity level: High-fidelity sprite asset ready for use

## Requirements Summary

### Functional Requirements

- **Two Enemy Types**: Stationary and Patrol enemies using the existing sprite asset
  - **Stationary Enemy**: Hovers at fixed Y position, scrolls left with world (like asteroids)
    - Uses original gold/black sprite colors
  - **Patrol Enemy**: Moves back and forth horizontally while scrolling left
    - Uses red/orange color tint to distinguish from stationary type
    - Patrol within a fixed horizontal range

- **Sprite-Based Visuals**: Use existing enemy.png asset
  - Apply Godot's modulate/tint for color variations
  - Process sprite to have transparent background if needed

- **Health System**: Enemies have health that can be reduced
  - Health system prepared for future shooting mechanic (roadmap item 5)
  - Collision with player sets enemy health to 0 (instant kill)

- **Collision Combat**: Player-enemy collision handling
  - Player takes damage via existing `take_damage()` system
  - Enemy is destroyed on collision with player
  - Both effects occur on same collision event

- **Destroyed Animation**: Visual feedback when enemy dies
  - Play destruction animation/effect when enemy health reaches 0
  - Then remove enemy from scene

- **Spawning**: Similar to asteroid spawning system
  - Spawn from right edge of screen
  - Within playable Y range (80-1456)
  - Configurable spawn rates
  - Despawn when scrolled off left edge

### Reusability Opportunities

- **Asteroid system pattern**: Base enemy structure on `asteroid.gd` - Area2D, collision detection, leftward scrolling, despawn logic
- **Spawner pattern**: Model enemy spawner on `obstacle_spawner.gd` - spawn rates, tracking, player death connection
- **Player damage integration**: Use existing `take_damage()` function and signal system
- **Scene structure**: Follow main.tscn pattern for integrating spawner into scene tree

### Scope Boundaries

**In Scope:**

- Two enemy types: Stationary and Patrol
- Sprite-based visuals using existing enemy.png asset
- Color tinting for enemy type differentiation (gold/black vs red/orange)
- Health system (for future shooting integration)
- Collision-based combat (player damaged, enemy destroyed)
- Destroyed animation when enemy dies
- Enemy spawner (similar to obstacle spawner)
- Despawning when off-screen

**Out of Scope:**

- Following/tracking enemy type (deferred)
- Enemy projectiles/shooting
- Scoring for enemy kills (handled in Score System spec)
- Complex spawn formations/waves (potential future roadmap item)
- Sound effects (handled in Audio Integration spec)
- Multiple distinct sprite assets (using color tints instead)

### Technical Considerations

- **Node type**: Area2D for enemies (like asteroids) with collision detection
- **Sprite handling**: Sprite2D node with enemy.png texture, use `modulate` property for color tinting
- **Collision layers**: Enemies need appropriate collision layer/mask setup to detect player
- **Health system**: Simple integer health variable with setter that checks for death
- **Destroyed animation**: Could use AnimationPlayer, Tween, or particle effects
- **Patrol movement**: Track patrol center point, oscillate within range while also moving left
- **Viewport size**: 2048x1536 pixels
- **Playable Y range**: 80-1456 pixels
- **World scroll speed**: 120 px/s (enemies should match or be relative to this)
- **Enemy sprite**: May need background removal/transparency processing before use
