# Spec Requirements: Obstacles System

## Initial Description

Add static and moving obstacles (asteroids, space debris) with collision detection and player damage/death handling.

## Requirements Discussion

### First Round Questions

**Q1:** I assume we'll have two main obstacle types: static asteroids (fixed position, player must navigate around) and moving debris (drifting horizontally or at angles). Should both types spawn from the right side and scroll left with the world, or should some spawn in patterns/formations?
**Answer:** Static asteroids start static on screen, more scroll on from the right. Dynamic/moving obstacles will be added later (not in this spec).

**Q2:** For moving obstacles, I'm thinking they should have simple movement patterns - either drifting at a constant angle or floating up/down while scrolling. Should any obstacles have more complex behavior like rotating in place, or keep it simple for this first implementation?
**Answer:** Simple drift patterns only.

**Q3:** I assume obstacles should despawn when they scroll off the left edge of the screen to avoid memory buildup. Is that correct?
**Answer:** Yes, despawn when off left edge.

**Q4:** For collision feedback, I'm assuming: player takes damage (loses health/life), brief invincibility period (1-2 seconds with visual flashing), and the obstacle remains in place. Should collisions destroy the obstacle, or should the player "bounce" off slightly?
**Answer:** Yes - player takes damage, brief invincibility with flashing, obstacle remains in place.

**Q5:** I assume the player should have a lives system (e.g., 3 lives) where each obstacle collision costs one life, and losing all lives triggers death/game over. Is that correct, or would you prefer a health bar system?
**Answer:** Yes - lives system (3 lives, lose one per collision).

**Q6:** For player death, should the game immediately show a "Game Over" screen, or should there be a respawn at a checkpoint?
**Answer:** Game over screen on death.

**Q7:** I'm thinking we should use procedurally drawn shapes for now (similar to the existing debris.gd and asteroid_boundaries.gd patterns) as placeholder visuals. Is that acceptable?
**Answer:** Yes - procedurally drawn shapes for now.

**Q8:** Is there anything specific you want to exclude from this obstacles system?
**Answer:** Only do the core obstacles system - exclude destructible obstacles, level-based spawning patterns, and power-ups.

### Existing Code to Reference

**Similar Features Identified:**

- Feature: Procedural debris drawing - Path: `/Users/matt/dev/space_scroller/scripts/background/debris.gd`
- Feature: Asteroid shape generation - Path: `/Users/matt/dev/space_scroller/scripts/background/asteroid_boundaries.gd`
- Feature: Player character with collision - Path: `/Users/matt/dev/space_scroller/scripts/player.gd`
- Feature: Player scene with CharacterBody2D - Path: `/Users/matt/dev/space_scroller/scenes/player.tscn`
- Feature: Main scene structure - Path: `/Users/matt/dev/space_scroller/scenes/main.tscn`
- Feature: Scroll controller - Path: `/Users/matt/dev/space_scroller/scripts/scroll_controller.gd`

No additional similar features provided by user.

### Follow-up Questions

No follow-up questions needed - user provided clear, comprehensive answers.

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

N/A - No visual references provided. Development will follow existing codebase visual patterns from debris.gd and asteroid_boundaries.gd.

## Requirements Summary

### Functional Requirements

- **Static Asteroids**: Obstacles that remain in fixed positions relative to the scrolling world
  - Some start on-screen at game start
  - Additional asteroids scroll in from the right edge
  - Use procedurally drawn shapes (irregular polygons) as placeholder visuals
  - Despawn when scrolled off the left edge of the screen

- **Collision Detection**: Player-obstacle collision system
  - Detect when player CharacterBody2D collides with obstacle collision shapes
  - Obstacles remain in place after collision (not destroyed)

- **Player Damage System**: Lives-based health system
  - Player starts with 3 lives
  - Each obstacle collision costs 1 life
  - Brief invincibility period after taking damage (1-2 seconds)
  - Visual feedback during invincibility (flashing/blinking effect)

- **Player Death**: Game over handling
  - When all 3 lives are lost, trigger game over state
  - Display game over screen (placeholder UI acceptable, full UI comes later in roadmap)

### Reusability Opportunities

- **Asteroid shape generation**: Reuse patterns from `asteroid_boundaries.gd` for generating irregular polygon vertices
- **Color palettes**: Reuse rocky brown/gray color generation from existing background scripts
- **Procedural drawing**: Follow `_draw()` pattern established in debris.gd and asteroid_boundaries.gd
- **Collision setup**: Reference player.tscn for CharacterBody2D + CollisionShape2D structure
- **Scroll integration**: Reference scroll_controller.gd for world scroll speed (120 pixels/second)

### Scope Boundaries

**In Scope:**

- Static asteroid obstacles (no self-movement, scroll with world)
- Spawning asteroids from right edge
- Initial on-screen asteroid placement
- Despawning when off left edge
- Player-obstacle collision detection
- Lives system (3 lives)
- Damage feedback (invincibility + flashing)
- Game over state on death
- Placeholder procedural visuals
- Placeholder game over screen

**Out of Scope:**

- Moving/dynamic obstacles (deferred to future spec)
- Destructible obstacles
- Level-based spawning patterns
- Power-ups
- Complex obstacle movement patterns
- Sprite-based artwork (placeholder only)
- Full game over UI (handled in Game UI spec)

### Technical Considerations

- **Node types**: Obstacles should use Area2D or StaticBody2D for collision detection
- **Collision layers**: Will need obstacle collision layer separate from boundary collision
- **Signal-based communication**: Use Godot signals for damage events (following codebase conventions)
- **Scene inheritance**: Consider base obstacle scene for future obstacle types
- **Viewport size**: 2048x1536 pixels (from project.godot)
- **Scroll speed**: 120 pixels/second (from scroll_controller.gd)
- **Player collision shape**: 144x144 pixels (from player.tscn)
- **Playable area**: Between top boundary (y=80) and bottom boundary (y=1456) based on main.tscn
