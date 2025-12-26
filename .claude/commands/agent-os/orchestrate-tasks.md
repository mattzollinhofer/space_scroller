# Process for Orchestrating a Spec's Implementation

Now that we have a spec and tasks list ready for implementation, we will proceed
with orchestrating implementation of each slice by a dedicated agent using the
following MULTI-PHASE process.

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### FIRST: Get tasks.md for this spec

IF you already know which spec we're working on and IF that spec folder has a
`tasks.md` file, then use that and skip to the NEXT phase.

IF you don't already know which spec we're working on and IF that spec folder
doesn't yet have a `tasks.md` THEN output the following request to the user:

```
Please point me to a spec's `tasks.md` that you want to orchestrate implementation for.

If you don't have one yet, then run any of these commands first:
/shape-spec
/write-spec
/create-tasks
```

### NEXT: Create orchestration.yml to serve as a roadmap for orchestration of slices

In this spec's folder, create this file:
`agent-os/specs/[this-spec]/orchestration.yml`.

Populate this file with with the names of each slice found in this spec's
`tasks.md` and use this EXACT structure for the content of `orchestration.yml`:

```yaml
slices:
  - name: [slice-name]
  - name: [slice-name]
  - name: [slice-name]
  # Repeat for each slice found in tasks.md
```


### NEXT: Ask user to assign subagents to each slice

Next we must determine which subagents should be assigned to which slices. Ask
the user to provide this info using the following request to user and WAIT for
user's response:

```
Please specify the name of each subagent to be assigned to each slice:

1. [slice-name]
2. [slice-name]
3. [slice-name]
[repeat for each slice you've added to orchestration.yml]

Simply respond with the subagent names and corresponding slice number and I'll update orchestration.yml accordingly.
```

Using the user's responses, update `orchestration.yml` to specify those subagent
names. `orchestration.yml` should end up looking like this:

```yaml
slices:
  - name: [slice-name]
    claude_code_subagent: [subagent-name]
  - name: [slice-name]
    claude_code_subagent: [subagent-name]
  - name: [slice-name]
    claude_code_subagent: [subagent-name]
  # Repeat for each slice found in tasks.md
```

For example, after this step, the `orchestration.yml` file might look like this
(exact names will vary):

```yaml
slices:
  - name: user-can-create-comment
    claude_code_subagent: implementer
  - name: user-can-edit-comment
    claude_code_subagent: implementer
  - name: user-can-delete-comment
    claude_code_subagent: implementer
```



### NEXT: Ask user to assign standards to each slice

Next we must determine which standards should guide the implementation of each
slice. Ask the user to provide this info using the following request to user and
WAIT for user's response:

```
Please specify the standard(s) that should be used to guide the implementation of each slice:

1. [slice-name]
2. [slice-name]
3. [slice-name]
[repeat for each slice you've added to orchestration.yml]

For each slice number, you can specify any combination of the following:

"all" to include all of your standards
"global/*" to include all of the files inside of standards/global
"frontend/css.md" to include the css.md standard file
"none" to include no standards for this slice.
```

Using the user's responses, update `orchestration.yml` to specify those
standards for each slice. `orchestration.yml` should end up having AT LEAST the
following information added to it:

```yaml
slices:
  - name: [slice-name]
    standards:
      - [users' 1st response for this slice]
      - [users' 2nd response for this slice]
      - [users' 3rd response for this slice]
      # Repeat for all standards that the user specified for this slice
  - name: [slice-name]
    standards:
      - [users' 1st response for this slice]
      - [users' 2nd response for this slice]
      # Repeat for all standards that the user specified for this slice
  # Repeat for each slice found in tasks.md
```

For example, after this step, the `orchestration.yml` file might look like this
(exact names will vary):

```yaml
slices:
  - name: user-can-create-comment
    standards:
      - all
  - name: user-can-edit-comment
    standards:
      - global/*
      - frontend/components.md
      - testing/test-writing.md
  - name: user-can-delete-comment
    standards:
      - all
```

Note: If the `use_claude_code_subagents` flag is enabled, the final
`orchestration.yml` would include BOTH `claude_code_subagent` assignments AND


### NEXT: Delegate slice implementations to assigned subagents

Loop through each slice in `agent-os/specs/[this-spec]/tasks.md` and delegate
its implementation to the assigned subagent specified in `orchestration.yml`.

For each delegation, provide the subagent with:

- The slice (including the slice description and all sub-tasks)
- The spec file: `agent-os/specs/[this-spec]/spec.md`
- Instruct subagent to:
  - Perform their implementation following the red-green cycle
  - Check off the tasks in `agent-os/specs/[this-spec]/tasks.md`

In addition to the above items, also instruct the subagent to closely adhere to
the user's standards & preferences as specified in the following files. To build
the list of file references to give to the subagent, follow these instructions:

#### Compile Implementation Standards

Use the following logic to compile a list of file references to standards that
should guide implementation:

##### Steps to Compile Standards List

1. Find the current slice in `orchestration.yml`
2. Check the list of `standards` specified for this slice in `orchestration.yml`
3. Compile the list of file references to those standards, one file reference
   per line, using this logic for determining which files to include: a. If the
   value for `standards` is simply `all`, then include every single file,
   folder, sub-folder and files within sub-folders in your list of files. b. If
   the item under standards ends with "_" then it means that all files within
   this folder or sub-folder should be included. For example,
   `frontend/_`means include all files and sub-folders and their files located inside of`agent-os/standards/frontend/`. c. If a file ends in `.md`then it means this is one specific file you must include in your list of files. For example`backend/api.md`means you must include the file located at`agent-os/standards/backend/api.md`.
   d. De-duplicate files in your list of file references.

##### Output Format

The compiled list of standards should look something like this, where each file
reference is on its own line and begins with `@`. The exact list of files will
vary:

```
@agent-os/standards/global/coding-style.md
@agent-os/standards/global/conventions.md
@agent-os/standards/global/tech-stack.md
@agent-os/standards/backend/api/authentication.md
@agent-os/standards/backend/api/endpoints.md
@agent-os/standards/backend/api/responses.md
@agent-os/standards/frontend/css.md
@agent-os/standards/frontend/responsive.md
```


Provide all of the above to the subagent when delegating slices for it to
