# Specification: Player Character

## Goal

Create the player spacecraft with 4-directional movement, supporting both virtual joystick touch controls and keyboard input, while changing the project orientation from portrait to landscape.

## User Stories

- As a player, I want to control my spacecraft smoothly in any direction so that I can navigate through the game world
- As a mobile player, I want to use touch controls via a virtual joystick so that I can play comfortably on my iPad

## Specific Requirements

**Project displays in landscape orientation**

- Change viewport dimensions from 1536x2048 (portrait) to 2048x1536 (landscape)
- Update window/handheld/orientation setting from portrait (1) to landscape (0)
- Main scene should display correctly in new orientation

**Player spacecraft moves in 4 directions with snappy feel**

- CharacterBody2D as the player node type for controlled movement
- Movement responds to input immediately with minimal to no inertia
- Movement speed controlled via exported variable for easy tuning
- Use velocity-based movement in _physics_process for consistent behavior

**Keyboard controls work using existing InputMap**

- Use existing move_up, move_down, move_left, move_right actions
- WASD and arrow keys already configured in project.godot
- Input.get_vector() for normalized diagonal movement

**Virtual joystick provides touch control**

- TouchScreenButton-based or custom Control node for joystick
- Position joystick in bottom-left corner for comfortable thumb access
- Joystick output integrated with same movement logic as keyboard
- Visual indicator shows joystick position and input direction

**Player stays within screen bounds**

- Clamp player position to viewport rectangle
- Account for player sprite size when clamping (half-width/half-height offset)
- Use get_viewport_rect() to determine bounds dynamically

**Camera follows the player**

- Camera2D node attached to player or following player position
- Camera setup prepares for future auto-scrolling implementation
- Smooth following behavior (position_smoothing_enabled)

**Placeholder sprite represents the spacecraft**

- Simple geometric shape (triangle or rectangle pointing right)
- Created as PNG or using Godot's drawing primitives
- Sized appropriately for 2048x1536 viewport (approximately 64-96 pixels)
- Collision shape matches sprite bounds

## Visual Design

No visual mockups provided. Use simple placeholder graphics:

- Spacecraft: Right-pointing triangle or arrow shape in a visible color
- Virtual joystick: Semi-transparent circle with inner thumb indicator

## Leverage Existing Knowledge

**Code, component, or existing logic found**

Input mappings already configured in project.godot

- [@/Users/matt/dev/space_scroller/project.godot:27-50] - Existing InputMap with move_up, move_down, move_left, move_right, shoot actions
  - Use Input.get_vector("move_left", "move_right", "move_up", "move_down") to get normalized direction
  - WASD (W=87, A=65, S=83, D=68) and arrow keys already mapped
  - Deadzone set to 0.5 for all actions
  - Shoot action exists for future combat implementation

Main scene structure as reference

- [@/Users/matt/dev/space_scroller/scenes/main.tscn:1-21] - Basic scene structure pattern
  - Node2D as root node
  - Shows Label positioning with anchors for UI elements
  - Can be modified to add player and camera nodes

Display configuration requiring modification

- [@/Users/matt/dev/space_scroller/project.godot:18-24] - Current portrait display settings
  - viewport_width=1536, viewport_height=2048 need to be swapped
  - window/handheld/orientation=1 (portrait) needs to change to 0 (landscape)
  - stretch/mode="canvas_items" should remain for responsive scaling

**Git Commit found**

Project initialization patterns from Z

- [c3dcf72:Initialize Godot 4.3 project for iPad portrait development] - Shows project.godot structure and folder organization
  - Follow same folder conventions: scenes/, scripts/, assets/sprites/
  - .gitkeep pattern for empty directories
  - Project config format and sections

- [f1f6a7d:Add keyboard input mappings for player controls] - InputMap configuration pattern
  - Shows how input actions are defined in project.godot
  - Includes both primary (WASD) and secondary (arrow) key bindings
  - Physical keycode format for cross-platform compatibility

- [fc2b6fb:Add runnable main scene with game title display] - Scene creation pattern
  - .tscn file format for Godot scenes
  - Node hierarchy and property configuration
  - How to set main_scene in project.godot

## Out of Scope

- Health/lives system (roadmap item 3 - Obstacles System)
- Invincibility frames or damage feedback
- Sprite animations or frame-based visuals
- Particle trails or thrust effects (roadmap item 14 - Polish and Juice)
- Sound effects for movement (roadmap item 13 - Audio Integration)
- Shooting mechanics (roadmap item 5 - Player Combat)
- Auto-scrolling background movement (roadmap item 2 - Side-Scrolling Environment)
- Enemy interactions or collision damage
- UI elements beyond virtual joystick (HUD, score display)
- Save/load player position or state
