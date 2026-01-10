# Spec Requirements: High Score Initials

## Initial Description

Add classic arcade-style initials entry to the high score system. When a player achieves a score that qualifies for the top 10, they should be prompted to enter three-letter initials (like "AAA" or "MJK"). These initials should be displayed alongside scores on both the game over/level complete screens and on a dedicated high score screen accessible from the main menu.

### Context from Initialization

- The current high score system stores top 10 scores with timestamps but no player identification
- High scores are displayed on game over and level complete screens
- Main menu has a "High Scores" button that is currently a placeholder
- Target audience is kids ages 6-12

## Requirements Discussion

### First Round Questions

**Q1:** When should the initials prompt appear - only when a player achieves a top 10 score, or any time the game ends?
**Answer:** Top 10 - show initials entry when player qualifies for top 10 leaderboard

**Q2:** What input method should be used for entering initials - classic arcade-style (cycle through letters with up/down) or a tap-to-select letter grid?
**Answer:** Classic arcade-style - cycle through letters (A-Z) with up/down navigation

**Q3:** What characters should be allowed - uppercase A-Z only, or should numbers and special characters be included?
**Answer:** Classic - uppercase A-Z only (26 letters)

**Q4:** Should there be a skip option if the player doesn't want to enter initials, or is entry required?
**Answer:** Default to "AAA" - no skip option, required entry with AAA as default

**Q5:** What format should the high score screen display - just initials and score, or additional info like date achieved?
**Answer:** Simple - just initials and score, no date or extra info

**Q6:** Should the main menu's "High Scores" button be enabled to show a dedicated high scores screen?
**Answer:** Yes - enable the high scores button

**Q7:** Are there any kid-friendly considerations like larger touch targets or simplified input for younger players (ages 6-8)?
**Answer:** No - keep standard, no special accessibility features

**Q8:** Is there anything you explicitly want to exclude from this feature?
**Answer:** Keep it simple - no extras, no global leaderboards (that's roadmap #24)

### Existing Code to Reference

No similar existing features identified for reference. The user did not point to any specific patterns to follow.

### Follow-up Questions

No follow-up questions were needed - all answers were clear and comprehensive.

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

N/A - No visuals were submitted for this specification.

## Requirements Summary

### Functional Requirements

- Prompt player to enter 3-letter initials when their score qualifies for top 10
- Use classic arcade-style input: cycle through A-Z letters with up/down navigation
- Support only uppercase letters A-Z (26 characters)
- Default initials to "AAA" - entry is required (no skip option)
- Display initials alongside scores on game over screen
- Display initials alongside scores on level complete screen
- Enable main menu "High Scores" button to show dedicated high scores screen
- High scores screen displays initials and score only (no dates or extra info)
- Persist initials with existing high score data

### Reusability Opportunities

- Existing high score storage system (scores already persist with timestamps)
- Existing game over and level complete UI screens
- Existing main menu with placeholder "High Scores" button
- Existing UI patterns and styling from current screens

### Scope Boundaries

**In Scope:**

- 3-letter initials entry UI with arcade-style letter cycling
- Integration with existing high score storage
- Display of initials on game over screen
- Display of initials on level complete screen
- Dedicated high scores screen accessible from main menu
- Keyboard/touch input for navigating letters and confirming

**Out of Scope:**

- Global/online leaderboards (roadmap item #24)
- Date/timestamp display on high score screen
- Skip option for initials entry
- Numbers or special characters in initials
- Special accessibility features for younger players
- Any gamification beyond basic initials display

### Technical Considerations

- Uses Godot 4.3 with GDScript
- High scores currently use ConfigFile or JSON storage (user://)
- Must work on both web (HTML5) and iOS platforms
- Input must support both touch (iOS/iPad) and keyboard/mouse (web)
- Target audience is kids ages 6-12 (keep UI simple and clear)
- Existing UI uses Control nodes and CanvasLayer for HUD
