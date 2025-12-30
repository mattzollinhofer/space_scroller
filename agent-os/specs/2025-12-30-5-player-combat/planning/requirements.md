# Spec Requirements: Player Combat

## Initial Description

Add player shooting mechanics with projectiles that can destroy enemies, including visual and audio feedback.

## Requirements Discussion

### First Round Questions

**Q1:** I assume projectiles will be fired by pressing a button/tapping the screen. For controls, I'm thinking:
- Touch: Tap anywhere on screen (or tap a dedicated fire button)
- Keyboard: Spacebar or another key

Should firing be automatic (hold to continuously fire) or require repeated presses? I'm assuming auto-fire when holding would be better for mobile.
**Answer:** Auto-fire when holding.

**Q2:** I found an existing `laser-bolt.png` sprite in `assets/sprites/`. Should we use this for the player's projectile, or do you have something else in mind?
**Answer:** Yes, use the existing `laser-bolt.png`.

**Q3:** For projectile behavior, I assume:
- Projectiles travel from left to right (direction player faces)
- Speed should be faster than scroll speed (maybe 800-1000 px/s)
- Despawn when leaving screen on the right edge

Is this correct, or should projectiles also be able to fire in other directions?
**Answer:** Yes, left-to-right only, faster than scroll speed, despawn off-screen.

**Q4:** For fire rate, I'm thinking a cooldown between shots (maybe 0.2-0.3 seconds) to prevent spam while keeping it responsive. Does this feel right, or should it be faster/slower for a kid-friendly feel?
**Answer:** On the faster side - 0.1-0.15 seconds cooldown instead of 0.2-0.3.

**Q5:** The enemy system already has a health property (currently 1) and a `died` signal. I assume projectiles should reduce enemy health by 1 on hit. Should enemies have different health values (e.g., patrol enemies take 2 hits)? Or keep all enemies at 1 HP for now?
**Answer:** Different enemy types should have different health values.

**Q6:** The enemy death animation already exists (explosion sprite that scales up and fades). For projectile-hit feedback, should we:
- Reuse this explosion for both collision deaths and projectile kills?
- Add a smaller hit effect when projectile connects (even before death)?
- Just use the existing death animation?
**Answer:** Not sure about reusing explosion, but wants a pulse/strobe/flash effect when hit (before death).

**Q7:** Should projectiles pass through enemies after hitting (piercing) or be destroyed on contact? I'm assuming destroyed on contact (one projectile = one hit).
**Answer:** Yes, destroyed on contact (1 projectile = 1 hit).

**Q8:** Audio feedback is mentioned in the roadmap description. Should we add placeholder sound effect hooks now (functions/signals that can be connected later), or defer all audio to the Audio Integration spec (roadmap item 13)?
**Answer:** Add placeholder hooks for audio, no actual audio implementation yet.

**Q9:** Is there anything specific you want to exclude from this combat system? For example: multiple weapon types, charged shots, limited ammo, or projectile-obstacle interactions (shooting asteroids)?
**Answer:** Yes, keep it simple - exclude multiple weapons, charged shots, limited ammo, shooting asteroids.

### Existing Code to Reference

**Similar Features Identified:**

- Feature: Player character - Path: `scripts/player.gd`
  - CharacterBody2D with input handling, damage system, lives, invincibility
  - Signals: `damage_taken`, `lives_changed`, `died`
  - Uses `Input.get_vector()` for keyboard, virtual joystick for touch
- Feature: Base enemy system - Path: `scripts/enemies/base_enemy.gd`
  - Area2D with health system, `died` signal, destruction animation
  - Uses `body_entered` signal for collision detection
  - Already has explosion animation using `assets/sprites/explosion.png`
- Feature: Patrol enemy - Path: `scripts/enemies/patrol_enemy.gd`
  - Extends BaseEnemy, demonstrates inheritance pattern
- Feature: Enemy spawner - Path: `scripts/enemies/enemy_spawner.gd`
  - Spawner pattern for managing entity lifecycle
- Feature: Player scene - Path: `scenes/player.tscn`
  - Scene structure with Sprite2D, CollisionShape2D
- Feature: Main scene - Path: `scenes/main.tscn`
  - Shows how spawners and player integrate into scene tree

### Follow-up Questions

**Follow-up 1:** Regarding different health values for enemy types: I'm thinking of these defaults:
- Stationary Enemy: 1 HP (one-shot kill)
- Patrol Enemy: 2 HP (takes two hits)

Does this feel right for the kid-friendly difficulty?
**Answer:** Yes, confirmed - Stationary = 1 HP, Patrol = 2 HP.

