# Task Breakdown: High Score Initials

## Overview

Total Slices: 5
Each slice delivers incremental user value and is tested end-to-end.

This feature adds classic arcade-style 3-letter initials entry to the high score system. Players enter initials when qualifying for top 10, and can view scores with initials on game over, level complete, and a dedicated high scores screen.

---

## Task List

### Slice 1: Player can enter initials on game over screen

**What this delivers:** When a player's score qualifies for top 10 and the game ends (game over), they see an arcade-style initials entry UI, enter 3 letters using keyboard, and their initials are saved with their score.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/game_over_screen.gd:26-32] - `show_game_over()` entry point to modify
- [@/Users/matt/dev/space_scroller/scripts/game_over_screen.gd:84-106] - `_update_high_score_display()` saves score, modify to pass initials
- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:104-110] - `qualifies_for_top_10()` check to use
- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:113-145] - `save_high_score()` to extend with initials parameter
- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:189-207] - `_save_to_file()` ConfigFile pattern for initials
- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:210-247] - `load_high_scores()` to load initials with "AAA" default
- [@/Users/matt/dev/space_scroller/scripts/ui/character_selection.gd:98-111] - Visual highlighting pattern (gold for selected)
- [@/Users/matt/dev/space_scroller/scenes/ui/game_over_screen.tscn:1-67] - UI structure to extend
- [@/Users/matt/dev/space_scroller/tests/test_high_score_save_load.gd:1-119] - Test pattern for persistence

#### Tasks

- [x] 1.1 Write integration test: player enters initials "MJK" on game over, verify saved to file
- [x] 1.2 Run test, verify expected failure [save_high_score() expects 0 arguments]
- [x] 1.3 Add initials parameter to ScoreManager.save_high_score() -> test passes for persistence
- [x] 1.4 Write UI component test for InitialsEntry keyboard navigation
- [x] 1.5 Run test, verify expected failure [initials_entry.tscn not found]
- [x] 1.6 Create InitialsEntry component (scripts/ui/initials_entry.gd, scenes/ui/initials_entry.tscn) -> UI test passes
- [x] 1.7 Write full game over integration test with initials entry
- [x] 1.8 Run test, verify expected failure [InitialsEntry not in game_over_screen]
- [x] 1.9 Add InitialsEntry to game_over_screen.tscn and wire up in game_over_screen.gd -> test passes
- [x] 1.10 Run score-related tests, found regression in test_high_score_game_over.tscn
- [x] 1.11 Update test_high_score_game_over.gd to handle new initials flow -> regression fixed
- [x] 1.12 Run all score tests again, found regression in test_high_score_not_new.tscn
- [x] 1.13 Add _update_existing_high_score_display() to show existing high score during initials entry -> all tests pass
- [x] 1.14 Run score-related tests to verify no regressions: all 14 tests pass
- [x] 1.15 Commit working slice

**Red-Green Iterations:**
1. [save_high_score expects 0 args] -> Added initials parameter with "AAA" default, added initials to entry dict, _save_to_file, load_high_scores - Success
2. [initials_entry.tscn not found] -> Created InitialsEntry component with keyboard navigation - Success
3. [InitialsEntry not in game_over_screen] -> Added InitialsEntry to scene and integrated in script - Success
4. [Regression: high score shows 0 during initials entry] -> Added _update_existing_high_score_display() - Success

**Acceptance Criteria:**
- [x] When score qualifies for top 10, initials entry UI appears on game over screen
- [x] Three letter slots display, defaulting to "AAA"
- [x] Keyboard up/down cycles current letter A-Z (wrapping)
- [x] Keyboard left/right moves between slots
- [x] Visual highlighting shows active slot (gold color)
- [x] Enter/Space confirms and saves score with initials
- [x] High score label updates to show "HIGH SCORE: MJK - 12,500" format
- [x] Initials persist to `user://high_scores.cfg` with `initials_%d` keys
- [x] Loading high scores reads initials (defaults "AAA" for legacy entries)
- [x] Button click SFX plays on letter changes and confirmation

---

### Slice 2: Player can enter initials using touch controls

**What this delivers:** Same initials entry as Slice 1, but with touch-friendly controls for iOS/iPad users - up/down buttons per slot and OK confirmation button.

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/virtual_joystick.gd:47-57] - Touch/mouse input handling pattern
- Slice 1's InitialsEntry component (extend for touch support)

#### Tasks

