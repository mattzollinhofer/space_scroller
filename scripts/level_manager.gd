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

## Signals
signal section_changed(section_index: int)
signal level_completed()
signal player_respawned()

## Level data loaded from JSON
var _level_data: Dictionary = {}

## Total distance of the level in pixels
var _total_distance: float = 9000.0

## Sections array from level data
var _sections: Array = []

## Current section index
var _current_section: int = -1

## Checkpoint data
var _checkpoint_section: int = -1
var _checkpoint_scroll_offset: float = 0.0

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

## Current progress (0.0 to 1.0)
var _current_progress: float = 0.0


func _ready() -> void:
	_load_level_data()
	_setup_references()
	_setup_wave_based_spawning()
	_connect_player_signals()
	# Set initial section density and spawn first wave
	_check_section_change()


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


func _setup_references() -> void:
	# Get scroll controller reference
	if not scroll_controller_path.is_empty():
		_scroll_controller = get_node_or_null(scroll_controller_path)
	if not _scroll_controller:
		_scroll_controller = get_tree().root.get_node_or_null("Main/ParallaxBackground")

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


func _setup_wave_based_spawning() -> void:
	# Disable continuous enemy spawning - we'll spawn waves at section boundaries
	if _enemy_spawner and _enemy_spawner.has_method("set_continuous_spawning"):
		_enemy_spawner.set_continuous_spawning(false)


func _connect_player_signals() -> void:
	if _player and _player.has_signal("died"):
		# Disconnect from game over screen if connected
		if _game_over_screen and _player.died.is_connected(_game_over_screen.show_game_over):
			_player.died.disconnect(_game_over_screen.show_game_over)

		# Connect to our handler instead
		_player.died.connect(_on_player_died)


func _on_player_died() -> void:
	# Check if we have a checkpoint (section > 0)
	if _checkpoint_section > 0:
		# Respawn at checkpoint
		respawn_player()
	else:
		# No checkpoint, show game over
		if _game_over_screen and _game_over_screen.has_method("show_game_over"):
			_game_over_screen.show_game_over()


func _process(_delta: float) -> void:
	_update_progress()
	_check_section_change()


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


## Get section data by index
func get_section(index: int) -> Dictionary:
	if index >= 0 and index < _sections.size():
		return _sections[index]
	return {}


## Check if a checkpoint has been saved
func has_checkpoint() -> bool:
	return _checkpoint_section > 0
