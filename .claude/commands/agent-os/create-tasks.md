# Task List Creation Process

You are creating a tasks breakdown from a given spec and requirements for a new
feature.

## PHASE 1: Get and read the spec.md and/or requirements document(s)

You will need ONE OR BOTH of these files to inform your tasks breakdown:

- `agent-os/specs/[this-spec]/spec.md`
- `agent-os/specs/[this-spec]/planning/requirements.md`

IF you don't have ONE OR BOTH of those files in your current conversation
context, then ask user to provide direction on where to you can find them by
outputting the following request then wait for user's response:

```
I'll need a spec.md or requirements.md (or both) in order to build a tasks list.

Please direct me to where I can find those.  If you haven't created them yet, you can run /shape-spec or /write-spec.
```

## PHASE 2: Create tasks.md

Once you have `spec.md` AND/OR `requirements.md`, use the **tasks-list-creator**
subagent to break down the spec and requirements into an actionable tasks list
with strategic grouping and ordering.

Provide the tasks-list-creator:

- `agent-os/specs/[this-spec]/spec.md` (if present)
- `agent-os/specs/[this-spec]/planning/requirements.md` (if present)
- `agent-os/specs/[this-spec]/planning/visuals/` and its' contents (if present)

The tasks-list-creator will create `tasks.md` inside the spec folder.

## PHASE 2.5: Validate Vertical Slicing

Before informing the user, verify the generated tasks.md:

1. Read the generated tasks.md
2. For each slice, check: Does "What this delivers" describe something a USER
   can see or do?
3. If any slice describes internal/technical work (e.g., "Model now has X
   method", "Add scope to Season"), the slicing needs review.

**If slices look technical:**

First, try to restructure by asking the tasks-list-creator to reframe around
user outcomes.

If restructuring fails or the work is genuinely infrastructure-only (CI/CD,
refactoring, tooling), ask the user for confirmation:

```
⚠️ Some slices don't have clear user-facing outcomes:

- Slice X: "[slice title]"
- Slice Y: "[slice title]"

Options:
1. Help me find the user/developer outcome for these
2. Confirm this is truly infrastructure-only work
3. Let me try restructuring the slices differently
```

Only proceed to Phase 3 after:
- All slices are user-focused, OR
- User has explicitly confirmed infrastructure-only exceptions

## PHASE 3: Inform user

Once the tasks-list-creator has created `tasks.md` output the following to
inform the user:

```
Your tasks list ready!

✅ Tasks list created: `agent-os/specs/[this-spec]/tasks.md`

NEXT STEP 👉 Run `/implement-tasks` (simple, effective) or `/orchestrate-tasks` (advanced, powerful) to start building!
```
