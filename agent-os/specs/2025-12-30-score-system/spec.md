# Specification: Score System

## Goal

Implement a simple, kid-friendly score tracking system that awards points for destroying enemies and collecting pickups, persists high scores locally, and displays the score on the HUD and end screens.

## User Stories

- As a player, I want to earn points for destroying enemies so that I feel rewarded for my combat success
- As a player, I want to see my current score during gameplay so that I can track my progress

## Specific Requirements

**Player sees current score in the HUD**

- Display score in top-right area of screen (lives are top-left, progress bar is top-center)
- Format: "SCORE: 12,500" with comma-separated thousands
- Use CanvasLayer similar to HealthDisplay for consistent UI overlay
- Font size should be readable but not dominate screen (similar to progress bar styling)
- Score updates immediately when points are awarded
- CanvasLayer layer value should match other UI elements (layer 10)

**Enemies award points based on type**

- Stationary enemies (1 HP): 100 points
- Patrol enemies (2 HP): 200 points
- Points awarded when enemy.died signal emits (death, not just damage)
- ScoreManager listens to enemy deaths via signal connection
- Enemy type identified via class_name (BaseEnemy vs PatrolEnemy)

**UFO Friend pickup awards bonus points**

- Award 500 bonus points when UFO Friend is collected
- Points awarded in addition to the extra life gained
- Connect to UfoFriend.collected signal for point award
- Only award points if UFO was actually collected (life was gained)

**Level completion awards flat bonus**

- Award 5,000 points when level_completed signal emits
- Bonus added to current score before displaying on Level Complete screen
- LevelManager.level_completed signal triggers the bonus

**High scores persist locally**

- Store top 10 high scores using Godot ConfigFile
- Save to user://high_scores.cfg for cross-platform compatibility
- Each entry stores: score (int), date (ISO string)
- Load high scores on game start, save when new high score achieved
- Scores sorted descending, oldest duplicate scores dropped first

**End screens display score information**

- Game Over screen: Show "SCORE: X,XXX" and "HIGH SCORE: X,XXX"
- Level Complete screen: Show "SCORE: X,XXX" (includes level bonus) and "HIGH SCORE: X,XXX"
- Add Label nodes to existing VBoxContainer in each screen
- Check if current score qualifies as new high score and indicate visually

## Visual Design

No visual mockups provided.

**Score Display (HUD element)**

- Position: top-right corner, mirroring health display placement on left
- Approximate offset: right edge minus ~300px, top offset ~25px
- Text style: white color, font size ~48-64 to match game aesthetic
- Format: "SCORE:" label followed by formatted number

**End Screen Score Labels**

- Add below existing "GAME OVER" or "LEVEL COMPLETE" title
- Smaller font size than title (~64px vs 128px)
- Show both current score and high score
- Optional: "NEW HIGH SCORE!" indicator when applicable

## Leverage Existing Knowledge

**Code, component, or existing logic found**

HUD UI pattern from HealthDisplay

- [@scripts/ui/health_display.gd:1-83] - CanvasLayer-based HUD element pattern
   - Extends CanvasLayer for UI overlay above game content
   - Uses process_mode = PROCESS_MODE_ALWAYS for pause compatibility
   - _connect_to_player() pattern for finding and connecting to game nodes
   - Container child node with positioned UI elements
   - _update_display() method for refreshing visual state

- [@scenes/ui/health_display.tscn:1-43] - Scene structure for HUD elements
   - layer = 10 for proper UI stacking
   - Container Control node with offset positioning
   - TextureRect children for visual elements
   - Can use Label node instead for score text

Enemy death signals and tracking

- [@scripts/enemies/enemy_spawner.gd:156-159] - Enemy died signal connection pattern
   - Connects to enemy.died signal in _setup_enemy()
   - _on_enemy_killed() callback for handling death events
   - Pattern can be extended for score awarding

- [@scripts/enemies/base_enemy.gd:32-33] - Enemy died signal definition
   - signal died() emitted in _on_health_depleted()
   - Emitted before destruction animation starts
   - Available for ScoreManager to connect to

- [@scripts/enemies/patrol_enemy.gd:1-10] - PatrolEnemy class identification
   - class_name PatrolEnemy distinguishes from base enemy
   - Can use is PatrolEnemy check to determine point value

UFO Friend collection integration

- [@scripts/pickups/ufo_friend.gd:31-32] - Collected signal
   - signal collected() emitted when player gains life
   - Only emits if gain_life() returns true
   - Perfect hook for awarding bonus points

- [@scripts/pickups/ufo_friend.gd:95-101] - Collection handling
   - _on_body_entered checks gain_life() success
   - collected.emit() happens after successful life gain
   - ScoreManager can connect to this signal

Level completion integration

- [@scripts/level_manager.gd:29-32] - Level completed signal
   - signal level_completed() emits when progress reaches 100%
   - Perfect hook for level completion bonus
   - Already used by test_level_complete.gd

End screen patterns

- [@scripts/game_over_screen.gd:1-24] - Game over screen script
   - show_game_over() method for displaying screen
   - Can be extended to accept and display score
   - Uses get_tree().paused = true

- [@scenes/ui/game_over_screen.tscn:1-26] - Game over screen structure
   - VBoxContainer for vertical layout of labels
   - theme_override_font_sizes for text styling
   - Can add ScoreLabel and HighScoreLabel nodes

- [@scenes/ui/level_complete_screen.tscn:1-26] - Level complete screen structure
   - Same VBoxContainer pattern as game over
   - Can add same score display elements

Progress bar as UI reference

- [@scripts/ui/progress_bar.gd:1-43] - Simple HUD component pattern
   - Minimal script with set/get methods
   - _update_fill() for visual refresh
   - Can use similar pattern for score display

Main scene integration points

- [@scenes/main.tscn:79-84] - EnemySpawner in scene tree
   - Located at Main/EnemySpawner path
   - ScoreManager needs reference to connect enemy signals

- [@scenes/main.tscn:104] - HealthDisplay instance
   - Added as sibling to other UI elements
   - ScoreDisplay should be added similarly

**Git Commit found**

Health display implementation

- [66d8b97:Show player lives as heart icons in the UI] - HUD element creation pattern
   - Created CanvasLayer-based UI component
   - Added to main.tscn as instance
   - Signal connection to player for updates
   - Floating animation effect for visual feedback

UFO friend with signals

- [72f59d3:Reward skilled players with extra lives from UFO friends] - Pickup with signal pattern
   - collected signal emission pattern
   - Integration with existing game systems
   - spawn_floating_heart() visual feedback method

Level complete screen

- [238fc57:Show Level Complete screen when player finishes level] - End screen pattern
   - Created UI screen with VBoxContainer layout
   - Connected to level_completed signal
   - Pause game on show pattern

Game over screen

- [e6ac740:Add game over screen displayed when player loses] - End screen creation
   - CanvasLayer-based overlay
   - CenterContainer for positioning
   - Player.died signal connection

## Out of Scope

- Combo system or score multipliers (keep simple for ages 6-12)
- Time-based survival bonuses
- Accuracy bonuses for hit percentage
- Online leaderboards or cloud sync
- Score sharing to social media
- Per-section or per-checkpoint score bonuses
- Score penalties for taking damage
- Animated score counter (counting up effect)
- Score popup text at enemy death location
- Achievement system tied to score milestones