- [x] 2.1 Write integration test: touch-based initials entry saves correctly
- [x] 2.2 Run test, verify expected failure [Missing UpButton0 for slot 0]
- [x] 2.3 Add touch buttons to InitialsEntry scene (UpButton0-2, DownButton0-2, OKButton)
- [x] 2.4 Update InitialsEntry script to connect button signals and handle touch input
- [x] 2.5 Run test, observe success - all touch tests pass
- [x] 2.6 Verify keyboard input still works alongside touch (mixed input test passes)
- [x] 2.7 Refactor if needed (keep tests green) - no refactor needed
- [x] 2.8 Run score-related tests to verify no regressions: all 17 tests pass
- [x] 2.9 Commit working slice

**Red-Green Iterations:**
1. [Missing UpButton0 for slot 0] -> Added UpButton0-2, DownButton0-2, OKButton to scene, updated script to connect signals - Success

**Acceptance Criteria:**
- [x] Up/Down arrow buttons appear for each letter slot
- [x] Tapping up/down cycles the letter in that slot
- [x] Tapping a slot makes it the active slot
- [x] OK button confirms and saves initials
- [x] Touch and keyboard input can be used interchangeably
- [x] Works on both web (HTML5) and iOS platforms

---

### Slice 3: Player can enter initials on level complete screen

**What this delivers:** Same initials entry flow on the level complete screen - when score qualifies for top 10, show initials entry before Next Level/Main Menu buttons appear.

**Dependencies:** Slices 1-2 (reuse InitialsEntry component)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/level_complete_screen.gd:47-55] - `show_level_complete()` entry point
- [@/Users/matt/dev/space_scroller/scripts/ui/level_complete_screen.gd:152-174] - `_update_high_score_display()` to modify
- [@/Users/matt/dev/space_scroller/scenes/ui/level_complete_screen.tscn:1-72] - UI structure to extend

#### Tasks

- [x] 3.1 Write integration test: initials entry on level complete saves score with initials
- [x] 3.2 Run test, verify expected failure [InitialsEntry not found in level_complete_screen]
- [x] 3.3 Add InitialsEntry instance to level_complete_screen.tscn
- [x] 3.4 Run test, verify failure [InitialsEntry should be visible when score qualifies for top 10]
- [x] 3.5 Update level_complete_screen.gd with initials flow (qualifies check, show_entry, hide buttons, _on_initials_confirmed)
- [x] 3.6 Run test, observe success - all initials and button visibility checks pass
- [x] 3.7 Refactor if needed (keep tests green) - no refactor needed
- [x] 3.8 Run score-related and level-related tests, found regression in test_high_score_level_complete.tscn
- [x] 3.9 Update test_high_score_level_complete.gd to handle new initials flow -> regression fixed, 18 tests pass
- [x] 3.10 Commit working slice

**Red-Green Iterations:**
1. [InitialsEntry not found in level_complete_screen] -> Added InitialsEntry instance to scene - Success
2. [InitialsEntry should be visible] -> Updated script with initials flow logic - Success
3. [Regression: test_high_score_level_complete expected immediate score display] -> Updated test to confirm initials first - Success

**Acceptance Criteria:**
- [x] When score qualifies for top 10 on level complete, initials entry appears
- [x] Initials entry appears BEFORE Next Level/Main Menu buttons are shown
- [x] After confirming initials, buttons appear and game continues normally
- [x] High score label shows initials in same format as game over screen
- [x] "NEW HIGH SCORE!" indicator still works correctly
- [x] If score doesn't qualify for top 10, buttons appear immediately (no initials entry)

---

### Slice 4: Player can view high scores screen from main menu

**What this delivers:** Player can click the "High Scores" button in main menu to see a dedicated screen listing all top 10 scores with their initials, ranked 1-10.

**Dependencies:** Slices 1-3 (initials are stored and can be retrieved)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/main_menu.gd:51-54] - Placeholder handler to implement
- [@/Users/matt/dev/space_scroller/scenes/ui/main_menu.tscn:77-85] - Disabled button to enable
- [@/Users/matt/dev/space_scroller/scenes/ui/level_select.tscn:1-121] - Full menu screen structure pattern
- [@/Users/matt/dev/space_scroller/scripts/ui/level_select.gd:94-101] - Back button navigation pattern

#### Tasks

