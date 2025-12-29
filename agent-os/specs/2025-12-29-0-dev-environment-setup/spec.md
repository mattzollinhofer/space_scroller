# Specification: Development Environment Setup

## Goal

Initialize a Godot 4.3 project structure for "Solar System Showdown" with proper folder organization, input mappings, and project settings optimized for a 2D mobile game targeting iPad in portrait mode.

## User Stories

- As a developer, I want a properly configured Godot project so that I can immediately begin building game features without setup overhead
- As a developer, I want input actions pre-configured for touch and keyboard so that I can implement controls consistently across features

## Specific Requirements

**Standard Godot project folder structure is created**

- Create `scenes/` directory for all game scene files (.tscn)
- Create `scripts/` directory for GDScript files (.gd)
- Create `assets/sprites/` directory for PNG and SVG graphics
- Create `assets/audio/` directory for OGG music and WAV sound effects
- Create `assets/fonts/` directory for font files
- Create `autoloads/` directory for global singleton scripts
- All directories should contain a `.gdkeep` or `.gitkeep` file to preserve empty folders in version control

**Project configured for iPad portrait orientation**

- Set `display/window/size/viewport_width` to 1536 (iPad resolution in portrait)
- Set `display/window/size/viewport_height` to 2048 (iPad resolution in portrait)
- Set `display/window/handheld/orientation` to portrait
- Configure stretch mode to `canvas_items` for proper 2D scaling
- Configure stretch aspect to `keep` to maintain aspect ratio on different devices

**Input actions mapped for touch and keyboard**

- Create `move_up` action with keyboard W/Up Arrow and touch gesture support
- Create `move_down` action with keyboard S/Down Arrow and touch gesture support
- Create `move_left` action with keyboard A/Left Arrow and touch gesture support
- Create `move_right` action with keyboard D/Right Arrow and touch gesture support
- Create `shoot` action with keyboard Space and touch tap support
- All actions should be defined in project.godot InputMap section

**2D physics enabled for game mechanics**

- Ensure 2D physics engine is enabled in project settings
- Default physics settings are appropriate for CharacterBody2D and Area2D nodes
- No custom physics configuration needed for initial setup

**Web export template installed**

- Download Godot 4.3 HTML5/Web export template via Editor > Manage Export Templates
- Template installation only; full export configuration deferred to roadmap item 15
- Verify template appears in export template manager

**Minimal placeholder scene created for verification**

- Create a simple 2D scene named `main.tscn` in `scenes/` directory
- Scene should contain only a Node2D root and a Label showing "Solar System Showdown"
- Set this scene as the main scene in project settings
- Scene must run without errors when launched (F5 in editor)
- Keep scene minimal to avoid cleanup work later

**Version control configured with proper .gitignore**

- Add `.godot/` directory (Godot 4.x cache and imports)
- Add `.import/` directory (legacy import cache)
- Add `export.cfg` and `export_credentials.cfg` (export settings with potential secrets)
- Add `*.translation` files (compiled translations)
- Add `*.tmp` files (temporary files)
- Add `.mono/` and `mono_crash.*.json` (C# runtime files if ever used)
- Add standard OS files: `.DS_Store`, `Thumbs.db`

## Visual Design

No visual assets provided for this setup specification.

## Leverage Existing Knowledge

**Code, component, or existing logic found**

No existing Godot project code in this repository. This is the foundational setup.

**Git Commit found**

Initial project definition commit:

- [0c08f3f:Define product vision, roadmap, and tech stack] - Establishes technical requirements
  - Tech stack specifies Godot 4.3 with GDScript as primary language
  - Confirms iOS/iPad as primary platform with Web as secondary
  - Documents CharacterBody2D and Area2D as core physics nodes
  - Specifies PNG/SVG for sprites, OGG for music, WAV for SFX
  - Confirms autoloads pattern for global game state

**External Reference: GitHub Godot .gitignore**

- [github.com/github/gitignore/Godot.gitignore] - Standard Godot ignore patterns
  - `.godot/` is the key directory for Godot 4.x (replaces `.import/` from 3.x)
  - Include both `.godot/` and `.import/` for compatibility
  - Export configs should be ignored as they may contain credentials
  - Mono-specific patterns included for future-proofing if C# is ever used

## Out of Scope

- Godot 4.3 editor installation (already complete per requirements)
- Full Web export configuration and testing (deferred to roadmap item 15)
- iOS export template and configuration (deferred to roadmap item 16)
- Apple Developer account setup (explicitly deferred)
- Any game assets, sprites, or audio files
- Any gameplay code or mechanics
- Complex editor preferences or custom editor plugins
- Touch control UI elements (virtual joystick, buttons) - these come with Player Character
- Scene inheritance or base class setup - comes with specific features
- Autoload script implementations - only create the folder structure
