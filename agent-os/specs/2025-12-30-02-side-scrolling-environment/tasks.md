# Task Breakdown: Side-Scrolling Environment

## Overview

Total Slices: 4
Each slice delivers incremental user value and is tested end-to-end.

**Key Technical Notes:**
- Viewport: 2048x1536 (landscape, iPad-optimized)
- Current player has Camera2D as child with position smoothing
- Player uses `_clamp_to_viewport()` which will need adjustment for collision-based boundaries
- ParallaxBackground requires camera setup consideration for proper scrolling

---

## Task List

### Slice 1: Player sees scrolling star field background

**What this delivers:** When the game runs, the player sees a distant star field scrolling slowly leftward, creating the sense of moving through space. This is the most fundamental visual feedback that the world is in motion.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/debug_grid.gd:8-34] - Custom _draw() pattern for placeholder visuals
- [@/Users/matt/dev/space_scroller/scenes/main.tscn:1-18] - Scene hierarchy to add ParallaxBackground
- [@/Users/matt/dev/space_scroller/scenes/player.tscn:18-21] - Camera2D setup that may need adjustment

#### Tasks

- [x] 1.1 Create integration test: verify star field layer scrolls leftward over time
- [x] 1.2 Run test, verify expected failure
- [x] 1.3 Make smallest change possible to progress
- [x] 1.4 Run test, observe failure or success
- [x] 1.5 Document result and update task list
- [x] 1.6 Repeat 1.3-1.5 as necessary (expected iterations: ParallaxBackground node, ParallaxLayer, star field script, scroll controller, camera adjustments)
  - Created scroll_controller.gd with @export scroll_speed (default 120 px/sec)
  - Created star_field.gd using _draw() with random 2-4px dots in white/pale yellow
  - Added ParallaxBackground to main.tscn with StarFieldLayer (motion_scale=0.15, motion_mirroring=2048)
  - Success: Headless test passes, scene loads without errors
- [x] 1.7 Refactor if needed (keep tests green)
- [x] 1.8 Commit working slice

**Implementation Notes:**
- Create `ParallaxBackground` node in main.tscn (should be early child for proper layering)
- Create `ParallaxLayer` with `motion_scale = Vector2(0.15, 0)` (15% of scroll speed - farthest layer)
- Set `motion_mirroring` to viewport width for seamless looping
- Create star field script using `_draw()` with random small dots (2-4px, white/pale yellow)
- Scroll controller script updates `ParallaxBackground.scroll_offset.x` each frame
- Scroll speed: @export var, default 120 px/sec (middle of 100-150 range)
- Camera may need to be detached from player OR ParallaxBackground needs to follow camera

**Acceptance Criteria:**
- Star field is visible as small dots across the background
- Stars scroll leftward continuously at slow pace (10-20% of world scroll speed)
- Scrolling is seamless with no visible seams or jumps
- Player movement does not affect star field scroll rate

---

### Slice 2: Player sees depth with 3 parallax layers

**What this delivers:** The space environment gains visual depth - distant stars scroll slowest, middle nebulae scroll at medium speed, and near debris scrolls fastest. The player perceives they are flying through a 3D space environment.

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/virtual_joystick.gd:40-44] - draw_circle() usage pattern
- Slice 1 star field layer as template for additional layers

#### Tasks

- [x] 2.1 Write integration test: verify all 3 layers scroll at different rates
- [x] 2.2 Run test, verify expected failure
- [x] 2.3 Make smallest change possible to progress
- [x] 2.4 Run test, observe failure or success
- [x] 2.5 Document result and update task list
- [x] 2.6 Repeat 2.3-2.5 as necessary
  - Created nebulae.gd with 8 semi-transparent circles (100-300px) in purple/blue/pink
  - Created debris.gd with 40 small irregular shapes (8-16px) in gray/brown tones
  - Added NebulaLayer (motion_scale=0.5) and DebrisLayer (motion_scale=0.9) to main.tscn
  - Success: Headless test passes, all 3 layers configured with proper z-ordering
- [x] 2.7 Refactor if needed (keep tests green)
- [x] 2.8 Run all slice tests (1 and 2) to verify no regressions
- [x] 2.9 Commit working slice

**Implementation Notes:**
- Layer 2 (nebulae): `motion_scale = Vector2(0.5, 0)` (50% speed)
  - Draw semi-transparent circles (100-300px diameter)
  - Colors: purple, blue, pink with alpha 0.3-0.5
  - Fewer elements than star field (5-10 shapes)
- Layer 3 (debris): `motion_scale = Vector2(0.9, 0)` (90% speed)
  - Draw small irregular shapes (8-16px)
  - Colors: gray/brown tones
  - Medium density
- Ensure proper z-ordering (Layer 1 behind Layer 2 behind Layer 3)
- All layers use same scroll controller

**Acceptance Criteria:**
- 3 distinct visual layers visible
- Each layer scrolls at visibly different speed (slowest to fastest: stars, nebulae, debris)
- All layers loop seamlessly
- Visual depth effect is perceivable

---

### Slice 3: Player sees asteroid belt boundaries at screen edges

**What this delivers:** Rocky asteroid belt strips appear at the top and bottom edges of the screen, defining the playable corridor. These scroll with the world, reinforcing the side-scrolling motion and showing where the boundaries are.

**Dependencies:** Slice 2

**Reference patterns:**
- Parallax layer pattern from Slices 1-2
- [@/Users/matt/dev/space_scroller/scripts/debug_grid.gd:26-27] - draw_rect() for filled shapes

#### Tasks

