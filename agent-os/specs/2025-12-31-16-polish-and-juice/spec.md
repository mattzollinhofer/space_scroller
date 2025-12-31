# Specification: Polish and Juice

## Goal

Add visual polish and "juice" effects to enhance game feel through projectile trails, impact particles, and boss attack telegraphs, making the game more responsive and satisfying while remaining accessible for younger players.

## User Stories

- As a player, I want visual feedback when my projectiles hit enemies so that combat feels impactful and satisfying
- As a younger player, I want clear visual cues before boss attacks so that I can anticipate and dodge them more easily

## Specific Requirements

**Player projectiles display trail effect**

- Add CPUParticles2D child node to projectile scene for trail particles
- Emit small particles behind the projectile as it moves
- Keep particle count conservative (10-20 particles) for web performance
- Use subtle glow/fade effect on trail particles
- Trail should disappear shortly after projectile despawns

**Sidekick projectiles share same trail effect**

- Sidekick uses same projectile scene as player (res://scenes/projectile.tscn)
- No additional work needed - trail automatically applies to sidekick shots
- Verify visual consistency between player and sidekick projectiles

**Enemy hit shows minimal impact spark**

- Add CPUParticles2D burst effect when projectile hits enemy
- Spawn particle effect at collision point in take_hit() before queue_free()
- Short burst duration (0.2-0.3s) with outward spread pattern
- Conservative particle count (5-10 particles) for performance
- Effect should auto-free after emission completes

**Boss barrage attack has visual telegraph**

- Add visual warning before _attack_horizontal_barrage() fires
- Options: pulsing glow, color shift to warning color, scale pulse
- Telegraph duration matches wind_up_duration (0.5s default)
- Reset visual state after attack fires

**Boss sweep attack has visual telegraph**

- Add visual warning before _attack_vertical_sweep() begins
- Same telegraph style as barrage for consistency
- Clear indication that boss is about to move and fire

**Boss charge attack has visual telegraph**

- Add visual warning before _attack_charge() lunges
- Most important telegraph since charge is fastest/most dangerous
- Consider brighter or more dramatic effect than other attacks

**Telegraph implementation approach**

- Add _play_attack_telegraph() method to boss.gd
- Call at start of WIND_UP state in _process_attack_state()
- Use tween-based modulate animation on AnimatedSprite2D
- Pulse between normal and warning color (e.g., Color(1.5, 1.0, 1.0))
- Clean up telegraph tween before executing attack

**CPUParticles2D configuration for projectile trail**

- emission_shape: Point or small sphere
- direction: Vector2(-1, 0) (backward from projectile movement)
- spread: 15-30 degrees
- initial_velocity: 50-100 (slower than projectile)
- scale_amount_min/max: 0.5-1.0
- color: Match laser-bolt sprite color with fade
- lifetime: 0.3-0.5 seconds

**CPUParticles2D configuration for impact spark**

- one_shot: true (burst effect)
- emission_shape: Point
- direction: Vector2(0, 0) with high spread (180 degrees)
- initial_velocity: 100-150
- gravity: Vector2(0, 0)
- scale_amount_min/max: 0.3-0.8
- color: Bright white/yellow with quick fade
- lifetime: 0.2-0.3 seconds

## Visual Design

No visual assets provided. Implementation should follow existing game aesthetic and Godot best practices for 2D particle effects.

## Leverage Existing Knowledge

**Code, component, or existing logic found**

Hit flash effect pattern in base_enemy.gd

- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:126-148] - White modulate flash with elastic scale bounce
  - Stores original modulate and scale before applying effect
  - Uses create_tween() with set_parallel(true) for simultaneous animations
  - TRANS_ELASTIC gives satisfying bounce feel
  - Tween management pattern prevents overlapping effects with _flash_tween.kill()
  - Same pattern should be adapted for boss attack telegraph

Boss hit flash and screen shake

- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:413-434] - Boss-specific hit flash using AnimatedSprite2D
  - Demonstrates accessing sprite via get_node_or_null("AnimatedSprite2D")
  - Shows modulate Color(3.0, 3.0, 3.0, 1.0) for bright white flash
  - Telegraph effect should use similar approach but different colors

Boss screen shake implementation

- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:467-504] - Shake effect on Main node
  - Example of effect that manipulates parent node position
  - Uses randf_range for random offsets
  - Decreasing intensity pattern over multiple steps
  - Reference for understanding effect scope and cleanup

