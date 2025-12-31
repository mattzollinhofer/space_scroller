# Spec Requirements: Boss Battle

## Initial Description

Create an end-of-level boss with health bar, attack patterns, and victory condition that completes the level.

**Context:** This is roadmap item 7. The boss battle hooks into the `level_completed` signal from the Level Structure feature (item 6) that was just implemented. When the player reaches 100% progress, instead of showing "Level Complete" immediately, the boss should appear.

**Existing Assets:** Boss sprites already exist in the codebase:
- `res://assets/sprites/boss-1.png`
- `res://assets/sprites/boss-2.png`

## Requirements Discussion

### First Round Questions

**Q1:** Should the boss appear from the right side of the screen (standard for side-scrollers) with an entrance animation, or did you have a different entrance in mind?
**Answer:** Yes, from the right. Open to suggestions for entrance animation ("whatever a boss should do").

**Q2:** For attack patterns, I'm thinking 2-3 simple patterns for the first boss: (1) horizontal projectile barrage, (2) vertical sweep attack, (3) charge/rush at player. Does this sound right, or do you have specific attacks in mind?
**Answer:** Yes, the 2-3 simple patterns (horizontal barrage, vertical sweep, charge) sound good.

**Q3:** How many hits should it take to defeat the boss? I'm assuming somewhere in the 10-15 hit range for a satisfying but not frustrating fight.
**Answer:** 13 hits to defeat.

**Q4:** For the boss health bar, should it appear at the top of the screen (common convention), or somewhere else? Should it show numeric health or just a visual bar?
**Answer:** Bottom right - opposite the player health (which is top left). Visual bar implied.

**Q5:** Should the screen stop scrolling during the boss fight (creating a fixed arena), or continue scrolling with the boss moving alongside?
**Answer:** Yes, fixed arena (scrolling stops during boss fight).

**Q6:** For the victory moment when the boss is defeated, should there be a dramatic explosion/death animation before showing "Level Complete"?
**Answer:** Yes to dramatic effect - "dramatic shake effect before pixel exploding." User offered to provide more graphics if needed.

**Q7:** If the player dies during the boss fight, should they respawn at the boss (checkpoint) or restart the entire level?
**Answer:** Respawn at boss entrance (checkpoint at start of boss battle).

**Q8:** Is there anything you specifically want to exclude from this first boss? (e.g., no multiple phases, no invincibility windows, no minion spawning)
**Answer:** "Your call" - keeping it simple for the first boss means: no multiple phases, no invincibility windows, no minion spawning.

### Existing Code to Reference

Based on the completed roadmap items, the following existing features should be referenced:

- **Enemy System (Item 4):** Enemy patterns, collision detection, damage handling in existing enemy scenes
- **Player Combat (Item 5):** Projectile system, hit detection, visual/audio feedback patterns
- **Level Structure (Item 6):** The `level_completed` signal that triggers boss appearance at 100% progress
- **Obstacles System (Item 3):** Collision detection and player damage/death handling patterns

### Follow-up Questions

No follow-up questions needed - all answers were clear and comprehensive.

## Visual Assets

### Files Provided:

No visual assets provided in the planning/visuals folder.

### Existing Game Assets:

Boss sprites already exist in the codebase:
- `res://assets/sprites/boss-1.png` - Boss sprite frame 1
- `res://assets/sprites/boss-2.png` - Boss sprite frame 2

These can be used for the boss animation.

## Requirements Summary

### Functional Requirements

- **Boss Trigger:** Boss appears when player reaches 100% level progress (hooks into existing `level_completed` signal)
- **Boss Entrance:** Boss enters from the right side of screen with appropriate entrance animation
- **Fixed Arena:** Screen scrolling stops during boss fight, creating a contained battle area
- **Boss Health:** 13 hits required to defeat the boss
- **Health Bar UI:** Visual health bar displayed in bottom right corner (opposite player health in top left)
- **Attack Patterns:** 3 distinct attack patterns:
  1. Horizontal projectile barrage
  2. Vertical sweep attack
  3. Charge/rush at player
- **Victory Sequence:** Upon boss defeat: screen shake effect followed by pixel explosion animation, then level completion
- **Defeat Handling:** Player respawns at boss entrance (checkpoint system for boss fight)
- **Boss Sprites:** Use existing boss-1.png and boss-2.png for boss animation

### Scope Boundaries

**In Scope:**
- Single boss encounter for first level
- 3 simple attack patterns (barrage, sweep, charge)
- Visual health bar in bottom right
- Boss entrance animation from right side
- Fixed arena (scrolling stops)
- Victory effects (shake + pixel explosion)
- Checkpoint respawn at boss entrance
- Integration with level_completed signal at 100% progress

**Out of Scope:**
- Multiple boss phases
- Invincibility windows during attacks
- Minion spawning during boss fight
- Complex AI behavior
- Multiple boss variants for this level
- Boss music (deferred to Audio Integration - item 13)

### Technical Considerations

- **Signal Integration:** Must hook into existing `level_completed` signal from Level Structure feature
- **Scene Structure:** Boss should follow existing enemy scene patterns for consistency
- **Collision System:** Reuse existing projectile and enemy collision patterns
- **Animation:** Use AnimatedSprite2D with boss-1.png and boss-2.png
- **UI Layer:** Health bar should use CanvasLayer for HUD (per tech stack)
- **Checkpoint System:** May need to implement or extend save state for boss entrance checkpoint
- **Target Audience:** Kid-friendly (ages 6-12) - boss should be challenging but not frustrating with 13-hit health

### Reusability Opportunities

- Reference existing enemy movement and attack patterns
- Reuse projectile system from player combat for boss projectiles
- Follow existing collision detection patterns from obstacles system
- Model health bar after any existing UI patterns in the game
