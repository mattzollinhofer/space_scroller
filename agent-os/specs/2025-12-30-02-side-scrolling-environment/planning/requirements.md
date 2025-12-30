# Spec Requirements: Side-Scrolling Environment

## Initial Description

Side-Scrolling Environment — Implement auto-scrolling space background with parallax layers and basic ground/ceiling boundaries.

This is item #2 on the product roadmap for Solar System Showdown, a kid-friendly space side-scrolling game built in Godot 4.3. The player character (spacecraft with 4-directional movement) is already implemented.

## Requirements Discussion

### First Round Questions

**Q1:** I assume the background auto-scrolls continuously at a constant speed (world moves leftward while the player stays relatively centered horizontally). Is that correct, or should the scrolling speed vary?
**Answer:** Yes, constant speed with the world moving leftward.

**Q2:** Should the player be able to move freely within the full viewport, or constrained to a specific portion?
**Answer:** Free movement within full viewport.

**Q3:** I assume we'll have 3 parallax layers for depth: a distant star field (slowest), a mid-layer with nebulae or planets (medium speed), and a near layer with space debris or particles (fastest). Is this the right number of layers?
**Answer:** Yes, 3 layers sounds good (distant stars, mid nebulae/planets, near debris).

**Q4:** For the visual style, should these be placeholder graphics for now, or do you have specific artwork in mind?
**Answer:** Placeholder graphics for now.

**Q5:** Should the ground/ceiling boundaries have visual indicators, or remain invisible?
**Answer:** Should have something visual there (not invisible).

**Q6:** Should the boundaries be fixed at the viewport edges, or a narrower corridor?
**Answer:** At viewport edges.

**Q7:** The current player has a Camera2D attached. For side-scrolling, should we keep the camera following the player vertically but lock it horizontally?
**Answer:** Whatever is normal for side-scrollers.

**Q8:** Is there anything specific you want to explicitly exclude from this spec?
**Answer:** (Not answered in first round)

### Existing Code to Reference

No similar existing features identified for reference. The current codebase includes:
- Player character (`/scripts/player.gd`, `/scenes/player.tscn`) - CharacterBody2D with movement and viewport clamping
- Main scene (`/scenes/main.tscn`) - Node2D with DebugGrid, Player, and UILayer
- Debug grid (`/scripts/debug_grid.gd`) - Useful reference for custom drawing

The player currently clamps position to viewport bounds, which will need adjustment once world scrolling is implemented.

### Follow-up Questions

**Follow-up 1:** Which style fits the space theme best for the visual boundaries: asteroid belt strips, energy barriers, or nebula clouds?
**Answer:** Rocky asteroid belt strips along top and bottom edges.

**Follow-up 2:** For scroll speed, does "moderate pace" sound right (200-300 px/sec), or should it feel faster/slower?
**Answer:** Slower rather than faster - kids are playing. Gentler pace, around 100-150 pixels/second.

**Follow-up 3:** Exclusions confirmation - keeping focused on auto-scrolling background, 3 parallax layers with placeholder art, and visual boundaries. No procedural generation, no interactive background elements, no level-specific theming yet. Correct?
**Answer:** Yes, confirmed.

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

N/A - No reference images or mockups were provided. Implementation will use placeholder graphics.

## Requirements Summary

### Functional Requirements

- **Auto-scrolling world**: The game world scrolls continuously leftward at a constant, gentle speed (100-150 pixels/second) appropriate for young players (ages 6-12)
- **Parallax background system**: 3 distinct layers creating depth perception:
  - Layer 1 (farthest): Distant star field - slowest scroll rate
  - Layer 2 (middle): Nebulae and/or distant planets - medium scroll rate
  - Layer 3 (nearest): Space debris/particles - fastest scroll rate (matches or slightly exceeds world scroll)
- **Visual boundaries**: Rocky asteroid belt strips along the top and bottom edges of the viewport, serving as both visual indicators and collision boundaries
- **Player movement area**: Full viewport remains accessible for player movement
- **Camera behavior**: Standard side-scroller camera setup (implementation to follow common patterns)

### Technical Considerations

- **Viewport size**: 2048x1536 pixels (landscape, iPad-optimized)
- **Scroll speed**: 100-150 pixels/second (configurable via export variable)
- **Existing player**: CharacterBody2D at `/scenes/player.tscn` with Camera2D child - may need camera adjustments for scrolling world
- **Current viewport clamping**: Player script clamps to viewport bounds - will need to work with new world-space boundaries
- **Graphics**: Placeholder/programmatic visuals acceptable; PNG format when real assets added
- **Engine**: Godot 4.3 with GDScript, using ParallaxBackground/ParallaxLayer nodes

### Reusability Opportunities

- Godot's built-in `ParallaxBackground` and `ParallaxLayer` nodes are ideal for the parallax system
- `StaticBody2D` or `Area2D` with collision shapes for boundary enforcement
- The debug_grid.gd pattern shows how to use custom `_draw()` for placeholder visuals

### Scope Boundaries

**In Scope:**
- Auto-scrolling background system with constant speed
- 3-layer parallax effect with placeholder graphics
- Rocky asteroid belt visual boundaries at top and bottom viewport edges
- Collision boundaries to keep player within playable area
- Camera setup appropriate for side-scrolling gameplay

**Out of Scope:**
- Procedural generation of backgrounds or obstacles
- Interactive background elements
- Level-specific visual theming (different planets/areas)
- Dynamic scroll speed changes
- Day/night cycles or environmental effects
- Real artwork (placeholders only for this spec)
