# Spec Requirements: Player Character

## Initial Description

Create the player spacecraft with basic movement controls (touch input for up/down/left/right) and smooth scrolling camera follow.

## Requirements Discussion

### First Round Questions

**Q1:** I notice the game is configured in portrait orientation (1536x2048). I assume the spacecraft will move primarily up/down to avoid obstacles while auto-scrolling happens upward (or rightward?). Which direction should the level auto-scroll - upward (traditional vertical shooter style) or rightward (side-scroller style as mentioned in the mission)?
**Answer:** The game should be LANDSCAPE, not portrait. Standard side-scroller scrolling to the right. The project orientation needs to be changed from portrait (1536x2048) to landscape.

**Q2:** For touch controls, I'm assuming we'll implement a virtual joystick or touch-drag control scheme where the player drags their finger and the ship follows. Is that correct, or would you prefer tap-to-move or tilt controls?
**Answer:** Normal controls (virtual joystick or similar). Should also support keyboard.

**Q3:** The roadmap mentions "touch input for up/down/left/right." I assume this means free movement in all 4 directions within the visible screen area. Is that correct?
**Answer:** Normal side-scroller - free movement in all 4 directions within screen bounds (not trying to be special).

**Q4:** For the spacecraft visual, I'm planning to use a simple placeholder sprite that can be replaced with proper art later. Is that acceptable, or do you already have spacecraft artwork ready?
**Answer:** Basic blocky placeholder shapes are fine.

**Q5:** Regarding movement speed and feel: Should the movement feel snappy and arcade-like (quick response, minimal inertia) or floaty and space-like (gradual acceleration, momentum)?
**Answer:** Snappy and arcade-like (quick response, minimal inertia).

**Q6:** For the camera follow behavior: Should the player be able to move anywhere on screen, or should we constrain the player to stay within certain screen bounds?
**Answer:** Constrain player to screen bounds - can't go off edges.

**Q7:** Should touch controls also work simultaneously with keyboard for web testing, or should we detect the platform and only enable the appropriate input method?
**Answer:** Support both keyboard and touch - whatever is easier and won't cause issues changing later. User will primarily test with keyboard.

**Q8:** Is there anything specific you want to exclude from this initial player character implementation?
**Answer:** Just focus on this work - exclude health/lives system, invincibility frames, animations, particle trails, sound effects.

### Existing Code to Reference

No similar existing features identified for reference.

### Follow-up Questions

None required - all answers were clear and complete.

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

N/A

## Requirements Summary

### Functional Requirements

- Player spacecraft with free movement in all 4 directions (up/down/left/right)
- Snappy, arcade-like movement feel with quick response and minimal inertia
- Virtual joystick touch controls for mobile/tablet
- Keyboard controls (WASD/arrow keys) for web testing - already configured in project
- Both input methods should work simultaneously
- Player constrained to visible screen bounds (cannot move off edges)
- Camera follows player smoothly (for when auto-scrolling is added in future roadmap item)

### Project Configuration Changes

- **CRITICAL**: Change project orientation from portrait (1536x2048) to landscape
- Recommended landscape resolution: 2048x1536 (swap current dimensions) or standard 1920x1080
- Update window/handheld/orientation setting from portrait to landscape

### Technical Implementation

- Use CharacterBody2D for the player spacecraft (Godot best practice for controlled movement)
- Implement virtual joystick UI element for touch input
- Use existing InputMap actions (move_up, move_down, move_left, move_right)
- Clamp player position to viewport bounds
- Camera2D attached to or following the player

### Visual Requirements

- Basic placeholder sprite for spacecraft (simple geometric shape)
- Blocky/rectangular shape is acceptable
- No animations required for initial implementation

### Reusability Opportunities

- None identified - this is the first gameplay feature

### Scope Boundaries

**In Scope:**

- Player spacecraft scene with CharacterBody2D
- Movement script with 4-directional input handling
- Virtual joystick UI for touch controls
- Keyboard input support (using existing InputMap)
- Screen boundary constraints
- Basic Camera2D setup for player following
- Project orientation change to landscape
- Simple placeholder sprite

**Out of Scope:**

- Health/lives system (roadmap item 3 - Obstacles System)
- Invincibility frames
- Sprite animations
- Particle trails or visual effects (roadmap item 14 - Polish and Juice)
- Sound effects (roadmap item 13 - Audio Integration)
- Shooting mechanics (roadmap item 5 - Player Combat)
- Auto-scrolling background (roadmap item 2 - Side-Scrolling Environment)

### Technical Considerations

- Godot 4.3 with GDScript
- CharacterBody2D with collision shape for future collision detection
- Input handling should be extensible for future "shoot" action
- Movement speed should be tunable via exported variable
- Virtual joystick should be positioned for comfortable thumb access on iPad
- Ensure touch and keyboard inputs don't conflict
