# Task Breakdown: Player Character

## Overview

Total Slices: 4

Each slice delivers incremental user value and is tested end-to-end.

This is the first gameplay feature for "Solar System Showdown" - creating a controllable player spacecraft with keyboard and touch controls.

## Task List

### Slice 1: Player sees game in landscape orientation and can move spacecraft with keyboard

**What this delivers:** User launches the game, sees it in landscape orientation (2048x1536), and can control a visible spacecraft using WASD or arrow keys. The spacecraft moves snappily in all 4 directions and stays within screen bounds.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/project.godot:18-24] - Current portrait display settings to modify
- [@/Users/matt/dev/space_scroller/project.godot:27-50] - Existing InputMap with move_up, move_down, move_left, move_right
- [@/Users/matt/dev/space_scroller/scenes/main.tscn:1-21] - Current main scene structure
- [commit:c3dcf72] - Project structure pattern (scenes/, scripts/, assets/sprites/)
- [commit:f1f6a7d] - How input actions are configured

#### Tasks

- [x] 1.1 Change project.godot display settings from portrait (1536x2048) to landscape (2048x1536)
  - Set viewport_width=2048, viewport_height=1536
  - Set window/handheld/orientation=0 (landscape)
- [x] 1.2 Create placeholder spacecraft sprite (right-pointing triangle PNG, ~64-96px)
  - Save to assets/sprites/player.png
- [x] 1.3 Create player scene (scenes/player.tscn) with CharacterBody2D
  - Add Sprite2D child with placeholder sprite
  - Add CollisionShape2D with RectangleShape2D matching sprite bounds
- [x] 1.4 Create player movement script (scripts/player.gd)
  - Use Input.get_vector() for normalized 4-directional input
  - Implement snappy movement with minimal inertia via velocity-based _physics_process
  - Export movement speed variable for tuning
  - Clamp position to viewport bounds using get_viewport_rect()
- [x] 1.5 Update main scene to instance player at center of screen
- [ ] 1.6 Run game and verify:
  - Game displays in landscape orientation
  - Spacecraft appears at center
  - WASD/arrow keys move spacecraft in all 4 directions
  - Movement feels snappy (immediate response, minimal drift)
  - Spacecraft cannot move off screen edges
- [ ] 1.7 Tune movement speed if needed (adjust exported variable)
- [ ] 1.8 Commit working slice

**Acceptance Criteria:**
- Game launches in landscape orientation (2048x1536)
- Spacecraft visible on screen with placeholder sprite
- Keyboard controls (WASD and arrow keys) move spacecraft in all 4 directions
- Movement feels snappy with immediate response
- Player cannot move off screen edges
- Collision shape is set up for future collision detection

---

### Slice 2: Camera follows the player smoothly

**What this delivers:** User can move the spacecraft and the camera smoothly tracks its position, preparing the groundwork for future auto-scrolling.

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scenes/player.tscn] - Player scene to add Camera2D to (created in Slice 1)

#### Tasks

- [ ] 2.1 Add Camera2D node as child of player in player.tscn
  - Enable position_smoothing_enabled for smooth following
  - Configure reasonable smoothing speed
  - Set as current camera
- [ ] 2.2 Run game and verify:
  - Camera follows player smoothly
  - No jittering or harsh movements
  - Screen bounds clamping still works correctly
- [ ] 2.3 Run all tests from Slice 1 to verify no regressions
- [ ] 2.4 Commit working slice

**Acceptance Criteria:**
- Camera smoothly follows player movement
- Smooth following behavior (position_smoothing_enabled)
- Player still constrained to screen bounds
- Previous slice functionality intact

---

### Slice 3: Player can control spacecraft with virtual joystick on touch devices

**What this delivers:** User on a touch device sees a virtual joystick in the bottom-left corner and can drag it to move the spacecraft in any direction, with the same snappy feel as keyboard controls.

**Dependencies:** Slices 1, 2

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/player.gd] - Player movement script to integrate joystick input (created in Slice 1)

#### Tasks

- [ ] 3.1 Create virtual joystick scene (scenes/ui/virtual_joystick.tscn)
  - Use Control or CanvasLayer as root for UI layer
  - Add base circle (semi-transparent) for joystick area
  - Add inner circle (thumb indicator) that moves with touch input
  - Position in bottom-left corner for comfortable thumb access on iPad
