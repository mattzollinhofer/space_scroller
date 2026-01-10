# Specification: High Score Initials

## Goal

Add classic arcade-style 3-letter initials entry to the high score system, allowing players to personalize their top 10 scores with initials displayed on game over, level complete, and a dedicated high scores screen.

## User Stories

- As a player, I want to enter my initials when I achieve a top 10 score so that I can see my name alongside my achievement
- As a player, I want to view a dedicated high scores screen from the main menu so that I can see all top 10 scores with their initials

## Specific Requirements

**Player enters initials when qualifying for top 10**

- Show initials entry UI only when current score qualifies for top 10 (use existing `qualifies_for_top_10()` method)
- Display three letter slots, each cycling A-Z independently
- Default all three slots to "A" (resulting in "AAA" if confirmed immediately)
- Use arcade-style navigation: up/down to cycle letters, left/right to move between slots
- Require confirmation to submit - no skip option
- Play button click SFX on letter changes and confirmation (use existing `_play_sfx()` pattern)

**Arcade-style letter cycling input**

- Support keyboard: Up/W to cycle up, Down/S to cycle down, Left/A and Right/D to move slots, Enter/Space to confirm
- Support touch: Up/Down arrow buttons per slot, tap-to-select focused slot, OK button to confirm
- Cycle wraps: A -> Z when going up from A, Z -> A when going down from Z
- Only uppercase A-Z (26 characters total), no numbers or special characters
- Visual feedback showing which slot is currently active/focused

**Display initials on game over screen**

- Show player's initials alongside their score after entry
- Update the existing high score label to include initials (e.g., "HIGH SCORE: MJK - 12,500")
- Continue showing "NEW HIGH SCORE!" indicator when applicable

**Display initials on level complete screen**

- Same display pattern as game over screen
- Show initials with score after player enters them
- Initials entry appears before showing Next Level/Main Menu buttons

**Dedicated high scores screen from main menu**

- Enable the existing disabled "High Scores" button in main menu
- Navigate to a new `high_scores_screen.tscn` scene
- Display ranked list (1-10) with initials and score only
- Use consistent UI styling: gold title, white/gold text, dark space background
- Include Back button to return to main menu

**Persist initials with high score data**

- Extend existing ConfigFile storage to include "initials" field per entry
- Update `_save_to_file()` to write `initials_%d` keys alongside `score_%d` and `date_%d`
- Update `load_high_scores()` to read initials, defaulting to "AAA" for legacy entries
- Extend `save_high_score()` to accept initials parameter or store pending initials

## Visual Design

No visual mockups were provided. Follow existing UI patterns from game over screen, level complete screen, and level select screen for styling.

## Leverage Existing Knowledge

**Code, component, or existing logic found**

Score persistence and high score management

- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:113-145] - `save_high_score()` adds entry to list and saves to ConfigFile
  - Entry dictionary currently has "score" and "date" keys - extend with "initials"
  - Use same pattern: append entry, sort, trim to MAX_HIGH_SCORES, save
  - Check `qualifies_for_top_10()` to determine if initials entry should show
  - Emit `new_high_score` signal after save for UI feedback

- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:189-207] - `_save_to_file()` ConfigFile persistence pattern
  - Add `config.set_value("high_scores", "initials_%d" % i, entry["initials"])` pattern
  - Follows existing section/key naming convention

- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:210-247] - `load_high_scores()` reads from ConfigFile
  - Add `initials` loading with default "AAA" for backwards compatibility
  - Load pattern: `config.get_value("high_scores", "initials_%d" % i, "AAA")`

Game over screen integration point

- [@/Users/matt/dev/space_scroller/scripts/game_over_screen.gd:26-32] - `show_game_over()` main entry point
  - Insert initials entry check before updating score display
  - If qualifies for top 10, show initials entry UI first, then continue with display updates

- [@/Users/matt/dev/space_scroller/scripts/game_over_screen.gd:84-106] - `_update_high_score_display()` saves score
  - Modify to pass initials to `save_high_score()` after initials entry
  - Update high score label format to include initials

- [@/Users/matt/dev/space_scroller/scenes/ui/game_over_screen.tscn:1-67] - CanvasLayer UI structure
  - Uses CenterContainer/VBoxContainer layout pattern
  - layer = 10 for overlay positioning
  - Consistent button styling: 400x80 minimum size, font size 48

