extends Node2D
## Spawns and manages enemy entities.
## Handles continuous spawning from the right edge and tracks active enemies.

## Stationary enemy scene to spawn
@export var stationary_enemy_scene: PackedScene

## Patrol enemy scene to spawn
@export var patrol_enemy_scene: PackedScene

## Minimum spawn interval in seconds
@export var spawn_rate_min: float = 3.0

## Maximum spawn interval in seconds
@export var spawn_rate_max: float = 6.0

## Probability of spawning a patrol enemy (0.0 - 1.0)
@export var patrol_spawn_chance: float = 0.4

## Number of initial enemies to spawn at game start
@export var initial_count: int = 2

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


func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()

	_viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")

	# Set initial spawn time
	_next_spawn_time = _rng.randf_range(spawn_rate_min, spawn_rate_max)

	# Connect to player died signal to stop spawning
	_connect_to_player()

	# Spawn initial enemies
	_spawn_initial_enemies()


func _process(delta: float) -> void:
	if _game_over:
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
	# Position off right edge
	var x_pos = _viewport_width + 100.0
	var y_pos = _rng.randf_range(PLAYABLE_Y_MIN, PLAYABLE_Y_MAX)
	enemy.position = Vector2(x_pos, y_pos)

	# Add to scene and track
	add_child(enemy)
	_active_enemies.append(enemy)

	# Connect to tree_exiting to remove from tracking when despawned
	enemy.tree_exiting.connect(_on_enemy_despawned.bind(enemy))


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
