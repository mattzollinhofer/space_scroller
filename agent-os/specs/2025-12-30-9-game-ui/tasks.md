# Task Breakdown: Game UI

## Overview

Total Slices: 7
Each slice delivers incremental user value and is tested end-to-end.

**Feature Goal:** Build a complete menu system with main menu, character selection, pause menu, enhanced game over screen, and HUD elements (score display, level indicator) to transform the game from a direct-launch prototype into a polished playable experience.

---

## Task List

### Slice 1: Player can launch game to main menu and start playing

**What this delivers:** When the game launches, the player sees a main menu with a Play button. Pressing Play starts the gameplay experience, replacing the current direct-launch-to-gameplay behavior.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/game_over_screen.gd:1-24] - CanvasLayer extends with show/hide methods and process_mode pattern
- [@/Users/matt/dev/space_scroller/scenes/ui/game_over_screen.tscn:1-26] - Scene structure with CenterContainer > VBoxContainer > Label
- [@/Users/matt/dev/space_scroller/project.godot:14] - run/main_scene setting to change
- [commit:238fc57] - Overlay screen creation pattern (LevelCompleteScreen)

#### Tasks

- [ ] 1.1 Write integration test: game launches to main menu, Play button visible, clicking Play loads gameplay
- [ ] 1.2 Run test, verify expected failure
- [ ] 1.3 Make smallest change possible to progress
- [ ] 1.4 Run test, observe failure or success
- [ ] 1.5 Document result and update task list
- [ ] 1.6 Repeat 1.3-1.5 as necessary (expected iterations):
  - [ ] Create main_menu.gd script extending Control (full scene, not overlay)
  - [ ] Create main_menu.tscn scene with CenterContainer > VBoxContainer layout
  - [ ] Add game title Label with large font (128pt) and space-themed color
  - [ ] Add Play button using Button node with space-themed styling
  - [ ] Add High Scores button (disabled placeholder, disabled = true)
  - [ ] Add Character Selection button (functional in Slice 3)
  - [ ] Connect Play button pressed signal to _on_play_pressed()
  - [ ] Implement _on_play_pressed() to change_scene_to_file("res://scenes/main.tscn")
  - [ ] Update project.godot run/main_scene to "res://scenes/ui/main_menu.tscn"
  - [ ] Add semi-transparent space background or solid dark color
- [ ] 1.7 Refactor if needed (keep tests green)
- [ ] 1.8 Commit working slice

**Acceptance Criteria:**
- Game launches to main menu (not directly to gameplay)
- Title "Solar System Showdown" displayed prominently
- Play button visible and responsive to touch/click
- High Scores button visible but disabled (grayed out)
- Character Selection button visible
- Pressing Play loads the gameplay scene
- Space-themed visual styling consistent with game

---

### Slice 2: Player sees current score during gameplay

**What this delivers:** During gameplay, the player can see their current score in the top-right corner of the screen, updating as they progress.

**Dependencies:** Slice 1 (main menu exists to navigate from)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/health_display.gd:19-25] - CanvasLayer HUD with process_mode ALWAYS
- [@/Users/matt/dev/space_scroller/scenes/ui/health_display.tscn:10-16] - Container positioned at fixed offset from corner
- [@/Users/matt/dev/space_scroller/scenes/main.tscn:102-104] - Adding HUD components to main scene
- [commit:66d8b97] - HUD element creation pattern (HealthDisplay)

#### Tasks

- [ ] 2.1 Write integration test: score display shows "Score: 0" at start, value updates when score changes
- [ ] 2.2 Run test, verify expected failure
- [ ] 2.3 Make smallest change possible to progress
- [ ] 2.4 Run test, observe failure or success
- [ ] 2.5 Document result and update task list
- [ ] 2.6 Repeat 2.3-2.5 as necessary (expected iterations):
  - [ ] Create score_display.gd script extending CanvasLayer
  - [ ] Create score_display.tscn scene at layer 10
  - [ ] Add Container with anchors_preset for top-right positioning
  - [ ] Add Label child with "Score: 0" default text
  - [ ] Set theme_override_font_sizes/font_size = 48 for readability
  - [ ] Set process_mode = Node.PROCESS_MODE_ALWAYS
  - [ ] Add _current_score variable and update_score(value: int) method
  - [ ] Add score_changed signal (for future Score System integration)
  - [ ] For now, implement simple internal score tracking
  - [ ] Add add_score(points: int) method for incrementing score
  - [ ] Add get_score() method for retrieval
  - [ ] Add ScoreDisplay instance to main.tscn
  - [ ] Position to avoid overlap with fire button zone (top-right, left of x=1448)
- [ ] 2.7 Refactor if needed (keep tests green)
- [ ] 2.8 Run all slice tests to verify no regressions
- [ ] 2.9 Commit working slice

