extends Node2D
## Spawns and manages enemy entities.
## Handles continuous spawning from the right edge and tracks active enemies.
## Supports wave-based spawning controlled by LevelManager.
## Supports filler spawning between waves (every 4-6 seconds).

## Stationary enemy scene to spawn
@export var stationary_enemy_scene: PackedScene

## Patrol enemy scene to spawn
@export var patrol_enemy_scene: PackedScene

## Shooting enemy scene to spawn
@export var shooting_enemy_scene: PackedScene

## Charger enemy scene to spawn
@export var charger_enemy_scene: PackedScene

## Garlic enemy scene to spawn (Level 4 special enemy)
@export var garlic_enemy_scene: PackedScene

## Ghost Eye enemy scene to spawn (Level 5 special enemy)
@export var ghost_eye_enemy_scene: PackedScene

## Jelly Snail enemy scene to spawn (Level 6 special enemy)
@export var jelly_snail_enemy_scene: PackedScene

## Star pickup scene to spawn when kill threshold is reached
@export var star_pickup_scene: PackedScene

## Sidekick pickup scene to spawn when kill threshold is reached
@export var sidekick_pickup_scene: PackedScene

## Minimum spawn interval in seconds
@export var spawn_rate_min: float = 2.0

## Maximum spawn interval in seconds
@export var spawn_rate_max: float = 4.0

## Probability of spawning a patrol enemy (0.0 - 1.0)
@export var patrol_spawn_chance: float = 0.4

## Number of initial enemies to spawn at game start
@export var initial_count: int = 3

## Filler spawn rate minimum (seconds)
@export var filler_spawn_rate_min: float = 4.0

## Filler spawn rate maximum (seconds)
@export var filler_spawn_rate_max: float = 6.0

## Playable Y range (between asteroid belt boundaries, accounting for enemy size)
const PLAYABLE_Y_MIN: float = 140.0  # 80 + 60 margin
const PLAYABLE_Y_MAX: float = 1396.0  # 1456 - 60 margin

## Viewport dimensions
var _viewport_width: float = 2048.0

## Active enemies array
var _active_enemies: Array = []

## Random number generator
var _rng: RandomNumberGenerator

## Spawn timer
var _spawn_timer: float = 0.0
var _next_spawn_time: float = 0.0

## Game over state
var _game_over: bool = false

## Continuous spawning enabled (can be disabled for wave-based levels)
var _continuous_spawning: bool = true

## Filler spawning enabled (spawns random enemies between waves)
var _filler_spawning: bool = false

## Filler spawn timer (separate from continuous spawn timer)
var _filler_timer: float = 0.0
var _next_filler_time: float = 0.0

## Kill tracking for pickup spawning
var _kill_count: int = 0
var _next_pickup_threshold: int = 5

## Enemy configuration from level (zigzag params, etc.)
var _enemy_config: Dictionary = {}

## Special enemies configuration (level-specific special enemy spawning rules)
var _special_enemies_config: Array = []

## Current section index (set by LevelManager for special enemy spawning)
var _current_section: int = 0


func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()

	_viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")

	# Set initial spawn time
	_next_spawn_time = _rng.randf_range(spawn_rate_min, spawn_rate_max)
	_next_filler_time = _rng.randf_range(filler_spawn_rate_min, filler_spawn_rate_max)

	# Connect to player died signal to stop spawning
	_connect_to_player()

	# Note: Initial enemies are now spawned by LevelManager via spawn_wave
	# for wave-based levels, or here if continuous spawning is enabled


func _process(delta: float) -> void:
	if _game_over:
		return

	# Handle continuous spawning (old system)
	if _continuous_spawning:
		_spawn_timer += delta

		if _spawn_timer >= _next_spawn_time:
			_spawn_random_enemy()
			_spawn_timer = 0.0
			_next_spawn_time = _rng.randf_range(spawn_rate_min, spawn_rate_max)

	# Handle filler spawning (new system - independent of continuous spawning)
	if _filler_spawning:
		_filler_timer += delta

		if _filler_timer >= _next_filler_time:
			_spawn_filler_enemy()
			_filler_timer = 0.0
			_next_filler_time = _rng.randf_range(filler_spawn_rate_min, filler_spawn_rate_max)


