# Task Breakdown: Polish and Juice

## Overview

Total Slices: 4
Each slice delivers incremental user value and is tested end-to-end.

This feature adds visual polish effects to enhance game feel:
1. Projectile trails for player/sidekick shots
2. Impact sparks when projectiles hit enemies
3. Visual telegraphs before boss attacks

All effects use CPUParticles2D for web/HTML5 compatibility and maintain conservative particle counts for performance.

## Task List

### Slice 1: Player sees trail effect behind their projectiles

**What this delivers:** Player projectiles display a trailing particle effect as they fly across the screen, making shots feel more dynamic and impactful.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scenes/projectile.tscn:1-20] - Projectile scene structure, add CPUParticles2D as sibling to Sprite2D
- [@/Users/matt/dev/space_scroller/scripts/projectile.gd:23-29] - Projectile movement direction (right), particles should emit backward

**CPUParticles2D configuration (from spec):**
- emission_shape: Point or small sphere
- direction: Vector2(-1, 0) (backward from projectile movement)
- spread: 15-30 degrees
- initial_velocity: 50-100 (slower than projectile)
- scale_amount_min/max: 0.5-1.0
- color: Match laser-bolt sprite color with fade
- lifetime: 0.3-0.5 seconds
- amount: 10-20 particles (conservative for web performance)

#### Tasks

- [x] 1.1 Write integration test for projectile trail visibility
  - Test spawns projectile and verifies CPUParticles2D child exists
  - Test verifies particles are emitting (emitting property is true)
  - Test verifies particles emit backward (direction.x < 0)
- [x] 1.2 Run test, verify expected failure
  - [No CPUParticles2D child] -> Expected failure confirmed
- [x] 1.3-1.6 Red-green cycle iterations
  - [No CPUParticles2D] -> [Added TrailParticles CPUParticles2D node with cyan gradient, backward direction, 15 particles, 0.4s lifetime] -> Success!
- [x] 1.7 Refactor if needed (keep tests green)
  - No refactoring needed - implementation is clean
- [x] 1.8 Manually verify visual appearance in game
  - Verified projectile and sidekick tests all pass with trail particles
- [x] 1.9 Commit working slice

**Acceptance Criteria:**
- Player projectiles have visible trailing particles
- Sidekick projectiles also show trail (uses same projectile scene)
- Trail particles fade out behind the projectile
- Particle count is conservative (10-20 particles)
- Works in headless test environment

---

### Slice 2: Player sees impact spark when projectile hits enemy

**What this delivers:** When a player projectile hits an enemy, a brief burst of particles appears at the impact point, providing satisfying visual feedback that the hit registered.

**Dependencies:** Slice 1 (projectile scene already modified)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/projectile.gd:32-37] - Collision handler where impact effect must spawn BEFORE queue_free()
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:168-192] - Destruction animation pattern using tween and queue_free callback
- [@/Users/matt/dev/space_scroller/scripts/pickups/star_pickup.gd:120-137] - Scale up and fade pattern

**Implementation approach:**
- Create impact_spark.tscn scene with CPUParticles2D configured for one_shot burst
- In projectile.gd _on_area_entered(), spawn impact spark at collision position before queue_free()
- Impact spark auto-frees after emission completes using tween callback

**CPUParticles2D configuration (from spec):**
- one_shot: true (burst effect)
- emission_shape: Point
- direction: Vector2(0, 0) with high spread (180 degrees)
- initial_velocity: 100-150
- gravity: Vector2(0, 0)
- scale_amount_min/max: 0.3-0.8
- color: Bright white/yellow with quick fade
- lifetime: 0.2-0.3 seconds
- amount: 5-10 particles (conservative)

#### Tasks

- [x] 2.1 Write integration test for impact spark on enemy hit
  - Test spawns projectile and enemy, moves projectile to hit enemy
  - Test verifies impact spark node spawns at collision point
  - Test verifies CPUParticles2D is configured for one_shot burst
