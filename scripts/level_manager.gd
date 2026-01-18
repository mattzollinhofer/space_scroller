extends Node
## Manages level progression, section tracking, and checkpoints.
## Loads level data from JSON and orchestrates spawners based on current section.

## Path to the level JSON file
@export var level_path: String = "res://levels/level_1.json"

## Reference to the scroll controller for progress tracking
@export var scroll_controller_path: NodePath

## Reference to the progress bar UI
@export var progress_bar_path: NodePath

## Reference to the obstacle spawner
@export var obstacle_spawner_path: NodePath

## Reference to the enemy spawner
@export var enemy_spawner_path: NodePath

## Reference to the player
@export var player_path: NodePath

## Reference to the game over screen
@export var game_over_screen_path: NodePath

## Reference to the level complete screen
@export var level_complete_screen_path: NodePath

## Boss scene to spawn
@export var boss_scene: PackedScene

## Boss health bar scene to spawn
@export var boss_health_bar_scene: PackedScene

## Signals
signal section_changed(section_index: int)
signal level_completed()
signal player_respawned()
signal boss_spawned()

## Level data loaded from JSON
var _level_data: Dictionary = {}

## Level metadata (scroll_speed, background_theme, etc.)
var _level_metadata: Dictionary = {}

## Enemy configuration from level data
var _enemy_config: Dictionary = {}

## Total distance of the level in pixels
var _total_distance: float = 9000.0

## Sections array from level data
var _sections: Array = []

## Current section index
var _current_section: int = -1

## Current level number (1, 2, or 3)
var _level_number: int = 1

## Checkpoint data
var _checkpoint_section: int = -1
var _checkpoint_scroll_offset: float = 0.0

## Level completion state
var _level_complete: bool = false

## Boss fight state
var _boss_fight_active: bool = false
var _boss: Node = null
var _boss_health_bar: Node = null

## Boss battle position (stored for respawn)
var _boss_battle_position: Vector2 = Vector2.ZERO

## Original scroll speed (stored to restore after boss fight if needed)
var _original_scroll_speed: float = 180.0

## Reference to scroll controller
var _scroll_controller: Node = null

## Reference to progress bar
var _progress_bar: Node = null

## Reference to obstacle spawner
var _obstacle_spawner: Node = null

## Reference to enemy spawner
var _enemy_spawner: Node = null

## Reference to player
var _player: Node = null

## Reference to game over screen
var _game_over_screen: Node = null

## Reference to level complete screen
var _level_complete_screen: Node = null

## Current progress (0.0 to 1.0)
var _current_progress: float = 0.0

## Viewport dimensions for boss positioning
var _viewport_width: float = 2048.0
var _viewport_height: float = 1536.0


func _ready() -> void:
	_viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	_viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	_get_selected_level_from_game_state()
	_load_level_data()
	_setup_references()
	_apply_level_metadata()
	_setup_wave_based_spawning()
	_connect_player_signals()
	# Set initial section density and spawn first wave
	_check_section_change()
	# Start gameplay background music
	_start_gameplay_music()
	# Spawn sidekick if player had one from previous level (deferred to ensure player is ready)
	call_deferred("_restore_sidekick_from_game_state")


## Start gameplay background music via AudioManager
func _start_gameplay_music() -> void:
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("play_music"):
			audio_manager.play_music()


