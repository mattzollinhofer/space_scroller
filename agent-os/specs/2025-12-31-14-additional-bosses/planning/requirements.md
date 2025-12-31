# Spec Requirements: Additional Bosses

## Initial Description

From the product roadmap item 14: "Design unique boss encounters for each additional level with distinct attack patterns and mechanics."

The goal is to make the boss fights for levels 2 and 3 feel more unique and thematically connected to their solar system locations, while keeping the existing boss system architecture.

## Requirements Discussion

### First Round Questions

**Q1:** I see the current system uses ONE boss class (`boss.gd`) with 3 attack patterns, configured differently per level via JSON. I'm assuming you want entirely new boss classes with unique mechanics (not just different combinations of existing attacks). Is that correct, or would you prefer to extend the existing boss with more attack patterns that can be mixed/matched?

**Answer:** User asked "what do we have now" - indicating they want to understand and work with the current system. This suggests extending the existing `boss.gd` class with additional attack patterns rather than creating entirely new boss classes.

**Q2:** There are currently 3 levels (each with a boss fight) and 4 boss sprites exist (boss-1 through boss-4). I'm assuming you want to either add bosses for future levels (4+), OR replace/enhance the existing level 2 and 3 bosses with more distinct mechanics. Which direction should we take?

**Answer:** "save boss 4 for later" - Focus on enhancing bosses for levels 2 and 3. The boss-4.png sprite should be reserved for a future level 4.

**Q3:** The current boss has barrage, sweep, and charge attacks. For new bosses, I'm thinking each should have at least 2-3 unique mechanics that feel distinctly different. Are there specific mechanics you'd like to see, or should I design varied patterns appropriate for kids ages 6-12?

**Answer:** "your call" - Designer discretion to create appropriate attack patterns for the target audience (kids ages 6-12).

**Q4:** Currently difficulty scales via health, scale, number of attacks, and cooldown. Should new bosses follow this pattern or prefer each boss to have a consistent challenge but different style of difficulty?

**Answer:** "increased, but not crazy" - Moderate difficulty scaling. Bosses should get harder but remain accessible for young players.

**Q5:** Each boss currently uses a different sprite with optional color modulation. Should new bosses use the existing boss sprites with new behavior, OR require new sprite assets?

**Answer:** "existing sprites, but probably a bit larger" - Use the existing boss-2.png and boss-3.png sprites, but increase their scale slightly.

**Q6:** Level 1 is outer space, Level 2 is "Inner Solar" (Mercury/Venus), Level 3 is "Outer Solar" (Kuiper Belt). Should each boss have a thematic connection to its level's location?

**Answer:** "if possible" - Yes, bosses should have thematic connection to their level's solar system location where feasible.

**Q7:** What should we explicitly NOT include in this scope?

**Answer:** "keep it trimmed down" - Minimal scope, focused on core boss mechanics only. No new enemy types, new levels, audio/music changes, or other features.

### Existing Code to Reference

**Similar Features Identified:**

- Feature: Existing Boss Implementation - Path: `/Users/matt/dev/space_scroller/scripts/enemies/boss.gd`
- Feature: Boss Scene - Path: `/Users/matt/dev/space_scroller/scenes/enemies/boss.tscn`
- Feature: Boss Projectile - Path: `/Users/matt/dev/space_scroller/scripts/enemies/boss_projectile.gd`
- Feature: Level Configuration - Paths: `/Users/matt/dev/space_scroller/levels/level_2.json` and `/Users/matt/dev/space_scroller/levels/level_3.json`
- Feature: Level Manager (boss spawning logic) - Path: `/Users/matt/dev/space_scroller/scripts/level_manager.gd`
- Feature: Boss Health Bar UI - Path: `/Users/matt/dev/space_scroller/scenes/ui/boss_health_bar.gd`

### Follow-up Questions

No follow-up questions needed - user responses were clear and sufficient.

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

N/A - No visuals to analyze.

## Requirements Summary

### Functional Requirements

- **Extend existing boss.gd** with new attack patterns (attacks 3, 4, 5, etc.) that can be configured via level JSON
- **Level 2 Boss ("Inner Solar" theme)** should have unique attack patterns thematically connected to the sun/heat/Mercury/Venus area:
  - Suggested themes: solar flares, heat waves, fiery projectiles, radial burst patterns
  - Should use attacks that feel "hot" or "intense"
- **Level 3 Boss ("Outer Solar" theme)** should have unique attack patterns thematically connected to the Kuiper Belt/ice/cold area:
  - Suggested themes: ice shards, slow-moving but numerous projectiles, freezing patterns
  - Should use attacks that feel "cold" or "expansive"
- **Larger boss sprites**: Increase scale for level 2 and level 3 bosses beyond current values
- **Moderate difficulty progression**: Each boss should be harder than the previous but remain kid-friendly
- **Reserve boss-4.png**: Do not use this sprite; it's for a future level 4

### Current Boss Configuration Reference

| Level | Health | Scale | Attacks | Cooldown |
|-------|--------|-------|---------|----------|
| 1 | 10 | 5 | [0] (barrage only) | 1.5s |
| 2 | 13 | 6 | [0, 1] (barrage + sweep) | 1.3s |
| 3 | 16 | 8 | [0, 1, 2] (all three) | 1.1s |

### Current Attack Patterns (for reference)

- **Attack 0 - Horizontal Barrage**: Fires 5-7 projectiles in a spread pattern toward the player
- **Attack 1 - Vertical Sweep**: Boss moves up/down across screen while firing single projectiles at intervals
- **Attack 2 - Charge Attack**: Boss rushes toward player position then retreats to battle position

### Reusability Opportunities

- Extend `boss.gd` attack state machine with new attack indices (3, 4, 5, etc.)
- Reuse existing `boss_projectile.gd` or create variants with different speeds/visuals
- Leverage existing JSON configuration system (`boss_config.attacks` array)
- Use existing collision, health, and damage systems unchanged

### Scope Boundaries

**In Scope:**

- New attack patterns for the existing boss class
- Level 2 boss: thematic "Inner Solar" attacks
- Level 3 boss: thematic "Outer Solar" attacks
- Updated level JSON configuration for new attacks
- Increased boss scale for levels 2 and 3
- Moderate difficulty tuning

**Out of Scope:**

- New boss classes or entirely separate boss scripts
- Boss for level 4 (boss-4.png reserved for future)
- New enemy types
- New levels
- Audio/music changes (handled by roadmap item 15)
- New visual effects or particles (handled by roadmap item 16)
- New sprites or art assets

### Technical Considerations

- **Architecture**: Extend existing `boss.gd` with new attack methods following the established pattern (`_attack_horizontal_barrage`, `_attack_vertical_sweep`, `_attack_charge`)
- **Configuration**: New attacks should be selectable via the `attacks` array in level JSON (`boss_config.attacks`)
- **State Machine**: Current `AttackState` enum and `_execute_attack()` method should be extended
- **Projectiles**: May need projectile variants with different speeds or patterns, but should extend existing `boss_projectile.gd`
- **Testing**: Existing boss tests in `/Users/matt/dev/space_scroller/tests/` (test_boss_*.gd) should be extended for new attack patterns
- **Kid-friendly**: All attacks should have clear visual telegraphing and be dodgeable by players ages 6-12
