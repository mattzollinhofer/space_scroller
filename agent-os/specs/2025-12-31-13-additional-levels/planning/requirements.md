# Spec Requirements: Additional Levels

## Initial Description

Create 2-3 more levels with unique visual themes (different planets/areas of solar system), new obstacles, and escalating difficulty.

## Requirements Discussion

### First Round Questions

**Q1:** I assume you want 2 additional levels (Levels 2 and 3) rather than 3, since Level 1 is being enhanced in roadmap item 12.5. Each would be a completely separate level JSON file with its own section structure. Is that correct, or do you want 3 entirely new levels (totaling 4 levels)?
**Answer:** 2-3 levels is good (2 additional levels confirmed)

**Q2:** The current Level 1 is set up as a single "main.tscn" scene with level data loaded from JSON. Should the new levels use the same main scene structure with different JSON files (e.g., level_2.json, level_3.json), and a level selection mechanism to choose which to load? Or should each level be its own separate scene?
**Answer:** Same scene structure with different JSON files

**Q3:** I'm thinking each new level would have a distinct solar system theme:
- Level 2: Inner solar system (e.g., asteroid belt near Mars, rocky red/orange tones, more asteroids)
- Level 3: Outer solar system (e.g., gas giant atmosphere, ice/blue tones, different debris types)
The current background system uses procedurally-drawn elements (star_field.gd, nebulae.gd, debris.gd) with configurable colors. Is this approach acceptable, or do you want actual sprite-based backgrounds?
**Answer:** Keep it simple - procedural backgrounds with color themes are fine

**Q4:** Should each level have a visually distinct boss? We have boss-1.png and boss-2.png sprites. Level 2 could use boss-2.png (if not already used for the enhanced Level 1), and Level 3 would need a new boss visual. How should we handle the Level 3 boss - recolor existing sprites, or is new artwork expected?
**Answer:** Yes to distinct bosses - boss-2.png is ready for Level 2, user will create another for Level 3 later

**Q5:** I assume the new enemy types being added in roadmap item 12.5 (shooting enemy, charger enemy) should appear across all levels, with the mix and difficulty scaling being what varies per level. Is that correct? Or should certain enemy types be level-exclusive?
**Answer:** Add new enemies to new levels incrementally (not all enemy types at once - introduce them progressively)

**Q6:** For new obstacles, should we create level-themed variants (e.g., ice chunks for outer solar system, solar flares for inner solar system), or stick with asteroids across all levels with just visual color changes?
**Answer:** Yes to level-themed obstacle variants if it's easy to implement

**Q7:** For escalating difficulty across levels, I'm thinking:
- Level 2: 15000-18000 pixels, faster scroll speed (+10-15%), denser enemy waves
- Level 3: 18000-22000 pixels, faster scroll speed (+20-25%), most aggressive enemy patterns
Should difficulty also include new mechanics (e.g., environmental hazards like solar wind, gravity wells), or focus purely on more/faster enemies and obstacles?
**Answer:** Use judgment on environmental mechanics

**Q8:** Is there anything specific you want to exclude from this work (e.g., no level select screen yet, no new enemy types beyond what 12.5 adds, no audio per level)?
**Answer:** Use judgment

### Existing Code to Reference

**Similar Features Identified:**

- Feature: Level Manager - Path: `scripts/level_manager.gd`
  - Level loading and progression system
  - Section-based difficulty management
  - Boss spawning at level completion
  - Checkpoint system

- Feature: Level Data Structure - Path: `levels/level_1.json`
  - JSON-based level definition template
  - Section configuration with enemy waves and obstacle density

- Feature: Background System - Path: `scripts/background/`
  - `star_field.gd` - Configurable star colors and density
  - `nebulae.gd` - Configurable nebula colors (purple, blue, pink)
  - `debris.gd` - Configurable debris colors (gray, brown tones)
  - All use `@export` variables and random seeds for theming

- Feature: Enemy Spawner - Path: `scripts/enemies/enemy_spawner.gd`
  - Wave-based spawning with enemy type configuration
  - Support for multiple enemy scenes (stationary, patrol)

- Feature: Obstacle Spawner - Path: `scripts/obstacles/obstacle_spawner.gd`
  - Density-based spawning (low, medium, high)
  - Single asteroid scene currently

- Feature: Boss System - Path: `scripts/enemies/boss.gd`
  - Attack patterns (barrage, sweep, charge)
  - Health system and defeat handling

### Follow-up Questions

**Follow-up 1:** Regarding introducing enemy types progressively - should this mean:
- Option A: New enemy types debut in later levels (e.g., shooting enemy first appears in Level 2, charger enemy first appears in Level 3)
- Option B: Each level introduces enemies within its own progression (all enemy types available from Level 1, but each level starts easy and ramps up)