## Restore sidekick from GameState if player had one from previous level
func _restore_sidekick_from_game_state() -> void:
	if not has_node("/root/GameState"):
		return

	var game_state = get_node("/root/GameState")
	if not game_state.has_method("has_sidekick") or not game_state.has_sidekick():
		print("Restoring sidekick - has_sidekick: false")
		return

	print("Restoring sidekick - has_sidekick: true")

	# Load sidekick scene
	var sidekick_scene = load("res://scenes/pickups/sidekick.tscn")
	if not sidekick_scene:
		push_warning("Could not load sidekick scene for restoration")
		return

	# Spawn sidekick
	var sidekick = sidekick_scene.instantiate()
	sidekick.name = "Sidekick"

	# Get sprite path from game state
	var sprite_path = ""
	if game_state.has_method("get_sidekick_sprite"):
		sprite_path = game_state.get_sidekick_sprite()

	# Ensure we have a player reference
	if not _player:
		_player = get_tree().root.get_node_or_null("Main/Player")

	if not _player:
		push_warning("Cannot restore sidekick - player not found")
		return

	# Setup sidekick with player reference and sprite
	if sidekick.has_method("setup"):
		sidekick.setup(_player, sprite_path)

	# Add to main scene
	var main = get_parent()
	if main:
		main.add_child(sidekick)

	# Clear sidekick state so it doesn't persist if player loses it
	game_state.clear_sidekick_state()


## Get the selected level from GameState autoload
func _get_selected_level_from_game_state() -> void:
	if has_node("/root/GameState"):
		var game_state = get_node("/root/GameState")
		if game_state.has_method("get_selected_level"):
			_level_number = game_state.get_selected_level()
		if game_state.has_method("get_selected_level_path"):
			level_path = game_state.get_selected_level_path()


func _load_level_data() -> void:
	var file = FileAccess.open(level_path, FileAccess.READ)
	if not file:
		push_warning("Could not load level data from: %s" % level_path)
		return

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_warning("Failed to parse level JSON: %s" % json.get_error_message())
		return

	_level_data = json.data
	_total_distance = _level_data.get("total_distance", 9000.0)
	_sections = _level_data.get("sections", [])
	_level_metadata = _level_data.get("metadata", {})
	_enemy_config = _level_data.get("enemy_config", {})


func _setup_references() -> void:
	# Get scroll controller reference
	if not scroll_controller_path.is_empty():
		_scroll_controller = get_node_or_null(scroll_controller_path)
	if not _scroll_controller:
		_scroll_controller = get_tree().root.get_node_or_null("Main/ParallaxBackground")

	# Store original scroll speed
	if _scroll_controller and "scroll_speed" in _scroll_controller:
		_original_scroll_speed = _scroll_controller.scroll_speed

	# Get progress bar reference
	if not progress_bar_path.is_empty():
		_progress_bar = get_node_or_null(progress_bar_path)
	if not _progress_bar:
		_progress_bar = get_tree().root.get_node_or_null("Main/ProgressBar")

	# Get obstacle spawner reference
	if not obstacle_spawner_path.is_empty():
		_obstacle_spawner = get_node_or_null(obstacle_spawner_path)
	if not _obstacle_spawner:
		_obstacle_spawner = get_tree().root.get_node_or_null("Main/ObstacleSpawner")

	# Get enemy spawner reference
	if not enemy_spawner_path.is_empty():
		_enemy_spawner = get_node_or_null(enemy_spawner_path)
	if not _enemy_spawner:
		_enemy_spawner = get_tree().root.get_node_or_null("Main/EnemySpawner")

	# Get player reference
	if not player_path.is_empty():
		_player = get_node_or_null(player_path)
	if not _player:
		_player = get_tree().root.get_node_or_null("Main/Player")

	# Get game over screen reference
	if not game_over_screen_path.is_empty():
		_game_over_screen = get_node_or_null(game_over_screen_path)
	if not _game_over_screen:
		_game_over_screen = get_tree().root.get_node_or_null("Main/GameOverScreen")

	# Get level complete screen reference
	if not level_complete_screen_path.is_empty():
		_level_complete_screen = get_node_or_null(level_complete_screen_path)
	if not _level_complete_screen:
		_level_complete_screen = get_tree().root.get_node_or_null("Main/LevelCompleteScreen")


