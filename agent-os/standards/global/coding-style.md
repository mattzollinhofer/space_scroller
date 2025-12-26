## Coding style best practices

- **Committing**: Commits are a first class citizen. They should be done
  atomically. They should be focused on ONE thing. Sometimes they are very
  small, sometimes they can be larger. Documentation (checking boxes) commits
  are always separate. They follow the git-commits.md standards.
- **Consistent Naming Conventions**: Establish and follow naming conventions for
  variables, functions, classes, and files across the codebase
- **Automated Formatting**: Maintain consistent code style (indenting, line
  breaks, etc.)
- **Meaningful Names**: Choose descriptive names that reveal intent; avoid
  abbreviations and single-letter variables except in narrow contexts
- **Small, Focused Functions**: Keep functions small and focused on a single
  task for better readability and testability
- **File Size Limit**: CRITICAL - Keep all files under 200 lines maximum. When a
  file approaches this limit, refactor by extracting logic into separate
  modules, services, or concerns. This enforces better code organization and
  maintainability. There will be exceptions, but they should be minimal.
- **Consistent Indentation**: Use consistent indentation (spaces or tabs) and
  configure your editor/linter to enforce it
- **Remove Dead Code**: Delete unused code, commented-out blocks, and imports
  rather than leaving them as clutter
- **Backward compatibility only when required:** Unless specifically instructed
  otherwise, assume you do not need to write additional code logic to handle
  backward compatibility.
- **DRY Principle**: Avoid duplication by extracting common logic into reusable
  functions or modules
- **No Unnecessary Changes**: Only make changes necessary to complete the current task.
  Don't refactor unrelated code, update whitespace, "fix" something you noticed.
  If you see something worth improving, note it for later rather than addressing it now.
