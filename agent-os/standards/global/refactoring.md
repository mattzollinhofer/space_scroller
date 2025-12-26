# Refactoring Standards

## When to Refactor

Refactor **after tests are green**, not while they're red. The cycle is:
Red → Green → Refactor → Commit

Refactor when you notice:
- Duplicate code that could be extracted
- Long methods that do too many things
- Unclear variable or method names
- Code that's hard to understand on first read
- Opportunities to use existing patterns from the codebase

## When NOT to Refactor

- **While tests are red** - Get to green first, then clean up
- **Code you didn't change** - Don't refactor unrelated code in the same commit
- **Without test coverage** - If there's no test covering the code, add one first
- **For hypothetical future needs** - Refactor for clarity now, not for features
  you might need later

## Keep Refactors Small

Each refactor should be a small, focused change:
- Rename a variable or method
- Extract a method
- Inline an unnecessary abstraction
- Move code to a better location
- Simplify a conditional

If a refactor is getting large, break it into smaller steps. Run tests after
each step.

## Refactoring Checklist

Before committing, ask:

1. **Is this clearer than before?** - Would someone reading this understand it
   faster?
2. **Does it follow existing patterns?** - Does it match how similar code works
   in this codebase?
3. **Is it simpler?** - Did you remove complexity, not add it?
4. **Are tests still green?** - Never commit with failing tests after refactor

## What Good Refactoring Looks Like

**DO:**
- Extract repeated code into a well-named method
- Rename unclear variables to reveal intent
- Simplify nested conditionals
- Remove dead code
- Use existing utilities/helpers from the codebase

**DON'T:**
- Create abstractions for single-use code
- Add configuration for things that don't vary
- Refactor toward patterns you prefer but the codebase doesn't use
- Gold-plate or over-engineer
- Refactor and add features in the same step

## Trust Your Tests

Refactoring should not change behavior. If tests stay green, you're safe. If a
test fails during refactoring, you either:
- Changed behavior (undo and try again)
- Found a gap in test coverage (good - now you know)