Level complete screen integration point

- [@/Users/matt/dev/space_scroller/scripts/ui/level_complete_screen.gd:47-55] - `show_level_complete()` entry point
  - Same pattern as game over: check qualification, show initials entry, then continue
  - Must complete initials entry before showing Next Level/Main Menu buttons

- [@/Users/matt/dev/space_scroller/scenes/ui/level_complete_screen.tscn:1-72] - Same UI structure as game over
  - Reuse identical styling for consistency

Main menu high scores button

- [@/Users/matt/dev/space_scroller/scripts/ui/main_menu.gd:51-54] - Placeholder `_on_high_scores_button_pressed()`
  - Replace pass with transition to high scores screen scene
  - Use same TransitionManager pattern as other buttons

- [@/Users/matt/dev/space_scroller/scenes/ui/main_menu.tscn:77-85] - Disabled HighScoresButton
  - Remove `disabled = true` property
  - Update font_color from gray to white to match other buttons

Menu screen patterns for high scores screen

- [@/Users/matt/dev/space_scroller/scenes/ui/level_select.tscn:1-121] - Full menu screen structure
  - BackgroundColor (dark purple/blue), MenuBackground instance, CenterContainer/VBoxContainer
  - Title label with gold color, font_size 96
  - Back button at bottom with 300x80 size, white font

- [@/Users/matt/dev/space_scroller/scripts/ui/level_select.gd:94-101] - Back button navigation pattern
  - Use TransitionManager for scene transition to main menu
  - Fallback to `get_tree().call_deferred("change_scene_to_file", ...)`

Touch input handling patterns

- [@/Users/matt/dev/space_scroller/scripts/ui/virtual_joystick.gd:47-57] - Input event handling for touch and mouse
  - Handle InputEventScreenTouch for tap detection
  - Handle InputEventMouseButton for desktop testing
  - Both platforms use same logical flow

UI highlighting and selection patterns

- [@/Users/matt/dev/space_scroller/scripts/ui/character_selection.gd:98-111] - Visual selection highlighting
  - Gold color for selected: `Color(1, 0.84, 0, 1)`
  - Gray/dimmed for unselected: `Color(0.7, 0.7, 0.7, 1)`
  - Use `add_theme_color_override()` and `modulate` property

Test patterns for high score features

- [@/Users/matt/dev/space_scroller/tests/test_high_score_save_load.gd:1-119] - Integration test structure
  - Clean up test file before and after
  - Use ScoreManager autoload methods directly
  - Verify file creation and data round-trip

- [@/Users/matt/dev/space_scroller/tests/test_high_score_top10.gd:30-39] - Adding multiple test scores pattern
  - Reset score, add points, save - repeat for each test case
  - Verify ordering and list size after all saves

**Git Commit found**

Level unlock persistence implementation

- [20e6d91:Add level unlock persistence and Level 2/3 locked buttons] - Pattern for extending ConfigFile storage
  - Shows how to add new data section to existing high_scores.cfg
  - Demonstrates reading with defaults for backwards compatibility
  - Pattern for UI updates reflecting persisted state

Level complete screen button additions

- [eac46a6:Add Next Level / Main Menu button to level complete screen] - UI extension pattern
  - Shows how to add conditional buttons to end screen
  - Scene modifications and script signal connections
  - Pattern for showing/hiding buttons based on state

Animated menu background

- [75619b3:Add animated menu background and improve character selection layout] - Menu screen component pattern
  - Reusable MenuBackground component instanced in multiple scenes
  - Scene structure: BackgroundColor, MenuBackground, CenterContainer content
  - GridContainer layout for organized button/item display

Score system completion

- [fd0163a:Complete Score System verification and update roadmap] - Feature verification approach
  - Documents all working slices and test coverage
  - Pattern for verification report structure

## Out of Scope

- Global/online leaderboards (roadmap item #24 - separate feature)
- Date/timestamp display on high score screen (requirement explicitly excludes dates)
- Skip option for initials entry (required entry with AAA default)
- Numbers or special characters in initials (A-Z only)
- Special accessibility features for younger players (6-8 age range)
- Custom fonts or elaborate visual styling beyond existing patterns
- Sound effects for letter cycling beyond existing button click SFX
- Animation or visual effects during initials entry
- Leaderboard filtering or sorting options
- Player profile or account system
