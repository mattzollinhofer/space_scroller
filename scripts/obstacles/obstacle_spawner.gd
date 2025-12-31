extends Node2D
## Spawns and manages asteroid obstacles.
## Handles continuous spawning from the right edge and tracks active asteroids.

## Asteroid scene to spawn
@export var asteroid_scene: PackedScene

## Minimum spawn interval in seconds
@export var spawn_rate_min: float = 4.0

## Maximum spawn interval in seconds
@export var spawn_rate_max: float = 7.0

## Number of initial asteroids to spawn at game start
@export var initial_count: int = 2

## Playable Y range (between asteroid belt boundaries)
const PLAYABLE_Y_MIN: float = 80.0 + 60.0  # Top boundary + margin for asteroid size
const PLAYABLE_Y_MAX: float = 1456.0 - 60.0  # Bottom boundary - margin for asteroid size

## Density level spawn rates
const DENSITY_RATES: Dictionary = {
	"low": { "min": 6.0, "max": 9.0 },
	"medium": { "min": 4.0, "max": 7.0 },
	"high": { "min": 2.0, "max": 4.0 }
}

## Viewport dimensions
var _viewport_width: float = 2048.0

## Active asteroids array
var _active_asteroids: Array = []

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

	# Spawn initial asteroids
	_spawn_initial_asteroids()


func _process(delta: float) -> void:
	if _game_over:
		return

	_spawn_timer += delta

	if _spawn_timer >= _next_spawn_time:
		_spawn_asteroid()
		_spawn_timer = 0.0
		_next_spawn_time = _rng.randf_range(spawn_rate_min, spawn_rate_max)


func _connect_to_player() -> void:
	# Find the player in the scene tree
	var player = get_tree().root.get_node_or_null("Main/Player")
	if player and player.has_signal("died"):
		player.died.connect(_on_player_died)


func _on_player_died() -> void:
	_game_over = true


func _spawn_asteroid() -> void:
	if not asteroid_scene:
		push_warning("No asteroid scene assigned to ObstacleSpawner")
		return

	var asteroid = asteroid_scene.instantiate()

	# Position off right edge
	var x_pos = _viewport_width + 100.0
	var y_pos = _rng.randf_range(PLAYABLE_Y_MIN, PLAYABLE_Y_MAX)
	asteroid.position = Vector2(x_pos, y_pos)

	# Add to scene and track
	add_child(asteroid)
	_active_asteroids.append(asteroid)

	# Connect to tree_exiting to remove from tracking when despawned
	asteroid.tree_exiting.connect(_on_asteroid_despawned.bind(asteroid))


func _spawn_initial_asteroids() -> void:
	if not asteroid_scene:
		push_warning("No asteroid scene assigned to ObstacleSpawner")
		return

	for i in range(initial_count):
		var asteroid = asteroid_scene.instantiate()

		# Position within visible area
		var x_pos = _rng.randf_range(_viewport_width * 0.4, _viewport_width * 0.9)
		var y_pos = _rng.randf_range(PLAYABLE_Y_MIN, PLAYABLE_Y_MAX)
		asteroid.position = Vector2(x_pos, y_pos)

		# Add to scene and track
		add_child(asteroid)
		_active_asteroids.append(asteroid)

		# Connect to tree_exiting to remove from tracking when despawned
		asteroid.tree_exiting.connect(_on_asteroid_despawned.bind(asteroid))


func _on_asteroid_despawned(asteroid: Node) -> void:
	var idx = _active_asteroids.find(asteroid)
	if idx >= 0:
		_active_asteroids.remove_at(idx)


## Set the obstacle spawn density level
## @param level: "low", "medium", or "high"
func set_density(level: String) -> void:
	if DENSITY_RATES.has(level):
		var rates = DENSITY_RATES[level]
		spawn_rate_min = rates["min"]
		spawn_rate_max = rates["max"]
		# Reset next spawn time to use new rates
		_next_spawn_time = _rng.randf_range(spawn_rate_min, spawn_rate_max)
	else:
		push_warning("Unknown density level: %s" % level)


## Get count of active asteroids (for debugging/testing)
func get_active_count() -> int:
	return _active_asteroids.size()


## Clear all active asteroids (used for checkpoint respawn)
func clear_all() -> void:
	for asteroid in _active_asteroids.duplicate():
		if is_instance_valid(asteroid):
			asteroid.queue_free()
	_active_asteroids.clear()


## Reset spawner state (used for checkpoint respawn)
func reset() -> void:
	_game_over = false
	_spawn_timer = 0.0
	_next_spawn_time = _rng.randf_range(spawn_rate_min, spawn_rate_max)
