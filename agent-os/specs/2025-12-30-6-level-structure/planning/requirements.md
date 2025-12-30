# Spec Requirements: Level Structure

## Initial Description

Build a complete first level with defined start, obstacle sections, enemy placements, and level-end trigger.

## Requirements Discussion

### First Round Questions

**Q1:** I notice the current system uses random spawning for obstacles and enemies (spawning at random intervals from the right edge). For a "defined level structure," I assume you want to switch to pre-designed, fixed placements rather than random spawning. Is that correct, or should we have a hybrid approach where some sections use fixed placements and others use random spawning?
**Answer:** Hybrid approach - define "encounter zones" (sections) that specify what type/density of obstacles and enemies spawn, but allow some randomness within those zones for replayability. This keeps level design intentional while maintaining variety.

**Q2:** For level sections/segments, I'm thinking of dividing the level into distinct phases: Opening section (easier, sparse), Middle sections (increasing difficulty), Pre-boss section (clearing before boss). Should the level have 3-5 sections like this, or do you have a different structure in mind?
**Answer:** Yes, 3-5 sections with relatively short duration so player feels progress and quick progression.

**Q3:** For the level-end trigger, I assume this means reaching a specific point in the scrolling distance. Options include time-based, distance-based, or section-based. Which approach do you prefer?
**Answer:** Section-based - complete all defined sections to end the level.

**Q4:** For obstacle sections, the current asteroids have random sizes. Should level design specify exact asteroid placements (size, position, timing), or just define "asteroid density zones" where the spawner increases/decreases spawn rate?
**Answer:** "Density zones" rather than exact placements. Define asteroid density (low/medium/high) per section. This is easier to tune and maintains some variety.

**Q5:** For enemy placements, should enemies be placed at exact positions in the level (like obstacles), or should we define "enemy waves" that spawn at certain level progress points?
**Answer:** "Waves" at section boundaries or progress points. E.g., "Section 2 starts with 2 stationary enemies, then 1 patrol enemy at 50% through section." This gives control without micromanaging exact pixels.

**Q6:** How long should Level 1 be? I'm assuming a first playthrough should be around 60-90 seconds for a kid-friendly, accessible experience. Does that feel right?
**Answer:** 45-60 seconds total (shorter, good for kids).

**Q7:** Should there be any visual indicators of level progress for the player (e.g., a progress bar, distance counter, or section markers)?
**Answer:** Simple progress bar at top of screen showing current section / total sections. Minimal but gives player awareness.

**Q8:** Is there anything specific you want to exclude from this level structure system?
**Answer:**
- Exclude: Branching paths
- Include: Checkpoints (good idea)
- Include: Restart from section (good idea)
- Defer: Power-ups (later roadmap item)

### Existing Code to Reference

**Similar Features Identified:**

- Feature: Obstacle Spawner - Path: `scripts/obstacles/obstacle_spawner.gd`
  - Random spawning from right edge, configurable spawn rates
  - Tracks active instances, connects to player died signal
  - Will need to be adapted to work with section-based density zones
- Feature: Enemy Spawner - Path: `scripts/enemies/enemy_spawner.gd`
  - Similar pattern to obstacle spawner
  - Supports multiple enemy types (stationary, patrol) with configurable probability
  - Will need to be adapted for wave-based spawning
- Feature: Scroll Controller - Path: `scripts/scroll_controller.gd`
  - Controls world scroll speed (180 px/s)
  - Can be used to track level progress/distance
- Feature: Base Enemy - Path: `scripts/enemies/base_enemy.gd`
  - Enemy health system, collision detection, destruction animation
- Feature: Player - Path: `scripts/player.gd`
  - Lives system, damage handling, died signal
  - Checkpoint system will need to interact with player position/state
- Feature: Main Scene - Path: `scenes/main.tscn`
  - Current scene structure with spawners, player, UI layer
  - Level manager will need to integrate here

### Follow-up Questions

**Follow-up 1:** For checkpoints and restart from section - should this be a full checkpoint system where the player respawns at the last checkpoint when they die? Or simpler: when player dies, show "Retry from Section X?" option vs "Restart Level"?
**Answer:** Full checkpoint system - player respawns at last checkpoint automatically when they die.

**Follow-up 2:** For the progress bar showing sections - should this be implemented in this spec, or should we just emit signals/events that the Game UI spec (roadmap item 9) can hook into later?
**Answer:** Implement a minimal progress bar now since Game UI spec is not yet implemented. Provides important player feedback.

