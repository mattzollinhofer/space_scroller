# Task Breakdown: Development Environment Setup

## Overview

Total Slices: 3
Each slice delivers incremental user value and is tested end-to-end.

This is roadmap item 0 - foundational setup that must be complete before any game development begins. The slices are organized so each delivers a working, verifiable milestone.

## Task List

### Slice 1: Developer can open a configured Godot project

**What this delivers:** A developer can open the project in Godot Editor, see the proper folder structure, and verify project settings are configured for iPad portrait mode.

**Dependencies:** None (Godot 4.3 Editor already installed per spec)

**Reference patterns:**
- [commit:0c08f3f] - Tech stack specifies Godot 4.3, GDScript, iPad as primary platform
- [github.com/github/gitignore/Godot.gitignore] - Standard Godot ignore patterns

#### Tasks

- [ ] 1.1 Create project.godot file with basic Godot 4.3 configuration
- [ ] 1.2 Set display/window/size/viewport_width to 1536
- [ ] 1.3 Set display/window/size/viewport_height to 2048
- [ ] 1.4 Set display/window/handheld/orientation to portrait
- [ ] 1.5 Configure stretch mode to canvas_items
- [ ] 1.6 Configure stretch aspect to keep
- [ ] 1.7 Create folder structure with .gitkeep files:
  - scenes/
  - scripts/
  - assets/sprites/
  - assets/audio/
  - assets/fonts/
  - autoloads/
- [ ] 1.8 Create .gitignore with Godot patterns:
  - .godot/
  - .import/
  - export.cfg
  - export_credentials.cfg
  - *.translation
  - *.tmp
  - .mono/
  - data_*/
  - mono_crash.*.json
  - .DS_Store
  - Thumbs.db
- [ ] 1.9 Open project in Godot Editor, verify settings appear correctly
- [ ] 1.10 Commit working slice

**Acceptance Criteria:**
- Project opens in Godot 4.3 Editor without errors
- Project Settings show viewport 1536x2048
- Project Settings show portrait orientation
- Project Settings show canvas_items stretch mode with keep aspect
- All six directories exist in FileSystem dock
- .gitignore prevents .godot/ from being tracked

---

### Slice 2: Developer can test input mappings in editor

**What this delivers:** A developer can view and test the pre-configured input actions (move_up, move_down, move_left, move_right, shoot) in Project Settings > Input Map, with keyboard bindings ready for testing.

**Dependencies:** Slice 1 (project.godot must exist)

**Reference patterns:**
- [commit:0c08f3f] - Tech stack confirms InputMap with touch and keyboard/mouse actions
- [@agent-os/product/tech-stack.md:48] - Input system specification

#### Tasks

- [ ] 2.1 Add move_up action to InputMap with:
  - W key
  - Up Arrow key
- [ ] 2.2 Add move_down action to InputMap with:
  - S key
  - Down Arrow key
- [ ] 2.3 Add move_left action to InputMap with:
  - A key
  - Left Arrow key
- [ ] 2.4 Add move_right action to InputMap with:
  - D key
  - Right Arrow key
- [ ] 2.5 Add shoot action to InputMap with:
  - Space key
- [ ] 2.6 Open Project Settings > Input Map in Godot Editor
- [ ] 2.7 Verify all five actions appear with correct bindings
- [ ] 2.8 Commit working slice

**Acceptance Criteria:**
- All five input actions visible in Input Map settings
- Each movement action has two keyboard bindings (WASD + Arrow keys)
- Shoot action has Space key binding
- No duplicate or conflicting bindings

**Note on touch input:** Touch gesture support for these actions will be implemented with virtual joystick/buttons in roadmap item 1 (Player Character). The InputMap actions defined here will receive events from those touch controls.

---

### Slice 3: Developer can run the game and see placeholder scene

**What this delivers:** A developer can press F5 (or Play) in Godot Editor and see a running game window at the correct resolution showing "Solar System Showdown" text, confirming the entire setup works end-to-end.

**Dependencies:** Slice 1 and Slice 2 (project configured, inputs mapped)

**Reference patterns:**
- [@agent-os/product/mission.md] - Game title "Solar System Showdown"

#### Tasks

- [ ] 3.1 Create scenes/main.tscn with:
  - Node2D root node named "Main"
  - Label child node with text "Solar System Showdown"
  - Label positioned center-ish on screen (visible in viewport)
- [ ] 3.2 Set scenes/main.tscn as the main scene in project settings
- [ ] 3.3 Press F5 in Godot Editor to run the game
- [ ] 3.4 Verify game window opens at correct resolution
- [ ] 3.5 Verify "Solar System Showdown" text is visible
- [ ] 3.6 Verify no errors in Output panel
- [ ] 3.7 Close game window, verify clean exit
- [ ] 3.8 Commit working slice

**Acceptance Criteria:**
- F5 launches the game without errors
- Game window displays at iPad portrait aspect ratio
- "Solar System Showdown" label is visible
- Game closes cleanly with no error messages

---

### Slice 4: Web export template installed and verified

**What this delivers:** A developer can access Export menu and see Web (HTML5) as an available export option, ready for roadmap item 15.

**Dependencies:** Slices 1-3 (project fully functional)

#### Tasks

- [ ] 4.1 Open Editor > Manage Export Templates in Godot
- [ ] 4.2 Download/install Godot 4.3 export templates if not present
- [ ] 4.3 Verify Web export template appears in the list
- [ ] 4.4 Open Project > Export to confirm HTML5 preset can be added
- [ ] 4.5 Document template version installed
- [ ] 4.6 Commit any project changes (if export templates modify project)

**Acceptance Criteria:**
- Export Templates manager shows templates installed for current Godot version
- Web/HTML5 export option is available when creating export preset
- No actual export configuration needed (deferred to roadmap item 15)

---

## Final Verification Checklist

After all slices complete, verify:

- [ ] Project opens in Godot 4.3 without errors or warnings
- [ ] All six directories present: scenes/, scripts/, assets/sprites/, assets/audio/, assets/fonts/, autoloads/
- [ ] Viewport configured: 1536x2048 portrait
- [ ] Stretch mode: canvas_items with keep aspect
- [ ] Five input actions defined: move_up, move_down, move_left, move_right, shoot
- [ ] Main scene runs and displays game title
- [ ] Web export template installed
- [ ] .gitignore prevents .godot/ directory from tracking
- [ ] All changes committed to version control

## Notes

- **Touch controls:** The spec mentions touch gesture support for input actions, but the actual touch UI (virtual joystick, buttons) is explicitly out of scope per spec and will be built in roadmap item 1 (Player Character). The InputMap actions are keyboard-only for now.

- **2D Physics:** The spec mentions ensuring 2D physics is enabled. Godot 4.3 has 2D physics enabled by default - no configuration needed. This will be verified implicitly when physics nodes are used in roadmap item 1.

- **Export templates:** Templates are installed globally in Godot, not per-project. If templates are already installed from another project, Slice 4 becomes verification only.
