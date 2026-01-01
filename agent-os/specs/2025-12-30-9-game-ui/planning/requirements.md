# Spec Requirements: Game UI

## Initial Description

Game UI - Build main menu, pause menu, game over screen, and HUD showing score, lives, and level progress.

## Requirements Discussion

### First Round Questions

**Q1:** Main Menu Structure - Should the main menu be simple with "Play" and "High Scores", or include additional options like "Settings" or "How to Play"?
**Answer:** Play button and placeholder for High Scores. Also wants Character Selection screen added.

**Q2:** Pause Menu Access - Should pause include Resume, Restart Level, and Quit to Menu, or simpler with just Resume?
**Answer:** Pause, Resume, Quit to Menu. Also wants keyboard support with "P" key to pause.

**Q3:** Game Over Screen Enhancement - Should we add interactive buttons and show player's score?
**Answer:** Placeholder for high scores along with player score. Main Menu button.

**Q4:** HUD Score Display - Should it show just current score, or also high score during gameplay?
**Answer:** Yes, show current score only.

**Q5:** Level/Progress Indicator - Should we add a level number indicator alongside the progress bar?
**Answer:** Yes, add level indicator.

**Q6:** Transition Animations - Should menus have smooth fade transitions or appear instantly?
**Answer:** Smooth fade if easy, instant is acceptable as fallback.

**Q7:** Button Style - Should we use consistent space-themed buttons or simple text buttons initially?
**Answer:** Consistent space theme. User offered to provide graphics if needed.

**Q8:** Exclusions - Anything to exclude from this work?
**Answer:** None specified.

### Existing Code to Reference

**Similar Features Identified:**
- Feature: GameOverScreen - Path: `scenes/ui/game_over_screen.tscn` and `scripts/game_over_screen.gd`
- Feature: LevelCompleteScreen - Path: `scenes/ui/level_complete_screen.tscn` and `scripts/ui/level_complete_screen.gd`
- Feature: HealthDisplay - Path: `scenes/ui/health_display.tscn` and `scripts/ui/health_display.gd`
- Feature: ProgressBar - Path: `scenes/ui/progress_bar.tscn` and `scripts/ui/progress_bar.gd`
- Components to potentially reuse: CanvasLayer pattern at layer 10, CenterContainer layout for overlay screens, VBoxContainer for menu layouts
- Backend logic to reference: LevelManager (`scripts/level_manager.gd`) for game state management, pause functionality pattern

### Follow-up Questions

**Follow-up 1:** Character Differences - Cosmetic vs Gameplay: Should different characters have gameplay differences or be purely cosmetic?
**Answer:** Cosmetic only for now.

**Follow-up 2:** Character Unlock System: Should characters be unlocked through gameplay or all available from start?
**Answer:** All unlocked from the start.

**Follow-up 3:** Character Themes: Do the suggested themes (Rocket Red, Star Cruiser, Cosmic Turtle, Nebula Dolphin, Asteroid Miner) work, or prefer different themes?
**Answer:** User likes the ideas but asked for dragon and cat themed characters too.

**Follow-up 4:** Character Persistence: Should selected character be remembered between play sessions?
**Answer:** Reset to default each launch (no persistence).

**Follow-up 5:** Keyboard Pause: Should ESC also pause/unpause in addition to "P" key?
**Answer:** Yes, both "P" key AND ESC key should pause/unpause.

**Follow-up 6:** Score Display Format: Just number or with label?
**Answer:** Show with "Score: " label (e.g., "Score: 1250").

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

- Existing game uses colorful, kid-friendly space theme
- Current player ship is a cute blue spacecraft/UFO with rounded design
- UI elements use CanvasLayer at layer 10 for overlay
- Large readable fonts (128pt for overlay text like "GAME OVER")
- Simple geometric shapes for controls (circles for joystick)
- Heart icons for lives display
- Progress bar with fill animation

## Requirements Summary

### Functional Requirements

**Main Menu:**
- Play button to start game
- Placeholder for High Scores display (anticipating Score System feature)
- Character Selection button/screen
- Space-themed visual style consistent with game

**Character Selection:**
- 3 playable characters total:
  1. Blue Blaster (Current/Default) - existing blue spacecraft/UFO
  2. Star Dragon (Green) - dragon-shaped ship with wings and tail fin
  3. Celestial Cat (Purple) - cat-faced spacecraft with pointy ears and whiskers
- All characters are cosmetic only (no gameplay differences)
- All characters unlocked from start
- Selection resets to default (Blue Blaster) each game launch
- Selection persists only for current play session

**Pause Menu:**
- Pause button accessible during gameplay (unobtrusive location)
- Keyboard shortcuts: "P" key AND ESC key both toggle pause
- Menu options: Resume, Quit to Menu
- Pauses game tree when shown

**Game Over Screen:**
- Displays player's score from current run
- Placeholder for high scores list (anticipating Score System feature)
- Main Menu button
- Enhances existing GameOverScreen scene

**HUD Elements:**
- Score display in top-right area with label format: "Score: 1250"
- Lives display (already exists as heart icons in top-left)
- Progress bar (already exists at top-center)
- Level indicator showing current level number (e.g., "Level 1")

**Level Complete Screen:**
- Already exists - may need minor updates to integrate with new menu flow

**Transitions:**
- Smooth fade-in/fade-out transitions preferred
- Instant transitions acceptable as fallback if fade is complex

### Reusability Opportunities

- Extend existing `GameOverScreen` pattern for Main Menu and Pause Menu
- Use same CanvasLayer approach (layer 10) for all menu screens
- Follow `health_display.gd` pattern for new HUD elements (score, level indicator)
- Use existing CenterContainer + VBoxContainer layout pattern for menus
- Leverage existing `process_mode = Node.PROCESS_MODE_ALWAYS` pattern for pause-aware UI

### Scope Boundaries

**In Scope:**
- Main Menu scene with Play, High Scores placeholder, Character Selection
- Character Selection screen with 6 character options
- Pause Menu with Resume and Quit to Menu
- Keyboard pause support (P and ESC keys)
- Game Over Screen enhancements (score display, high scores placeholder, Main Menu button)
- HUD score display with label
- HUD level indicator
- Smooth transitions (best effort)
- Space-themed button styling

**Out of Scope:**
- Actual high score persistence (handled by Score System spec)
- Settings/Options menu
- How to Play/Tutorial screen
- Character unlock system
- Character gameplay differences
- Character selection persistence between sessions
- Restart Level option in pause menu
- Sound effects for UI interactions (handled by Audio Integration spec)

### Technical Considerations

- Game resolution: 2048x1536 (iPad optimized)
- Touch-first design with keyboard fallback
- UI must work with existing touch controls (virtual joystick, fire button)
- Pause button placement must not interfere with gameplay controls
- All menu screens use CanvasLayer for proper layering
- Input handling: InputMap actions for pause (new "pause" action needed)
- No autoloads currently exist - may need GameState autoload for character selection
- Character sprites will need to be created (2 new sprites matching existing art style)
- Main scene currently launches directly into gameplay - will need new main menu as entry point
- Project main scene (`run/main_scene`) will need to change from `main.tscn` to new main menu scene
