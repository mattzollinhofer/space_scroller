extends Node2D
## Spawns and manages enemy entities.
## Handles continuous spawning from the right edge and tracks active enemies.
## Supports wave-based spawning controlled by LevelManager.

## Stationary enemy scene to spawn
@export var stationary_enemy_scene: PackedScene

## Patrol enemy scene to spawn
@export var patrol_enemy_scene: PackedScene

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

## Kill tracking for pickup spawning
var _kill_count: int = 0
var _next_pickup_threshold: int = 5


func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()

	_viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")

	# Set initial spawn time
	_next_spawn_time = _rng.randf_range(spawn_rate_min, spawn_rate_max)

	# Connect to player died signal to stop spawning
	_connect_to_player()

	# Note: Initial enemies are now spawned by LevelManager via spawn_wave
	# for wave-based levels, or here if continuous spawning is enabled


func _process(delta: float) -> void:
	if _game_over or not _continuous_spawning:
		return

	_spawn_timer += delta

	if _spawn_timer >= _next_spawn_time:
		_spawn_random_enemy()
		_spawn_timer = 0.0
		_next_spawn_time = _rng.randf_range(spawn_rate_min, spawn_rate_max)


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


## Spawn a wave of enemies based on configuration
## wave_config is an array of dictionaries with enemy_type and count
func spawn_wave(wave_configs: Array) -> void:
	for wave_config in wave_configs:
		var enemy_type = wave_config.get("enemy_type", "stationary")
		var count = wave_config.get("count", 1)

		for i in range(count):
			if enemy_type == "patrol":
				_spawn_patrol_enemy()
			else:
				_spawn_stationary_enemy()


func _spawn_random_enemy() -> void:
	# Randomly decide which enemy type to spawn
	if _rng.randf() < patrol_spawn_chance:
		_spawn_patrol_enemy()
	else:
		_spawn_stationary_enemy()


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


func _setup_enemy(enemy: Node2D) -> void:
	# Position off right edge with slight vertical spread
	var x_pos = _viewport_width + 100.0 + _rng.randf_range(0, 200)
	var y_pos = _rng.randf_range(PLAYABLE_Y_MIN, PLAYABLE_Y_MAX)
	enemy.position = Vector2(x_pos, y_pos)

	# Add to scene and track
	add_child(enemy)
	_active_enemies.append(enemy)

	# Connect to tree_exiting to remove from tracking when despawned
	enemy.tree_exiting.connect(_on_enemy_despawned.bind(enemy))

	# Connect to died signal for kill tracking and score
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_killed.bind(enemy))


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


## Spawn a random pickup (star or sidekick) from a random edge
func _spawn_random_pickup() -> void:
	# Randomly select pickup type (50/50 chance)
	var spawn_sidekick = _rng.randf() < 0.5

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
