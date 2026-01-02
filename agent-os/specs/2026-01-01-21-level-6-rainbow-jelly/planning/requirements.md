# Spec Requirements: Level 6 - Rainbow Jelly Theme

## Initial Description

Add a new level, Level 6, with a Rainbow Jelly theme. This follows the same approach as previous levels with:
- Jelly Monster Boss with custom attack sprite (weapon-jelly-1.png) and attack sequence (enter, up/down shooting, grow/shrink, rapid jelly attack, repeat)
- Jelly Snail special enemy (slow zig-zag movement, 5 health, slow shooting, 10 +/- 3 per level)

## Requirements Discussion

### First Round Questions

**Q1:** For the "up and down while shooting" phase, should the boss move vertically across the entire screen height, and at what speed/rate should it fire? Also, should it use the custom weapon-jelly attack sprite?
**Answer:** Yes, use custom weapon-jelly-1.png sprite. Yes, vertical movement - up and down the whole screen while shooting.

**Q2:** For the "grow 4x larger then shrink to normal size" phase, is this purely visual intimidation, or should the larger boss deal contact damage or have other gameplay effects?
**Answer:** Damage on contact if it's easy to implement, otherwise visual intimidation is fine.

**Q3:** For the "rapid jelly attack" phase, how many projectiles should be fired in the rapid attack? Should they spread in a pattern or fire straight?
**Answer:** 6 projectiles, fired straight forward.

**Q4:** For Jelly Snail's "slow" zig-zag movement and "slow" shooting, what speed range should we target? (For reference, Garlic Man uses 240-280 speed, Ghost Eye uses 170-230)
**Answer:** 60-80 zigzag speed, 6 second fire rate.

**Q5:** Should the Jelly Snail use the same weapon-jelly projectile sprite as the boss, or a different/smaller projectile?
**Answer:** Yes, use weapon-jelly-1.png (same as boss).

**Q6:** Should Level 6 follow the same difficulty progression as Level 5, with ~6 sections, ~24,000 total distance, and scroll speed multiplier around 1.35-1.40?
**Answer:** Yes, follow the progression (~1.40 scroll speed, 180-240 zigzag speeds).

**Q7:** For the rainbow jelly theme, what background modulate color should we use? (Level 5 used bluish-gray [0.6, 0.6, 0.8, 1.0] for ghost theme)
**Answer:** Yes, pink/magenta tint for rainbow jelly theme.

**Q8:** Based on the Level 5 boss having 22 health, should the Level 6 boss have approximately 24-25 health to match difficulty progression?
**Answer:** Yes, ~24-25 HP.

**Q9:** Is there anything that should explicitly be excluded from this level implementation?
**Answer:** None specified - use your judgment.

### Existing Code to Reference

**Similar Features Identified:**

- Feature: Ghost Eye Enemy - Path: `/Users/matt/dev/space_scroller/scripts/enemies/ghost_eye_enemy.gd`
  - Template for Jelly Snail enemy implementation (extends ShootingEnemy)
  - Will adapt pattern for slower movement and slower fire rate

- Feature: Level 5 Configuration - Path: `/Users/matt/dev/space_scroller/levels/level_5.json`
  - Template for level structure, sections, boss config, special enemies config
  - Shows pattern for scroll_speed_multiplier, background_modulate, boss_config

- Feature: Boss Script - Path: `/Users/matt/dev/space_scroller/scripts/enemies/boss.gd`
  - Contains existing attack patterns including:
    - Wall attack (type 9) - reference for vertical projectile patterns
    - Square movement (type 10) - reference for movement patterns
  - Will need new attack types: up/down shooting, grow/shrink, rapid attack

- Feature: Enemy Spawner - Path: `/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd`
  - Handles special enemy spawning via `_try_spawn_special_enemy()`
  - Will need jelly_snail enemy scene reference added

### Follow-up Questions

No follow-up questions were needed - all requirements were sufficiently clarified in the first round.

## Visual Assets

### Files Provided:

No visual assets provided in the spec planning folder.

### Existing Sprites in Codebase:

- `assets/sprites/jelly-monster-1.png` - Jelly Monster Boss sprite
- `assets/sprites/jelly-snail-1.png` - Jelly Snail enemy sprite
- `assets/sprites/weapon-jelly-1.png` - Jelly attack/projectile sprite (used by both boss and jelly snail)

