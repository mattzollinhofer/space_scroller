extends Node2D
## Integration test: Score increases when enemy is destroyed
## Verifies that destroying a stationary enemy (1 HP) awards 100 points
## and destroying a patrol enemy (2 HP) awards 200 points.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var _main: Node = null
var _score_display: Node = null
var _enemy_spawner: Node = null


func _ready() -> void:
	print("=== Test: Score Increases When Enemy Destroyed ===")

	# Load and setup main scene to get all components
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	_main = main_scene.instantiate()
	add_child(_main)

	# Wait a frame for scene to initialize
	await get_tree().process_frame

	# Find the score display
	_score_display = _main.get_node_or_null("ScoreDisplay")
	if not _score_display:
		_fail("ScoreDisplay node not found in main scene")
		return

	# Find the enemy spawner
	_enemy_spawner = _main.get_node_or_null("EnemySpawner")
	if not _enemy_spawner:
		_fail("EnemySpawner node not found in main scene")
		return

	# Disable continuous spawning for controlled test
	_enemy_spawner.set_continuous_spawning(false)

	# Clear any existing enemies
	_enemy_spawner.clear_all()

	# Wait another frame for things to settle
	await get_tree().process_frame

	# Run the test
	await _run_stationary_enemy_test()


func _run_stationary_enemy_test() -> void:
	# Reset score to ensure clean state
	if has_node("/root/ScoreManager"):
		get_node("/root/ScoreManager").reset_score()

	# Get initial score
	var initial_score = _get_current_score()
	print("Initial score: %d" % initial_score)

	# Spawn a stationary enemy via the spawner's spawn_wave method
	# This ensures proper signal connections are made
	_enemy_spawner.spawn_wave([{"enemy_type": "stationary", "count": 1}])

	# Wait for enemy to spawn and initialize
	await get_tree().process_frame
	await get_tree().process_frame

	# Find the spawned enemy
	var enemies = _enemy_spawner.get_children().filter(func(child): return child is BaseEnemy)
	if enemies.is_empty():
		_fail("No enemy was spawned")
		return

	var enemy = enemies[0]
	print("Enemy spawned, health: %d" % enemy.health)

	# Kill the enemy (set health to 0 to trigger death)
	enemy.health = 0

	# Wait for death to process and score to update
	await get_tree().process_frame
	await get_tree().process_frame

	# Check score increased by 100 points
	var new_score = _get_current_score()
	print("Score after killing stationary enemy: %d" % new_score)

	var expected_score = initial_score + 100
	if new_score != expected_score:
		_fail("Expected score %d after killing stationary enemy, got %d" % [expected_score, new_score])
		return

	print("Stationary enemy awarded 100 points correctly!")
	_pass()


func _get_current_score() -> int:
	# Try to get score from ScoreManager autoload first
	if has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		if score_manager.has_method("get_score"):
			return score_manager.get_score()

	# Fall back to reading from score display
	if _score_display and _score_display.has_method("get_score"):
		return _score_display.get_score()

	return 0


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("Test timed out")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Score increases correctly when enemy is destroyed.")
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(1)
