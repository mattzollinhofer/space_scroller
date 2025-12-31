# Spec Requirements: Polish and Juice

## Initial Description

Add visual polish and "juice" effects to the Space Scroller game - things like screen shake, particle effects, hit feedback, and other satisfying visual flourishes that make the game feel more responsive and enjoyable. This is roadmap item 16.

## Requirements Discussion

### First Round Questions

**Q1:** I assume screen shake should be applied to more moments than just boss death - such as player taking damage, large explosions, and boss attacks. Is that correct, or should we keep screen shake minimal/boss-only?
**Answer:** Boss only - keep it minimal.

**Q2:** For particle effects, I'm thinking we should add: muzzle flash/burst when player/sidekick shoots, impact sparks when projectiles hit enemies, engine trails on the player ship, star/sparkle effects for pickups. Should we prioritize all of these, or focus on a subset?
**Answer:** Not too much, user is unsure about specifics. Conservative approach.

**Q3:** The player currently just flashes when taking damage. I'm thinking we could add brief screen shake, red screen flash/vignette, knockback effect. Do you want all of these, or prefer to keep damage feedback simple for the kid-friendly audience?
**Answer:** Keep it toned down for now.

**Q4:** I assume we should use Godot's GPUParticles2D for performance on mobile/web. Is that correct, or do you prefer simpler Sprite-based animations for maximum compatibility?
**Answer:** User deferred to recommendation. CPUParticles2D recommended and approved for better web/HTML5 compatibility.

**Q5:** For projectile visuals, should we: add a trail/glow effect to player projectiles, make enemy projectiles visually distinct with their own effects, add impact explosions when projectiles hit anything?
**Answer:** Yes to trails on player projectiles. Enemy projectiles are already visually distinct. Impact explosions: yes, but keep minimal.

**Q6:** I notice pickups have basic animations but could use more "pop". Should pickups get full juice treatment, or keep them simpler since they're less frequent?
**Answer:** Simpler for now, but user wants a roadmap item added to revisit this later with more juice.

**Q7:** Should we add anticipation/wind-up visual cues for boss attacks? Currently the boss has a brief wind-up time but no visual telegraph.
**Answer:** Yes, definitely add visual telegraphs.

**Q8:** Is there anything you specifically want to exclude from this polish pass?
**Answer:** Avoid distracting effects and anything that could cause issues for flash-sensitive players.

### Existing Code to Reference

Based on codebase analysis, the following existing patterns should be referenced:

**Similar Features Identified:**

- Feature: Enemy hit flash - Path: `/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd` (lines 126-147)
  - White modulate flash + scale bounce using Elastic tween
  - Good pattern for visual feedback without being overwhelming

- Feature: Boss screen shake - Path: `/Users/matt/dev/space_scroller/scripts/enemies/boss.gd` (lines 464-501)
  - Shakes Main node with decreasing intensity
  - Uses tween with random offsets

- Feature: Boss hit flash - Path: `/Users/matt/dev/space_scroller/scripts/enemies/boss.gd` (lines 410-431)
  - Similar to enemy flash but with scale multiplier

- Feature: Explosion animation - Path: `/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd` (lines 166-190)
  - Sprite-based explosion with scale up and fade out
  - Uses existing explosion.png asset

- Feature: Pickup collect animation - Path: `/Users/matt/dev/space_scroller/scripts/pickups/star_pickup.gd` (lines 120-137)
  - Scale up and fade out pattern

- Feature: Player invincibility flash - Path: `/Users/matt/dev/space_scroller/scripts/player.gd` (lines 124-137)
  - Visibility toggling at interval

### Follow-up Questions

**Follow-up 1:** Regarding GPUParticles2D vs CPUParticles2D - recommended CPUParticles2D for better web/HTML5 compatibility, simpler implementation, and predictable cross-platform behavior.
**Answer:** CPUParticles2D approach approved.

**Follow-up 2:** Should roadmap item for pickup juice be noted in requirements or should specific wording be suggested?
**Answer:** Just note it in requirements for user to add later.

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

N/A - No reference materials provided. Implementation should follow existing game aesthetic and Godot best practices for 2D particle effects.

## Requirements Summary

### Functional Requirements

**Screen Shake:**
- Keep existing boss defeat screen shake
- Do NOT add screen shake to other moments (player damage, explosions, etc.)
- Screen shake remains boss-only for minimal/focused impact

**Particle Effects (using CPUParticles2D):**
- Add trail effect to player projectiles (and sidekick projectiles for consistency)
- Add minimal impact explosion/spark when projectiles hit enemies
- Conservative approach - avoid overwhelming visual noise
- No muzzle flash or engine trails in this iteration

**Boss Attack Anticipation:**
- Add visual telegraph cues before boss attacks
- Options: glow effect, color shift, pulsing, or subtle shake
- Help younger players anticipate and react to incoming attacks
- Apply to all three attack patterns: barrage, sweep, and charge

**Projectile Enhancements:**
- Player projectiles: Add subtle trail/glow effect
- Enemy projectiles: Already visually distinct, no changes needed
- Impact effects: Small spark/burst on hit, keep minimal

**Player Damage Feedback:**
- Keep existing invincibility flash system
- Do NOT add additional effects (no screen shake, vignette, knockback)
- Toned down approach appropriate for kid-friendly audience

**Pickups:**
- Keep existing simple animations for now
- Note: Future roadmap item should be added to revisit pickup juice (pulsing glow, sparkle particles, collection burst)

### Accessibility Considerations

- Avoid rapid flashing that could affect photosensitive players
- Keep effects subtle and non-distracting
- Ensure visual feedback enhances rather than overwhelms gameplay
- Test effects at reasonable intervals to prevent sensory overload

### Technical Approach

- Use **CPUParticles2D** for all particle effects (better web/HTML5 compatibility)
- Leverage existing tween-based animation patterns in codebase
- Follow established visual feedback patterns (modulate flash, scale bounce)
- Ensure effects work consistently across iPad and web platforms

### Reusability Opportunities

- Existing explosion sprite and animation pattern can be adapted for impact effects
- Enemy hit flash pattern provides template for other visual feedback
- Boss screen shake implementation is already well-structured for reference

### Scope Boundaries

**In Scope:**
- Player projectile trails
- Minimal projectile impact effects
- Boss attack visual telegraphs
- CPUParticles2D implementation for new effects

**Out of Scope:**
- Additional screen shake (beyond existing boss defeat)
- Enhanced player damage feedback
- Muzzle flash effects
- Engine/thruster trails
- Enhanced pickup animations (deferred to future roadmap item)
- Enemy projectile enhancements
- Any effects that could be distracting or flash-sensitive

### Technical Considerations

- CPUParticles2D chosen for web/HTML5 compatibility over GPUParticles2D
- Must maintain performance on iPad and browser targets
- Particle counts should be conservative
- Effects should not interfere with gameplay visibility
- Integration with existing signal system for audio hooks (projectile_fired, hit_by_projectile, etc.)

### Future Roadmap Note

User requested a future roadmap item be added for "Pickup Juice Enhancement" to revisit pickup animations with more polish:
- Pulsing glow effects
- Sparkle particles on spawn
- Enhanced collection burst animations
- This was intentionally deferred from current scope to keep this feature focused