Boss attack state machine

- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:170-199] - Attack state machine in _process_attack_state()
  - WIND_UP state is where telegraph should be triggered
  - Current wind_up_duration is 0.5 seconds
  - Telegraph must complete before ATTACKING state begins
  - Clear state transitions provide hook points for effects

Boss attack execution methods

- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:202-212] - _execute_attack() pattern dispatch
  - Shows where actual attacks fire after wind-up
  - Telegraph cleanup should happen here before attack logic

Projectile structure and scene

- [@/Users/matt/dev/space_scroller/scenes/projectile.tscn:1-20] - Projectile scene structure
  - Area2D root with Sprite2D and CollisionShape2D children
  - CPUParticles2D should be added as sibling to Sprite2D
  - Scale is Vector2(2, 2) on sprite

Projectile hit detection

- [@/Users/matt/dev/space_scroller/scripts/projectile.gd:32-37] - _on_area_entered collision handler
  - Calls area.take_hit(damage) then queue_free()
  - Impact particle must spawn BEFORE queue_free()
  - Need to spawn particle at current position in parent

Destruction animation pattern

- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:168-192] - Explosion with scale and fade
  - Creates Sprite2D dynamically with explosion.png texture
  - Uses tween for scale up and modulate:a fade
  - tween.chain().tween_callback(queue_free) for cleanup
  - Impact particle should follow similar spawn-and-cleanup pattern

Transition manager tween patterns

- [@/Users/matt/dev/space_scroller/scripts/autoloads/transition_manager.gd:45-58] - Clean tween creation
  - Shows _stop_current_tween() pattern for cleanup
  - Demonstrates tween property animation on color:a
  - Good reference for tween lifecycle management

Sidekick projectile firing

- [@/Users/matt/dev/space_scroller/scripts/pickups/sidekick.gd:92-106] - Sidekick uses same projectile scene
  - Confirms single projectile.tscn modification covers both player and sidekick
  - Spawn position offset matches player pattern

Star pickup collect animation

- [@/Users/matt/dev/space_scroller/scripts/pickups/star_pickup.gd:120-137] - Scale up and fade pattern
  - Simple tween-based visual feedback
  - Same pattern suitable for impact particles

**Git Commit found**

Boss victory sequence with screen shake

- [ffec22a:Add boss victory sequence with screen shake and explosion] - Screen shake and explosion implementation
  - Shake effect uses Main node position manipulation
  - Explosion sprite created dynamically and animated
  - tween.chain().tween_callback(queue_free) pattern for cleanup
  - Good reference for effect timing and visual feedback

Enemy visual feedback improvements

- [c8d95fb:Improve enemy behavior and visual feedback] - Hit flash and explosion patterns
  - Bright white flash + scale punch pattern
  - Explosion sprite on death
  - Foundation for current hit flash implementation

Red flash feedback for patrol enemy

- [2ae7cda:Add patrol enemy 2-hit health system with red flash feedback] - Original hit flash implementation
  - Shows color-based modulate for damage feedback
  - Tween-based restore to original state
  - Pattern for any modulate-based visual effect

Boss attack patterns implementation

- [ea034a1:Add vertical sweep and charge attacks to boss battle] - Attack pattern implementation
  - Shows attack state machine and timing
  - Tween-based movement for sweep and charge
  - Reference for understanding attack flow and timing

Smooth fade transitions

- [71be875:Add smooth fade transitions between game screens] - TransitionManager patterns
  - Clean tween creation and management
  - Example of global effect system
  - Pattern for _stop_current_tween() cleanup

Sidekick destruction animation

- [01ac005:Add sidekick destruction on enemy contact with visual feedback] - Destruction animation
  - Scale-up and fade-out pattern
  - Proper signal cleanup before destruction
  - Reference for visual feedback on object destruction

## Out of Scope

- Additional screen shake effects beyond existing boss defeat shake
- Enhanced player damage feedback (keep existing invincibility flash only)
- Muzzle flash effects when player or sidekick fires
- Engine/thruster trail effects on player ship
- Enhanced pickup animations (deferred to future roadmap item)
- Enemy projectile visual enhancements (already distinct with red tint)
- Any effects that cause rapid flashing (photosensitivity concern)
- GPUParticles2D usage (CPUParticles2D only for web compatibility)
- Particle effects on enemy death (keep existing explosion sprite)
- Boss entrance animation enhancements