- [x] 4.1 Write integration test: high scores screen displays all 10 entries with initials and scores
- [x] 4.2 Run test, verify expected failure [high_scores_screen.tscn does not exist]
- [x] 4.3 Create high_scores_screen.tscn and high_scores_screen.gd following level_select pattern
- [x] 4.4 Run test, observe success - all 10 entries display correctly with format "1. AAA - 50,000"
- [x] 4.5 Write test for main menu button enabled state and navigation target
- [x] 4.6 Enable High Scores button in main_menu.tscn (remove disabled, set white color)
- [x] 4.7 Wire up navigation in main_menu.gd to transition to high_scores_screen.tscn
- [x] 4.8 Write test for empty slot placeholder format
- [x] 4.9 Run all feature tests (slices 1-4) - all 13 initials/high score tests pass
- [x] 4.10 Update test_main_menu.gd to expect High Scores button enabled (was placeholder check)
- [x] 4.11 Commit working slice

**Red-Green Iterations:**
1. [high_scores_screen.tscn does not exist] -> Created high_scores_screen.tscn/gd with score list - Success
2. [Main menu button disabled] -> Enabled button, set white color, wired navigation - Success
3. [test_main_menu expected disabled button] -> Updated test to expect enabled button - Success

**Acceptance Criteria:**
- [x] "High Scores" button in main menu is enabled (not grayed out)
- [x] Clicking button navigates to new high_scores_screen.tscn
- [x] Screen displays gold title "High Scores"
- [x] Ranked list shows positions 1-10 with format: "1. MJK - 12,500"
- [x] Uses dark space background consistent with other menu screens (MenuBackground component)
- [x] White/gold text styling matches existing UI
- [x] Back button returns to main menu using TransitionManager
- [x] Empty slots show placeholder (e.g., "1. --- - 0" or similar)

---

### Slice 5: Edge cases and polish

**What this delivers:** Production-ready feature with all edge cases handled - legacy score migration, no-qualification flow, and full test coverage.

**Dependencies:** All prior slices

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:210-247] - Backwards compatibility pattern in `load_high_scores()`

#### Tasks

- [ ] 5.1 Write test: legacy high scores without initials load with "AAA" default
- [ ] 5.2 Write test: score that doesn't qualify for top 10 skips initials entry entirely
- [ ] 5.3 Write test: high scores screen shows correct data after multiple sessions
- [ ] 5.4 Verify all edge cases pass
- [ ] 5.5 Run full test suite to verify no regressions: `timeout 180 bash -c 'failed=0; for t in tests/*.tscn; do timeout 10 godot --headless --path . "$t" || ((failed++)); done; echo "Failed: $failed"; exit $failed'`
- [ ] 5.6 Final polish: ensure SFX plays consistently, UI spacing is correct
- [ ] 5.7 Commit working slice

**Acceptance Criteria:**
- Legacy high scores (without initials) display as "AAA" on all screens
- Scores not qualifying for top 10 skip initials entry entirely
- Full test suite passes
- Feature works correctly across web and iOS platforms
- All user workflows from spec work correctly
- Error cases handled gracefully
- Code follows existing patterns

---

## Technical Notes

### InitialsEntry Component Design

Create a reusable `initials_entry.tscn` component that can be instanced in both game_over_screen and level_complete_screen:

**Structure:**
```
InitialsEntry (Control)
  - HBoxContainer
    - Slot1Container (VBoxContainer)
      - UpButton (for touch)
      - LetterLabel
      - DownButton (for touch)
    - Slot2Container (same)
    - Slot3Container (same)
  - OKButton
```

**Signals:**
- `initials_confirmed(initials: String)` - emitted when player confirms

**Public methods:**
- `show_entry()` - makes visible and starts input handling
- `hide_entry()` - hides and stops input handling
- `get_initials() -> String` - returns current 3-letter string

### ScoreManager Changes

Extend `save_high_score()` signature:
```gdscript
func save_high_score(initials: String = "AAA") -> void:
```

Entry dictionary adds `"initials"` key:
```gdscript
var entry: Dictionary = {
    "score": _current_score,
    "date": Time.get_datetime_string_from_system(true),
    "initials": initials
}
```

### File Storage Format

Extends existing `user://high_scores.cfg`:
```ini
[high_scores]
count=3
score_0=12500
date_0=2025-01-10T15:30:00
initials_0=MJK
score_1=10000
date_1=2025-01-09T12:00:00
initials_1=AAA
...
```

### Test Files to Create

- `tests/test_initials_entry.tscn` - InitialsEntry component keyboard input
- `tests/test_initials_touch.tscn` - InitialsEntry touch input
- `tests/test_initials_persistence.tscn` - Initials save/load round-trip
- `tests/test_high_scores_screen.tscn` - High scores screen display
- `tests/test_initials_legacy.tscn` - Legacy score migration