func _apply_level_metadata() -> void:
	## Apply level-specific metadata: scroll speed, background theme, obstacle modulate

	# Apply scroll speed multiplier
	if _scroll_controller and "scroll_speed" in _scroll_controller:
		var multiplier = _level_metadata.get("scroll_speed_multiplier", 1.0)
		_scroll_controller.scroll_speed = _original_scroll_speed * multiplier
		# Update the stored original for boss fight restoration
		_original_scroll_speed = _scroll_controller.scroll_speed

	# Apply background theme
	var background_theme = _level_metadata.get("background_theme", "default")
	_apply_background_theme(background_theme)

	# Apply obstacle modulate color
	var obstacle_modulate = _level_metadata.get("obstacle_modulate", null)
	if obstacle_modulate and _obstacle_spawner:
		var color = Color(obstacle_modulate[0], obstacle_modulate[1], obstacle_modulate[2], obstacle_modulate[3])
		if _obstacle_spawner.has_method("set_modulate_color"):
			_obstacle_spawner.set_modulate_color(color)
		elif "obstacle_modulate" in _obstacle_spawner:
			_obstacle_spawner.obstacle_modulate = color

	# Set progress bar level indicator
	if _progress_bar and _progress_bar.has_method("set_level"):
		_progress_bar.set_level(_level_number)


func _apply_background_theme(theme: String) -> void:
	## Apply theme to all background layer nodes
	var parallax_bg = get_tree().root.get_node_or_null("Main/ParallaxBackground")
	if not parallax_bg:
		return

	# Find all background layer nodes and apply theme
	for layer in parallax_bg.get_children():
		if layer is ParallaxLayer:
			for child in layer.get_children():
				if child.has_method("set_theme"):
					child.set_theme(theme)


func _setup_wave_based_spawning() -> void:
	# Disable continuous enemy spawning - we'll spawn waves at section boundaries
	if _enemy_spawner and _enemy_spawner.has_method("set_continuous_spawning"):
		_enemy_spawner.set_continuous_spawning(false)

	# Pass enemy config to spawner for per-level zigzag parameters
	if _enemy_spawner and _enemy_spawner.has_method("set_enemy_config"):
		_enemy_spawner.set_enemy_config(_enemy_config)

	# Pass current level number to spawner for level-specific pickups
	if _enemy_spawner and _enemy_spawner.has_method("set_current_level"):
		_enemy_spawner.set_current_level(_level_number)

	# Pass special enemies config to spawner for level-specific special enemies
	var special_enemies = _level_metadata.get("special_enemies", [])
	if _enemy_spawner and _enemy_spawner.has_method("set_special_enemies_config"):
		_enemy_spawner.set_special_enemies_config(special_enemies)

	# Enable filler spawning if special enemies are configured (they spawn during filler spawns)
	if not special_enemies.is_empty() and _enemy_spawner and _enemy_spawner.has_method("set_filler_spawning"):
		_enemy_spawner.set_filler_spawning(true)

	# Pass custom explosion sprite to spawner if configured
	var explosion_sprite = _level_metadata.get("explosion_sprite", "")
	if explosion_sprite != "" and _enemy_spawner and _enemy_spawner.has_method("set_explosion_sprite"):
		_enemy_spawner.set_explosion_sprite(explosion_sprite)


func _connect_player_signals() -> void:
	if _player and _player.has_signal("died"):
		# Disconnect from game over screen if connected
		if _game_over_screen and _player.died.is_connected(_game_over_screen.show_game_over):
			_player.died.disconnect(_game_over_screen.show_game_over)

		# Connect to our handler instead
		_player.died.connect(_on_player_died)


func _on_player_died() -> void:
	# Player has run out of lives - always show game over
	# No infinite respawns regardless of boss fight or checkpoint status
	if _game_over_screen and _game_over_screen.has_method("show_game_over"):
		_game_over_screen.show_game_over()


