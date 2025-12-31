# Specification: Boss Battle

## Goal

Create an end-of-level boss encounter with health bar, three attack patterns, and victory sequence that triggers when the player reaches 100% level progress.

## User Stories

- As a player, I want to fight a challenging boss at the end of the level so that completing the level feels rewarding
- As a player, I want visual feedback on boss health so I know how close I am to victory

## Specific Requirements

**Boss appears when level reaches 100% progress**

- Hook into existing `level_completed` signal from LevelManager
- Modify LevelManager to spawn boss instead of showing level complete screen immediately
- Boss spawns off-screen to the right (matching enemy spawn patterns)
- Level complete screen only shows after boss is defeated

**Boss enters from right side with entrance animation**

- Boss starts at x position beyond viewport (e.g., viewport_width + 200)
- Tween animation slides boss into battle position (right third of screen)
- Use AnimatedSprite2D alternating between boss-1.png and boss-2.png for idle animation
- Player cannot damage boss during entrance animation

**Screen scrolling stops during boss fight**

- Set ParallaxBackground scroll_speed to 0 when boss fight begins
- Disable obstacle and enemy spawners during boss fight
- Creates fixed arena for contained battle

**Boss has 13 health points with visual health bar**

- Health bar positioned in bottom-right corner (opposite player health in top-left)
- Use CanvasLayer for HUD consistency with existing UI
- Visual bar fills from right-to-left as boss takes damage
- Bar uses contrasting color (red or purple) to distinguish from progress bar

**Three distinct attack patterns cycle**

- Pattern 1: Horizontal projectile barrage (fires 5-7 projectiles in spread)
- Pattern 2: Vertical sweep attack (boss moves up/down while firing)
- Pattern 3: Charge/rush at player (boss moves toward player position, then returns)
- Patterns cycle with brief cooldown between each
- Boss projectiles use same collision system as player projectiles (reversed direction)

**Victory sequence with dramatic effects**

- Screen shake effect when boss health reaches 0 (camera/viewport shake)
- Explosion animation using existing explosion.png scaled up
- Brief pause before showing level complete screen
- Emit signal for future audio hook integration

**Player respawns at boss entrance if defeated**

- Save checkpoint when boss fight begins
- If player dies during boss fight, respawn at boss entrance position
- Reset boss health to full on respawn
- Clear any active boss projectiles on respawn

## Visual Design

No mockup visuals provided. Use existing sprite assets:

**`res://assets/sprites/boss-1.png`**
- Purple dragon-like creature sprite (first animation frame)
- Use for idle animation alternating with boss-2.png
- Scale appropriately (3-4x) to make boss visually imposing
- Collision shape should match sprite bounds

**`res://assets/sprites/boss-2.png`**
- Purple dragon-like creature sprite (second animation frame)
- Slightly different pose for animation variety
- Same scale and collision as boss-1.png

## Leverage Existing Knowledge

**Code, component, or existing logic found**

Enemy health and damage system
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:6-11] - Health property with setter that triggers death
   - Boss should use similar health property pattern with exported value of 13
   - Reuse `_on_health_depleted()` pattern for boss death trigger
   - Reuse `take_hit(damage)` method signature for projectile compatibility

- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:110-133] - Hit flash effect for damage feedback
   - Boss should use same white flash + scale punch effect when hit
   - Uses tween for smooth animation restoration
   - Stores original modulate/scale before applying effect

- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:151-176] - Destruction animation with explosion
   - Boss death should use similar but larger explosion effect
   - Add screen shake before explosion for dramatic effect
   - Use explosion.png texture scaled up for boss-sized explosion

Level completion and signal integration
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:227-244] - Level complete trigger at 100% progress
   - Modify `_check_level_complete()` to spawn boss instead of immediate completion
   - Add `boss_defeated` signal to trigger actual level completion
   - Keep `level_completed` signal for boss spawn trigger

- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:277-313] - Checkpoint respawn system
   - Extend checkpoint system to save boss fight state
   - Use `respawn_player()` pattern but also reset boss health
   - Clear boss projectiles similar to `clear_all()` calls