**Answer:** Option A confirmed - new enemy types debut in later levels (shooting enemy first appears in Level 2, charger enemy first appears in Level 3)

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

N/A - No visuals to analyze.

## Requirements Summary

### Functional Requirements

**Level Structure:**
- 2 additional levels (Level 2 and Level 3)
- Same main.tscn scene structure with level-specific JSON files
- level_2.json and level_3.json in `levels/` folder
- Level selection mechanism needed to choose which level to load

**Visual Themes:**

Level 2 - Inner Solar System (Asteroid Belt/Mars Region):
- Procedural backgrounds with red/orange color tones
- Star field: warmer star colors
- Nebulae: red/orange/amber hues
- Debris: reddish-brown rocky tones
- Overall dusty, rocky asteroid belt atmosphere

Level 3 - Outer Solar System (Gas Giant/Ice Region):
- Procedural backgrounds with ice/blue color tones
- Star field: cooler star colors, possibly denser
- Nebulae: blue/cyan/purple icy hues
- Debris: blue-gray icy chunks
- Overall cold, icy deep space atmosphere

**Boss Configuration:**
- Level 1: boss-1.png (current, enhanced in 12.5)
- Level 2: boss-2.png sprite
- Level 3: Placeholder/recolored boss until new artwork provided
- Each boss should have distinct attack pattern variations

**Enemy Introduction (Progressive):**
- Level 1: Basic enemies (stationary, patrol) - from 12.5 enhancements
- Level 2: Introduces shooting enemy type (alongside Level 1 enemies)
- Level 3: Introduces charger enemy type (alongside all previous enemies)
- This creates a learning curve where players master enemy types before facing new ones

**Obstacle Variants (if feasible):**
- Level 2: Rocky asteroids (existing), potentially add solar flare hazards
- Level 3: Ice chunk obstacles (blue-tinted asteroids or new ice debris)
- Implementation: Modulate colors on existing asteroid sprites or create simple variants

**Difficulty Escalation:**
- Level 2:
  - Length: ~15000-18000 pixels
  - Scroll speed: +10-15% faster than Level 1
  - Enemy waves: Denser, more frequent
  - 5-6 sections with progressive difficulty curve

- Level 3:
  - Length: ~18000-22000 pixels
  - Scroll speed: +20-25% faster than Level 1
  - Enemy waves: Most dense, all enemy types present
  - 6-7 sections with aggressive difficulty curve
  - Boss has most challenging attack patterns

### Reusability Opportunities

- Extend `level_manager.gd` to accept level path as parameter
- Create theme configuration system for background scripts (color presets)
- Extend `obstacle_spawner.gd` to support multiple obstacle types
- Create level select UI component (new)
- Boss scene can be parameterized for different sprites and attack timings

### Scope Boundaries

**In Scope:**
- 2 new level JSON files (level_2.json, level_3.json)
- Level selection mechanism (UI or progression-based)
- Procedural background theming system with color presets
- Level 2 boss using boss-2.png
- Level 3 boss placeholder (recolored or basic until artwork ready)
- Progressive enemy type introduction across levels
- Difficulty scaling (length, speed, density)
- Level-themed obstacle variants (color modulation at minimum)

**Out of Scope:**
- New sprite artwork (using existing assets, recoloring as needed)
- New enemy types beyond what 12.5 adds (shooting, charger)
- Per-level audio/music (future roadmap item 15)
- Complex environmental mechanics (keeping it simple per user preference)
- Level 3 final boss artwork (user will provide later)

### Technical Considerations

- Level manager needs refactoring to accept level path parameter
- Background scripts need color configuration exports or theme presets
- Consider a LevelTheme resource class to bundle visual settings
- Level select could be:
  - Simple: Sequential progression (complete L1 to unlock L2)
  - Or: Main menu level selection screen
- Boss scene may need parameterization for sprite and attack timing overrides
- Obstacle spawner needs support for multiple obstacle scenes
- Test level transitions and state reset between levels
- Consider save system for level unlock progress

### Design Decisions (Spec Writer Discretion)

1. **Level Selection Approach**: Recommend simple main menu level select with locked/unlocked states based on completion

2. **Environmental Mechanics**: Keep simple - no gravity wells or complex hazards. Focus on visual theming and enemy/obstacle density for difficulty

3. **Level 3 Boss**: Use boss-1.png with ice-blue color modulation as placeholder until artwork ready

4. **Obstacle Implementation**: Use sprite modulation (Sprite2D.modulate) to tint existing asteroids for themed variants - minimal code change

5. **Background Theming**: Create simple color preset dictionaries in background scripts rather than complex resource system

6. **Progression System**: Complete level to unlock next; store unlock state in same ConfigFile as high scores
