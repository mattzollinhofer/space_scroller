# Task Breakdown: Additional Bosses

## Overview

Total Slices: 4
Each slice delivers incremental user value and is tested end-to-end.

The feature extends the existing boss class with thematic attack patterns for
levels 2 (Inner Solar/hot) and 3 (Outer Solar/cold), making each boss fight
feel unique while maintaining kid-friendly difficulty.

## Task List

### Slice 1: Player fights Level 2 boss with Solar Flare attack

**What this delivers:** When fighting the Level 2 boss, the player encounters
the new "Solar Flare" attack - a radial burst of fast projectiles firing in
all directions, matching the Inner Solar System "hot" theme.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:214-250] - `_attack_horizontal_barrage()` as template for projectile spawning pattern
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:202-211] - `_execute_attack()` match statement to extend
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss_projectile.gd:6-9] - speed property to configure for faster solar projectiles
- [@/Users/matt/dev/space_scroller/tests/test_boss_patterns.gd:95-98] - test pattern for configuring boss attacks

#### Tasks

- [x] 1.1 Write integration test: verify boss uses attack index 3 (Solar Flare) when configured
  - Created test_boss_solar_flare.gd and test_boss_solar_flare.tscn
- [x] 1.2 Run test, verify expected failure (attack 3 not implemented)
  - Test failed: "No projectiles spawned - Solar Flare attack not implemented"
- [x] 1.3 Make smallest change possible to progress
  - Added case 3 to _execute_attack() match statement
  - Added _attack_solar_flare() method that fires 12 projectiles radially (360 degrees)
  - Set projectile speed to 950 (in range 900-1000)
  - Added orange/yellow telegraph color for Solar Flare attacks
- [x] 1.4 Run test, observe failure or success
  - Success: Test passed on first implementation
- [x] 1.5 Document result and update task list
- [x] 1.6 Repeat 1.3-1.5 as necessary until Solar Flare fires radial projectiles
  - Not needed - worked on first try
- [x] 1.7 Verify projectiles use faster speed (900-1000 vs default 750)
  - Verified: Average projectile speed is 950.0
- [x] 1.8 Update level_2.json: attacks [0, 3, 4] (placeholder 4), scale 7
  - Updated boss_config.attacks to [0, 3, 4]
  - Updated boss_config.scale to 7
- [x] 1.9 Run boss-related tests to verify no regressions
  - Fixed pre-existing bug in test_boss_damage.gd (expected 13 health but Level 1 has 10)
  - All 9 boss tests pass
- [ ] 1.10 Commit working slice

**Acceptance Criteria:**
- [x] Level 2 boss uses Solar Flare attack (radial burst pattern)
- [x] Solar Flare projectiles are faster than default (speed 900-1000)
- [x] Attack fires projectiles in all directions (360-degree spread)
- [x] Integration test for attack index 3 passes

---

### Slice 2: Player fights Level 2 boss with Heat Wave attack

**What this delivers:** When fighting the Level 2 boss, the player encounters
the new "Heat Wave" attack - a continuous stream of fast projectiles in a
sweeping arc, completing the Level 2 "hot" attack set.

**Dependencies:** Slice 1 (Solar Flare attack infrastructure)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:253-276] - `_attack_vertical_sweep()` as template for tween-based movement with continuous fire
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:279-284] - `_process_sweep_projectiles()` for interval-based firing during movement

#### Tasks

- [ ] 2.1 Write integration test: verify boss uses attack index 4 (Heat Wave) when configured
- [ ] 2.2 Run test, verify expected failure (attack 4 not implemented)
- [ ] 2.3 Make smallest change possible to progress
- [ ] 2.4 Run test, observe failure or success
- [ ] 2.5 Document result and update task list
- [ ] 2.6 Repeat 2.3-2.5 as necessary until Heat Wave performs sweeping arc with continuous fire
- [ ] 2.7 Verify projectiles use faster speed (900-1000)
- [ ] 2.8 Update level_2.json attacks array to final: [0, 3, 4]
- [ ] 2.9 Run boss-related tests to verify no regressions
- [ ] 2.10 Manually playtest Level 2 boss to verify thematic feel and kid-friendly difficulty
- [ ] 2.11 Commit working slice

**Acceptance Criteria:**
- Level 2 boss uses Heat Wave attack (sweeping arc with continuous fire)
- Heat Wave projectiles are faster than default
- Boss moves in arc while firing stream of projectiles
- All Level 2 attacks (barrage, solar flare, heat wave) cycle correctly
- Previous slice functionality still works

---

### Slice 3: Player fights Level 3 boss with Ice Shards attack

