# Specification: Game UI

## Goal

Build a complete menu system with main menu, character selection, pause menu, enhanced game over screen, and HUD elements (score display, level indicator) to transform the game from a direct-launch prototype into a polished playable experience.

## User Stories

- As a player, I want to select my spaceship character before starting so that I can personalize my experience
- As a player, I want to pause the game and return to the main menu so that I can take breaks or restart

## Specific Requirements

**Player can launch game to main menu and start playing**

- Create MainMenu scene as new entry point (replaces main.tscn as run/main_scene)
- Play button transitions to gameplay (loads main.tscn)
- High Scores placeholder button (disabled, awaits Score System feature)
- Character Selection button opens character selection screen
- Space-themed visual styling with large readable fonts

**Player can select from 6 cosmetic characters**

- Character Selection screen shows 6 selectable characters in grid layout
- Characters: Blue Blaster (default), Rocket Red, Space Dragon (Green), Cosmic Cat (Purple), Star Cruiser (Yellow), one additional slot
- All characters cosmetic only (same gameplay stats)
- All characters unlocked from start
- Create GameState autoload to store selected character for current session
- Selection resets to Blue Blaster on each game launch
- Player scene loads appropriate sprite based on GameState selection
- 5 new character sprites needed (matching existing cute space art style)

**Player can pause gameplay with button or keyboard**

- Pause button in top-right corner (clear of joystick and fire button areas)
- Add "pause" action to InputMap for P key and ESC key
- PauseMenu as CanvasLayer (layer 10) with Resume and Quit to Menu buttons
- Resume unpauses game and hides menu
- Quit to Menu returns to MainMenu scene
- Pauses game tree when shown (process_mode = PROCESS_MODE_ALWAYS pattern)

**Game Over screen shows score and navigation**

- Enhance existing GameOverScreen scene
- Display final score with "Score: X" label format
- High Scores placeholder (visual only, awaits Score System feature)
- Main Menu button returns to MainMenu scene
- Keep existing pause-on-show behavior

**HUD displays current score and level**

- Score display in top-right area showing "Score: 0" format
- Create ScoreDisplay as CanvasLayer (layer 10) with Label
- Connect to future Score System signal (or track internally for now)
- Level indicator showing "Level 1" near progress bar
- Update existing ProgressBar scene to include level label

**Transitions feel smooth between screens**

- Implement fade-in/fade-out transitions using Tween on CanvasModulate or screen ColorRect
- Apply to: MainMenu->Game, Game->PauseMenu, Game->GameOver, Game->MainMenu
- Fallback to instant transitions if fade implementation proves complex

## Visual Design

No visual mockups provided. Reference existing UI patterns:

- Kid-friendly colorful space theme
- Large readable fonts (128pt for titles, smaller for labels)
- CenterContainer + VBoxContainer layout for overlay menus
- CanvasLayer at layer 10 for all UI overlays
- Semi-transparent backgrounds for pause/overlay screens
- Heart icons positioned top-left (existing)
- Progress bar positioned top-center (existing)
- Fire button zone on right side, joystick bottom-left (avoid overlap)

## Leverage Existing Knowledge

**Overlay screen pattern (pause-aware CanvasLayer)**

GameOverScreen and LevelCompleteScreen patterns
- [@scripts/game_over_screen.gd:1-24] - CanvasLayer extends with show/hide methods that toggle visibility and pause game tree
  - Start hidden with visible = false in _ready()
  - Set process_mode = Node.PROCESS_MODE_ALWAYS to respond while game paused
  - Show method sets visible = true and get_tree().paused = true
  - Hide method reverses both
  - Reuse for PauseMenu and MainMenu overlays

**Scene structure for overlay UI**

- [@scenes/ui/game_over_screen.tscn:1-26] - CanvasLayer at layer 10 with CenterContainer > VBoxContainer > Label structure
  - anchors_preset = 15 for full-screen CenterContainer
  - anchor_right = 1.0, anchor_bottom = 1.0 for full coverage
  - theme_override_colors/font_color for colored text
  - theme_override_font_sizes/font_size = 128 for large titles
  - Reuse this exact layout pattern for MainMenu, PauseMenu, CharacterSelection

