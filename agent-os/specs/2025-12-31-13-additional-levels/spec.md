# Specification: Additional Levels

## Goal

Create 2 additional levels (Level 2 and Level 3) with unique solar system visual themes, progressive enemy introduction, and escalating difficulty, accessed via a level select menu.

## User Stories

- As a player, I want to unlock and play additional levels so that the game has more content and replay value
- As a player, I want each level to feel visually distinct so that progression feels meaningful

## Specific Requirements

**Level select screen from main menu**

- Add "Level Select" button to main menu (between Play and Character Select)
- Level select screen shows 3 level buttons with locked/unlocked states
- Level 1 always unlocked; Level 2 unlocks after beating Level 1; Level 3 unlocks after beating Level 2
- Store unlock state in ConfigFile at same path as high scores (user://high_scores.cfg)
- Selecting a level transitions to main.tscn with that level's JSON loaded

**Level 2 JSON configuration (Inner Solar System theme)**

- Create levels/level_2.json with 5-6 sections
- Total distance: 15000-18000 pixels
- Scroll speed: 10-15% faster than Level 1 base (set in JSON metadata)
- Introduce shooting enemy type in waves (alongside stationary and patrol)
- Denser obstacle spawning (use "high" density earlier)
- Boss uses boss-2.png sprite

**Level 3 JSON configuration (Outer Solar System theme)**

- Create levels/level_3.json with 6-7 sections
- Total distance: 18000-22000 pixels
- Scroll speed: 20-25% faster than Level 1 base
- Introduce charger enemy type (alongside all previous enemy types)
- Most dense obstacle spawning throughout
- Boss uses boss-1.png with ice-blue modulation (Color(0.6, 0.8, 1.0, 1.0)) as placeholder

**Level manager accepts level selection**

- Add level_number property to level_manager.gd
- Read scroll_speed from JSON metadata and apply to scroll_controller
- Read boss_sprite and boss_modulate from JSON for boss instantiation
- Update progress_bar level indicator when level loads

**Background theming system with color presets**

- Add theme_preset export variable to star_field.gd, nebulae.gd, debris.gd
- Presets: "default" (current purple/blue), "inner_solar" (red/orange/amber), "outer_solar" (blue/cyan/ice)
- Level JSON includes "background_theme" key that LevelManager passes to background nodes
- Background nodes read preset and regenerate with themed colors on _ready()

**Obstacle color modulation per level**

- Add obstacle_modulate color to JSON metadata
- ObstacleSpawner applies modulate to asteroid sprites when spawning
- Level 2: reddish-brown tint (Color(1.2, 0.8, 0.6, 1.0))
- Level 3: blue-gray ice tint (Color(0.7, 0.85, 1.0, 1.0))

**Enemy spawner supports all enemy types**

- Add shooting_enemy_scene and charger_enemy_scene exports to enemy_spawner.gd
- spawn_wave() handles "shooting" and "charger" enemy_type values
- Level JSON waves reference appropriate enemy types per level

**Level unlock persistence**

- Extend ScoreManager to track level_unlocks array in ConfigFile
- Add unlock_level(level_num) and is_level_unlocked(level_num) methods
- LevelCompleteScreen calls unlock_level() for next level on boss defeat

## Visual Design

No visual mockups were provided. Design follows existing UI patterns from main_menu.tscn.

## Leverage Existing Knowledge

**Code, component, or existing logic found**

Level Manager pattern for loading level data

- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:111-129] - JSON loading and parsing pattern
   - Uses FileAccess.open() with FileAccess.READ mode
   - Parses JSON with JSON.new() and json.parse()
   - Extracts total_distance and sections from parsed data
   - Already has level_path export variable for specifying which JSON to load

Level JSON structure template

- [@/Users/matt/dev/space_scroller/levels/level_1.json:1-43] - Complete level data format
   - Sections array with start_percent, end_percent, obstacle_density
   - enemy_waves array with enemy_type and count per section
   - Ready to extend with scroll_speed, background_theme, boss_sprite metadata

Background procedural color generation

- [@/Users/matt/dev/space_scroller/scripts/background/star_field.gd:49-57] - Star color generation with RNG
   - Uses randf_range for brightness variation
   - Mixes white and pale yellow - can add warm/cool presets
- [@/Users/matt/dev/space_scroller/scripts/background/nebulae.gd:49-65] - Nebula color palette
   - Uses match statement for color_choice selection
   - Returns Color with alpha for semi-transparency
   - Easy to add inner_solar and outer_solar color cases