**What this delivers:** When fighting the Level 3 boss, the player encounters
the new "Ice Shards" attack - many slow-moving projectiles in a wide spread
pattern, matching the Outer Solar System "cold/expansive" theme.

**Dependencies:** Slices 1-2 (attack infrastructure patterns established)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:214-250] - `_attack_horizontal_barrage()` as template, but with more projectiles and wider spread
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss_projectile.gd:6-9] - speed property to configure for slower ice projectiles (400-500)

#### Tasks

- [ ] 3.1 Write integration test: verify boss uses attack index 5 (Ice Shards) when configured
- [ ] 3.2 Run test, verify expected failure (attack 5 not implemented)
- [ ] 3.3 Make smallest change possible to progress
- [ ] 3.4 Run test, observe failure or success
- [ ] 3.5 Document result and update task list
- [ ] 3.6 Repeat 3.3-3.5 as necessary until Ice Shards fires many slow projectiles
- [ ] 3.7 Verify projectiles use slower speed (400-500)
- [ ] 3.8 Verify wide spread pattern with more projectiles than barrage
- [ ] 3.9 Update level_3.json: attacks [0, 1, 5, 6] (placeholder 6), scale 9
- [ ] 3.10 Run boss-related tests to verify no regressions
- [ ] 3.11 Commit working slice

**Acceptance Criteria:**
- Level 3 boss uses Ice Shards attack (wide spread of slow projectiles)
- Ice Shards projectiles are slower than default (speed 400-500)
- More projectiles than standard barrage for "numerous" feel
- Integration test for attack index 5 passes

---

### Slice 4: Player fights Level 3 boss with Frozen Nova attack

**What this delivers:** When fighting the Level 3 boss, the player encounters
the new "Frozen Nova" attack - a delayed burst that expands outward slowly,
completing the Level 3 "cold/expansive" attack set.

**Dependencies:** Slice 3 (Ice Shards attack)

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:316-346] - `_attack_charge()` as template for timed/delayed attack phases
- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:214-250] - projectile spawning pattern

#### Tasks

- [ ] 4.1 Write integration test: verify boss uses attack index 6 (Frozen Nova) when configured
- [ ] 4.2 Run test, verify expected failure (attack 6 not implemented)
- [ ] 4.3 Make smallest change possible to progress
- [ ] 4.4 Run test, observe failure or success
- [ ] 4.5 Document result and update task list
- [ ] 4.6 Repeat 4.3-4.5 as necessary until Frozen Nova performs delayed expanding burst
- [ ] 4.7 Verify delay/telegraph before burst fires
- [ ] 4.8 Verify projectiles use slower speed (400-500) for expansive feel
- [ ] 4.9 Update level_3.json attacks array to final: [0, 1, 5, 6]
- [ ] 4.10 Run all boss tests to verify complete functionality
- [ ] 4.11 Manually playtest Level 3 boss to verify thematic feel and kid-friendly difficulty
- [ ] 4.12 Run full test suite to verify no regressions across codebase
- [ ] 4.13 Commit working slice

**Acceptance Criteria:**
- Level 3 boss uses Frozen Nova attack (delayed expanding burst)
- Clear visual telegraph before burst fires (kid-friendly warning)
- Frozen Nova projectiles are slow (speed 400-500)
- All Level 3 attacks (barrage, sweep, ice shards, frozen nova) cycle correctly
- All previous slice functionality still works
- Full test suite passes

---

## Final Configuration Summary

After all slices complete, the boss configuration should be:

| Level | Health | Scale | Attacks | Cooldown | Theme |
|-------|--------|-------|---------|----------|-------|
| 1 | 10 | 5 | [0] | 1.5s | Outer space (unchanged) |
| 2 | 13 | 7 | [0, 3, 4] | 1.3s | Inner Solar - Hot/Intense |
| 3 | 16 | 9 | [0, 1, 5, 6] | 1.1s | Outer Solar - Cold/Expansive |

**Attack Index Reference:**
- 0: Horizontal Barrage (existing)
- 1: Vertical Sweep (existing)
- 2: Charge Attack (existing, unused in final configs)
- 3: Solar Flare - radial burst, fast projectiles (NEW)
- 4: Heat Wave - sweeping arc stream, fast projectiles (NEW)
- 5: Ice Shards - wide spread, slow numerous projectiles (NEW)
- 6: Frozen Nova - delayed expanding burst, slow projectiles (NEW)

## Testing Strategy

**During development (per slice):**
```bash
for t in tests/test_boss*.tscn; do timeout 20 godot --headless --path . "$t" || exit 1; done
```

**After final slice:**
```bash
timeout 180 bash -c 'failed=0; for t in tests/*.tscn; do timeout 10 godot --headless --path . "$t" || ((failed++)); done; echo "Failed: $failed"; exit $failed'
```