**Acceptance Criteria:**
- Score display visible in top-right during gameplay
- Shows "Score: 0" format with label
- Score updates when add_score() is called
- Does not overlap with fire button zone or health display
- Readable font size on iPad resolution
- Previous slice functionality still works

---

### Slice 3: Player can select character from main menu

**What this delivers:** From the main menu, the player can open character selection, choose from 3 characters, and see their selection reflected when starting gameplay.

**Dependencies:** Slice 1 (main menu exists)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scenes/ui/game_over_screen.tscn:1-26] - Overlay screen scene structure
- [@/Users/matt/dev/space_scroller/scenes/player.tscn:14-16] - Player Sprite2D with texture reference
- [@/Users/matt/dev/space_scroller/project.godot:14] - Autoload configuration location

#### Tasks

- [ ] 3.1 Write integration test: open character selection, select a character, start game, player uses selected character sprite
- [ ] 3.2 Run test, verify expected failure
- [ ] 3.3 Make smallest change possible to progress
- [ ] 3.4 Run test, observe failure or success
- [ ] 3.5 Document result and update task list
- [ ] 3.6 Repeat 3.3-3.5 as necessary (expected iterations):
  - [ ] Create GameState autoload script (scripts/autoloads/game_state.gd)
  - [ ] Add selected_character variable (enum or string identifier)
  - [ ] Default to "blue_blaster" on launch
  - [ ] Add get_selected_character() and set_selected_character() methods
  - [ ] Register GameState as autoload in project.godot [autoload] section
  - [ ] Create placeholder character sprites (2 new, can be color variations initially)
    - [ ] Space Dragon (Green) - green tinted version
    - [ ] Cosmic Cat (Purple) - purple tinted version
  - [ ] Create character_selection.gd script extending Control
  - [ ] Create character_selection.tscn scene with horizontal layout (1x3 row)
  - [ ] Add character buttons with preview sprites
  - [ ] Add "Back" button to return to main menu
  - [ ] Highlight currently selected character
  - [ ] On character button press, update GameState.selected_character
  - [ ] Connect main menu Character Selection button to show character selection
  - [ ] Modify player.gd _ready() to load texture based on GameState.selected_character
  - [ ] Add character texture mapping dictionary in player.gd or separate resource
- [ ] 3.7 Refactor if needed (keep tests green)
- [ ] 3.8 Run all slice tests to verify no regressions
- [ ] 3.9 Commit working slice

**Acceptance Criteria:**
- Character Selection button on main menu works
- 3 characters displayed in selection screen (Blue Blaster + 2 new)
- Current selection visually highlighted
- Selection persists while navigating back to main menu
- Starting game loads player with selected character sprite
- Back button returns to main menu
- Selection resets to Blue Blaster on game relaunch

---

### Slice 4: Player can pause gameplay and return to menu

**What this delivers:** During gameplay, the player can tap a pause button or press P/ESC to pause the game, then choose to resume or quit to the main menu.

**Dependencies:** Slice 1 (main menu exists to quit to)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/game_over_screen.gd:1-24] - Pause/unpause game tree pattern
- [@/Users/matt/dev/space_scroller/scenes/ui/game_over_screen.tscn:1-26] - Overlay CanvasLayer at layer 10
- [@/Users/matt/dev/space_scroller/project.godot:24-54] - InputMap action format
- [@/Users/matt/dev/space_scroller/scenes/ui/fire_button.tscn:6-16] - Touch control positioning (avoid overlap)

#### Tasks

- [ ] 4.1 Write integration test: press pause button, game pauses, press resume, game continues; press quit, returns to menu
- [ ] 4.2 Run test, verify expected failure
- [ ] 4.3 Make smallest change possible to progress
- [ ] 4.4 Run test, observe failure or success
- [ ] 4.5 Document result and update task list
- [ ] 4.6 Repeat 4.3-4.5 as necessary (expected iterations):
  - [ ] Add "pause" action to project.godot InputMap with P key and ESC key
  - [ ] Create pause_menu.gd script extending CanvasLayer
  - [ ] Create pause_menu.tscn scene at layer 10
  - [ ] Add semi-transparent background ColorRect (full screen, dark overlay)
  - [ ] Add CenterContainer > VBoxContainer layout for menu
  - [ ] Add "PAUSED" title Label (large font)
  - [ ] Add Resume button
  - [ ] Add Quit to Menu button
  - [ ] Set process_mode = Node.PROCESS_MODE_ALWAYS
  - [ ] Start hidden (visible = false in _ready)
  - [ ] Implement show_pause_menu() - set visible = true, get_tree().paused = true
  - [ ] Implement hide_pause_menu() - set visible = false, get_tree().paused = false
  - [ ] Connect Resume button to hide_pause_menu()
  - [ ] Connect Quit to Menu button to change_scene and unpause
  - [ ] Add PauseMenu instance to main.tscn
  - [ ] Create pause_button.gd script extending Control
  - [ ] Create pause_button.tscn scene (small button, top-right corner)
  - [ ] Position: anchor top-right, offset to avoid fire button zone (y < 150)
  - [ ] Add pause icon or "II" text
  - [ ] Connect pause button press to toggle pause menu
  - [ ] Add _unhandled_input() in pause_menu.gd for P/ESC toggle
  - [ ] Add PauseButton instance to main.tscn UILayer
