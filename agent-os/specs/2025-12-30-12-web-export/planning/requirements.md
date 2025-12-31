# Spec Requirements: Web Export

## Initial Description

The user wants to configure web export in their Godot game project. This is related to roadmap item 12 (GitHub Pages Hosting) which involves deploying the web export to GitHub Pages.

Context:
- This feature enables the game to be exported for web browsers
- The web export will be deployed to GitHub Pages for hosting
- Part of the distribution/deployment phase of the project

## Requirements Discussion

### First Round Questions

**Q1:** I assume you want to deploy the game to a GitHub Pages site under your existing `space_scroller` repository (e.g., `https://yourusername.github.io/space_scroller/`). Is that correct, or would you prefer a separate repository for hosting?
**Answer:** Yes, they want to use the existing space_scroller repo. However, the repo is currently private. They don't want to manage another repository, but are okay with a separate public repo if that's required to make it publicly playable on GitHub Pages.

**Q2:** Looking at the roadmap, item 11 mentions "keyboard/mouse fallback controls" for web. I see you already have WASD and arrow key bindings configured in the project. I assume these are sufficient for web play and no additional mouse-based controls (like click-to-shoot or mouse movement) are needed. Is that correct?
**Answer:** Yes, existing WASD/arrow key bindings are sufficient for web play. No additional mouse controls needed.

**Q3:** For the build/deployment workflow, I'm thinking we should create a GitHub Actions workflow that automatically builds and deploys to GitHub Pages when you push to main (or a specific branch). Would you prefer this automated CI/CD approach, or a manual export-and-push process?
**Answer:** Yes, automated CI/CD with GitHub Actions.

**Q4:** The roadmap mentions localStorage for personal high score persistence. I assume we should configure the web export to use Godot's standard `user://` data storage which maps to IndexedDB/localStorage in browsers. Is that correct, or do you have specific requirements for how scores should be stored?
**Answer:** Yes, use Godot's standard user:// data storage (maps to IndexedDB/localStorage in browsers). Whatever is normal.

**Q5:** For the GitHub Pages deployment, I assume we should output the build to a `docs/` folder on the main branch (simplest GitHub Pages setup) or would you prefer a dedicated `gh-pages` branch?
**Answer:** No preference - go with whatever is easiest.

**Q6:** Should we add any loading screen or splash screen for the web build while assets load, or is the default Godot loading behavior acceptable?
**Answer:** Default Godot loading behavior is acceptable.

**Q7:** Is there anything that should explicitly NOT be included in this web export work? For example, should we avoid mobile touch controls, Firebase integration, or any analytics at this stage?
**Answer:** Keep it simple - only what was discussed. No mobile touch controls, Firebase, or analytics.

### Existing Code to Reference

No similar existing features identified for reference.

Note: The project does not currently have:
- An `export_presets.cfg` file (no export configuration exists yet)
- A `.github/` folder (no existing workflows)

The project does have keyboard input bindings already configured in `project.godot`:
- WASD keys for movement (move_up, move_down, move_left, move_right)
- Arrow keys as alternatives for movement
- Spacebar for shooting

### Follow-up Questions

No follow-up questions were needed.

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

N/A

## Requirements Summary

### Functional Requirements

- Configure Godot 4.3 HTML5/Web export for the Solar System Showdown game
- Set up GitHub Actions workflow for automated builds on push to main
- Deploy built game to GitHub Pages for public access
- Use Godot's standard `user://` storage for high score persistence (maps to browser IndexedDB/localStorage)
- Leverage existing keyboard controls (WASD, arrow keys, spacebar) for web gameplay

### Repository Considerations

- Primary preference: Use existing `space_scroller` repository
- Current status: Repository is private
- Fallback option: User is willing to create a separate public repository if required for GitHub Pages public access
- Note: GitHub Pages can serve from private repos with GitHub Pro/Team/Enterprise, or the repo can be made public

### Reusability Opportunities

- Existing input mappings in `project.godot` are already configured for keyboard play
- No existing export or CI/CD patterns to build upon (greenfield setup)

### Scope Boundaries

**In Scope:**
- Godot HTML5 export configuration (`export_presets.cfg`)
- GitHub Actions workflow for automated web builds
- GitHub Pages deployment configuration
- Standard Godot loading behavior
- Keyboard controls (WASD, arrows, spacebar)
- Browser-based score persistence via Godot's `user://` storage

**Out of Scope:**
- Mobile touch controls for web
- Firebase integration or global leaderboards
- Analytics or tracking
- Custom loading/splash screens
- Mouse-based controls
- Any additional control schemes beyond existing keyboard bindings

### Technical Considerations

- Godot version: 4.3 (project.godot shows features=PackedStringArray("4.5", "Forward Plus"))
- Rendering method: "mobile" (already configured, suitable for web)
- Viewport: 2048x1536 with canvas_items stretch mode
- Will need Godot HTML5 export templates installed in CI environment
- GitHub Actions will need to use a Godot Docker image or install Godot for headless export
- Deployment target: `gh-pages` branch (easiest for GitHub Actions to deploy without affecting main branch)