func _connect_to_player() -> void:
	# Find the player in the scene tree
	var player = get_tree().root.get_node_or_null("Main/Player")
	if player and player.has_signal("died"):
		player.died.connect(_on_player_died)


func _on_player_died() -> void:
	_game_over = true


## Enable or disable continuous random spawning
func set_continuous_spawning(enabled: bool) -> void:
	_continuous_spawning = enabled
	if enabled:
		# Reset timer when re-enabling
		_spawn_timer = 0.0
		_next_spawn_time = _rng.randf_range(spawn_rate_min, spawn_rate_max)


## Enable or disable filler enemy spawning (between waves)
func set_filler_spawning(enabled: bool) -> void:
	_filler_spawning = enabled
	if enabled:
		# Reset timer when re-enabling
		_filler_timer = 0.0
		_next_filler_time = _rng.randf_range(filler_spawn_rate_min, filler_spawn_rate_max)


## Check if filler spawning is enabled
func is_filler_spawning() -> bool:
	return _filler_spawning


## Set enemy configuration from level data
func set_enemy_config(config: Dictionary) -> void:
	_enemy_config = config


## Set special enemies configuration from level metadata
func set_special_enemies_config(config: Array) -> void:
	_special_enemies_config = config


## Update current section index (called by LevelManager on section change)
func set_current_section(section_index: int) -> void:
	_current_section = section_index


## Spawn a wave of enemies based on configuration
## wave_config is an array of dictionaries with enemy_type and count
func spawn_wave(wave_configs: Array) -> void:
	for wave_config in wave_configs:
		var enemy_type = wave_config.get("enemy_type", "stationary")
		var count = wave_config.get("count", 1)

		for i in range(count):
			match enemy_type:
				"patrol":
					_spawn_patrol_enemy()
				"shooting":
					_spawn_shooting_enemy()
				"charger":
					_spawn_charger_enemy()
				"garlic":
					_spawn_garlic_enemy()
				"ghost_eye":
					_spawn_ghost_eye_enemy()
				"jelly_snail":
					_spawn_jelly_snail_enemy()
				_:
					_spawn_stationary_enemy()


func _spawn_random_enemy() -> void:
	# Randomly decide which enemy type to spawn
	if _rng.randf() < patrol_spawn_chance:
		_spawn_patrol_enemy()
	else:
		_spawn_stationary_enemy()


## Spawn a filler enemy with weighted random selection
## First checks for special enemy spawning based on level config
## Then falls back to: 60% stationary, 30% shooting, 10% charger
func _spawn_filler_enemy() -> void:
	# Check for special enemy spawn first
	if _try_spawn_special_enemy():
		return

	# Fall back to normal filler spawning
	var roll = _rng.randf()
	if roll < 0.6:
		# 60% chance: stationary
		_spawn_stationary_enemy()
	elif roll < 0.9:
		# 30% chance: shooting (0.6 to 0.9)
		_spawn_shooting_enemy()
	else:
		# 10% chance: charger (0.9 to 1.0)
		_spawn_charger_enemy()


## Try to spawn a special enemy based on current section and config
## Returns true if a special enemy was spawned, false otherwise
func _try_spawn_special_enemy() -> bool:
	if _special_enemies_config.is_empty():
		return false

	# Check each special enemy config
	for special_config in _special_enemies_config:
		var enemy_type = special_config.get("enemy_type", "")
		var spawn_probability = special_config.get("spawn_probability", 0.0)
		var allowed_sections = special_config.get("allowed_sections", [])

		# Skip if current section is not in allowed sections
		if not allowed_sections.has(_current_section):
			continue

		# Roll for spawn probability
		if _rng.randf() < spawn_probability:
			# Spawn the special enemy
			match enemy_type:
				"garlic":
					_spawn_garlic_enemy()
					return true
				"ghost_eye":
					_spawn_ghost_eye_enemy()
					return true
				"jelly_snail":
					_spawn_jelly_snail_enemy()
					return true
				_:
					push_warning("Unknown special enemy type: %s" % enemy_type)

	return false


