# Task Breakdown: Boss Battle

## Overview

Total Slices: 6
Each slice delivers incremental user value and is tested end-to-end.

The boss battle feature adds an end-of-level boss encounter with health bar, three attack patterns, and victory sequence. The boss appears when the player reaches 100% level progress, replacing the immediate level complete screen.

## Task List

### Slice 1: User sees boss appear when level reaches 100%

**What this delivers:** When the player reaches 100% progress, instead of seeing the level complete screen immediately, a boss appears from the right side of the screen with an entrance animation.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:227-244] - level_completed signal and _check_level_complete() to modify
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:143-158] - enemy positioning off right edge
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:1-45] - Area2D enemy pattern with signals
- [@/Users/matt/dev/space_scroller/tests/test_level_complete.gd:1-109] - integration test structure for level events
- [commit:238fc57] - Level complete signal implementation to hook into

#### Tasks

- [x] 1.1 Write integration test: boss spawns instead of level complete screen at 100%
  - Load main scene, speed up scroll to reach 100%
  - Verify level complete screen is NOT visible
  - Verify boss node exists in scene tree
- [x] 1.2 Run test, verify expected failure (no boss, level complete shows)
  - [failure: Level complete screen is visible - should be delayed for boss fight] -> Success after implementation
- [x] 1.3 Create boss scene (scenes/enemies/boss.tscn)
  - Area2D root node with CollisionShape2D
  - AnimatedSprite2D with boss-1.png and boss-2.png frames
  - Scale sprite 4x for imposing size
- [x] 1.4 Create boss script (scripts/enemies/boss.gd)
  - Extend Area2D
  - Signal `boss_defeated` for level manager
  - Signal `boss_entered` for when entrance completes
  - Basic structure following BaseEnemy pattern
- [x] 1.5 Modify LevelManager._on_level_complete() to spawn boss instead of showing level complete
  - Check if boss fight is active, defer level complete screen
  - Instantiate and add boss to scene
  - Position boss off right edge (viewport_width + 200)
- [x] 1.6 Implement boss entrance animation
  - Tween from spawn position to battle position (right third of screen)
  - Emit `boss_entered` signal when animation completes
  - Set `_entrance_complete` flag for damage immunity during entrance
- [x] 1.7 Run test, iterate until boss spawns correctly
  - Success - boss spawns and level complete screen does not show
- [x] 1.8 Verify manually: boss animates between boss-1 and boss-2 sprites
  - AnimatedSprite2D configured with idle animation at 3fps
- [x] 1.9 Commit working slice

**Acceptance Criteria:**
- [x] Player reaches 100% progress and boss appears from right side
- [x] Boss has entrance animation tweening into position
- [x] Level complete screen does NOT show during boss entrance
- [x] Boss sprite animates between two frames

---

### Slice 2: User can damage boss and sees health bar depleting

**What this delivers:** Player can shoot the boss, see hit feedback, and watch a health bar in the bottom-right corner decrease from 13 hits to 0.

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:6-11] - health property with setter
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:91-108] - take_hit() method
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:110-133] - hit flash effect
- [@/Users/matt/dev/space_scroller/scripts/ui/progress_bar.gd:1-43] - bar fill pattern
- [@/Users/matt/dev/space_scroller/scenes/ui/progress_bar.tscn:15-43] - ColorRect bar scene structure
- [@/Users/matt/dev/space_scroller/scripts/projectile.gd:32-37] - projectile collision with take_hit

#### Tasks

- [x] 2.1 Write integration test: boss takes damage and health bar updates
  - Spawn boss, fire projectile at boss
  - Verify boss health decreases
  - Verify health bar UI updates
- [x] 2.2 Run test, verify expected failure
  - [failure: Boss health bar not found in scene] -> Created health bar scene and script
- [x] 2.3 Add health system to boss.gd
  - `@export var health: int = 13` with setter (already implemented in Slice 1)
  - `_max_health` to track initial value for UI percentage (already implemented)
  - `take_hit(damage: int)` method matching enemy interface (already implemented)
  - Emit `health_changed` signal for UI binding (already implemented)
- [x] 2.4 Add hit flash effect to boss
  - Reuse pattern from base_enemy.gd _play_hit_flash() (already implemented in Slice 1)
  - White flash + scale punch on damage
  - Tween to restore original state
- [x] 2.5 Create boss health bar scene (scenes/ui/boss_health_bar.tscn)
  - CanvasLayer with layer = 10 (HUD layer)
  - Container anchored to bottom-right
  - Background ColorRect (dark, 80% opacity)
  - Fill ColorRect (red/purple for danger)
  - Label "BOSS" above bar