- [ ] 4.7 Refactor if needed (keep tests green)
- [ ] 4.8 Run all slice tests to verify no regressions
- [ ] 4.9 Commit working slice

**Acceptance Criteria:**
- Pause button visible in top-right during gameplay (not overlapping controls)
- Tapping pause button shows pause menu and freezes gameplay
- P key toggles pause menu
- ESC key toggles pause menu
- Resume button hides menu and continues gameplay
- Quit to Menu button returns to main menu
- Game tree properly paused/unpaused
- Previous slice functionality still works

---

### Slice 5: Player sees score and navigation on game over

**What this delivers:** When the player loses all lives, the game over screen shows their final score, a placeholder for high scores, and a button to return to the main menu.

**Dependencies:** Slices 1-2 (main menu and score display exist)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/game_over_screen.gd:1-24] - Existing game over screen to enhance
- [@/Users/matt/dev/space_scroller/scenes/ui/game_over_screen.tscn:1-26] - Current scene structure

#### Tasks

- [ ] 5.1 Write integration test: player dies, game over shows score value, main menu button returns to menu
- [ ] 5.2 Run test, verify expected failure
- [ ] 5.3 Make smallest change possible to progress
- [ ] 5.4 Run test, observe failure or success
- [ ] 5.5 Document result and update task list
- [ ] 5.6 Repeat 5.3-5.5 as necessary (expected iterations):
  - [ ] Modify game_over_screen.gd to accept and display score
  - [ ] Add set_score(value: int) method
  - [ ] Add Score Label node to game_over_screen.tscn VBoxContainer
  - [ ] Format as "Score: X" with readable font size (64-72pt)
  - [ ] Add "High Scores" placeholder Label (grayed out text, not button)
  - [ ] Add Main Menu Button node to VBoxContainer
  - [ ] Connect Main Menu button to _on_main_menu_pressed()
  - [ ] Implement _on_main_menu_pressed() to unpause and change scene to main menu
  - [ ] Modify show_game_over() to accept score parameter
  - [ ] Update LevelManager or caller to pass score when showing game over
  - [ ] Get score from ScoreDisplay or GameState
- [ ] 5.7 Refactor if needed (keep tests green)
- [ ] 5.8 Run all slice tests to verify no regressions
- [ ] 5.9 Commit working slice

**Acceptance Criteria:**
- Game over screen displays final score
- Score format matches HUD ("Score: X")
- High scores placeholder visible (awaiting Score System feature)
- Main Menu button visible and functional
- Pressing Main Menu returns to main menu
- Game tree properly unpaused when leaving
- Previous slice functionality still works

---

### Slice 6: Player sees current level indicator

**What this delivers:** During gameplay, the player can see the current level number displayed near the progress bar, showing their progression through the game.

**Dependencies:** Slice 2 (HUD patterns established)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scenes/ui/progress_bar.tscn:9-44] - Progress bar structure to enhance
- [@/Users/matt/dev/space_scroller/scripts/ui/progress_bar.gd] - Progress bar script (if exists)
- [commit:2422989] - Progress bar creation pattern

#### Tasks

- [ ] 6.1 Write integration test: level indicator shows "Level 1" near progress bar, visible during gameplay
- [ ] 6.2 Run test, verify expected failure
- [ ] 6.3 Make smallest change possible to progress
- [ ] 6.4 Run test, observe failure or success
- [ ] 6.5 Document result and update task list
- [ ] 6.6 Repeat 6.3-6.5 as necessary (expected iterations):
  - [ ] Add Level Label node to progress_bar.tscn Container
  - [ ] Position below or beside the progress bar
  - [ ] Set font size (36-48pt) for readability without dominating
  - [ ] Default text "Level 1"
  - [ ] Add @onready reference in progress_bar.gd
  - [ ] Add set_level(level: int) method
  - [ ] Update label text in set_level()
  - [ ] Connect to LevelManager level_changed signal (if exists) or add one
  - [ ] Alternatively, LevelManager calls progress_bar.set_level() directly
