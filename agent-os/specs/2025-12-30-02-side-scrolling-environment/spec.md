# Specification: Side-Scrolling Environment

## Goal

Implement auto-scrolling space background with 3 parallax layers and rocky asteroid belt boundaries at viewport edges, creating the foundational side-scrolling gameplay environment.

## User Stories

- As a player, I want the world to scroll automatically so that I experience forward momentum through space without manual camera control
- As a player, I want to see depth in the space environment through parallax layers so that the game feels immersive

## Specific Requirements

**World scrolls continuously leftward at a gentle pace**

- Scroll speed of 100-150 pixels/second (configurable via @export variable)
- Constant speed appropriate for young players ages 6-12
- ParallaxBackground node handles the automatic scrolling
- Scroll offset updates each frame in _process using delta time

**3-layer parallax system creates depth perception**

- Layer 1 (farthest): Distant star field at 10-20% of scroll speed
- Layer 2 (middle): Nebulae or distant planets at 40-60% of scroll speed
- Layer 3 (nearest): Space debris/particles at 80-100% of scroll speed
- Each layer uses ParallaxLayer with appropriate motion_scale
- Layers use motion_mirroring for seamless infinite scrolling

**Placeholder visuals for parallax layers**

- Star field: Random small white/yellow dots drawn programmatically
- Nebulae: Semi-transparent colored circles or gradient shapes
- Debris: Small irregular shapes or particles
- Use custom _draw() function pattern from debug_grid.gd or simple sprites

**Rocky asteroid belt boundaries at top and bottom edges**

- Visual asteroid strip along top edge (approximately 60-100 pixels tall)
- Visual asteroid strip along bottom edge (approximately 60-100 pixels tall)
- Placeholder graphics using irregular brown/gray shapes
- Boundaries span full viewport width and tile/repeat as world scrolls

**Collision boundaries keep player in playable area**

- StaticBody2D with CollisionShape2D for top boundary
- StaticBody2D with CollisionShape2D for bottom boundary
- Boundaries positioned at viewport edges, accounting for visual height
- Player's existing CharacterBody2D will collide naturally via move_and_slide()

**Camera setup supports side-scrolling gameplay**

- Evaluate whether player's Camera2D needs adjustment
- Camera may need to be detached from player or have limits set
- Ensure parallax scrolls relative to camera position correctly

## Visual Design

No visual mockups provided. Implementation uses placeholder graphics:

- Star field: Small dots (2-4 pixels) randomly placed, white/pale yellow colors
- Nebulae: Soft circular shapes (100-300 pixels) with semi-transparent purple/blue/pink
- Debris: Small irregular shapes (8-16 pixels) in gray/brown tones
- Asteroid belts: Rocky irregular shapes in brown/gray, forming continuous strips

## Leverage Existing Knowledge

**Code, component, or existing logic found**

debug_grid.gd custom drawing pattern

- [@/Users/matt/dev/space_scroller/scripts/debug_grid.gd:8-34] - Custom _draw() implementation for placeholder visuals
  - Uses draw_line(), draw_rect(), draw_string(), draw_circle() primitives
  - Gets viewport size from ProjectSettings for consistent dimensions
  - Shows pattern for creating visual elements without sprite assets
  - queue_redraw() can trigger redraw when needed

Player viewport clamping logic

- [@/Users/matt/dev/space_scroller/scripts/player.gd:58-68] - Current boundary enforcement
  - Uses ProjectSettings viewport dimensions (2048x1536)
  - Accounts for sprite half-size offset
  - This logic may need adjustment to work with world-space collision boundaries instead

Player CharacterBody2D with collision

- [@/Users/matt/dev/space_scroller/scenes/player.tscn:6-16] - Player collision setup
  - RectangleShape2D collision shape (48x48)
  - move_and_slide() in player.gd will automatically handle StaticBody2D collisions
  - Camera2D is child of player with position_smoothing enabled

Main scene structure

- [@/Users/matt/dev/space_scroller/scenes/main.tscn:1-18] - Current scene hierarchy
  - Node2D root with DebugGrid, Player, UILayer children
  - ParallaxBackground should be added as sibling, likely before Player
  - Boundary StaticBody2D nodes should be added to scene

Virtual joystick drawing pattern

- [@/Users/matt/dev/space_scroller/scripts/ui/virtual_joystick.gd:40-44] - draw_circle() usage
  - Shows how to draw circles with _draw() override
  - Pattern for simple placeholder graphics

Project display settings

- [@/Users/matt/dev/space_scroller/project.godot:18-24] - Viewport configuration
  - 2048x1536 pixels landscape orientation
  - stretch/mode="canvas_items" for responsive scaling
  - mobile rendering method configured

**Git Commit found**

Debug grid implementation

- [7cd0488:Add debug grid and fix viewport bounds calculation] - Custom drawing and viewport bounds
  - Shows _draw() pattern for placeholder visuals
  - Fixed viewport bounds to use ProjectSettings directly
  - Demonstrates how to handle camera interference with boundaries

Player movement and collision setup

- [a0cacc7:Add player spacecraft with keyboard movement] - CharacterBody2D pattern
  - Player uses move_and_slide() for physics-based movement
  - Collision shapes and viewport clamping established
  - Shows scene structure conventions (scenes/, scripts/ folders)

Camera implementation

- [60faf16:Add smooth-following Camera2D attached to player] - Camera setup
  - Camera2D as child of player with position_smoothing
  - May need adjustment for parallax to scroll correctly
  - position_smoothing_speed = 8.0 for smooth follow

Scene modification pattern

- [c4846e7:Add virtual joystick for touch control] - Adding new scene elements
  - Shows how to add CanvasLayer and child nodes to main.tscn
  - Pattern for instancing PackedScenes
  - Demonstrates adding new scripts and scenes together

## Out of Scope

- Procedural generation of backgrounds or obstacles (static/looping only)
- Interactive background elements (collectibles, triggers)
- Level-specific visual theming (different planets/areas)
- Dynamic scroll speed changes (speed-up zones, slow-down)
- Day/night cycles or environmental effects
- Real artwork (placeholders only for this spec)
- Obstacles that damage the player (roadmap item 3 - Obstacles System)
- Enemy spawning from background (roadmap item 4 - Basic Enemies)
- Multiple level support or level transitions
- Background music or sound effects (roadmap item 13 - Audio Integration)