- [x] 2.6 Create boss health bar script (scripts/ui/boss_health_bar.gd)
  - `set_health(current: int, max_health: int)` method
  - Fill from right-to-left (opposite of progress bar)
  - `_update_fill()` pattern from progress_bar.gd
- [x] 2.7 Spawn health bar when boss enters, connect to health_changed
  - Added _spawn_boss_health_bar() to level_manager.gd
  - Connected boss.health_changed signal to _on_boss_health_changed
- [x] 2.8 Verify projectile collision triggers take_hit on boss
  - Projectile collision_mask = 2, Boss collision_layer = 2 (compatible)
  - Projectile._on_area_entered checks for take_hit method
- [x] 2.9 Run all slice tests (1 and 2) to verify no regressions
  - test_boss_spawn.tscn: PASSED
  - test_boss_damage.tscn: PASSED
- [x] 2.10 Commit working slice

**Acceptance Criteria:**
- [x] Boss has 13 HP that decreases when shot
- [x] Health bar appears in bottom-right corner when boss spawns
- [x] Health bar depletes visually as boss takes damage
- [x] Boss flashes white and scales when hit

---

### Slice 3: User fights boss with horizontal projectile barrage attack

**What this delivers:** Boss fires a spread of 5-7 projectiles at the player that move left across the screen. Player must dodge or take damage.

**Dependencies:** Slice 2

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/projectile.gd:1-38] - projectile movement pattern (reverse direction)
- [@/Users/matt/dev/space_scroller/scenes/projectile.tscn] - projectile scene structure
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:48-68] - movement and despawn pattern

#### Tasks

- [ ] 3.1 Write integration test: boss fires projectiles that can hit player
  - Start boss fight, wait for attack
  - Verify projectiles spawn and move left
  - Verify projectile can trigger player.take_damage()
- [ ] 3.2 Run test, verify expected failure
- [ ] 3.3 Create boss projectile scene (scenes/enemies/boss_projectile.tscn)
  - Area2D with CollisionShape2D
  - Sprite2D with different color/style than player projectiles
  - Collision layer set to interact with player
- [ ] 3.4 Create boss projectile script (scripts/enemies/boss_projectile.gd)
  - Move left (negative x direction) at configurable speed
  - Despawn at left edge (x < -100)
  - Call player.take_damage() on collision with CharacterBody2D
- [ ] 3.5 Add attack state machine to boss.gd
  - States: IDLE, ATTACKING, COOLDOWN
  - Attack cooldown timer between patterns
  - Track current attack pattern index
- [ ] 3.6 Implement horizontal barrage attack (Pattern 1)
  - Spawn 5-7 projectiles in spread pattern
  - Calculate spread angles from boss position toward left
  - Brief wind-up delay before firing
- [ ] 3.7 Add boss_projectile_scene export to boss.gd
- [ ] 3.8 Run all slice tests to verify no regressions
- [ ] 3.9 Commit working slice

**Acceptance Criteria:**
- Boss periodically fires a spread of 5-7 projectiles
- Projectiles move left across screen
- Player takes damage if hit by boss projectile
- Projectiles despawn when leaving screen

---

### Slice 4: User fights boss with vertical sweep and charge attacks

**What this delivers:** Boss has two additional attack patterns: moving up/down while firing, and charging toward the player position then returning. Patterns cycle with cooldowns.

**Dependencies:** Slice 3

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:48-68] - vertical movement with Y bounds
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:20-21] - Y_MIN and Y_MAX constants

#### Tasks

- [ ] 4.1 Write integration test: boss cycles through multiple attack patterns
  - Start boss fight, wait through multiple attacks
  - Verify boss position changes (vertical sweep, charge)
  - Verify pattern cycling occurs
- [ ] 4.2 Run test, verify expected failure
- [ ] 4.3 Implement vertical sweep attack (Pattern 2)
  - Boss tweens up/down while firing single projectiles
  - Use Y_MIN/Y_MAX bounds from base_enemy constants
  - Fire projectiles at intervals during sweep
- [ ] 4.4 Implement charge attack (Pattern 3)
  - Store player position at attack start
  - Tween boss toward player X position (not all the way to avoid overlap)
  - Pause briefly, then tween back to battle position
  - Player takes contact damage if boss overlaps
- [ ] 4.5 Add body_entered collision for charge attack damage
  - Connect to player CharacterBody2D collision
  - Call player.take_damage() on contact
- [ ] 4.6 Implement pattern cycling
  - Cycle through patterns 1, 2, 3 in order
  - Add cooldown between patterns (1-2 seconds)
  - Reset to pattern 1 after pattern 3
- [ ] 4.7 Run all slice tests to verify no regressions
- [ ] 4.8 Commit working slice