- [@/Users/matt/dev/space_scroller/scripts/background/debris.gd:51-67] - Debris color palette
   - Gray/brown tones with brightness variation
   - Match statement pattern for multiple color options

Enemy spawner wave system

- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:106-118] - Wave spawning from config
   - Iterates wave_configs array with enemy_type and count
   - Calls type-specific spawn functions based on enemy_type string
   - Pattern ready to extend with "shooting" and "charger" cases

Enemy type class hierarchy

- [@/Users/matt/dev/space_scroller/scripts/enemies/shooting_enemy.gd:1-56] - ShootingEnemy extending BaseEnemy
   - Loads projectile scene and fires at intervals
   - Has 1 HP as fragile ranged attacker
- [@/Users/matt/dev/space_scroller/scripts/enemies/charger_enemy.gd:1-28] - ChargerEnemy extending BaseEnemy
   - Overrides movement with high-speed horizontal charge
   - Has 1 HP, moves at 2.5x scroll speed

Obstacle spawner density system

- [@/Users/matt/dev/space_scroller/scripts/obstacles/obstacle_spawner.gd:22-26] - DENSITY_RATES constant
   - Dictionary with low/medium/high spawn rate ranges
   - set_density() method updates spawn_rate_min/max
- [@/Users/matt/dev/space_scroller/scripts/obstacles/obstacle_spawner.gd:84-101] - Asteroid spawning pattern
   - Instantiates asteroid_scene, positions off right edge
   - Can add modulate property application here

Main menu UI pattern

- [@/Users/matt/dev/space_scroller/scenes/ui/main_menu.tscn:47-74] - Button layout with VBoxContainer
   - custom_minimum_size for button sizing
   - theme_override for font colors and sizes
   - disabled property for locked state
   - Signal connections to script methods
- [@/Users/matt/dev/space_scroller/scripts/ui/main_menu.gd:11-18] - Scene transition pattern
   - Checks for TransitionManager autoload
   - Falls back to direct change_scene_to_file

Score persistence with ConfigFile

- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:151-161] - ConfigFile save pattern
   - Creates ConfigFile, sets values by section/key, calls save()
- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:165-188] - ConfigFile load pattern
   - Checks file_exists, loads, gets values with defaults
   - Handles missing or corrupt files gracefully

Progress bar level indicator

- [@/Users/matt/dev/space_scroller/scripts/ui/progress_bar.gd:42-49] - set_level() method
   - Updates _current_level and calls _update_level_label()
   - Already exists and ready for LevelManager to call

Boss instantiation and sprite

- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:372-428] - Boss spawning in _spawn_boss()
   - Loads boss_scene PackedScene
   - Positions and adds to scene tree
   - Can add sprite modulation after instantiation

Level complete screen unlock trigger

- [@/Users/matt/dev/space_scroller/scripts/ui/level_complete_screen.gd:25-36] - show_level_complete() method
   - Already updates score display and pauses game
   - Good place to trigger level unlock

**Git Commit found**

Main menu structure and button patterns

- [6484af8:Add main menu as game entry point with Play button] - Initial menu implementation
   - Establishes VBoxContainer button layout
   - TransitionManager integration for smooth transitions
   - Pattern for adding new menu buttons

Level indicator display feature

- [99325ed:Show current level number below progress bar] - Level display UI
   - Added set_level() to progress_bar.gd
   - Test pattern for level indicator verification

Shooting enemy introduction

- [67f5068:Add ShootingEnemy type that fires projectiles toward player] - New enemy type pattern
   - Created shooting_enemy.gd extending BaseEnemy
   - Demonstrates enemy type introduction in waves

Pickup spawning from enemy kills

- [8d37715:Random pickup spawns every 5 enemy kills with sidekick or star] - Enemy spawner extension
   - Added new scene exports to enemy_spawner.gd
   - Extended spawn logic without breaking existing behavior

## Out of Scope

- New sprite artwork (use existing assets with color modulation)
- New enemy types beyond shooting and charger (already added in 12.5)
- Per-level audio/music (future roadmap item 15)
- Complex environmental mechanics (gravity wells, solar wind)
- Level 3 final boss unique artwork (user will provide later)
- Animated level select previews
- Per-level high score tracking (single global high score list remains)
- Level skip or cheat codes
- Difficulty settings separate from level
- Endless/survival mode