**Follow-up 2:** For the pulse/strobe/flash effect when hit - should this be:
- A quick white flash (enemy briefly turns white/bright)
- A color tint flash (enemy briefly turns red)
- A scale pulse (enemy briefly grows/shrinks)

I'm leaning toward a quick white flash (0.1-0.15 seconds) as it's clear and commonly used. Does that work?
**Answer:** Color tint (red flash), timing of 0.1-0.15 seconds sounds good.

## Visual Assets

### Files Provided:

No visual assets provided in the planning/visuals folder.

### Visual Insights:

- Existing projectile sprite available at `assets/sprites/laser-bolt.png`
- Existing explosion sprite at `assets/sprites/explosion.png` (used for enemy death)
- Existing energy orb sprite at `assets/sprites/energy-orb.png` (potential future use)
- All existing sprites in project are available for use
- Fidelity level: Production-ready sprite assets

## Requirements Summary

### Functional Requirements

- **Projectile Firing System**: Player can shoot projectiles
  - Auto-fire when holding fire button (continuous shooting)
  - Fire rate: 0.1-0.15 second cooldown between shots (fast, responsive)
  - Projectiles spawn from player position

- **Input Controls**:
  - Touch: Tap/hold to fire (dedicated fire button or screen area)
  - Keyboard: Key press/hold to fire (e.g., Spacebar)

- **Projectile Behavior**:
  - Travel left-to-right (direction player faces)
  - Speed faster than world scroll speed (800-1000+ px/s recommended)
  - Despawn when leaving screen on right edge
  - Destroyed on contact with enemy (1 projectile = 1 hit)
  - Do NOT interact with obstacles/asteroids (pass through)

- **Projectile Visuals**:
  - Use existing `assets/sprites/laser-bolt.png` sprite

- **Enemy Health System Updates**:
  - Stationary Enemy: 1 HP (one-shot kill)
  - Patrol Enemy: 2 HP (requires two hits)
  - Projectile hit reduces enemy health by 1

- **Hit Feedback - Red Flash Effect**:
  - When enemy takes damage but survives: red color tint flash
  - Flash duration: 0.1-0.15 seconds
  - Enemy returns to normal color after flash
  - Provides clear visual feedback that hit registered

- **Death Animation**:
  - Use existing explosion animation system in BaseEnemy
  - Triggers when enemy health reaches 0 (from projectile or collision)

- **Audio Placeholder Hooks**:
  - Add signals/functions for future audio integration
  - Shooting sound hook (when projectile fires)
  - Hit sound hook (when projectile hits enemy)
  - No actual audio implementation (deferred to roadmap item 13)

### Reusability Opportunities

- **Player input system**: Extend existing input handling in `player.gd` for fire button
- **Enemy health system**: Already exists in `base_enemy.gd`, just need to update default values
- **Death animation**: Already implemented in `base_enemy.gd` with explosion sprite
- **Area2D pattern**: Use same pattern as enemies for projectile collision detection
- **Spawner pattern**: Could reference `enemy_spawner.gd` for projectile pooling if needed
- **Scene structure**: Follow existing patterns from `player.tscn` and enemy scenes

### Scope Boundaries

**In Scope:**

- Single projectile type (laser bolt)
- Auto-fire mechanic with fast fire rate (0.1-0.15s cooldown)
- Left-to-right projectile movement
- Projectile-enemy collision detection
- Enemy health differentiation (1 HP stationary, 2 HP patrol)
- Red flash hit feedback effect
- Existing explosion death animation
- Audio placeholder hooks (signals/functions)
- Touch and keyboard input support

**Out of Scope:**

- Multiple weapon types
- Charged shots
- Limited ammo system
- Projectile-obstacle interactions (cannot shoot asteroids)
- Actual audio implementation (deferred to Audio Integration spec)
- Power-ups or weapon upgrades
- Enemy projectiles/shooting back
- Scoring for kills (handled in Score System spec)

### Technical Considerations

- **Projectile node type**: Area2D for collision detection with enemies
- **Collision layers**: Projectiles need own layer, mask for enemies only (not obstacles)
- **Projectile scene**: Separate scene (`projectile.tscn`) for instantiation
- **Fire input**: Add new input action to InputMap (e.g., "fire" or "shoot")
- **Cooldown timer**: Track time since last shot in player script
- **Projectile speed**: Should be significantly faster than scroll speed (180 px/s) - recommend 800-1000 px/s
- **Red flash effect**: Use `modulate` property on enemy sprite, tween back to normal
- **Audio hooks**: Emit signals like `projectile_fired`, `enemy_hit` for future connection
- **Viewport size**: 2048x1536 pixels
- **World scroll speed**: 180 px/s (from base_enemy.gd)
- **Playable Y range**: 80-1456 pixels (projectiles should work within this range)