func _spawn_stationary_enemy() -> void:
	if not stationary_enemy_scene:
		push_warning("No stationary enemy scene assigned to EnemySpawner")
		return

	var enemy = stationary_enemy_scene.instantiate()
	_setup_enemy(enemy)


func _spawn_patrol_enemy() -> void:
	if not patrol_enemy_scene:
		push_warning("No patrol enemy scene assigned to EnemySpawner")
		return

	var enemy = patrol_enemy_scene.instantiate()
	_setup_enemy(enemy)


func _spawn_shooting_enemy() -> void:
	if not shooting_enemy_scene:
		push_warning("No shooting enemy scene assigned to EnemySpawner")
		return

	var enemy = shooting_enemy_scene.instantiate()
	_setup_enemy(enemy)


func _spawn_charger_enemy() -> void:
	if not charger_enemy_scene:
		push_warning("No charger enemy scene assigned to EnemySpawner")
		return

	var enemy = charger_enemy_scene.instantiate()
	_setup_enemy(enemy)


func _spawn_garlic_enemy() -> void:
	if not garlic_enemy_scene:
		push_warning("No garlic enemy scene assigned to EnemySpawner")
		return

	var enemy = garlic_enemy_scene.instantiate()
	_setup_enemy(enemy)


func _spawn_ghost_eye_enemy() -> void:
	if not ghost_eye_enemy_scene:
		push_warning("No ghost eye enemy scene assigned to EnemySpawner")
		return

	var enemy = ghost_eye_enemy_scene.instantiate()
	_setup_enemy(enemy)


func _spawn_jelly_snail_enemy() -> void:
	if not jelly_snail_enemy_scene:
		push_warning("No jelly snail enemy scene assigned to EnemySpawner")
		return

	var enemy = jelly_snail_enemy_scene.instantiate()
	_setup_enemy(enemy)


func _setup_enemy(enemy: Node2D) -> void:
	# Position off right edge with slight vertical spread
	var x_pos = _viewport_width + 100.0 + _rng.randf_range(0, 200)
	var y_pos = _rng.randf_range(PLAYABLE_Y_MIN, PLAYABLE_Y_MAX)
	enemy.position = Vector2(x_pos, y_pos)

	# Apply level-specific enemy config (zigzag parameters)
	_apply_enemy_config(enemy)

	# Add to scene and track
	add_child(enemy)
	_active_enemies.append(enemy)

	# Connect to tree_exiting to remove from tracking when despawned
	enemy.tree_exiting.connect(_on_enemy_despawned.bind(enemy))

	# Connect to died signal for kill tracking and score
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_killed.bind(enemy))


func _apply_enemy_config(enemy: Node2D) -> void:
	# Apply zigzag speed range if specified
	if _enemy_config.has("zigzag_speed_min") and _enemy_config.has("zigzag_speed_max"):
		var speed = _rng.randf_range(_enemy_config["zigzag_speed_min"], _enemy_config["zigzag_speed_max"])
		if "zigzag_speed" in enemy:
			enemy.zigzag_speed = speed

	# Apply zigzag angle range if specified
	if _enemy_config.has("zigzag_angle_min"):
		if "zigzag_angle_min" in enemy:
			enemy.zigzag_angle_min = _enemy_config["zigzag_angle_min"]
	if _enemy_config.has("zigzag_angle_max"):
		if "zigzag_angle_max" in enemy:
			enemy.zigzag_angle_max = _enemy_config["zigzag_angle_max"]