Scroll controller for stopping scrolling
- [@/Users/matt/dev/space_scroller/scripts/scroll_controller.gd:1-12] - Simple scroll speed control
   - Set `scroll_speed = 0.0` when boss fight begins
   - Store original speed to restore if needed

Projectile system for boss attacks
- [@/Users/matt/dev/space_scroller/scripts/projectile.gd:1-38] - Projectile movement and collision
   - Create boss_projectile.gd variant that moves left instead of right
   - Use same Area2D collision detection pattern
   - Despawn at left edge instead of right

- [@/Users/matt/dev/space_scroller/scenes/projectile.tscn] - Projectile scene structure
   - Boss projectile scene should mirror this structure
   - Use different sprite/color to distinguish from player projectiles

UI health bar pattern
- [@/Users/matt/dev/space_scroller/scripts/ui/progress_bar.gd:1-43] - Bar fill animation pattern
   - Boss health bar should use similar ColorRect background + fill approach
   - Position in bottom-right using Control anchors
   - Use `_update_fill()` pattern for smooth health updates

- [@/Users/matt/dev/space_scroller/scenes/ui/progress_bar.tscn:15-43] - ColorRect bar scene structure
   - Use same anchors_preset pattern for positioning
   - Container with Background and Fill ColorRects
   - Different color scheme (red fill for boss danger)

CanvasLayer for HUD
- [@/Users/matt/dev/space_scroller/scenes/ui/health_display.tscn:6-8] - CanvasLayer setup for UI
   - Boss health bar should use layer = 10 for HUD consistency
   - Use same process_mode pattern

Enemy spawner patterns
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:143-158] - Enemy setup and positioning
   - Boss spawn should use similar off-screen positioning
   - Connect signals for tracking and cleanup

Test patterns
- [@/Users/matt/dev/space_scroller/tests/test_level_complete.gd:1-109] - Integration test structure
   - Boss tests should follow same pattern: load main scene, manipulate state, verify outcome
   - Use timeout pattern for async operations
   - Test boss spawn, damage, and defeat sequence

- [@/Users/matt/dev/space_scroller/tests/test_checkpoint_respawn.gd:1-149] - Checkpoint respawn test pattern
   - Test boss checkpoint respawn follows same structure
   - Trigger player death during boss fight, verify respawn behavior

**Git Commit found**

Level completion signal implementation
- [238fc57:Show "Level Complete" screen when player finishes level] - Foundation for boss trigger
   - Shows how level_completed signal is emitted and consumed
   - Boss should intercept this signal to spawn instead of showing screen
   - Level complete screen shows after boss defeat instead

Checkpoint respawn system
- [ad60c3b:Add checkpoint respawn system for incremental level progress] - Respawn pattern to extend
   - Shows checkpoint save/restore pattern in LevelManager
   - Boss fight needs similar checkpoint at boss entrance
   - Player respawns with boss reset on death

Enemy health and damage feedback
- [2ae7cda:Add patrol enemy 2-hit health system with red flash feedback] - Multi-hit enemy pattern
   - Shows how to implement health > 1 enemies
   - Boss uses same pattern but with 13 HP
   - Flash feedback makes hits feel impactful

Player shooting integration
- [7ebb7ad:Add player shooting to destroy enemies with projectiles] - Projectile/enemy collision
   - Shows take_hit() method integration with projectiles
   - Boss uses same collision detection approach
   - Boss projectiles reverse the direction

Enemy behavior improvements
- [c8d95fb:Improve enemy behavior and visual feedback] - Movement and explosion patterns
   - Zigzag movement could inspire boss vertical sweep attack
   - Explosion sprite usage for death animation
   - White flash + scale punch for hit feedback

## Out of Scope

- Multiple boss phases (single continuous fight only)
- Invincibility windows during boss attacks
- Minion spawning during boss fight
- Complex AI behavior or learning patterns
- Multiple boss variants for this level
- Boss-specific music or audio (deferred to Audio Integration feature)
- Boss telegraph/warning indicators before attacks
- Difficulty scaling based on player performance
- Boss rage mode at low health
- Cutscenes or dialogue during boss encounter