**Follow-up 3:** For level data structure - should level definitions be hardcoded in GDScript or JSON/Resource files?
**Answer:** JSON/Resource files for level definitions (more flexible, easier to edit).

## Visual Assets

### Files Provided:

No visual assets provided in the planning/visuals folder.

### Visual Insights:

- No mockups or wireframes provided
- Level layout will be defined through JSON/Resource data files
- Progress bar design to be kept minimal (styling can be refined in Game UI spec)
- Fidelity level: N/A

## Requirements Summary

### Functional Requirements

- **Level Data System**: JSON/Resource file format for level definitions
  - Define sections with duration, obstacle density, enemy waves
  - Flexible format that can be extended for future levels
  - Easy to edit without code changes

- **Section-Based Level Structure**: 3-5 sections per level
  - Each section has configurable duration (total level: 45-60 seconds)
  - Sections define obstacle density (low/medium/high)
  - Sections define enemy waves at start and progress points
  - Level ends when all sections are complete

- **Hybrid Spawning System**: Adapt existing spawners for section-based control
  - Obstacle spawner responds to density settings per section
  - Enemy spawner responds to wave definitions
  - Maintain some randomness within defined parameters for replayability

- **Checkpoint System**: Full automatic checkpoint at section boundaries
  - Checkpoint saved when player enters new section
  - On player death, respawn at last checkpoint automatically
  - Reset section progress but maintain checkpoint
  - Player lives may need adjustment for checkpoint system

- **Progress Bar UI**: Minimal progress indicator
  - Display at top of screen
  - Show current section progress (section X of Y, or continuous bar)
  - Keep styling simple, can be refined in Game UI spec

- **Level-End Trigger**: Section completion based
  - Level ends when final section is complete
  - Emit signal for boss battle integration (roadmap item 7)
  - Transition to boss or level complete state

### Reusability Opportunities

- **Obstacle Spawner**: Extend `obstacle_spawner.gd` to accept density parameters from level manager
- **Enemy Spawner**: Extend `enemy_spawner.gd` to accept wave definitions from level manager
- **Scroll Controller**: Use `scroll_controller.gd` scroll_offset to track level progress/distance
- **Player signals**: Use existing `died` signal to trigger checkpoint respawn
- **Scene structure**: Build on existing `main.tscn` patterns

### Scope Boundaries

**In Scope:**

- Level data format (JSON/Resource files)
- Level 1 definition with 3-5 sections
- Section-based obstacle density zones
- Section-based enemy wave spawning
- Full checkpoint system with automatic respawn
- Minimal progress bar UI
- Level-end trigger (completes all sections)
- Level manager to orchestrate sections and spawners

**Out of Scope:**

- Branching paths
- Power-up placements (deferred to later roadmap item)
- Boss battle (handled in roadmap item 7)
- Polished UI styling (handled in Game UI spec, item 9)
- Additional levels (handled in roadmap item 10)
- Audio (handled in Audio Integration spec, item 13)

### Technical Considerations

- **Level data format**: JSON files in `res://levels/` or Godot Resource files
  - Section definitions: duration, obstacle_density, enemy_waves
  - Enemy wave format: timing (% through section), enemy_type, count
  - Density levels: low (longer spawn intervals), medium, high (shorter intervals)

- **Level Manager**: New script to orchestrate level flow
  - Load level data from JSON/Resource
  - Track current section and progress within section
  - Control spawner parameters based on current section
  - Handle checkpoint saving and respawn
  - Emit signals for progress bar updates and level completion

- **Checkpoint data**: Store player position, current section, section progress
  - May need to clear existing enemies/obstacles on respawn
  - Reset spawner state to section start

- **Progress calculation**: Based on scroll distance or time within section
  - Scroll speed: 180 px/s (from scroll_controller.gd)
  - 45-60 second level = ~8100-10800 pixels total scroll distance
  - Each section ~2000-3000 pixels or 10-15 seconds

- **Spawner modifications**:
  - Add methods to set spawn rate dynamically
  - Add methods to spawn specific enemy waves on demand
  - May need pause/resume functionality for checkpoints

- **Viewport size**: 2048x1536 pixels
- **Playable Y range**: 80-1456 pixels (for spawning)
- **World scroll speed**: 180 px/s