func _spawn_initial_enemies() -> void:
	for i in range(initial_count):
		# Spawn within visible area for initial enemies
		var enemy: Node2D
		if _rng.randf() < patrol_spawn_chance:
			if not patrol_enemy_scene:
				continue
			enemy = patrol_enemy_scene.instantiate()
		else:
			if not stationary_enemy_scene:
				continue
			enemy = stationary_enemy_scene.instantiate()

		# Position within visible area
		var x_pos = _rng.randf_range(_viewport_width * 0.5, _viewport_width * 0.9)
		var y_pos = _rng.randf_range(PLAYABLE_Y_MIN, PLAYABLE_Y_MAX)
		enemy.position = Vector2(x_pos, y_pos)

		# Add to scene and track
		add_child(enemy)
		_active_enemies.append(enemy)

		# Connect to tree_exiting to remove from tracking when despawned
		enemy.tree_exiting.connect(_on_enemy_despawned.bind(enemy))


func _on_enemy_despawned(enemy: Node) -> void:
	var idx = _active_enemies.find(enemy)
	if idx >= 0:
		_active_enemies.remove_at(idx)


## Get count of active enemies (for debugging/testing)
func get_active_count() -> int:
	return _active_enemies.size()


## Clear all active enemies (used for checkpoint respawn)
func clear_all() -> void:
	for enemy in _active_enemies.duplicate():
		if is_instance_valid(enemy):
			enemy.queue_free()
	_active_enemies.clear()


## Reset spawner state (used for checkpoint respawn)
func reset() -> void:
	_game_over = false
	_spawn_timer = 0.0
	_next_spawn_time = _rng.randf_range(spawn_rate_min, spawn_rate_max)
	_filler_timer = 0.0
	_next_filler_time = _rng.randf_range(filler_spawn_rate_min, filler_spawn_rate_max)
	_kill_count = 0
	_next_pickup_threshold = 5


## Called when an enemy is killed
func _on_enemy_killed(enemy: Node) -> void:
	_kill_count += 1

	# Award score points via ScoreManager
	if has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		score_manager.award_enemy_kill(enemy)

	if _kill_count >= _next_pickup_threshold:
		_spawn_random_pickup()
		_kill_count = 0
		_next_pickup_threshold *= 2


## Choose which pickup type to spawn based on player state
## Returns true for sidekick, false for star (health boost)
func _choose_pickup_type() -> bool:
	var player = get_tree().root.get_node_or_null("Main/Player")
	var has_sidekick = get_tree().get_nodes_in_group("sidekick").size() > 0
	var health_full = false

	if player and player.has_method("get_health"):
		health_full = player.get_health() >= player.max_health

	# Smart selection: give what the player can actually use
	if has_sidekick and not health_full:
		# Has sidekick but needs health -> give star
		return false
	elif health_full and not has_sidekick:
		# Full health but no sidekick -> give sidekick
		return true
	else:
		# Either can use both or neither -> random 50/50
		return _rng.randf() < 0.5


## Spawn a pickup (star or sidekick) from a random edge
## Smart selection: avoids giving unusable pickups when possible
func _spawn_random_pickup() -> void:
	var spawn_sidekick = _choose_pickup_type()

	var pickup: Node2D
	if spawn_sidekick and sidekick_pickup_scene:
		pickup = sidekick_pickup_scene.instantiate()
	elif star_pickup_scene:
		pickup = star_pickup_scene.instantiate()
	else:
		push_warning("No pickup scene assigned to EnemySpawner")
		return

	# Pick random edge
	var edge = _rng.randi() % 4
	var spawn_pos: Vector2
	var spawn_edge: int

	match edge:
		0:  # Left
			spawn_pos = Vector2(-100, _rng.randf_range(PLAYABLE_Y_MIN, PLAYABLE_Y_MAX))
			spawn_edge = 0
		1:  # Right
			spawn_pos = Vector2(_viewport_width + 100, _rng.randf_range(PLAYABLE_Y_MIN, PLAYABLE_Y_MAX))
			spawn_edge = 1
		2:  # Top
			spawn_pos = Vector2(_rng.randf_range(100, _viewport_width - 100), -100)
			spawn_edge = 2
		3:  # Bottom
			spawn_pos = Vector2(_rng.randf_range(100, _viewport_width - 100), 1536 + 100)
			spawn_edge = 3

	pickup.position = spawn_pos
	pickup.setup(spawn_edge)

	# Add to Main scene, not EnemySpawner
	get_parent().add_child(pickup)
