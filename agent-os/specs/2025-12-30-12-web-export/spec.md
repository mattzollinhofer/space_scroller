# Specification: Web Export

## Goal

Configure automated web (HTML5) export and GitHub Pages deployment for Solar System Showdown, enabling players to access the game via browser with persistent high scores.

## User Stories

- As a player, I want to play Solar System Showdown in my web browser so that I can enjoy the game without installing anything
- As a developer, I want automated builds deployed to GitHub Pages on each push to main so that the latest version is always publicly available

## Specific Requirements

**Game is playable in web browser via GitHub Pages URL**

- Create `export_presets.cfg` with Web/HTML5 export configuration for Godot 4.3
- Export preset name must be exactly "Web" (case-sensitive, used by CI)
- Use "mobile" rendering method (already configured in project.godot)
- Target viewport 2048x1536 with canvas_items stretch mode (existing settings)
- Ensure CORS headers are properly handled by GitHub Pages (automatic for static content)

**Automated builds on push to main branch**

- Create GitHub Actions workflow at `.github/workflows/deploy-web.yml`
- Use `barichello/godot-ci:4.3` Docker container for headless Godot export
- Trigger on push to main branch only
- Run on `ubuntu-24.04` (required for Godot 4)
- Export to `build/web/index.html` using `godot --headless --export-release "Web"`
- Upload build artifact for debugging/verification

**Deployment to GitHub Pages gh-pages branch**

- Use `JamesIves/github-pages-deploy-action@releases/v4` for deployment
- Deploy from `build/web` folder to `gh-pages` branch
- Install rsync in container (required by deploy action)
- Repository must be configured to serve GitHub Pages from gh-pages branch

**High scores persist across browser sessions**

- Existing ScoreManager already uses `user://high_scores.cfg` path
- Godot automatically maps `user://` to IndexedDB/localStorage in web exports
- No code changes required; existing ConfigFile-based persistence will work

**Existing keyboard controls work in browser**

- Existing input mappings in project.godot are keyboard-based (WASD, arrows, spacebar)
- No changes needed; keyboard input works natively in web exports
- No touch/mouse controls in scope

## Visual Design

No visual assets provided.

## Leverage Existing Knowledge

**Code, component, or existing logic found**

ScoreManager persistence pattern using user:// path

- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:23-24] - HIGH_SCORE_PATH constant using user:// storage
  - Uses `user://high_scores.cfg` path which Godot maps to browser storage
  - ConfigFile-based persistence will work automatically in web export
  - No modifications needed for web compatibility

Existing gitignore patterns for export files

- [@/Users/matt/dev/space_scroller/.gitignore:8-9] - Ignores export.cfg and export_credentials.cfg
  - Note: export_presets.cfg is NOT ignored and should be committed
  - This is correct; export_presets.cfg must be in version control for CI

Project rendering configuration

- [@/Users/matt/dev/space_scroller/project.godot:62] - Mobile rendering method
  - Already set to "mobile" which is optimal for web performance
  - No changes needed to rendering configuration

Input mappings already configured for keyboard

- [@/Users/matt/dev/space_scroller/project.godot:30-58] - WASD, arrow keys, spacebar bindings
  - All controls are keyboard-based, will work in browser
  - No touch controls configured (out of scope)

**Git Commit found**

Development environment setup established project foundation

- [fc2a854:Document requirements for dev environment setup] - Initial project structure patterns
  - Established Godot 4.3 as project version
  - Set up basic project.godot configuration
  - Pattern for adding new configuration files

Score system implementation shows autoload pattern

- [e0fa2bd:Display player score in HUD during gameplay] - ScoreManager autoload integration
  - ScoreManager registered in project.godot autoloads
  - Uses signals for UI updates
  - High score persistence already implemented

Roadmap context for web deployment

- [e2a6ab1:Add GitHub Pages hosting to roadmap] - Web deployment planning
  - Roadmap items 11-12 cover web export and GitHub Pages
  - localStorage for high scores mentioned
  - Future Firebase upgrade noted as out of scope

## Out of Scope

- Mobile touch controls for web gameplay
- Firebase integration or global leaderboards
- Analytics or tracking scripts
- Custom loading/splash screens beyond Godot default
- Mouse-based controls (click-to-shoot, mouse movement)
- Multiple export platforms (Windows, Linux, macOS, iOS)
- Custom domain configuration for GitHub Pages
- CI/CD for any branch other than main
- Automated testing in CI pipeline
- Build notifications or status badges
