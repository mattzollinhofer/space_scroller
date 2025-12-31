# Testing Instructions for Agents

## Running Tests During Implementation

**CRITICAL: Do NOT run the full test suite after every change.**

The full suite (60+ tests) takes 3-5+ minutes. Running it repeatedly during
implementation wastes massive amounts of time.

### During Development

Only run tests related to your feature:

```bash
# Level-related work:
for t in tests/test_level*.tscn; do timeout 10 godot --headless --path . "$t" || exit 1; done

# Enemy-related work:
for t in tests/test_*enemy*.tscn; do timeout 10 godot --headless --path . "$t" || exit 1; done

# Boss-related work:
for t in tests/test_boss*.tscn; do timeout 10 godot --headless --path . "$t" || exit 1; done

# Score-related work:
for t in tests/test_score*.tscn tests/test_high_score*.tscn; do timeout 10 godot --headless --path . "$t" || exit 1; done
```

### After Completing a Slice

Run the full suite **once** at the end:

```bash
timeout 180 bash -c 'failed=0; for t in tests/*.tscn; do timeout 10 godot --headless --path . "$t" || ((failed++)); done; echo "Failed: $failed"; exit $failed'
```

### Time Comparison

| Approach | Per iteration | 10 iterations |
|----------|--------------|---------------|
| Full suite (67 tests) | 3-5 min | 30-50 min |
| Feature-specific (8-12) | 30-60 sec | 5-10 min |

## Test Naming Convention

Tests are named by feature area for easy filtering:
- `test_level_*.tscn` - Level/progression
- `test_boss_*.tscn` - Boss behavior
- `test_enemy_*.tscn`, `test_*_enemy*.tscn` - Enemy types
- `test_score_*.tscn`, `test_high_score_*.tscn` - Scoring
- `test_pickup_*.tscn` - Pickups/collectibles
- `test_player_*.tscn` - Player mechanics