**HUD element pattern (always-visible CanvasLayer)**

- [@scripts/ui/health_display.gd:19-25] - CanvasLayer for HUD with signal connection pattern
  - visible = true by default (always shown during gameplay)
  - process_mode = Node.PROCESS_MODE_ALWAYS
  - _connect_to_player() finds nodes via get_tree().root.get_node_or_null() pattern
  - Use same pattern for ScoreDisplay connecting to score signals

**HUD positioning and layout**

- [@scenes/ui/health_display.tscn:10-16] - Container positioned at fixed offset from corner
  - anchors_preset = 0 (top-left anchor)
  - offset_left/top for margin from screen edge
  - Use similar approach for ScoreDisplay at top-right (anchors_preset = 1)

**Progress bar with label integration**

- [@scenes/ui/progress_bar.tscn:9-44] - Progress bar structure at top-center
  - anchors_preset = 10 for top-center horizontal
  - Could add level Label node as sibling to Container
  - Background and Fill ColorRect pattern for bars

**Touch control positioning reference**

- [@scenes/ui/fire_button.tscn:6-16] - Fire button anchored to right side
  - anchor_left/right = 1.0, offset_left = -600 covers right 600px
  - Pause button must not overlap this zone

**Virtual joystick positioning reference**

- [@scenes/ui/virtual_joystick.tscn:7-13] - Joystick anchored to bottom-left
  - anchor_top/bottom = 1.0 (bottom edge)
  - offset 50-250px from edges
  - Pause button must not overlap this zone

**Main scene structure for scene management**

- [@scenes/main.tscn:29-115] - Full main scene structure showing node hierarchy
  - Player node with path for reference
  - UI components as direct children of Main
  - UILayer CanvasLayer contains touch controls
  - GameOverScreen and LevelCompleteScreen as siblings

**Player sprite loading reference**

- [@scenes/player.tscn:14-16] - Player Sprite2D with texture reference
  - scale = Vector2(3, 3) for 3x sprite scaling
  - texture = ExtResource for sprite path
  - Character system needs to swap this texture based on selection

**Project configuration for main scene**

- [@project.godot:14] - run/main_scene setting
  - Currently "res://scenes/main.tscn"
  - Must change to new MainMenu scene path

**Input action reference**

- [@project.godot:24-54] - InputMap action definitions
  - Shows format for adding new "pause" action with P and ESC keys
  - Physical keycode format for key bindings

**Integration test pattern**

- [@tests/test_progress_bar.gd:1-97] - Complete test structure pattern
  - extends Node2D with _test_passed/_test_failed tracking
  - _ready() loads main scene and finds nodes
  - _process() checks conditions with timeout
  - _pass() and _fail() functions with exit codes
  - Use this pattern for UI integration tests

**Git Commit found**

UI/HUD implementation patterns

- [66d8b97:Show player lives as heart icons] - HUD element creation pattern
  - Created CanvasLayer at layer 10 for overlay
  - Added script with process_mode ALWAYS
  - Connected to player signals for updates
  - Includes animation effects (floating hearts)

- [238fc57:Show "Level Complete" screen] - Overlay screen creation pattern
  - New scene + script pair following GameOverScreen pattern
  - Added to main.tscn as sibling node
  - Connected via LevelManager signals
  - Pauses game tree when visible

- [2422989:Add progress bar] - HUD bar creation with LevelManager
  - Created ProgressBar CanvasLayer with ColorRect fill
  - Script with set_progress/get_progress methods
  - LevelManager updates progress from scroll position
  - Test file validates progress updates

- [c63e4d3:Add touch fire button] - Touch control pattern
  - Control node with _input() handling
  - InputEventScreenTouch and InputEventMouseButton handling
  - is_pressed() method for player to query
  - Anchor positioning to avoid overlap

## Out of Scope

- Actual high score persistence and retrieval (Score System spec)
- Settings/Options menu with volume controls
- How to Play/Tutorial screen
- Character unlock progression system
- Character gameplay stat differences (speed, health, damage)
- Character selection persistence between app launches
- Restart Level option in pause menu
- Sound effects for button presses and menu transitions (Audio Integration spec)
- Multiple levels or level selection
- Animated character previews in selection screen
