extends Node2D
## Integration test: Pickup spawn threshold doubles after each spawn
## Verifies that after 5 kills spawn pickup, next threshold is 10, then 20...

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 10.0
var _timer: float = 0.0

var _main: Node = null
var _player: Node = null
var _enemy_spawner: Node = null


func _ready() -> void:
	print("=== Test: Pickup Threshold Doubling ===")

	# Load and setup main scene to get all components
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	_main = main_scene.instantiate()
	add_child(_main)

	# Wait a frame for scene to initialize
	await get_tree().process_frame

	# Find the player
	_player = _main.get_node_or_null("Player")
	if not _player:
		_fail("Player node not found in main scene")
		return

	# Find the enemy spawner
	_enemy_spawner = _main.get_node_or_null("EnemySpawner")
	if not _enemy_spawner:
		_fail("EnemySpawner node not found in main scene")
		return

	# Disable continuous spawning to have a clean test
	_enemy_spawner.set_continuous_spawning(false)
	_enemy_spawner.clear_all()
	_enemy_spawner.reset()

	# Wait another frame for things to settle
	await get_tree().process_frame

	# Run the test
	await _run_threshold_test()


func _run_threshold_test() -> void:
	# Move player to a known position away from enemies
	_player.position = Vector2(200, 768)
	await get_tree().process_frame

	# Verify initial threshold is 5
	var initial_threshold = _enemy_spawner._next_pickup_threshold
	print("Initial threshold: %d (expected: 5)" % initial_threshold)

	if initial_threshold != 5:
		_fail("Expected initial threshold to be 5, got %d" % initial_threshold)
		return

	# Kill 5 enemies (first spawn)
	print("Killing 5 enemies for first pickup spawn...")
	for i in range(5):
		await _spawn_and_kill_enemy()

	await get_tree().create_timer(0.2).timeout

	# Verify threshold doubled to 10
	var threshold_after_first = _enemy_spawner._next_pickup_threshold
	print("Threshold after first spawn: %d (expected: 10)" % threshold_after_first)

	if threshold_after_first != 10:
		_fail("Expected threshold to double to 10, got %d" % threshold_after_first)
		return

	# Verify kill count reset to 0
	var kill_count_after_first = _enemy_spawner._kill_count
	print("Kill count after first spawn: %d (expected: 0)" % kill_count_after_first)

	if kill_count_after_first != 0:
		_fail("Expected kill count to reset to 0, got %d" % kill_count_after_first)
		return

	# Kill 10 more enemies (second spawn)
	print("Killing 10 enemies for second pickup spawn...")
	for i in range(10):
		await _spawn_and_kill_enemy()

	await get_tree().create_timer(0.2).timeout

	# Verify threshold doubled to 20
	var threshold_after_second = _enemy_spawner._next_pickup_threshold
	print("Threshold after second spawn: %d (expected: 20)" % threshold_after_second)

	if threshold_after_second != 20:
		_fail("Expected threshold to double to 20, got %d" % threshold_after_second)
		return

	print("Threshold doubling works correctly: 5 -> 10 -> 20")
	_pass()


func _spawn_and_kill_enemy() -> void:
	# Spawn an enemy
	var enemy_scene = load("res://scenes/enemies/stationary_enemy.tscn")
	if not enemy_scene:
		_fail("Could not load stationary enemy scene")
		return

	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(800, 768)

	# Add to enemy spawner so it gets tracked properly
	_enemy_spawner.add_child(enemy)

	# Connect the died signal to spawner's kill handler
	if enemy.has_signal("died"):
		enemy.died.connect(_enemy_spawner._on_enemy_killed.bind(enemy))

	await get_tree().process_frame

	# Kill the enemy
	if enemy.has_method("take_hit"):
		enemy.take_hit(1)
		await get_tree().process_frame


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Pickup spawn threshold doubles correctly after each spawn.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