- [x] 3.1 Write integration test: verify asteroid visuals at top and bottom edges
- [x] 3.2 Run test, verify expected failure
- [x] 3.3 Make smallest change possible to progress
- [x] 3.4 Run test, observe failure or success
- [x] 3.5 Document result and update task list
- [x] 3.6 Repeat 3.3-3.5 as necessary
  - Created asteroid_boundaries.gd with 80px tall rocky strips at top/bottom edges
  - Uses irregular polygon shapes (5-8 vertices) in brown/gray tones
  - Background fill ensures no gaps between asteroids
  - Added BoundaryLayer (motion_scale=1.0) to main.tscn for full world speed
  - Success: Headless test passes, boundaries scroll with world
- [x] 3.7 Refactor if needed (keep tests green)
- [x] 3.8 Run all slice tests to verify no regressions
- [x] 3.9 Commit working slice

**Implementation Notes:**
- Create separate ParallaxLayer for boundaries OR use foreground layer
- Boundary height: 80px (middle of 60-100px range)
- Position: Top strip at y=0 to y=80, Bottom strip at y=1456 to y=1536
- `motion_scale = Vector2(1.0, 0)` - scrolls at full world speed (feels "close")
- Draw irregular rocky shapes using draw_polygon() or multiple draw_rect()
- Colors: browns and grays (Color(0.4, 0.3, 0.2), Color(0.5, 0.5, 0.5))
- Use motion_mirroring for seamless tiling

**Acceptance Criteria:**
- Rocky asteroid strips visible at top and bottom of screen
- Strips are approximately 60-100px tall
- Asteroids scroll leftward at world scroll speed
- Scrolling is seamless with no gaps

---

### Slice 4: Player is blocked by collision boundaries

**What this delivers:** The player spacecraft cannot fly into the asteroid belts - collision boundaries keep the player within the safe playable area. This completes the side-scrolling corridor gameplay foundation.

**Dependencies:** Slice 3

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scenes/player.tscn:6-16] - Player CollisionShape2D setup
- [@/Users/matt/dev/space_scroller/scripts/player.gd:52] - move_and_slide() handles StaticBody2D collisions
- [@/Users/matt/dev/space_scroller/scripts/player.gd:58-68] - Current _clamp_to_viewport() to be replaced

#### Tasks

- [ ] 4.1 Write integration test: verify player cannot move past top/bottom boundaries
- [ ] 4.2 Run test, verify expected failure
- [ ] 4.3 Make smallest change possible to progress
- [ ] 4.4 Run test, observe failure or success
- [ ] 4.5 Document result and update task list
- [ ] 4.6 Repeat 4.3-4.5 as necessary
- [ ] 4.7 Refactor if needed (keep tests green)
- [ ] 4.8 Run all feature tests to verify everything works together
- [ ] 4.9 Commit working slice

**Implementation Notes:**
- Create 2 StaticBody2D nodes with CollisionShape2D children
- Top boundary: RectangleShape2D spanning full width at top, aligned with visual asteroid height
- Bottom boundary: Same at bottom of viewport
- Position boundaries to match visual asteroid belt edges (player stops at asteroid edge, not viewport edge)
- Consider: Remove or modify player's _clamp_to_viewport() since collisions now handle Y-axis
  - Keep X-axis clamping (player shouldn't go off left/right of screen)
  - OR let collisions handle everything if we add side boundaries too
- Collision layers: Ensure player and boundaries are on compatible layers
- move_and_slide() already handles StaticBody2D collision response

**Acceptance Criteria:**
- Player spacecraft stops when hitting top asteroid boundary
- Player spacecraft stops when hitting bottom asteroid boundary
- Collision feels natural (no jitter or tunneling)
- Player can still move freely horizontally and within the corridor vertically
- All previous visual features still work correctly

---

## Final Verification

After all slices complete:
- [ ] Run game and verify complete side-scrolling experience
- [ ] Confirm scroll speed is configurable via @export
- [ ] Test at both 100 and 150 px/sec scroll speeds
- [ ] Verify player movement works correctly within boundaries
- [ ] Check that parallax creates visible depth effect
- [ ] Ensure no visual glitches or seams in scrolling layers

---

## Technical Architecture Summary

```
main.tscn (Node2D)
  |-- ParallaxBackground
  |     |-- StarFieldLayer (ParallaxLayer, motion_scale=0.15)
  |     |     +-- StarField (Node2D with _draw() script)
  |     |-- NebulaLayer (ParallaxLayer, motion_scale=0.5)
  |     |     +-- Nebulae (Node2D with _draw() script)
  |     |-- DebrisLayer (ParallaxLayer, motion_scale=0.9)
  |     |     +-- Debris (Node2D with _draw() script)
  |     +-- BoundaryLayer (ParallaxLayer, motion_scale=1.0)
  |           +-- AsteroidBoundaries (Node2D with _draw() script)
  |-- TopBoundary (StaticBody2D)
  |     +-- CollisionShape2D (RectangleShape2D)
  |-- BottomBoundary (StaticBody2D)
  |     +-- CollisionShape2D (RectangleShape2D)
  |-- DebugGrid (Node2D) [existing]
  |-- Player (CharacterBody2D) [existing]
  |     +-- Camera2D [may need adjustment]
  +-- UILayer (CanvasLayer) [existing]
        +-- VirtualJoystick [existing]
```

**New Scripts:**
- `scripts/scroll_controller.gd` - Manages scroll_offset updates in _process()
- `scripts/background/star_field.gd` - Draws random star dots
- `scripts/background/nebulae.gd` - Draws semi-transparent nebula shapes
- `scripts/background/debris.gd` - Draws small debris particles
- `scripts/background/asteroid_boundaries.gd` - Draws top/bottom rocky strips
