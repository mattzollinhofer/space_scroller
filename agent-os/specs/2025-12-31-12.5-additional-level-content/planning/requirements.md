# Spec Requirements: Additional Level Content

## Initial Description

Additional level through length and enemy difficulty. More enemies, different enemies. Shooting enemy. Longer time span. Different boss.

## Requirements Discussion

### First Round Questions

**Q1:** I assume we're enhancing the existing Level 1 rather than creating an entirely new level. The current level is 9000 pixels with 4 sections. Should we extend to approximately 12000-15000 pixels with 5-6 sections?
**Answer:** YES - extend to 12000-15000 pixels with 5-6 sections

**Q2:** The current level takes roughly 50 seconds to complete before the boss fight. Should we extend this to around 90-120 seconds of gameplay?
**Answer:** YES - extend to 90-120 seconds

**Q3:** For the "shooting enemy" - should it fire single projectiles periodically, have lower health since it's ranged, and use the existing enemy-2.png sprite?
**Answer:** YES, with modifications:
- Non-shooting enemy: 2 HP
- Shooting enemy: 1 HP
- Shoots every 4 seconds
- Use enemy-2.png sprite to distinguish

**Q4:** Should enemy waves scale from current sizes (2-3 per wave) up to perhaps 4-5 in the later intense sections?
**Answer:** YES to 4-5 enemies per wave, AND add individual enemies between waves to fill the long gaps

**Q5:** Should we add new movement patterns for variety, such as dive bomber, static shooter, or fast charger?
**Answer:** YES - add fast charger

**Q6:** For "different boss" - should this be a visual change (using boss-2.png sprite) with modified attack patterns, or an entirely new boss with new mechanics?
**Answer:** YES - visual change using boss-2.png sprite with modified attack patterns

**Q7:** Should the new/modified boss have increased health or more aggressive attack patterns?
**Answer:** More aggressive attack patterns (not increased health)

**Q8:** Is there anything specific you want to exclude from this work?
**Answer:** None - no exclusions

### Existing Code to Reference

**Similar Features Identified:**

- Feature: Base Enemy - Path: `scripts/enemies/base_enemy.gd`
  - Base class for creating new enemy types (shooting enemy, charger enemy)
  - Health system, collision detection, destruction animation

- Feature: Boss Projectile System - Path: `scripts/enemies/boss.gd` and `scripts/enemies/boss_projectile.gd`
  - Projectile firing patterns to adapt for shooting enemy
  - Direction-based projectile movement

- Feature: Patrol Enemy - Path: `scripts/enemies/patrol_enemy.gd`
  - Example of extending BaseEnemy with different HP

- Feature: Level Structure - Path: `levels/level_1.json`
  - JSON-based level definition template
  - Section-based progression system

- Feature: Enemy Spawner - Path: `scripts/enemies/enemy_spawner.gd`
  - Wave-based spawning system to extend for new enemy types
  - Continuous spawning logic (can be used for filler enemies)

### Follow-up Questions

**Follow-up 1:** Should enemies move diagonally and bounce off edges, or keep existing zigzag behavior?
**Answer:** IGNORE diagonal movement comment. Enemies should keep existing zigzag behavior. However, user noticed most enemies currently aren't moving much - the zigzag seems broken. This may be a bug to investigate/fix as part of this work.

**Follow-up 2:** Should filler enemies spawn continuously on a timer or be pre-placed in level JSON?
**Answer:** Your call - make a reasonable decision.

**Follow-up 3:** Fast charger enemy details - third enemy type? HP? Target player Y position?
**Answer:**
- YES, it's a third enemy type
- Tweak/recolor an existing enemy sprite for it
- Should target the player's Y position when charging

**Follow-up 4:** Boss aggressiveness - reduce cooldown, add new pattern, or faster projectiles?
**Answer:** Your call - make reasonable decisions for more aggressive patterns.

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

N/A - No visuals to analyze.

## Requirements Summary

### Functional Requirements