- [ ] 3.2 Create virtual joystick script (scripts/ui/virtual_joystick.gd)
  - Handle touch input events (_input or _unhandled_input)
  - Calculate normalized direction vector from center to touch position
  - Expose direction as a property that player script can read
  - Visual feedback: move inner circle to show input direction
  - Reset to center when touch released
- [ ] 3.3 Instance virtual joystick in main scene
  - Add as CanvasLayer child so it stays on screen regardless of camera
- [ ] 3.4 Modify player.gd to combine keyboard and joystick input
  - Read joystick direction in addition to Input.get_vector()
  - Combine inputs so either method works (take strongest input)
  - Ensure no conflicts between input methods
- [ ] 3.5 Run game and verify:
  - Virtual joystick visible in bottom-left corner
  - Touch/click on joystick moves inner indicator
  - Dragging joystick moves spacecraft in corresponding direction
  - Movement feels same snappy quality as keyboard
  - Releasing joystick stops movement
  - Keyboard still works simultaneously
- [ ] 3.6 Run all previous tests to verify no regressions
- [ ] 3.7 Commit working slice

**Acceptance Criteria:**
- Virtual joystick visible in bottom-left corner of screen
- Joystick provides visual feedback when touched (inner circle moves)
- Touching and dragging joystick moves spacecraft in corresponding direction
- Same snappy movement feel as keyboard controls
- Keyboard and touch controls can work simultaneously without conflict
- Joystick positioned comfortably for iPad thumb access

---

### Slice 4: Polish and edge case handling

**What this delivers:** Production-ready player character with all edge cases handled, proper visual sizing, and confirmed functionality across input methods.

**Dependencies:** All prior slices

#### Tasks

- [ ] 4.1 Verify sprite sizing is appropriate for 2048x1536 viewport
  - Spacecraft should be clearly visible but not oversized (64-96px recommended)
  - Adjust if needed
- [ ] 4.2 Verify collision shape accurately matches sprite bounds
  - Check for any gaps or oversized collision areas
- [ ] 4.3 Verify joystick sizing and positioning works well on iPad resolution
  - Joystick should be easily usable with thumb
  - Should not obstruct gameplay area
- [ ] 4.4 Test edge cases:
  - Moving into corners (should stop cleanly)
  - Diagonal movement normalization (diagonal shouldn't be faster)
  - Switching between keyboard and touch mid-movement
  - Rapid direction changes (should feel responsive)
- [ ] 4.5 Ensure all code follows project standards:
  - Files under 200 lines
  - Consistent naming conventions
  - Exported variables for tunable values
- [ ] 4.6 Run complete verification:
  - Launch game in landscape mode
  - Test all keyboard controls
  - Test virtual joystick
  - Verify screen bounds on all edges
  - Verify camera following
- [ ] 4.7 Final commit

**Acceptance Criteria:**
- All user workflows from spec work correctly
- Player spacecraft moves smoothly with keyboard (WASD/arrows)
- Virtual joystick provides equivalent touch control
- Player constrained to screen bounds in all situations
- Camera follows player smoothly
- Error cases handled gracefully
- Code follows existing patterns and standards

---

## Files to Create/Modify

### Modified Files
- `/Users/matt/dev/space_scroller/project.godot` - Change viewport to landscape (2048x1536)
- `/Users/matt/dev/space_scroller/scenes/main.tscn` - Add player instance and virtual joystick

### New Files
- `/Users/matt/dev/space_scroller/assets/sprites/player.png` - Placeholder spacecraft sprite
- `/Users/matt/dev/space_scroller/scenes/player.tscn` - Player CharacterBody2D scene
- `/Users/matt/dev/space_scroller/scripts/player.gd` - Player movement script
- `/Users/matt/dev/space_scroller/scenes/ui/virtual_joystick.tscn` - Virtual joystick UI scene
- `/Users/matt/dev/space_scroller/scripts/ui/virtual_joystick.gd` - Virtual joystick input handling

## Technical Notes

- Use CharacterBody2D (not RigidBody2D) for direct, responsive control
- Movement in _physics_process for consistent behavior
- Input.get_vector() provides normalized direction (prevents fast diagonal movement)
- Screen bounds clamping should account for player sprite half-width/half-height
- Virtual joystick should use CanvasLayer to stay fixed on screen
- Camera2D with position_smoothing_enabled prepares for future auto-scrolling