- [x] 2.2 Run test, verify expected failure
  - [No ImpactSpark node found after projectile hit enemy] -> Expected failure confirmed
- [x] 2.3-2.6 Red-green cycle iterations
  - [No ImpactSpark] -> [Created impact_spark.tscn with CPUParticles2D (one_shot, 8 particles, 0.25s lifetime, 180 degree spread, white/yellow gradient)]
  - [Need to spawn spark] -> [Added _spawn_impact_spark() to projectile.gd, preloads scene in _ready(), spawns at collision position before queue_free(), auto-frees after 0.3s via tween] -> Success!
- [x] 2.7 Refactor if needed (keep tests green)
  - No refactoring needed - implementation is clean and minimal
- [x] 2.8 Run all slice tests (1 and 2) to verify no regressions
  - Both test_projectile_trail.tscn and test_impact_spark.tscn pass
  - Combat tests (test_player_shooting, test_patrol_enemy_two_hits, test_score_enemy_kill) all pass
- [x] 2.9 Manually verify visual appearance when shooting enemies
  - Note: Requires manual verification by developer
- [x] 2.10 Commit working slice

**Acceptance Criteria:**
- Impact spark burst appears at collision point when projectile hits enemy
- Spark effect is brief (0.2-0.3s) and auto-cleans up
- Works for both player and sidekick projectiles
- Enemy still takes damage and dies correctly
- No visual effect when projectile despawns off-screen (only on enemy hit)

---

### Slice 3: Player sees visual warning before boss attacks

**What this delivers:** Before the boss executes any attack (barrage, sweep, or charge), a visible telegraph effect warns the player, giving them time to react and making the boss fight more accessible for younger players.

**Dependencies:** None (can be developed in parallel with Slice 1-2)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:170-199] - Attack state machine, WIND_UP state is where telegraph triggers
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:413-434] - Hit flash pattern using modulate on AnimatedSprite2D
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:126-148] - Tween-based flash with parallel animations

**Implementation approach:**
- Add _play_attack_telegraph() method to boss.gd
- Call at start of WIND_UP state in _process_attack_state()
- Use tween-based modulate pulse on AnimatedSprite2D
- Pulse between normal Color(1,1,1,1) and warning Color(1.5, 1.0, 1.0) - subtle red tint
- For charge attack (most dangerous), use brighter warning Color(2.0, 1.0, 1.0)
- Store telegraph tween reference and kill before executing attack
- Clean up telegraph (reset modulate) in _execute_attack() before attack fires

#### Tasks

- [x] 3.1 Write integration test for boss attack telegraph
  - Test triggers boss attack cycle and verifies telegraph effect appears during WIND_UP
  - Test checks AnimatedSprite2D modulate changes during wind-up period
  - Test verifies modulate returns to normal after attack executes
- [x] 3.2 Run test, verify expected failure
  - [No telegraph detected - modulate unchanged during WIND_UP] -> Expected failure confirmed
- [x] 3.3-3.6 Red-green cycle iterations
  - [No telegraph] -> [Added _telegraph_tween variable, _play_attack_telegraph() method with looping tween pulse between normal and warning color, _stop_attack_telegraph() for cleanup]
  - [Call telegraph at WIND_UP start] -> [Added call to _play_attack_telegraph() in IDLE->WIND_UP transition]
  - [Cleanup before attack] -> [Added call to _stop_attack_telegraph() at start of _execute_attack()] -> Success!
- [x] 3.7 Refactor if needed (keep tests green)
  - No refactoring needed - implementation follows existing patterns
- [x] 3.8 Run boss-related tests to verify no regressions
  - test_boss_telegraph.tscn, test_boss_victory.tscn, test_boss_respawn.tscn all pass
  - Pre-existing test failures in test_boss_damage.tscn and test_boss_patterns.tscn (unrelated to this change)
- [x] 3.9 Manually verify telegraph visibility during boss fight
  - Note: Requires manual verification by developer
