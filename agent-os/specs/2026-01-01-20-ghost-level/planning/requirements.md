# Spec Requirements: Level 5 - Ghost Theme

## Initial Description

Add a new level, Level 5, with a Ghost theme. This follows the same approach as previous levels with:
- Ghost Monster Boss with custom attack sprite and attack sequence (enter, wall attack, square move around arena, repeat)
- Ghost Eye special enemy (zig-zag pattern, 3 health, faster than other enemies, 5-10 per level)

## Requirements Discussion

### First Round Questions

**Q1:** You mentioned a "wall attack" for the Ghost Monster Boss. Could you describe what you envision for this attack?
**Answer:** 6 projectiles will fan vertically up and down from the boss, then shoot horizontally across the arena.

**Q2:** For the "square move around arena" attack, is this similar to the existing circle movement attack but following a square/rectangular path? Should the boss fire projectiles while moving?
**Answer:** Similar to circle movement attack, NO projectiles while moving.

**Q3:** For the Ghost boss attack cycle, should it follow: Enter -> Wall Attack -> Square Move -> repeat?
**Answer:** Confirmed - Enter -> Wall Attack -> Square Move -> repeat.

**Q4:** Should the Ghost Eye enemy follow the same implementation pattern as Garlic Man (extend ShootingEnemy, 3 health, faster zigzag, ghost-attack projectiles)?
**Answer:** Confirmed - same pattern as Garlic Man.

**Q5:** Should Ghost Eye enemies spawn throughout the entire level or only in certain sections?
**Answer:** About the same as Garlic Man (~45% probability in allowed sections).

**Q6:** Should Level 5 follow a similar structure to Level 4 with 6 sections, increasing difficulty, and approximately 24,000 total distance?
**Answer:** Same as Level 4 with 6 sections, increasing difficulty (~24,000 distance), with normal difficulty increases.

**Q7:** For the ghost theme, should we add a new background theme or use modulate colors on an existing background?
**Answer:** Use modulate colors on existing background (no new theme).

**Q8:** Is there anything that should explicitly be excluded from this level implementation?
**Answer:** Follow existing level patterns, do only what was discussed - no extras.

### Existing Code to Reference

**Similar Features Identified:**

- Feature: Garlic Enemy - Path: `/Users/matt/dev/space_scroller/scripts/enemies/garlic_enemy.gd`
  - Template for Ghost Eye enemy implementation
  - Extends ShootingEnemy, has 3 HP, faster zigzag movement, custom projectile texture

- Feature: Level 4 Configuration - Path: `/Users/matt/dev/space_scroller/levels/level_4.json`
  - Template for level structure, sections, boss config, special enemies config

- Feature: Boss Script - Path: `/Users/matt/dev/space_scroller/scripts/enemies/boss.gd`
  - Contains existing attack patterns including circle movement (attack type 8)
  - Will need new attack types: wall attack (new) and square movement (new)

- Feature: Enemy Spawner - Path: `/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd`
  - Handles special enemy spawning via `_try_spawn_special_enemy()`
  - Will need ghost eye enemy scene reference added

### Follow-up Questions

No follow-up questions were needed - all requirements were sufficiently clarified in the first round.

## Visual Assets

### Files Provided:

No visual assets provided in the spec planning folder.

### Existing Sprites in Codebase:

- `assets/sprites/ghost-boss-1.png` - Ghost Monster Boss sprite
- `assets/sprites/ghost-eye-enemy-1.png` - Ghost Eye enemy sprite
- `assets/sprites/ghost-attack-1.png` - Ghost attack/projectile sprite

### Visual Insights:

- All required sprites already exist in the codebase
- Sprites follow the existing naming convention
- No additional visual assets needed for implementation

## Requirements Summary

### Functional Requirements

**Ghost Monster Boss:**
- Custom sprite: `ghost-boss-1.png`
- Custom attack projectile sprite: `ghost-attack-1.png`
- Attack sequence: Enter -> Wall Attack -> Square Move -> repeat
- Wall Attack (new attack type 9):
  - 6 projectiles fan out vertically (up and down) from boss position
  - Then shoot horizontally across the arena toward the player
- Square Movement (new attack type 10):
  - Boss moves in a square/rectangular path around the arena
  - No projectiles fired during movement (similar to circle movement attack type 8)
- Health and scale to be determined based on Level 4 progression (likely 22-25 health, scale 6)

**Ghost Eye Special Enemy:**
- New enemy type extending ShootingEnemy (like GarlicEnemy)
- Custom sprite: `ghost-eye-enemy-1.png`
- Custom projectile sprite: `ghost-attack-1.png`
- 3 health points (survives 2 hits)
- Faster zigzag movement (240-280 speed range, same as Garlic)
- Faster fire rate than standard shooting enemy
- Spawns via special enemies system at ~45% probability in allowed sections
- Target: 5-10 Ghost Eye enemies throughout the level

**Level 5 Structure:**
- Total distance: ~24,000 pixels (same as Level 4)
- 6 sections with increasing difficulty
- Section names with ghost/spooky theme
- Enemy waves with progressive difficulty
- Ghost Eye enemies spawn in sections 1-5 (via special_enemies config)
- Background: existing theme with ghost-appropriate modulate colors (darker/spookier)

### Reusability Opportunities

- `GarlicEnemy` class as template for `GhostEyeEnemy`
- `level_4.json` as template for `level_5.json`
- Existing boss attack framework (attack state machine, telegraph system)
- Circle movement attack (type 8) as reference for square movement
- Special enemies spawning system already supports new enemy types

### Scope Boundaries

**In Scope:**
- New level configuration file: `level_5.json`
- New Ghost Eye enemy script: `ghost_eye_enemy.gd`
- New Ghost Eye enemy scene: `ghost_eye_enemy.tscn`
- New boss attack types in `boss.gd`: Wall Attack (9), Square Movement (10)
- Update `enemy_spawner.gd` to support ghost_eye enemy type
- Update level select UI to include Level 5
- Update GameState to support Level 5

**Out of Scope:**
- New background theme (using modulate colors instead)
- New power-ups or collectibles
- New player abilities
- Changes to existing game mechanics
- New audio/music (use existing boss battle music pattern)
- Any features not explicitly discussed

### Technical Considerations

- Boss attack indices: Wall Attack = 9, Square Movement = 10 (continuing from existing 0-8)
- Boss config attacks array: `[9, 10]` for wall attack -> square move cycle
- Ghost Eye enemy needs to be added to EnemySpawner's scene exports
- Level 5 path: `res://levels/level_5.json`
- Follow existing patterns for scene structure and signal connections
- Background modulate color should create spooky/ghostly atmosphere (suggested: darker blues/purples or desaturated grays)
