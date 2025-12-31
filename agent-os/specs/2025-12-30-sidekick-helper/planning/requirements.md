# Spec Requirements: Sidekick Helper

## Initial Description

Add a good alien sidekick that can be unlocked as a bonus, providing assistance to the player (e.g., extra firepower, shield, or collecting pickups). This is roadmap item #10 - a medium-sized feature.

## Requirements Discussion

### First Round Questions

**Q1:** How should the sidekick move - follow the player with a slight offset, or move independently?
**Answer:** Yes, sidekick follows the player with a slight offset and shoots an additional laser at the same time the player shoots.

**Q2:** What is the sidekick's primary ability?
**Answer:** Extra firepower - shoots at the same time the player shoots.

**Q3:** How long does the sidekick last?
**Answer:** Temporary - lasts until the sidekick takes first damage, then it's destroyed.

**Q4:** How is the sidekick unlocked?
**Answer:** This will be a NEW pickup type. The current "ufo_friend" should be renamed/repurposed as a "star power up" that gives extra life.

**Q5:** How does the power-up system change?
**Answer:** Every 5 enemies killed = random power up spawns. Two power-up options:
- Star power up (extra life) - this is what the current ufo_friend becomes
- UFO Friend sidekick (new) - follows player and shoots with them

**Q6:** What should the sidekick look like visually?
**Answer:** Reuse the existing UFO sprite for the sidekick, resize as appropriate.

**Q7:** How does collision work for the sidekick?
**Answer:** Same collision layers as player - sidekick can take damage from enemies.

**Q8:** Any additional features or scope considerations?
**Answer:** Keep it simple - no upgrades, multiple sidekicks, persistence across levels, or customization.

### Existing Code to Reference

**Similar Features Identified:**
- Feature: ufo_friend pickup - Path: `/Users/matt/dev/space_scroller/scenes/pickups/ufo_friend.tscn`
- Feature: ufo_friend script - Path: `/Users/matt/dev/space_scroller/scripts/pickups/ufo_friend.gd`
- Feature: UFO sprite asset - Path: `/Users/matt/dev/space_scroller/assets/sprites/friend-ufo-1.png`
- Components to potentially reuse: Existing UFO sprite, pickup scene structure
- Backend logic to reference: Player shooting mechanics for synchronizing sidekick shots

### Follow-up Questions

No follow-up questions needed - all requirements are clear from the user's comprehensive answers.

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

- Existing `friend-ufo-1.png` sprite will be reused for the sidekick
- May need resizing for appropriate sidekick proportions
- New star sprite may be needed for the star power-up (extra life)

## Requirements Summary

### Functional Requirements

**Power-Up Spawn System:**
- Every 5 enemies killed triggers a random power-up spawn
- Random selection between two power-up types:
  1. Star power-up (grants extra life)
  2. UFO Friend sidekick (provides extra firepower)

**Star Power-Up (Refactored from current ufo_friend):**
- Current ufo_friend pickup becomes "star power-up"
- Grants player one extra life when collected
- Visual: New star sprite (to be created or sourced)

**UFO Friend Sidekick (New):**
- Spawns as a collectible pickup
- When collected, sidekick appears and follows player
- Movement: Follows player with a slight positional offset
- Combat: Shoots an additional laser synchronized with player's shooting
- Health: One hit from enemies destroys the sidekick
- Collision: Uses same collision layers as player (can be damaged by enemies/obstacles)
- Duration: Persists until taking damage, then destroyed
- Limit: Only one sidekick active at a time (implicit from "keep it simple")

**Visual/Assets:**
- Sidekick reuses existing UFO sprite (`friend-ufo-1.png`)
- Resize sprite as appropriate for sidekick role
- Sidekick projectiles should be visually distinct or offset from player projectiles

### Reusability Opportunities

- Existing `ufo_friend.tscn` scene structure for pickup behavior
- Existing `ufo_friend.gd` script as reference for pickup logic
- Player shooting mechanics for synchronizing sidekick shots
- Player collision layer configuration for sidekick collision setup
- Existing projectile/laser scene for sidekick projectiles

### Scope Boundaries

**In Scope:**
- Power-up spawn system (every 5 enemy kills)
- Star power-up (extra life) - refactored from current ufo_friend
- UFO Friend sidekick pickup and active sidekick behavior
- Sidekick following player with offset
- Sidekick shooting synchronized with player
- Sidekick taking damage and being destroyed on first hit
- Resizing existing UFO sprite for sidekick

**Out of Scope:**
- Sidekick upgrades or leveling
- Multiple simultaneous sidekicks
- Sidekick persistence across levels/deaths
- Sidekick customization options
- Shield ability for sidekick
- Sidekick collecting pickups for player
- Complex AI or independent targeting

### Technical Considerations

- Integration with existing enemy death signal/counter system
- Random power-up selection logic (50/50 or weighted?)
- Sidekick position offset calculation relative to player
- Signal connection for synchronizing sidekick shots with player input
- Collision layer matching with player for damage reception
- Cleanup/destruction of sidekick on damage or player death
- Scene structure: Sidekick as child of level or independent node?
- Animation/feedback for sidekick spawn, active state, and destruction
