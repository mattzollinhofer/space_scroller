# Git Commit Message Standards

## Why This Matters

Good commit messages help the business understand _why_ changes were made, not
just what changed. When a non-technical coworker or user encounters this commit
message "Fix student enrollment conflicts", it tells them more than "Update
Enrollment model."

**The test:** Would a product manager understand why this commit matters? If
not, reframe it.

## The Rule: Value First, Technical Second

1. **Lead with the user or business outcome** - What problem is solved? What
   capability is added?
2. **Technical details support the story** - Only include them to explain _how_
   the value is delivered

## Format

```
<subject: 50 chars max, imperative mood>

<body: why this matters, what changed, key decisions - wrapped at 72 chars>

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Subject Line

- **Imperative mood**: "Add", "Fix", "Refactor" (not "Added", "Fixed")
- **Start with value**: What you accomplished, not implementation details
- **50 characters max**, no period, capitalize first letter

**Good:** `Provide student enrollment conflict detection`
**Bad:** `Update Enrollment model validation logic` (too technical)

## Body

Write for the next developer who needs to understand:

1. **Why** - The business reason or user need (always first)
2. **What** - Which features or behaviors changed
3. **How** - Key decisions or non-obvious behavior (only if needed)

Skip line-by-line code descriptions. Code reviews handle that.

### Example

```
Allow users to visually compare schedules

Users can now compare multiple engine outputs with this new side-by-side view
to pick the best schedule. Each run automatically creates a named version and
links all enrollments.

Cleanup removes old drafts (keep=false) to prevent bloat while preserving
important drafts (keep=true) for review.

Closes roadmap item 7.6

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Why it works:** Opens with user value, explains the design decision (cleanup),
references the roadmap.

## Keep Commits Focused

Checklist / roadmap updates should always be committed separately from code
changes. This makes it easier to review, revert, and understand the history.

## Linking

- `Closes roadmap item X.Y`
- `Implements spec: <date>-<feature>`

## Footer

Agent-generated commits include: `Co-Authored-By: Claude <noreply@anthropic.com>`

## Checklist Before Committing

- [ ] Subject explains the value delivered (not just technical change)
- [ ] Subject is 50 chars or less, imperative mood
- [ ] Body opens with why this matters to users/business
- [ ] Body includes context for key design decisions
- [ ] Related roadmap items or specs are referenced
- [ ] Commit is logically complete (not "work in progress")
- [ ] Checklist/tasklist updates are committed separately from code