func _respawn_at_boss() -> void:
	## Respawn player at boss entrance and reset boss to full health

	# Clear boss projectiles
	_clear_boss_projectiles()

	# Reset player position and lives
	if _player:
		_player.position = Vector2(400, 768)  # Default spawn position
		if _player.has_method("reset_lives"):
			_player.reset_lives()
		else:
			# Fallback: set lives directly
			_player._lives = _player.starting_lives
			_player._is_invincible = false
			if _player.has_method("_end_invincibility"):
				_player._end_invincibility()

	# Reset boss to full health and battle position
	if _boss and is_instance_valid(_boss):
		if _boss.has_method("reset_health"):
			_boss.reset_health()
		else:
			# Fallback: reset health directly
			_boss.health = _boss._max_health if "_max_health" in _boss else 13

		# Reset boss position to battle position
		if _boss_battle_position != Vector2.ZERO:
			_boss.position = _boss_battle_position

		# Update health bar
		if _boss_health_bar and _boss_health_bar.has_method("set_health"):
			var boss_health = _boss.health if "health" in _boss else 13
			var boss_max_health = _boss._max_health if "_max_health" in _boss else 13
			_boss_health_bar.set_health(boss_health, boss_max_health)

	# Emit respawn signal
	player_respawned.emit()


func _clear_boss_projectiles() -> void:
	## Clear all boss projectiles from the scene
	var main = get_parent()
	if not main:
		return

	# Find and remove all boss projectiles
	for child in main.get_children():
		if child.name.begins_with("BossProjectile") or "boss_projectile" in child.name.to_lower():
			child.queue_free()
		elif child.get_script():
			var script_path = child.get_script().resource_path
			if "boss_projectile" in script_path:
				child.queue_free()


func _process(_delta: float) -> void:
	if _level_complete:
		return

	_update_progress()
	_check_section_change()
	_check_level_complete()


func _unhandled_input(event: InputEvent) -> void:
	# Debug: Cmd+Ctrl+Right Arrow to skip to next checkpoint
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_RIGHT and event.ctrl_pressed and event.meta_pressed:
			_debug_skip_to_next_section()


func _debug_skip_to_next_section() -> void:
	if _sections.is_empty() or not _scroll_controller:
		return

	# Find next section
	var next_section = _current_section + 1
	if next_section >= _sections.size():
		# Skip to end (boss fight)
		next_section = _sections.size() - 1
		var end_percent = _sections[next_section].get("end_percent", 100)
		var target_distance = (_total_distance * end_percent / 100.0) + 100
		_scroll_controller.scroll_offset.x = -target_distance
	else:
		# Skip to next section start
		var start_percent = _sections[next_section].get("start_percent", 0)
		var target_distance = _total_distance * start_percent / 100.0
		_scroll_controller.scroll_offset.x = -target_distance

	# Force update
	_update_progress()
	_check_section_change()
	_check_level_complete()


func _update_progress() -> void:
	if not _scroll_controller:
		return

	# scroll_offset.x is negative as it scrolls left, so we use the absolute value
	var distance_traveled = abs(_scroll_controller.scroll_offset.x)
	_current_progress = clamp(distance_traveled / _total_distance, 0.0, 1.0)

	# Update progress bar
	if _progress_bar and _progress_bar.has_method("set_progress"):
		_progress_bar.set_progress(_current_progress)


func _check_section_change() -> void:
	if _sections.is_empty():
		return

	var progress_percent = _current_progress * 100.0
	var new_section = _current_section

	# Find which section we're in based on progress percentage
	for i in range(_sections.size()):
		var section = _sections[i]
		var start = section.get("start_percent", 0)
		var end = section.get("end_percent", 100)

		if progress_percent >= start and progress_percent < end:
			new_section = i
			break

	# If we've reached 100%, we're in the last section
	if progress_percent >= 100.0:
		new_section = _sections.size() - 1

	# Check if section changed
	if new_section != _current_section:
		_current_section = new_section
		_on_section_changed(_current_section)


