# Task Breakdown: Player Combat

## Overview

Total Slices: 4
Each slice delivers incremental user value and is tested end-to-end.

## Task List

### Slice 1: Player can shoot and destroy a stationary enemy with keyboard

**What this delivers:** Player presses spacebar, projectile fires right, hits enemy, enemy explodes.

**Dependencies:** None

**Reference patterns:**
- `/Users/matt/dev/space_scroller/scripts/player.gd:62-98` - _physics_process input handling and delta-based timers
- `/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:7-11` - Health setter auto-triggers death
- `/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:23-25` - Signal connection for collision
- `/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:109-120` - Entity instantiation pattern
- `/Users/matt/dev/space_scroller/scenes/enemies/stationary_enemy.tscn:9-11` - Collision layer setup
- `commit:8615a26` - BaseEnemy Area2D pattern and destruction animation

#### Tasks

- [ ] 1.1 Write integration test: player shoots, projectile hits stationary enemy, enemy dies
- [ ] 1.2 Run test, verify expected failure
- [ ] 1.3 Make smallest change possible to progress
- [ ] 1.4 Run test, observe failure or success
- [ ] 1.5 Document result and update task list
- [ ] 1.6 Repeat 1.3-1.5 as necessary (expected iterations):
  - Create `scenes/projectile.tscn` (Area2D + Sprite2D + CollisionShape2D)
  - Create `scripts/projectile.gd` with movement and despawn logic
  - Set projectile collision_layer = 4, collision_mask = 2
  - Update enemy scenes: add collision_mask = 4 (detect projectiles)
  - Add `take_hit(damage: int)` method to BaseEnemy
  - Add area_entered signal handling in BaseEnemy for projectiles
  - Add shooting logic to player.gd (cooldown timer, spawn projectile)
  - Add `projectile_fired` signal to player (audio placeholder)
- [ ] 1.7 Refactor if needed (keep tests green)
- [ ] 1.8 Commit working slice

**Acceptance Criteria:**
- Player presses spacebar and projectile appears
- Projectile moves right at 800-1000 px/s
- Projectile despawns at right screen edge
- Projectile collides with enemy, enemy dies with explosion animation
- Fire rate cooldown prevents spam (0.1-0.15s between shots)

---

### Slice 2: Patrol enemy requires two hits to kill with red flash feedback

**What this delivers:** Player hits patrol enemy, enemy flashes red, second hit destroys it.

**Dependencies:** Slice 1

**Reference patterns:**
- `/Users/matt/dev/space_scroller/scenes/enemies/patrol_enemy.tscn:15` - Sprite modulate property for tinting
- `/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:63-88` - Tween animation pattern
- `commit:0f816b2` - Patrol enemy inheritance and modulate usage

#### Tasks

- [ ] 2.1 Write integration test: patrol enemy takes 2 hits, flashes red on first hit
- [ ] 2.2 Run test, verify expected failure
- [ ] 2.3 Make smallest change possible to progress
- [ ] 2.4 Run test, observe failure or success
- [ ] 2.5 Document result and update task list
- [ ] 2.6 Repeat 2.3-2.5 as necessary (expected iterations):
  - Set patrol enemy health = 2 in scene or patrol_enemy.gd _ready()
  - Add `hit_by_projectile` signal to BaseEnemy (audio placeholder)
  - Add red flash effect in take_hit() when health > 0
  - Store original sprite modulate, apply red tint Color(1.5, 0.3, 0.3, 1.0)
  - Create tween to restore original modulate after 0.1-0.15s
- [ ] 2.7 Refactor if needed (keep tests green)
- [ ] 2.8 Run all slice tests (1 and 2) to verify no regressions
- [ ] 2.9 Commit working slice

**Acceptance Criteria:**
- Patrol enemy survives first hit
- Red flash effect visible on first hit (0.1-0.15s duration)
- Second hit destroys patrol enemy with explosion
- Stationary enemies still die in one hit

---

### Slice 3: Player can fire by touching screen (mobile support)

**What this delivers:** Player touches right side of screen (or anywhere outside joystick), projectiles fire continuously while holding.

**Dependencies:** Slice 1

**Reference patterns:**
- `/Users/matt/dev/space_scroller/scripts/ui/virtual_joystick.gd:47-57` - Touch input handling pattern
- `/Users/matt/dev/space_scroller/scenes/main.tscn:85-88` - UILayer structure

#### Tasks

- [ ] 3.1 Write integration test: touch input triggers continuous firing
- [ ] 3.2 Run test, verify expected failure
- [ ] 3.3 Make smallest change possible to progress
- [ ] 3.4 Run test, observe failure or success
- [ ] 3.5 Document result and update task list
- [ ] 3.6 Repeat 3.3-3.5 as necessary (expected iterations):
  - Create `scenes/ui/fire_button.tscn` (Control node)
  - Create `scripts/ui/fire_button.gd` with touch handling
  - Handle InputEventScreenTouch for touch press/release
  - Handle InputEventMouseButton for desktop testing
  - Add `is_pressed() -> bool` method for player to query
  - Add FireButton to UILayer in main.tscn (right side of screen)
  - Update player.gd to check fire button state alongside keyboard
- [ ] 3.7 Refactor if needed (keep tests green)
- [ ] 3.8 Run all slice tests (1, 2, and 3) to verify no regressions
- [ ] 3.9 Commit working slice

**Acceptance Criteria:**
- Touching right side of screen fires projectiles
- Holding touch continues firing at cooldown rate
- Releasing touch stops firing
- Keyboard spacebar still works (both input methods coexist)
- Fire button does not interfere with virtual joystick

---

### Slice 4: Projectiles pass through asteroids and final polish

**What this delivers:** Production-ready combat with correct collision filtering and edge cases handled.

**Dependencies:** Slices 1, 2, 3

**Reference patterns:**
- `/Users/matt/dev/space_scroller/scenes/obstacles/asteroid.tscn` - Asteroid collision setup

#### Tasks

- [ ] 4.1 Write integration test: projectile passes through asteroid without interaction
- [ ] 4.2 Run test, verify expected failure or success
- [ ] 4.3 Make smallest change possible to progress (if needed)
- [ ] 4.4 Verify projectile collision_mask excludes asteroid layer
- [ ] 4.5 Run all feature tests to verify everything works together
- [ ] 4.6 Test edge cases:
  - Rapid firing at cooldown limit
  - Multiple projectiles on screen simultaneously
  - Projectile hitting enemy at edge of screen
  - Player death stops firing (game over state)
- [ ] 4.7 Add any missing error handling
- [ ] 4.8 Final commit

**Acceptance Criteria:**
- Projectiles pass through asteroids without collision
- All user workflows from spec work correctly
- Both keyboard and touch firing work consistently
- Error cases handled gracefully
- Code follows existing patterns in codebase