**Level Structure:**
- Extend level from 9000 pixels to 12000-15000 pixels
- Increase from 4 sections to 5-6 sections
- Gameplay time extended from ~50 seconds to 90-120 seconds before boss fight

**New Enemy Types:**

1. **Shooting Enemy** (new)
   - 1 HP (fragile ranged attacker)
   - Fires projectile every 4 seconds toward player/left
   - Uses enemy-2.png sprite
   - Keeps zigzag movement pattern

2. **Non-Shooting Enemy** (modified from current)
   - 2 HP (matches current patrol enemy)
   - Keeps zigzag movement pattern
   - Uses existing enemy.png sprite

3. **Charger Enemy** (new)
   - HP: TBD (recommend 1 HP due to aggressive nature)
   - Fast horizontal charge toward player
   - Targets player's Y position when charging
   - Uses recolored/tweaked existing sprite

**Enemy Spawning:**
- Increase wave sizes to 4-5 enemies in later sections
- Add continuous "filler" enemy spawning between waves (recommended: timer-based, every 4-6 seconds)
- Progressive difficulty curve across sections

**Bug Investigation:**
- Investigate/fix potential zigzag movement bug - enemies appear stationary or barely moving

**Boss Changes:**
- Visual: Use boss-2.png sprite instead of boss-1.png
- Keep same health (13 HP)
- More aggressive attack patterns (recommended adjustments):
  - Reduce attack cooldown from 2.0 to 1.2-1.5 seconds
  - Reduce wind-up duration from 0.5 to 0.3 seconds
  - Increase projectile speed
  - Potentially add a 4th attack pattern or modify existing ones

### Reusability Opportunities

- Extend `BaseEnemy` class for shooting and charger enemies
- Adapt `boss_projectile.gd` logic for enemy projectiles
- Extend `enemy_spawner.gd` to support new enemy types and continuous spawning
- Modify `level_1.json` structure for additional sections

### Scope Boundaries

**In Scope:**
- Extended level length (12000-15000 pixels, 5-6 sections)
- Longer gameplay time (90-120 seconds)
- New shooting enemy type (1 HP, fires every 4 seconds)
- Modified non-shooting enemy (2 HP)
- New charger enemy type (targets player Y position)
- Larger enemy waves (4-5 per wave)
- Filler enemies between waves
- Boss visual change to boss-2.png
- More aggressive boss attack patterns
- Bug fix for enemy zigzag movement

**Out of Scope:**
- New sprite assets (use existing sprites, recolor if needed)
- New pickup types
- Scoring system changes
- Audio changes
- Additional levels beyond Level 1 enhancement

### Technical Considerations

- New enemy scripts should extend `BaseEnemy` class
- Enemy projectiles can reuse/adapt `boss_projectile.gd` pattern
- Level JSON structure supports the required section additions
- Sprite recoloring can be done via modulate property in Godot
- Continuous spawning already exists in `enemy_spawner.gd` (currently disabled for wave-based levels)
- Consider performance with increased enemy counts

### Design Decisions (Spec Writer Discretion)

1. **Filler enemy spawning**: Recommend timer-based continuous spawning (every 4-6 seconds) between section changes, using random enemy type selection weighted toward basic enemies

2. **Charger enemy HP**: Recommend 1 HP since it's fast and aggressive - should be high-risk/high-reward to destroy

3. **Boss aggressiveness**: Recommend:
   - Cooldown: 2.0s -> 1.3s
   - Wind-up: 0.5s -> 0.35s
   - Projectile speed: +25%
   - Consider adding a "rapid fire" variant of the barrage attack

4. **Section distribution** (6 sections over ~13500 pixels):
   - Opening (0-15%): Low density, basic enemies only
   - Building (15-35%): Medium density, introduce shooting enemy
   - Ramping (35-55%): Medium-high density, mixed enemies
   - Intense (55-75%): High density, introduce charger enemy
   - Gauntlet (75-90%): Very high density, all enemy types
   - Final Push (90-100%): High density, prepare for boss