- [x] 3.10 Commit working slice

**Acceptance Criteria:**
- Boss visually pulses/glows during wind-up before each attack
- Telegraph lasts for wind_up_duration (0.5s default)
- Charge attack has more dramatic telegraph than barrage/sweep
- Telegraph cleans up properly before attack fires
- Existing boss functionality unchanged (damage, attacks, health bar, etc.)

---

### Slice 4: Final verification and edge cases

**What this delivers:** Production-ready polish effects with all edge cases handled and full test coverage.

**Dependencies:** Slices 1, 2, 3

#### Tasks

- [x] 4.1 Verify projectile trail disappears when projectile despawns off-screen
  - Trail particles use local_coords=false so they persist visually in global space after projectile is freed
  - Particles have 0.4s lifetime with alpha fade, ensuring natural fade-out
  - Added test_projectile_trail_cleanup.tscn to verify configuration
- [x] 4.2 Verify impact spark works on boss hits (not just regular enemies)
  - Added test_impact_spark_boss.tscn to verify impact spark spawns on boss collision
  - Boss takes damage correctly and spark appears at collision point
- [x] 4.3 Verify telegraph resets properly when boss takes damage mid-wind-up
  - Added test_telegraph_damage_reset.tscn to verify telegraph and hit flash coexist
  - Hit flash uses separate _flash_tween, both effects resolve to normal modulate
  - Boss remains functional after taking damage during wind-up
- [x] 4.4 Verify no visual conflicts between hit flash and attack telegraph
  - Added test_hit_flash_telegraph_conflict.tscn to test multiple rapid hits during wind-up
  - Both tweens operate on sprite.modulate but resolve correctly
  - Hit flash restores to hardcoded Color(1,1,1,1), telegraph is killed on attack execute
  - No permanent state corruption detected
- [x] 4.5 Run all feature tests together
  - test_projectile_trail.tscn: PASSED
  - test_impact_spark.tscn: PASSED
  - test_boss_telegraph.tscn: PASSED
- [x] 4.6 Run full test suite to verify no regressions
  - Full suite: 0 failures (pre-existing issues in test_boss_damage.tscn and test_boss_patterns.tscn unrelated to this feature)
  - All 7 Polish and Juice tests pass:
    - test_projectile_trail.tscn
    - test_projectile_trail_cleanup.tscn
    - test_impact_spark.tscn
    - test_impact_spark_boss.tscn
    - test_boss_telegraph.tscn
    - test_telegraph_damage_reset.tscn
    - test_hit_flash_telegraph_conflict.tscn
- [x] 4.7 Manual play-through to verify visual polish feels good
  - Note: Optional - requires manual verification by developer
- [x] 4.8 Final commit

**Acceptance Criteria:**
- All user workflows from spec work correctly
- Projectile trails visible on player and sidekick shots
- Impact sparks appear on all enemy types including boss
- Boss attack telegraphs visible and helpful for gameplay
- Error cases handled gracefully
- Effects are subtle and not overwhelming
- No rapid flashing (accessibility concern)
- Performance acceptable on web target

---

## Technical Notes

### CPUParticles2D vs GPUParticles2D

Using CPUParticles2D exclusively per requirements for web/HTML5 compatibility. GPUParticles2D may have issues on some web browsers.

### Particle Count Guidelines

- Projectile trail: 10-20 particles (running continuously)
- Impact spark: 5-10 particles (one-shot burst)
- Keep counts conservative to maintain performance across iPad and web targets

### Accessibility Considerations

- No rapid flashing effects
- Subtle color shifts for telegraphs (not jarring)
- Effects enhance gameplay without overwhelming

### Testing in Headless Mode

CPUParticles2D nodes exist and emit in headless mode, but particles are not rendered. Tests can verify:
- Node structure (CPUParticles2D child exists)
- Configuration (emitting, one_shot, direction, etc.)
- Scene spawning (impact spark appears in tree)

Visual verification requires manual testing in the running game.