- [ ] 6.7 Refactor if needed (keep tests green)
- [ ] 6.8 Run all slice tests to verify no regressions
- [ ] 6.9 Commit working slice

**Acceptance Criteria:**
- Level indicator visible near progress bar during gameplay
- Shows "Level 1" format
- Updates when level changes (future-proofed for multi-level)
- Readable but not overly prominent
- Does not overlap with other HUD elements
- Previous slice functionality still works

---

### Slice 7: Smooth transitions between screens

**What this delivers:** Navigation between screens (menu to game, game to pause, game to game over) feels polished with fade-in/fade-out transitions.

**Dependencies:** Slices 1, 4, 5 (all screens exist to transition between)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/health_display.gd:70-82] - Tween animation pattern for UI effects

#### Tasks

- [ ] 7.1 Write integration test: transition from main menu to game has visible fade effect
- [ ] 7.2 Run test, verify expected failure
- [ ] 7.3 Make smallest change possible to progress
- [ ] 7.4 Run test, observe failure or success
- [ ] 7.5 Document result and update task list
- [ ] 7.6 Repeat 7.3-7.5 as necessary (expected iterations):
  - [ ] Create transition_manager.gd autoload script
  - [ ] Add full-screen ColorRect for fade overlay (black, starts transparent)
  - [ ] Implement fade_out() method using Tween (alpha 0 to 1, 0.3s)
  - [ ] Implement fade_in() method using Tween (alpha 1 to 0, 0.3s)
  - [ ] Implement transition_to_scene(scene_path: String) method
    - [ ] Call fade_out()
    - [ ] Wait for fade complete
    - [ ] Change scene
    - [ ] Call fade_in()
  - [ ] Register TransitionManager as autoload in project.godot
  - [ ] Update main_menu.gd Play button to use TransitionManager
  - [ ] Update pause_menu.gd Quit to Menu to use TransitionManager
  - [ ] Update game_over_screen.gd Main Menu button to use TransitionManager
  - [ ] Add fade-in when pause menu shows (optional, lighter transition)
  - [ ] Add fade-in when game over shows (optional, lighter transition)
  - [ ] If transitions prove complex, document and fall back to instant (acceptable per spec)
- [ ] 7.7 Refactor if needed (keep tests green)
- [ ] 7.8 Run all feature tests to verify everything works together
- [ ] 7.9 Final commit

**Acceptance Criteria:**
- Main menu to gameplay transition has fade effect
- Quit to menu has fade effect
- Game over to menu has fade effect
- Transitions are smooth (0.3s duration, no jarring cuts)
- If implementation is too complex, instant transitions acceptable as fallback
- All previous slice functionality still works
- No visual glitches during transitions

---

## Summary of Deliverables

After all slices are complete:

1. **main_menu.tscn / main_menu.gd** - Entry point scene with Play, High Scores placeholder, Character Selection buttons
2. **character_selection.tscn / character_selection.gd** - 3-character selection screen
3. **game_state.gd** - Autoload for session state (selected character)
4. **pause_menu.tscn / pause_menu.gd** - Pause overlay with Resume and Quit to Menu
5. **pause_button.tscn / pause_button.gd** - In-game pause button trigger
6. **score_display.tscn / score_display.gd** - HUD score counter
7. **transition_manager.gd** - Autoload for smooth screen transitions (optional)
8. **2 new character sprites** - Space Dragon and Cosmic Cat (placeholder acceptable)
9. **game_over_screen.tscn modifications** - Score display, high scores placeholder, Main Menu button
10. **progress_bar.tscn modifications** - Level indicator label
11. **main.tscn modifications** - Add PauseMenu, PauseButton, ScoreDisplay
12. **project.godot modifications** - Main scene change, pause InputMap, autoloads

## Technical Notes

- **Game Resolution:** 2048x1536 pixels (iPad optimized)
- **UI Layer:** CanvasLayer at layer 10 for all overlays
- **Pause Input:** "pause" action with P key (physical_keycode 80) and ESC key (physical_keycode 4194305)
- **Font Sizes:** 128pt for titles, 48-64pt for HUD elements, 36-48pt for secondary labels
- **Fire Button Zone:** Right 600px of screen (x > 1448) - avoid placing UI here
- **Joystick Zone:** Bottom-left 200x200px area - avoid placing UI here
- **Health Display:** Top-left corner (20, 10) - score display goes top-right
- **Progress Bar:** Top-center - level indicator goes nearby
- **Process Mode:** All overlay UI uses PROCESS_MODE_ALWAYS to work when game is paused
- **Scene Transition:** get_tree().change_scene_to_file() for navigation
- **Character Sprites:** Store in assets/sprites/characters/ folder
- **Autoloads:** Register in project.godot [autoload] section
