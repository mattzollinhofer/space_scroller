# Testing Standards

## Philosophy: Outside-In, Lean Testing

Write the minimum tests needed, with each test earning its place by covering
something unique. Avoid duplication across test levels.

### Outside-In Approach

1. **Start with an integration/system test** that captures the happy path user
   workflow end-to-end
2. **Add lower-level tests ONLY** when there's additional logic to cover that
   doesn't fit in the happy path system test.
3. **Don't duplicate coverage** - if the integration test covers it, don't
   re-test the same thing at lower levels

### Why Lower-Level Tests Exist

Lower-level tests (unit, controller, model) are NOT written "because you should
have unit tests." They exist ONLY to cover conditional branches that create
permutations you can't reasonably cover at the integration level.

**Example:**
```
Integration test: "User creates a comment" (happy path - covers the full flow)

Unit tests only if needed:
- Comment model: validation edge cases (blank, too long, special chars)
- Controller: authorization branches (owner vs non-owner vs admin)
- Service: conditional business logic branches

NOT needed as unit tests:
- "comment gets saved" (already covered by integration)
- "comment appears on page" (already covered by integration)
```

## Best Practices

### Update Existing Tests When Appropriate

When adding or modifying functionality, check for existing related tests first.
It's acceptable to update an existing system test than to create a new
one if they are closely aligned. We don't want to have massive system tests, but
tweaks are fine.

- Look for existing tests that cover similar user workflows
- Extend existing tests to cover new functionality when it makes sense
- Create new tests when the functionality is distinct

### Red-Green-Refactor Cycle

Follow the test-first cycle:

1. **Write the test** - define what success looks like
2. **Run the test, see it fail** - verify the failure is expected
3. **Make the smallest change** - address only what the failure tells you
4. **Run the test again** - observe failure change or success
5. **Repeat** until the test passes
6. **Refactor** - clean up the code while keeping tests green
   (see @standards/global/refactoring.md)

### Test Behavior, Not Implementation

Focus tests on what the code does, not how it does it. This reduces brittleness
and allows refactoring without rewriting tests.

### Clear Test Names

Use descriptive names that explain what's being tested and the expected outcome.
The test name should read like a specification.

### Fast Execution

Keep tests fast so they can be run frequently during development. Slow tests
discourage the red-green cycle.

### Mock External Dependencies

Isolate tests by mocking databases, APIs, file systems, and other external
services when appropriate. But prefer real integrations in system tests when
feasible.

## Front-End and View Testing

Front-end tests should focus on **user interactions, data flow, and business
logic**, not implementation details like CSS classes, styling, or layout.

### What TO Test

- **Data Rendering**: Verify that the correct data is displayed
  - "User name appears on profile page"
  - "List shows all items returned from API"
  - "Empty state displays when no results exist"
- **User Interactions**: Test that actions trigger the expected behavior
  - "Clicking delete button removes the item"
  - "Form submission sends correct data to the server"
  - "Toggling switch updates the state"
- **Conditional Logic**: Verify different states and branches
  - "Disabled button appears when form is invalid"
  - "Success message shows after form submission"
  - "Error message displays for network failures"
- **Navigation and Routing**: Test that users can navigate between views
  - "Clicking link navigates to the correct page"
  - "Back button returns to previous page"

### What NOT To Test

- **Styling and Visual Design**: CSS classes, colors, fonts, spacing
  - Don't assert `element.classList.contains('btn-primary')`
  - Don't test computed styles (use visual regression testing for that)
- **Layout and DOM Structure**: HTML element hierarchy, specific class names for positioning
  - Don't assert exact HTML structure unless required for accessibility
  - Don't test implementation details like `<div class="wrapper">` vs `<section>`
- **Framework-Specific Details**: Implementation details of your UI framework
  - Don't test React state directly; test the rendered output
  - Don't test component props unless they affect visible behavior

### The Rule of Thumb

**Would a user care about this if it broke?** If no, don't test it.

- User cares: "My name doesn't appear on my profile" ✓ Test it
- User doesn't care: "The username has class `profile-name` instead of `user-name`" ✗ Don't test it

## What NOT To Do

- **Don't write tests for every change** - Focus on completing logical units,
  then add strategic tests
- **Don't test edge cases during feature development** - Unless business-critical,
  defer to dedicated testing phases
- **Don't duplicate coverage across levels** - If integration covers it, skip
  the unit test
- **Don't always create new tests** - Update existing related tests when it
  makes sense
- **Don't aim for 100% coverage** - Aim for confidence in critical user workflows
- **Don't test framework behavior** - Standard Rails behavior (validations,
  associations, callbacks) is already tested by Rails. Trust the framework.
  Only test YOUR logic, not that `validates :name, presence: true` works.

## Running Tests (Godot)

Tests are standalone scenes in `tests/` that exit with code 0 (pass) or 1 (fail).

### Single test

```bash
godot --headless --path . tests/test_foo.tscn
```

### All tests

```bash
timeout 180 bash -c 'failed=0; for t in tests/*.tscn; do echo "=== $t ==="; timeout 10 godot --headless --path . "$t" || ((failed++)); done; echo "Failed: $failed"; exit $failed'
```

**Important:** Use `timeout 10` per test, not 60. Tests should complete in 2-5 seconds. The 180-second global timeout caps the entire suite.