func _check_level_complete() -> void:
	if _current_progress >= 1.0 and not _level_complete:
		_level_complete = true
		_on_level_complete()


func _on_level_complete() -> void:
	# Award level completion bonus points via ScoreManager
	_award_level_complete_bonus()

	# Emit signal for other systems
	level_completed.emit()

	# Spawn boss instead of showing level complete screen immediately
	_spawn_boss()


func _award_level_complete_bonus() -> void:
	# Award bonus points via ScoreManager autoload
	if has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		if score_manager.has_method("award_level_complete_bonus"):
			score_manager.award_level_complete_bonus()


func _spawn_boss() -> void:
	# Load boss scene if not assigned
	if not boss_scene:
		boss_scene = load("res://scenes/enemies/boss.tscn")

	if not boss_scene:
		push_warning("Boss scene not found - showing level complete screen")
		_show_level_complete_screen()
		return

	# Instantiate boss
	_boss = boss_scene.instantiate()

	# Apply boss sprite from level metadata if specified
	var boss_sprite_path = _level_metadata.get("boss_sprite", "")
	if boss_sprite_path != "" and _boss:
		_apply_boss_sprite(_boss, boss_sprite_path)

	# Apply boss modulate color from level metadata if specified
	var boss_modulate = _level_metadata.get("boss_modulate", null)
	if boss_modulate and _boss:
		_apply_boss_modulate(_boss, boss_modulate)

	# Apply boss configuration (attacks, health, scale) from level metadata
	var boss_config = _level_metadata.get("boss_config", {}).duplicate()
	boss_config["level_number"] = _level_number
	if boss_config and _boss and _boss.has_method("configure"):
		_boss.configure(boss_config)

	# Position boss off right edge
	var spawn_x = _viewport_width + 200
	var spawn_y = _viewport_height / 2.0
	var spawn_position = Vector2(spawn_x, spawn_y)

	# Battle position is in right third of screen
	var battle_x = _viewport_width * 0.75
	var battle_position = Vector2(battle_x, spawn_y)

	# Store battle position for respawns
	_boss_battle_position = battle_position

	# Add to main scene
	var main = get_parent()
	if main:
		main.add_child(_boss)
		_boss.name = "Boss"

		# Setup boss with entrance animation
		if _boss.has_method("setup"):
			_boss.setup(spawn_position, battle_position)
		else:
			_boss.position = spawn_position

		# Connect to boss signals
		if _boss.has_signal("boss_defeated"):
			_boss.boss_defeated.connect(_on_boss_defeated)
		if _boss.has_signal("boss_entered"):
			_boss.boss_entered.connect(_on_boss_entered)
		if _boss.has_signal("health_changed"):
			_boss.health_changed.connect(_on_boss_health_changed)

		_boss_fight_active = true

		# Stop scrolling during boss fight (arena mode)
		_stop_scrolling_for_boss_fight()

		# Disable spawners during boss fight
		_disable_spawners_for_boss_fight()

		# Spawn boss health bar
		_spawn_boss_health_bar()

		# Crossfade to boss battle music via AudioManager
		_start_boss_music()

		boss_spawned.emit()


## Start boss battle music via AudioManager crossfade
func _start_boss_music() -> void:
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("crossfade_to_boss_music"):
			audio_manager.crossfade_to_boss_music(_level_number)


func _apply_boss_sprite(boss: Node, sprite_path: String) -> void:
	## Apply a custom boss sprite from the level metadata
	var animated_sprite = boss.get_node_or_null("AnimatedSprite2D")
	if not animated_sprite:
		return

	var texture = load(sprite_path)
	if not texture:
		push_warning("Could not load boss sprite: %s" % sprite_path)
		return

	# Get sprite frames and update ALL frames of the idle animation
	var frames = animated_sprite.sprite_frames
	if frames and frames.has_animation("idle"):
		var frame_count = frames.get_frame_count("idle")
		for i in range(frame_count):
			frames.set_frame("idle", i, texture)


