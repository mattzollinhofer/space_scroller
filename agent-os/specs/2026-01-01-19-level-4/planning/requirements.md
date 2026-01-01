# Spec Requirements: Level 4 - Pepperoni Pizza Theme

## Initial Description

Add new level, level 4. This will mostly use the same approach as all previous
levels. A few notes:

### Theme
- Pepperoni pizza theme

### New Boss: Pepperoni Pizza Boss
- The boss has a custom attack sprite
- The boss has a special attack sequence:
  1. Enter
  2. Three pronged pepperoni attack
  3. Complete circle movement around the "arena"
  4. Repeat attack

### Custom Assets
- Custom images/sprites to be used for the level

### New Enemy: Garlic Man
- Custom sprite
- "Pizza-attack" sprite
- Movement pattern: zig-zag pattern, but a little faster than normal
- Health: 3

## Requirements Discussion

### First Round Questions

**Q1:** For Level 4 structure, I assume we should follow the same pattern as previous levels with increased difficulty. For total_distance, should we go with ~24000 (Level 3 is ~22000) and scroll_speed_multiplier of ~1.3?
**Answer:** YES to total_distance: 24000 and scroll_speed_multiplier: 1.3

**Q2:** For section structure, should we use the same pattern as existing levels (Opening, Building, Ramping, Intense, Gauntlet, Final Push)?
**Answer:** YES - use the same section pattern. User confirmed these are internal labels not visible to players.

**Q3:** For the Pepperoni Pizza Boss attack sequence:
- "Three pronged pepperoni attack": Should this be a spread pattern (3 projectiles in a spread) or sequential shots?
- "Circle movement around arena": Should this be clockwise, counter-clockwise, or alternating?
- Should the boss use any existing attack patterns in addition to the custom sequence?
**Answer:**
- Spread pattern: 3 projectiles fired in a spread
- Circle movement: ALTERNATE between clockwise and counter-clockwise
- No existing patterns - just use the custom sequence

**Q4:** For Pepperoni Pizza Boss stats, I assume health around 15-20 (scaling from previous bosses) and scale similar to Level 3 boss. Any specific values?
**Answer:** Health: 20, Scale: start with 9 (same as Level 3, adjust if needed). Use pepperoni-attack-1.png for projectiles.

**Q5:** For Garlic Man's zig-zag speed, should it be approximately 25-30% faster than the standard zig-zag speed?
**Answer:** YES to faster zig-zag speed (240-280)

**Q6:** Does Garlic Man shoot projectiles, or is he melee-only with the zig-zag movement?
**Answer:** YES shoots projectiles using pizza-attack-1.png, fire_rate: 1.0 (faster than normal 1.5)

**Q7:** Should Garlic Man appear only in Level 4, or should he be available for spawning in future levels too?
**Answer:** NEW enemy type only for Level 4

**Q8:** Anything that should definitely NOT be included in this level (specific mechanics, features, etc.)?
**Answer:** Nothing to exclude - should function like other levels with these additions

### Existing Code to Reference

**Similar Features Identified:**
- Level 3 implementation for overall level structure and section patterns
- Existing boss implementations for attack sequence patterns
- Zig-zag enemy movement patterns for Garlic Man base behavior
- Projectile shooting enemies for Garlic Man's ranged attack

No specific paths were provided by user, but spec-writer should reference:
- Existing level configuration files
- Boss scene and script files
- Enemy movement pattern implementations

### Follow-up Questions

**Follow-up 1:** You mentioned wanting a MORE COMPLEX special enemy system with own spawn rules per level and possibly other configuration rules. Can you elaborate on what additional configuration options you'd find useful?
**Answer:** User is open to suggestions and wants forward-thinking design for future levels that will also have special enemies.

## Visual Assets

### Files Provided:
No visual assets provided.

### Visual Insights:
User mentioned custom sprites exist but did not place them in the visuals folder:
- pepperoni-attack-1.png (boss projectile)
- pizza-attack-1.png (Garlic Man projectile)
- Garlic Man sprite (location unspecified)
- Pepperoni Pizza Boss sprite (location unspecified)

Spec-writer should locate existing sprites in assets folder or clarify sprite locations.

## Requirements Summary

### Functional Requirements

#### Level Structure
- Total distance: 24000
- Scroll speed multiplier: 1.3
- Section pattern: Opening, Building, Ramping, Intense, Gauntlet, Final Push (same as previous levels)
- Theme: Pepperoni Pizza

#### Pepperoni Pizza Boss
- Health: 20
- Scale: 9 (same as Level 3 boss)
- Attack projectile sprite: pepperoni-attack-1.png
- Attack sequence (repeating loop):
  1. Enter animation
  2. Three-pronged pepperoni attack (3 projectiles in spread pattern)
  3. Circle movement around arena (alternates clockwise/counter-clockwise each cycle)
  4. Repeat from step 2

#### Garlic Man Enemy (New)
- Health: 3
- Movement: Zig-zag pattern at faster speed (240-280)
- Ranged attack: Shoots projectiles using pizza-attack-1.png
- Fire rate: 1.0 seconds (faster than standard 1.5)
- Availability: Level 4 only (special enemy)

#### Special Enemy System (New)
User wants a forward-thinking system for special enemies that appear in specific levels:

**Core Configuration:**
- Own spawn rules per level (which levels can spawn this enemy)
- Level-specific spawn frequency/probability

**Suggested Additional Configuration Options:**
1. **Section restrictions**: Which level sections the enemy can appear in (e.g., only in Intense and Gauntlet sections)
2. **Spawn count limits**: Max number per level or per section
3. **First appearance distance**: Minimum distance into level before spawning
4. **Spawn cooldown**: Minimum distance between spawns of same special enemy
5. **Difficulty scaling**: Whether the enemy's stats scale with level difficulty or remain fixed
6. **Group spawning**: Whether they spawn solo or can appear in groups

### Reusability Opportunities

- Boss attack sequence system could be made more configurable for future bosses
- Enemy projectile system should support custom sprites per enemy type
- Special enemy spawn rules could become a reusable configuration pattern
- Zig-zag movement speed should be parameterized for easy variation

### Scope Boundaries

**In Scope:**
- Level 4 complete implementation with all sections
- Pepperoni Pizza Boss with custom attack sequence
- Garlic Man enemy with faster zig-zag and projectile attack
- Special enemy spawn configuration system
- Integration with existing game flow (level progression, score, etc.)

**Out of Scope:**
- Changes to other levels
- New music tracks (use existing or placeholder)
- New UI elements beyond what existing levels use
- Mobile-specific optimizations beyond existing patterns

### Technical Considerations

- Boss circle movement needs smooth path calculation (alternating direction each cycle)
- Spread attack pattern should have configurable angle spread
- Garlic Man's faster zig-zag may need collision tuning
- Special enemy system should be extensible for Level 5 ghost enemies (roadmap item 20)
- All new enemies/bosses should follow existing scene inheritance patterns
- Use existing signal patterns for enemy events
