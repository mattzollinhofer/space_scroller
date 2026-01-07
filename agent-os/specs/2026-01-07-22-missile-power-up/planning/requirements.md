# Spec Requirements: Missile Power-Up

## Initial Description

Add a missile power-up that enhances the player's projectile damage when collected. The power-up should integrate with the existing pickup spawning system and provide visual feedback for the damage boost state.

## Requirements Discussion

### First Round Questions

**Q1:** Should the damage boost persist across levels or reset when player dies?
**Answer:** Reset when player dies, but persist if they progress to next level.

**Q2:** Should the damage boost stack (collecting multiple power-ups increases damage further) or have a fixed boost?
**Answer:** Damage should increase/stack (1 -> 2 -> 3, etc.) when collecting multiple.

**Q3:** Should there be a visual indicator showing the player has the damage boost?
**Answer:** Yes, add a UI indicator - designer's choice on how to show it.

**Q4:** Should there be any special visual/audio feedback when collecting the missile power-up?
**Answer:** Yes, can use existing effects and add special feedback.

**Q5:** Should the missile power-up spawn under specific conditions or randomly like other pickups?
**Answer:** Same as other power-ups, random spawn in the pool.

**Q6:** Under what conditions is the damage boost lost?
**Answer:** Lost on loss of life.

**Q7:** Any additional features or scope to consider?
**Answer:** Keep it focused, no scope creep.

### Existing Code to Reference

**Similar Features Identified:**

- Feature: Star Pickup (health restore) - Path: `/Users/matt/dev/space_scroller/scripts/pickups/star_pickup.gd`
- Feature: Sidekick Pickup - Path: `/Users/matt/dev/space_scroller/scripts/pickups/sidekick_pickup.gd`
- Feature: Base Pickup class - Path: `/Users/matt/dev/space_scroller/scripts/pickups/base_pickup.gd`
- Feature: Enemy Spawner (manages pickup spawning) - Path: `/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd`
- Feature: Player (projectile handling, health/lives) - Path: `/Users/matt/dev/space_scroller/scripts/player.gd`
- Scene templates: `/Users/matt/dev/space_scroller/scenes/pickups/star_pickup.tscn`

### Follow-up Questions

None required - answers were comprehensive.

## Visual Assets

### Files Provided:

No visual files found in `/Users/matt/dev/space_scroller/agent-os/specs/2026-01-07-22-missile-power-up/planning/visuals/`

### Candidate Sprites in Codebase:

Based on search of `assets/sprites/` directory, several unused or potentially usable images were identified:

1. **`power-up-1.png`** - A green glowing orb with sparkles. Currently unused. Could work well for a missile/damage power-up with appropriate color interpretation.

2. **`energy-orb.png`** - A red/orange glowing energy orb. Has aggressive/fiery appearance that could suit a damage boost.

3. **`fireball-1.png`** - A red/orange swirling fireball. Very suitable for a damage/missile theme.

4. **`weapon-red-swirl-1.png`** - Same as fireball-1.png, a red/orange swirl effect. Good missile/damage visual.

5. **`upgrade-ghost-wand-1.png`** - A magical wand with sparkles. Less suitable for missile theme but could work as generic power-up.

**Recommendation:** `fireball-1.png` or `energy-orb.png` would be most thematically appropriate for a missile/damage power-up given their fiery, aggressive appearance.

## Requirements Summary

### Functional Requirements

- Create a new pickup type: MissilePickup
- When collected, increases player's projectile damage by +1 (stacking: 1 -> 2 -> 3, etc.)
- Damage boost persists through level progression
- Damage boost is lost when player loses a life (not just health damage)
- Add to the random pickup spawn pool alongside star and sidekick pickups
- Display UI indicator showing current damage boost level
- Play collection sound effect and visual feedback on pickup

### Technical Architecture

Based on existing codebase patterns:

1. **New Pickup Script**: `scripts/pickups/missile_pickup.gd` extending `BasePickup`
2. **New Pickup Scene**: `scenes/pickups/missile_pickup.tscn`
3. **Player Modifications**: Add damage boost tracking to `player.gd`
   - `_damage_boost: int = 0`
   - `get_damage_boost() -> int`
   - `add_damage_boost()`
   - `reset_damage_boost()` - called on life_lost signal
4. **Enemy Spawner Modifications**: Add missile pickup to `_spawn_random_pickup()` and `_choose_pickup_type()` logic
5. **UI Component**: New indicator for damage boost level (designer's choice - could be numeric, icons, or visual effect on player)
6. **Projectile Modifications**: Apply damage boost when player fires

### Reusability Opportunities

- Extend `BasePickup` class (already handles movement, collision, collection animation)
- Follow `StarPickup` pattern for collection behavior
- Use existing `AudioManager` for sound effects
- Use existing pickup spawn system in `EnemySpawner`
- Reference `HealthDisplay` pattern for UI indicator

### Scope Boundaries

**In Scope:**

- MissilePickup collectible that grants damage boost
- Stacking damage mechanic (+1 per collection)
- UI indicator for current damage level
- Integration with existing random pickup system
- Collection effects (sound, animation)
- Reset on life loss
- Persistence across levels

**Out of Scope:**

- Different projectile types/visuals based on damage level
- Time-limited damage boost
- Maximum cap on damage stacking
- Visual changes to player sprite when boosted
- Achievement/stat tracking for damage boosts

### Technical Considerations

- Damage boost must be tracked on player, not globally, to handle life loss reset correctly
- Need to modify projectile damage application in enemies (currently hardcoded in `take_hit` calls)
- Consider using `GameState` autoload for level persistence similar to lives
- UI indicator placement should not conflict with existing HealthDisplay and score
- Pickup selection logic in `_choose_pickup_type()` may need adjustment for 3-way selection