func _apply_boss_modulate(boss: Node, modulate_array: Array) -> void:
	## Apply a color modulation to the boss sprite from the level metadata
	if modulate_array.size() < 4:
		return

	var color = Color(modulate_array[0], modulate_array[1], modulate_array[2], modulate_array[3])

	# Apply modulate to the AnimatedSprite2D
	var animated_sprite = boss.get_node_or_null("AnimatedSprite2D")
	if animated_sprite:
		animated_sprite.modulate = color
	else:
		# Fallback: apply to the boss node itself
		boss.modulate = color


func _stop_scrolling_for_boss_fight() -> void:
	## Stop screen scrolling for fixed arena during boss fight
	if _scroll_controller and "scroll_speed" in _scroll_controller:
		_scroll_controller.scroll_speed = 0.0


func _disable_spawners_for_boss_fight() -> void:
	## Disable obstacle and enemy spawners during boss fight
	if _obstacle_spawner:
		if _obstacle_spawner.has_method("set_enabled"):
			_obstacle_spawner.set_enabled(false)
		elif _obstacle_spawner.has_method("stop"):
			_obstacle_spawner.stop()
		elif "enabled" in _obstacle_spawner:
			_obstacle_spawner.enabled = false

	if _enemy_spawner:
		if _enemy_spawner.has_method("set_enabled"):
			_enemy_spawner.set_enabled(false)
		elif _enemy_spawner.has_method("stop"):
			_enemy_spawner.stop()
		elif "enabled" in _enemy_spawner:
			_enemy_spawner.enabled = false

	# Also clear existing enemies and obstacles for clean arena
	if _enemy_spawner and _enemy_spawner.has_method("clear_all"):
		_enemy_spawner.clear_all()
	if _obstacle_spawner and _obstacle_spawner.has_method("clear_all"):
		_obstacle_spawner.clear_all()


func _spawn_boss_health_bar() -> void:
	# Load boss health bar scene if not assigned
	if not boss_health_bar_scene:
		boss_health_bar_scene = load("res://scenes/ui/boss_health_bar.tscn")

	if not boss_health_bar_scene:
		push_warning("Boss health bar scene not found")
		return

	# Instantiate health bar
	_boss_health_bar = boss_health_bar_scene.instantiate()

	# Add to main scene
	var main = get_parent()
	if main:
		main.add_child(_boss_health_bar)
		_boss_health_bar.name = "BossHealthBar"

		# Initialize health bar with boss health
		if _boss and _boss_health_bar.has_method("set_health"):
			var boss_health = _boss.health if "health" in _boss else 13
			var boss_max_health = _boss._max_health if "_max_health" in _boss else 13
			_boss_health_bar.set_health(boss_health, boss_max_health)


func _on_boss_health_changed(current: int, max_health: int) -> void:
	# Update health bar when boss health changes
	if _boss_health_bar and _boss_health_bar.has_method("set_health"):
		_boss_health_bar.set_health(current, max_health)


func _on_boss_entered() -> void:
	# Boss entrance animation complete - boss is now ready to fight
	pass


func _on_boss_defeated() -> void:
	_boss_fight_active = false

	# Hide health bar
	if _boss_health_bar:
		if _boss_health_bar.has_method("hide_bar"):
			_boss_health_bar.hide_bar()
		else:
			_boss_health_bar.visible = false

	# Wait for boss explosion animation to complete before showing level complete
	await get_tree().create_timer(2.5).timeout
	_show_level_complete_screen()


func _show_level_complete_screen() -> void:
	_play_sfx("level_complete")
	if _level_complete_screen:
		# Set the current level number before showing
		if _level_complete_screen.has_method("set_current_level"):
			_level_complete_screen.set_current_level(_level_number)
		elif "current_level" in _level_complete_screen:
			_level_complete_screen.current_level = _level_number

		if _level_complete_screen.has_method("show_level_complete"):
			_level_complete_screen.show_level_complete()


