# Project: Space Scroller

A side-scrolling space shooter game built with Godot 4.

## Running Tests

Tests are standalone Godot scenes in `tests/`. Each exits with code 0 (pass) or 1 (fail).

### Run a single test

```bash
godot --headless --path . tests/test_score_display.tscn
```

### Run all tests

```bash
# Run all tests with 10-second timeout each (most tests complete in 2-5 seconds)
for test in tests/*.tscn; do
  echo "=== $test ==="
  timeout 10 godot --headless --path . "$test" || echo "FAILED: $test"
done
```

**Important:** Use `timeout 10` not `timeout 60`. Tests should complete quickly - if a test needs more than 10 seconds, it's likely stuck.

### Running the full test suite for verification

When verifying an implementation, run all tests with a **global timeout** rather than per-test:

```bash
timeout 180 bash -c 'failed=0; for t in tests/*.tscn; do echo "=== $t ==="; timeout 10 godot --headless --path . "$t" || ((failed++)); done; echo "Failed: $failed"; exit $failed'
```

This caps total test time at 3 minutes regardless of test count.