### Visual Insights:

- All required sprites already exist in the codebase
- Sprites follow the existing naming convention
- Single projectile sprite (weapon-jelly-1.png) shared between boss and jelly snail enemy
- No additional visual assets needed for implementation

## Requirements Summary

### Functional Requirements

**Jelly Monster Boss:**
- Custom sprite: `jelly-monster-1.png`
- Custom attack projectile sprite: `weapon-jelly-1.png`
- Attack sequence: Enter -> Up/Down Shooting -> Grow/Shrink -> Rapid Jelly Attack -> repeat
- Up/Down Shooting Phase (new attack type 11):
  - Boss moves vertically across full screen height (up and down)
  - Fires projectiles using weapon-jelly-1.png while moving
- Grow/Shrink Phase (new attack type 12):
  - Boss scales up to 4x size, then shrinks back to normal
  - Contact damage during enlarged state (if easy to implement, otherwise visual only)
  - Purely visual intimidation phase with no projectiles
- Rapid Jelly Attack Phase (new attack type 13):
  - 6 projectiles fired straight forward
  - Uses weapon-jelly-1.png sprite
- Health: ~24-25 HP
- Scale: Standard boss scale (1.5 based on Level 5 pattern)

**Jelly Snail Special Enemy:**
- New enemy type extending ShootingEnemy (like GhostEyeEnemy)
- Custom sprite: `jelly-snail-1.png`
- Custom projectile sprite: `weapon-jelly-1.png`
- 5 health points (survives 4 hits)
- SLOW zigzag movement: 60-80 speed range (much slower than other special enemies)
- SLOW fire rate: 6 seconds between shots
- Spawns via special enemies system
- Target: 7-13 Jelly Snail enemies throughout the level (10 +/- 3)

**Level 6 Structure:**
- Total distance: ~24,000 pixels (consistent with Levels 4-5)
- Scroll speed multiplier: ~1.40 (slight increase from Level 5's 1.35)
- 6 sections with increasing difficulty
- Section names with jelly/rainbow theme
- Enemy waves with progressive difficulty
- Enemy zigzag speeds: 180-240 (increased from Level 5's 170-230)
- Jelly Snail enemies spawn via special_enemies config
- Background: existing theme with pink/magenta modulate color for rainbow jelly atmosphere

### Reusability Opportunities

- `GhostEyeEnemy` class as template for `JellySnailEnemy`
- `level_5.json` as template for `level_6.json`
- Existing boss attack framework (attack state machine, telegraph system)
- Wall attack (type 9) vertical projectile pattern as reference for up/down shooting
- Special enemies spawning system already supports new enemy types

### Scope Boundaries

**In Scope:**
- New level configuration file: `level_6.json`
- New Jelly Snail enemy script: `jelly_snail_enemy.gd`
- New Jelly Snail enemy scene: `jelly_snail_enemy.tscn`
- New boss attack types in `boss.gd`:
  - Up/Down Shooting (type 11)
  - Grow/Shrink (type 12)
  - Rapid Jelly Attack (type 13)
- Update `enemy_spawner.gd` to support jelly_snail enemy type
- Update level select UI to include Level 6
- Update GameState to support Level 6

**Out of Scope:**
- New background theme (using modulate colors instead)
- New power-ups or collectibles
- New player abilities
- Changes to existing game mechanics
- New audio/music (use existing boss battle music pattern)
- Any features not explicitly discussed

### Technical Considerations

- Boss attack indices: Up/Down Shooting = 11, Grow/Shrink = 12, Rapid Attack = 13 (continuing from existing 0-10)
- Boss config attacks array: `[11, 12, 13]` for up/down -> grow/shrink -> rapid attack cycle
- Jelly Snail enemy needs to be added to EnemySpawner's scene exports
- Level 6 path: `res://levels/level_6.json`
- Follow existing patterns for scene structure and signal connections
- Background modulate color: pink/magenta tint (suggested: [1.0, 0.7, 0.9, 1.0] or similar)
- Jelly Snail's slow speed (60-80) is intentionally much slower than other enemies (Ghost Eye: 170-230, Garlic: 240-280)
- Jelly Snail's slow fire rate (6 seconds) is intentionally much slower than standard shooting enemies
