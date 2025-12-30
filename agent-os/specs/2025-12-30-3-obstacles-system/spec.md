# Specification: Obstacles System

## Goal

Add static asteroid obstacles that scroll with the world, with collision detection that damages the player and a lives system that triggers game over when all lives are lost.

## User Stories

- As a player, I want to navigate around asteroids so that I can test my piloting skills
- As a player, I want visual feedback when I take damage so that I know to avoid obstacles

## Specific Requirements

**Player can collide with asteroids and take damage**

- Asteroids use Area2D with collision shapes for overlap detection
- Use separate collision layer for obstacles (distinct from boundary layer)
- On collision, emit signal that triggers player damage
- Player loses 1 life per collision (starts with 3 lives)
- Obstacles remain in place after collision (not destroyed)

**Player has invincibility period after taking damage**

- 1.5 second invincibility window after each hit
- Flashing/blinking visual effect during invincibility (toggle visibility every 0.1s)
- Player cannot take damage while invincible
- Clear visual end to invincibility state

**Static asteroids spawn and scroll with the world**

- Initial asteroids placed on-screen at game start (3-5 asteroids)
- Additional asteroids spawn off right edge and scroll left at 120 px/s
- Spawn new asteroids at random intervals (every 2-4 seconds)
- Asteroids spawn within playable Y range (y=80 to y=1456)
- Despawn asteroids when they scroll past left edge (x < -100)

**Asteroids have procedurally drawn visuals**

- Use irregular polygon shapes (5-8 vertices) like asteroid_boundaries.gd
- Size range: 60-120 pixels diameter
- Brown/gray color palette matching existing asteroid visuals
- Draw outline for depth (darkened color, 2px width)

**Game over triggers when all lives are lost**

- Track current lives (signal when lives change)
- When lives reach 0, emit game_over signal
- Display placeholder game over screen (CanvasLayer with "Game Over" label)
- Pause game or stop spawning on game over

**Obstacle spawner manages asteroid lifecycle**

- Central spawner node controls asteroid creation/destruction
- Track all active asteroids in array
- Remove references when asteroids despawn
- Configurable spawn rate and initial count

## Visual Design

No visual mockups provided. Follow existing visual patterns from asteroid_boundaries.gd and debris.gd for procedurally drawn asteroid shapes with brown/gray rocky tones.

## Leverage Existing Knowledge

**Procedural asteroid shape generation**

asteroid_boundaries.gd irregular polygon pattern
- [@/Users/matt/dev/space_scroller/scripts/background/asteroid_boundaries.gd:88-98] - Generate 5-8 vertex irregular polygon with varied radii
   - Uses angle-based vertex placement (i / num_vertices * TAU)
   - Radius varies 60-100% of base size for irregularity
   - Returns PackedVector2Array for draw_colored_polygon()
   - Pattern can be extracted to shared utility or replicated

**Asteroid color palette**

asteroid_boundaries.gd color generation
- [@/Users/matt/dev/space_scroller/scripts/background/asteroid_boundaries.gd:66-85] - Rocky brown/gray color palette
   - Dark brown, gray, reddish brown, dark gray variants
   - Brightness range 0.25-0.5 for space visibility
   - Match existing visual style for consistency

**Drawing asteroid with outline**

asteroid_boundaries.gd draw pattern
- [@/Users/matt/dev/space_scroller/scripts/background/asteroid_boundaries.gd:115-132] - Draw polygon with darkened outline
   - Rotate and translate vertices before drawing
   - draw_colored_polygon() for fill
   - draw_line() loop for 2px outline with darkened(0.3) color

**Player CharacterBody2D structure**

player.tscn collision setup
- [@/Users/matt/dev/space_scroller/scenes/player.tscn:1-22] - CharacterBody2D with CollisionShape2D child
   - RectangleShape2D sized to match sprite (144x144)
   - Player uses move_and_slide() for physics
   - Collision layer setup can be referenced

**Player script patterns**

player.gd physics and signals
- [@/Users/matt/dev/space_scroller/scripts/player.gd:35-56] - _physics_process pattern with move_and_slide()
   - Extend player.gd to add damage handling
   - Add invincibility timer and flashing effect
   - Add signal for damage_taken and died events

**Scroll speed constant**

scroll_controller.gd world speed
- [@/Users/matt/dev/space_scroller/scripts/scroll_controller.gd:6] - scroll_speed = 120.0 pixels/second
   - Obstacles should move left at this speed
   - Use same constant or reference for consistency

**Main scene structure**

main.tscn node hierarchy
- [@/Users/matt/dev/space_scroller/scenes/main.tscn:18-72] - Main scene organization
   - Add ObstacleSpawner as child of Main
   - Game over UI goes in UILayer CanvasLayer
   - Obstacles spawn as children of dedicated container node

**Viewport and playable area**

project.godot and main.tscn boundaries
- [@/Users/matt/dev/space_scroller/project.godot:19-20] - Viewport 2048x1536 pixels
   - Playable Y range: 80 to 1456 (between boundary strips)
   - Spawn asteroids within this Y range
   - Despawn when x < -100 (off left edge)

**Git Commit: Collision boundaries implementation**

a9b9b21: Add collision boundaries to keep player in playable area
- [@a9b9b21] - StaticBody2D collision setup pattern
   - Shows how to add collision bodies to main.tscn
   - RectangleShape2D sub-resource pattern
   - Position and size configuration

**Git Commit: Asteroid belt visual layer**

65b1da6: Add rocky asteroid belt boundaries at screen edges
- [@65b1da6] - Procedural asteroid drawing implementation
   - Full asteroid_boundaries.gd script creation
   - Integration into main.tscn scene tree
   - Vertex generation and color palette patterns

**Git Commit: Player sprite and collision sizing**

8ffaa01: Scale player sprite 3x and fix collision size calculation
- [@8ffaa01] - Collision shape sizing relative to sprite
   - Match collision to visual size
   - _half_size calculation for bounds

## Out of Scope

- Moving/dynamic obstacles with self-propelled movement
- Destructible obstacles that break apart
- Level-based or wave-based spawning patterns
- Power-ups or collectibles
- Complex obstacle movement patterns (rotating, homing)
- Sprite-based obstacle artwork (procedural only)
- Full game over UI with restart button (placeholder only)
- Score system or points
- Sound effects for collision or game over
- Particle effects on collision