func _on_section_changed(section_index: int) -> void:
	if section_index < 0 or section_index >= _sections.size():
		return

	var section = _sections[section_index]
	var density = section.get("obstacle_density", "medium")
	var enemy_waves = section.get("enemy_waves", [])

	# Save checkpoint (only for sections after the first)
	if section_index > 0:
		_save_checkpoint(section_index)

	# Update obstacle spawner density
	if _obstacle_spawner and _obstacle_spawner.has_method("set_density"):
		_obstacle_spawner.set_density(density)

	# Update enemy spawner with current section (for special enemy spawning)
	if _enemy_spawner and _enemy_spawner.has_method("set_current_section"):
		_enemy_spawner.set_current_section(section_index)

	# Spawn enemy wave for this section
	if _enemy_spawner and _enemy_spawner.has_method("spawn_wave") and not enemy_waves.is_empty():
		_enemy_spawner.spawn_wave(enemy_waves)

	# Emit signal for other systems
	section_changed.emit(section_index)


func _save_checkpoint(section_index: int) -> void:
	_checkpoint_section = section_index
	if _scroll_controller:
		_checkpoint_scroll_offset = _scroll_controller.scroll_offset.x


## Respawn player at last checkpoint
func respawn_player() -> void:
	if _checkpoint_section < 0:
		return

	# Clear all enemies and obstacles
	if _enemy_spawner and _enemy_spawner.has_method("clear_all"):
		_enemy_spawner.clear_all()
	if _obstacle_spawner and _obstacle_spawner.has_method("clear_all"):
		_obstacle_spawner.clear_all()

	# Reset player position and lives
	if _player:
		_player.position = Vector2(400, 768)  # Default spawn position
		if _player.has_method("reset_lives"):
			_player.reset_lives()
		else:
			# Fallback: set lives directly
			_player._lives = _player.starting_lives
			_player._is_invincible = false
			_player._end_invincibility()

	# Reset spawners
	if _enemy_spawner and _enemy_spawner.has_method("reset"):
		_enemy_spawner.reset()
	if _obstacle_spawner and _obstacle_spawner.has_method("reset"):
		_obstacle_spawner.reset()

	# Spawn the wave for the checkpoint section
	if _checkpoint_section >= 0 and _checkpoint_section < _sections.size():
		var section = _sections[_checkpoint_section]
		var enemy_waves = section.get("enemy_waves", [])
		if _enemy_spawner and _enemy_spawner.has_method("spawn_wave") and not enemy_waves.is_empty():
			_enemy_spawner.spawn_wave(enemy_waves)

	# Emit respawn signal
	player_respawned.emit()


## Get current progress as a percentage (0.0 to 1.0)
func get_progress() -> float:
	return _current_progress


## Get total distance of the level
func get_total_distance() -> float:
	return _total_distance


## Get current section index
func get_current_section() -> int:
	return _current_section


## Get current level number
func get_level_number() -> int:
	return _level_number


## Get section data by index
func get_section(index: int) -> Dictionary:
	if index >= 0 and index < _sections.size():
		return _sections[index]
	return {}


## Check if a checkpoint has been saved
func has_checkpoint() -> bool:
	return _checkpoint_section > 0


## Check if level is complete
func is_level_complete() -> bool:
	return _level_complete


## Check if boss fight is currently active
func is_boss_fight_active() -> bool:
	return _boss_fight_active


## Get reference to current boss
func get_boss() -> Node:
	return _boss


## Get reference to boss health bar
func get_boss_health_bar() -> Node:
	return _boss_health_bar


## Get level metadata
func get_metadata() -> Dictionary:
	return _level_metadata


## Play a sound effect via AudioManager
func _play_sfx(sfx_name: String) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(sfx_name)
