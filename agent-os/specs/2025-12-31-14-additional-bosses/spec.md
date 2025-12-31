# Specification: Additional Bosses

## Goal

Extend the existing boss class with new thematic attack patterns for levels 2 and 3, making each boss fight feel unique and connected to its solar system location while maintaining kid-friendly difficulty.

## User Stories

- As a player, I want the Level 2 boss to feel "hot" and intense with solar-themed attacks so that the fight matches the Inner Solar System theme
- As a player, I want the Level 3 boss to feel "cold" and expansive with ice-themed attacks so that the fight matches the Outer Solar System theme

## Specific Requirements

**Level 2 Boss: Inner Solar Theme Attacks**

- Add attack index 3: "Solar Flare" - radial burst pattern firing projectiles in all directions
- Add attack index 4: "Heat Wave" - continuous stream of fast projectiles in a sweeping arc
- Configure level_2.json to use attacks [0, 3, 4] (barrage + new solar attacks)
- Increase boss scale from 6 to 7 for larger visual presence
- Attacks should feel "intense" with faster projectile speed or tighter patterns
- Maintain kid-friendly dodgeability with clear visual telegraphing

**Level 3 Boss: Outer Solar Theme Attacks**

- Add attack index 5: "Ice Shards" - many slow-moving projectiles in a wide spread pattern
- Add attack index 6: "Frozen Nova" - delayed burst that expands outward slowly
- Configure level_3.json to use attacks [0, 1, 5, 6] (barrage + sweep + new ice attacks)
- Increase boss scale from 8 to 9 for even larger visual presence
- Attacks should feel "expansive" with more projectiles but slower speeds
- Maintain kid-friendly dodgeability with generous timing windows

**Attack Pattern Implementation**

- Extend AttackState enum if needed for new attack phases
- Add new attack methods following existing pattern: `_attack_solar_flare()`, `_attack_heat_wave()`, etc.
- Extend `_execute_attack()` match statement to handle attack indices 3, 4, 5, 6
- Each attack should emit `attack_fired` signal for audio hooks
- All attacks must use existing `boss_projectile.gd` scene

**Projectile Variants via Configuration**

- Modify `boss_projectile.gd` to accept speed parameter for variant behaviors
- Solar attacks (3, 4): faster projectiles (speed 900-1000 vs default 750)
- Ice attacks (5, 6): slower projectiles (speed 400-500) but more numerous
- No new projectile scenes needed - configure speed on spawn

**Difficulty Progression**

- Level 1: Health 10, Scale 5, Attacks [0], Cooldown 1.5s (unchanged)
- Level 2: Health 13, Scale 7, Attacks [0, 3, 4], Cooldown 1.3s
- Level 3: Health 16, Scale 9, Attacks [0, 1, 5, 6], Cooldown 1.1s
- Each boss harder than previous but all attacks dodgeable by ages 6-12

**Level JSON Configuration Updates**

- Update level_2.json boss_config with new attacks array and increased scale
- Update level_3.json boss_config with new attacks array and increased scale
- Existing configuration fields (health, attack_cooldown, explosion_scale) remain unchanged

## Visual Design

No visual mockups provided. Implementation should follow existing boss visual patterns.

## Leverage Existing Knowledge

**Boss attack state machine and pattern cycling**

Existing boss.gd implements a robust state machine for attack cycling.

Boss Attack Implementation
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:42-47] - AttackState enum (IDLE, WIND_UP, ATTACKING, COOLDOWN)
   - Extend this enum only if new attacks require additional states
   - Current states handle instant attacks (barrage) and tween-based attacks (sweep, charge)
   - New attacks likely fit within existing state flow
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:100-104] - _enabled_attacks array and _attack_count
   - New attack indices (3, 4, 5, 6) automatically supported by this system
   - Just add new indices to level JSON attacks array
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:202-211] - _execute_attack() match statement
   - Add cases for 3, 4, 5, 6 to route to new attack methods
   - Follow existing pattern of calling private attack methods

**Horizontal barrage attack pattern**

Template for projectile-based attacks.

Barrage Attack Pattern
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:214-250] - _attack_horizontal_barrage()
   - Spawns 5-7 projectiles with spread angles
   - Sets direction on each projectile via set_direction()
   - Adds projectiles to parent scene
   - Emits attack_fired signal for audio
   - Use this as template for Solar Flare (radial) and Ice Shards (wide spread)

**Vertical sweep attack pattern**

Template for movement-based attacks with continuous fire.

Sweep Attack Pattern
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:253-276] - _attack_vertical_sweep()
   - Uses tween for boss movement during attack
   - Fires projectiles at intervals via _process_sweep_projectiles()
   - Calls _on_sweep_complete() when done to transition state
   - Use this as template for Heat Wave (arc sweep with fire)

**Boss projectile with configurable direction**

Existing projectile supports direction but needs speed configuration.

Boss Projectile
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss_projectile.gd:7-9] - Exported speed property (default 750)
   - Can be modified after instantiation before adding to scene
   - Solar attacks: set speed to 900-1000
   - Ice attacks: set speed to 400-500
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss_projectile.gd:46-48] - set_direction() method
   - Normalizes direction for spread patterns
   - Works correctly with modified speeds

**Boss configuration from level JSON**

Existing configure() method handles attacks array.

Boss Configuration
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:615-656] - configure() method
   - Already reads attacks array from config dictionary
   - Handles health, scale, attack_cooldown, explosion_scale
   - No changes needed - just update JSON files with new attack indices

**Level manager boss spawning and configuration**

Shows how boss_config is passed from level metadata.

Level Manager Boss Setup
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:475-477] - Reads boss_config from level metadata
   - Passes config to boss.configure() automatically
   - New attacks configured via JSON with no code changes to level_manager

**Test pattern for boss attack cycling**

Template for testing new attack patterns.

Boss Pattern Test
- [@/Users/matt/dev/space_scroller/tests/test_boss_patterns.gd:95-98] - Configuring boss with attack array
   - Shows how to set up boss for testing specific attack patterns
   - Use this pattern to test new attacks [3, 4] and [5, 6]
- [@/Users/matt/dev/space_scroller/tests/test_boss_patterns.gd:112-149] - Monitoring attack pattern cycling
   - Tracks _current_pattern and position changes
   - Extend to verify new attack indices are observed

**Git Commit found**

Level 2 and Level 3 theme implementation patterns.

Level theme configuration
- [e68f654:Add Level 2 with Inner Solar System theme] - Pattern for level-specific boss configuration
   - Shows boss_sprite, boss_config structure in JSON
   - Demonstrates obstacle_modulate and background_theme usage
   - Follow same pattern for updating boss_config.attacks array
- [7090f27:Add Level 3 with Outer Solar System ice theme] - Extended level configuration
   - Shows boss_modulate for color tinting
   - Demonstrates higher enemy counts and difficulty scaling
   - Pattern for increasing boss scale in JSON config

## Out of Scope

- New boss classes or entirely separate boss scripts (extend existing boss.gd only)
- Boss for level 4 (boss-4.png sprite reserved for future)
- New enemy types
- New levels
- Audio/music changes (handled by roadmap item 15)
- New visual effects or particles (handled by roadmap item 16)
- New sprites or art assets
- Changes to boss entrance animation or defeat animation
- Modifications to boss health bar UI
- Changes to player respawn during boss fight