**Acceptance Criteria:**
- Boss performs vertical sweep while firing
- Boss charges toward player position then returns
- Player takes damage from charge contact
- Patterns cycle: barrage -> sweep -> charge -> barrage...
- Brief cooldown between each pattern

---

### Slice 5: User sees victory sequence when boss is defeated

**What this delivers:** When the boss's health reaches 0, there's a dramatic screen shake, a large explosion animation, and then the level complete screen appears.

**Dependencies:** Slices 1-4

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:135-176] - health depleted and destruction animation
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:233-244] - level complete screen display
- [commit:c8d95fb] - explosion sprite usage pattern

#### Tasks

- [ ] 5.1 Write integration test: defeating boss shows victory sequence
  - Spawn boss, deal 13 damage
  - Verify screen shake occurs
  - Verify explosion animation plays
  - Verify level complete screen appears after delay
- [ ] 5.2 Run test, verify expected failure
- [ ] 5.3 Implement _on_health_depleted() in boss.gd
  - Set `_is_destroying = true` flag
  - Disable collision (monitoring = false)
  - Emit `boss_defeated` signal
- [ ] 5.4 Implement screen shake effect
  - Create camera shake or viewport offset shake
  - Duration ~0.5 seconds, intensity decreasing
  - Can use tween with random offset applied to Camera2D or root node
- [ ] 5.5 Implement boss explosion animation
  - Load explosion.png texture
  - Scale up 4-6x for boss-sized explosion
  - Animate scale up further and fade out
- [ ] 5.6 Hide boss health bar when boss defeated
- [ ] 5.7 Connect LevelManager to boss_defeated signal
  - Wait for explosion to complete (~1 second)
  - Then show level complete screen
  - Clear any remaining boss projectiles
- [ ] 5.8 Add boss_defeated signal emit for future audio hooks
- [ ] 5.9 Run all slice tests to verify no regressions
- [ ] 5.10 Commit working slice

**Acceptance Criteria:**
- Boss death triggers screen shake effect
- Large explosion animation plays at boss position
- Level complete screen appears after explosion
- Boss health bar disappears on defeat
- boss_defeated signal emitted for future audio integration

---

### Slice 6: User respawns at boss entrance if defeated during fight

**What this delivers:** If the player dies during the boss fight, they respawn at the boss entrance with the boss reset to full health, rather than getting game over.

**Dependencies:** Slices 1-5

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:277-313] - checkpoint respawn system
- [@/Users/matt/dev/space_scroller/tests/test_checkpoint_respawn.gd:1-149] - respawn test pattern
- [commit:ad60c3b] - checkpoint respawn implementation

#### Tasks

- [ ] 6.1 Write integration test: player respawns at boss on death
  - Start boss fight, trigger player death
  - Verify game over screen does NOT show
  - Verify player respawns
  - Verify boss has full health again
- [ ] 6.2 Run test, verify expected failure
- [ ] 6.3 Modify LevelManager to save boss checkpoint
  - Save checkpoint state when boss fight begins
  - Set `_boss_fight_active = true` flag
  - Store reference to boss instance
- [ ] 6.4 Modify LevelManager._on_player_died() for boss fight
  - Check if boss fight is active
  - If so, respawn player instead of game over
  - Reset boss to full health
- [ ] 6.5 Implement boss.reset_health() method
  - Restore health to 13
  - Update health bar to full
  - Clear destroying state
  - Reset attack state machine
- [ ] 6.6 Clear boss projectiles on player respawn
  - Add method to clear all active boss projectiles
  - Call from LevelManager.respawn_player() during boss fight
- [ ] 6.7 Reset boss position to battle position on respawn
  - Boss should be in battle position, not do entrance again
- [ ] 6.8 Stop scrolling during boss fight (arena mode)
  - Set scroll_controller.scroll_speed = 0 when boss spawns
  - Disable obstacle and enemy spawners
- [ ] 6.9 Run all slice tests to verify complete feature works
- [ ] 6.10 Commit working slice

**Acceptance Criteria:**
- Player death during boss fight triggers respawn, not game over
- Boss resets to full 13 HP on player respawn
- Boss projectiles are cleared on respawn
- Screen scrolling is stopped during entire boss fight
- Spawners disabled during boss fight (fixed arena)

---

## Post-Implementation Checklist

- [ ] All 6 slices complete and tested
- [ ] Manual playthrough: complete level and defeat boss
- [ ] Manual playthrough: die to boss and verify respawn
- [ ] Verify all three attack patterns cycle correctly
- [ ] Verify health bar updates smoothly
- [ ] Verify victory sequence feels satisfying
- [ ] Code follows existing patterns (BaseEnemy, progress_bar, etc.)
- [ ] No console errors or warnings during boss fight
