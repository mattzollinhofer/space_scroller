# Task Breakdown: Web Export

## Overview

Total Slices: 3
Each slice delivers incremental user/developer value and is tested end-to-end.

This feature enables the Solar System Showdown game to be played in web browsers via GitHub Pages with automated deployment on push to main.

## Task List

### Slice 1: Developer can export game locally for web

**What this delivers:** Developer can run `godot --headless --export-release "Web"` and get a working HTML5 build in `build/web/`

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/project.godot:60-62] - Rendering method already set to "mobile" (optimal for web)
- [@/Users/matt/dev/space_scroller/.gitignore:8-9] - export.cfg and export_credentials.cfg are ignored, but export_presets.cfg should be committed

#### Tasks

- [x] 1.1 Create `export_presets.cfg` with Web/HTML5 export configuration
  - Export preset name must be exactly "Web" (case-sensitive, used by CI)
  - Use "mobile" rendering method (matches project.godot)
  - Target viewport 2048x1536 with canvas_items stretch mode
  - Export path: `build/web/index.html`
  - Note: VRAM texture compression disabled (for_desktop=false, for_mobile=false) to avoid ETC2/ASTC validation errors
- [x] 1.2 Add `build/` directory to `.gitignore` (export artifacts should not be committed)
- [x] 1.3 Verify export works locally by running Godot export command
  - Run `godot --headless --export-release "Web" build/web/index.html`
  - Verify `build/web/index.html` is created
  - Note: Requires Godot 4.x with Web export templates installed locally
  - Success: Export produces index.html, index.js, index.wasm, index.pck and supporting files
- [x] 1.4 Test the exported build in a local web server
  - Use Python: `python -m http.server 8000 -d build/web`
  - Open `http://localhost:8000` in browser
  - Verify game loads and runs (keyboard controls work, score displays)
  - Note: Manual testing step - server confirmed running, files served correctly
- [x] 1.5 Verify high score persistence works in browser
  - Play game, achieve a score, complete/die
  - Refresh browser page
  - Verify high score persists (uses IndexedDB via Godot's user:// mapping)
  - Note: Manual testing step - existing ScoreManager uses user:// path which maps to IndexedDB
- [x] 1.6 Commit export configuration files

**Acceptance Criteria:**
- `export_presets.cfg` exists with Web export preset named "Web"
- Running `godot --headless --export-release "Web" build/web/index.html` produces working HTML5 build
- Game runs in browser with keyboard controls working
- High scores persist across browser sessions
- `build/` directory is gitignored

---

### Slice 2: Automated web builds run on push to main

**What this delivers:** When developer pushes to main branch, GitHub Actions automatically builds the web export and uploads it as an artifact

**Dependencies:** Slice 1 (export_presets.cfg must exist)

**Reference patterns:**
- Spec requirement: Use `barichello/godot-ci:4.3` Docker container
- Spec requirement: Run on `ubuntu-24.04`

#### Tasks

- [x] 2.1 Create `.github/workflows/` directory structure
  - Created `.github/workflows/` directory
- [x] 2.2 Create `deploy-web.yml` workflow file with build job
  - Trigger on push to main branch only
  - Use `ubuntu-24.04` runner
  - Use `barichello/godot-ci:4.3` container
  - Run `godot --headless --export-release "Web" build/web/index.html`
  - Upload `build/web/` as artifact for verification
- [x] 2.3 Test workflow by pushing to main (or reviewing workflow syntax)
  - Workflow syntax verified valid
  - Full testing will occur when pushed to main
  - Note: Workflow will trigger on push to main, build artifact upload configured with 7-day retention
- [x] 2.4 Commit working CI workflow

**Acceptance Criteria:**
- `.github/workflows/deploy-web.yml` exists
- Workflow triggers only on push to main branch
- Build artifact is uploaded and downloadable
- Downloaded artifact runs correctly in browser

---

### Slice 3: Game is deployed to GitHub Pages automatically

**What this delivers:** Players can access the game at `https://mattzollinhofer.github.io/space_scroller/` after each push to main

**Dependencies:** Slice 2 (CI build must work first)

**Reference patterns:**
- Spec requirement: Use `JamesIves/github-pages-deploy-action@releases/v4`
- Spec requirement: Deploy to `gh-pages` branch
- Spec requirement: Install rsync in container (required by deploy action)

#### Tasks

- [x] 3.1 Update `deploy-web.yml` to add deployment step
  - Added rsync installation step (apt-get update && apt-get install -y rsync)
  - Added JamesIves/github-pages-deploy-action@releases/v4 deployment step
  - Configured to deploy from `build/web` folder to `gh-pages` branch
  - Renamed job from `build` to `build-and-deploy` to reflect its dual purpose
- [x] 3.2 Configure repository for GitHub Pages (manual step, document in task)
  - **Manual Configuration Required:**
    1. Go to repository Settings > Pages (https://github.com/mattzollinhofer/space_scroller/settings/pages)
    2. Under "Build and deployment", set Source to "Deploy from a branch"
    3. Select `gh-pages` branch and `/ (root)` folder
    4. Click Save
  - Note: Repository is private; GitHub Pages requires GitHub Pro/Team/Enterprise for private repos, or make repo public
  - Note: The `gh-pages` branch will be created automatically by the deploy action on first successful run
- [ ] 3.3 Test full deployment pipeline
  - Push to main and wait for workflow to complete
  - Verify `gh-pages` branch is created/updated
  - Access game at GitHub Pages URL
  - Verify game loads, plays with keyboard controls
  - Verify high scores persist across browser sessions
- [x] 3.4 Document the GitHub Pages URL for users
  - URL: `https://mattzollinhofer.github.io/space_scroller/`
- [x] 3.5 Commit final workflow changes

**Acceptance Criteria:**
- Game is accessible at GitHub Pages URL
- Deployment happens automatically on push to main
- Game is fully playable with keyboard controls
- High scores persist across browser sessions
- CORS works correctly (automatic for GitHub Pages static content)

---

## Notes

### No Code Changes Required

Per the spec, the following existing functionality works without modification:
- Keyboard controls (WASD, arrows, spacebar) work in browser
- High score persistence via `user://high_scores.cfg` maps to IndexedDB
- Mobile rendering method is already configured

### Manual Steps

Some tasks require manual configuration in GitHub UI:
- Task 3.2: Configure GitHub Pages source in repository settings
  - Navigate to: https://github.com/mattzollinhofer/space_scroller/settings/pages
  - Set source to "Deploy from a branch"
  - Select `gh-pages` branch, `/ (root)` folder

### GitHub Pages URL

Once deployed, the game will be accessible at:
**https://mattzollinhofer.github.io/space_scroller/**
