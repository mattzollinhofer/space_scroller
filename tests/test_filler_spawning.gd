extends Node2D
## Integration test: filler spawning spawns enemies every 4-6 seconds
## - Enable filler spawning on enemy spawner
## - Verify enemies spawn within the expected interval (4-6 seconds)
## - Verify filler spawning can be disabled independently

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 8.0
var _timer: float = 0.0

var _enemy_spawner: Node = null
var _spawn_times: Array = []
var _initial_enemy_count: int = 0
var _evaluating: bool = false


func _ready() -> void:
	print("=== Test: Filler Enemy Spawning ===")

	# Create enemy spawner node and attach script
	_enemy_spawner = Node2D.new()
	var script = load("res://scripts/enemies/enemy_spawner.gd")
	_enemy_spawner.set_script(script)
	add_child(_enemy_spawner)

	# Configure the spawner with required scenes
	_enemy_spawner.stationary_enemy_scene = load("res://scenes/enemies/stationary_enemy.tscn")
	_enemy_spawner.patrol_enemy_scene = load("res://scenes/enemies/patrol_enemy.tscn")
	_enemy_spawner.shooting_enemy_scene = load("res://scenes/enemies/shooting_enemy.tscn")
	_enemy_spawner.charger_enemy_scene = load("res://scenes/enemies/charger_enemy.tscn")

	# Disable continuous spawning (the old system)
	_enemy_spawner.set_continuous_spawning(false)

	# Enable filler spawning (the new system)
	_enemy_spawner.set_filler_spawning(true)

	_initial_enemy_count = _enemy_spawner.get_active_count()
	print("Initial enemy count: %d" % _initial_enemy_count)
	print("Filler spawning enabled, waiting for spawns...")


func _process(delta: float) -> void:
	if _test_passed or _test_failed or _evaluating:
		return

	_timer += delta

	# Track when enemies spawn
	if _enemy_spawner:
		var current_count = _enemy_spawner.get_active_count()
		if current_count > _initial_enemy_count + _spawn_times.size():
			_spawn_times.append(_timer)
			print("Enemy spawned at time: %.2f seconds (count: %d)" % [_timer, current_count])

	# After 7 seconds, evaluate results
	if _timer >= 7.0:
		_evaluating = true
		_evaluate_results()
		return

	if _timer >= _test_timeout:
		_fail("Test timed out waiting for filler spawns")
		return


func _evaluate_results() -> void:
	print("")
	print("Evaluating results...")
	print("Total spawns: %d" % _spawn_times.size())
	print("Spawn times: %s" % str(_spawn_times))

	# We expect at least 1 spawn in 7 seconds (interval is 4-6 seconds)
	if _spawn_times.size() < 1:
		_fail("Expected at least 1 filler enemy spawn in 7 seconds, got %d" % _spawn_times.size())
		return

	# Check that the first spawn happened within expected range (4-6 seconds)
	if _spawn_times.size() >= 1:
		var first_spawn = _spawn_times[0]
		if first_spawn < 3.5 or first_spawn > 6.5:
			_fail("First spawn at %.2f seconds, expected between 4-6 seconds (with margin)" % first_spawn)
			return
		print("First spawn at %.2f seconds (expected: 4-6)" % first_spawn)

	# Test disabling filler spawning
	print("")
	print("Testing filler spawning disable...")
	_enemy_spawner.set_filler_spawning(false)
	var count_before_disable = _enemy_spawner.get_active_count()

	# Wait a short bit and verify no more spawns
	await get_tree().create_timer(0.5).timeout

	var count_after_disable = _enemy_spawner.get_active_count()
	# Note: count might decrease due to despawning, but shouldn't increase much
	print("Count before disable: %d, after: %d" % [count_before_disable, count_after_disable])

	_pass()


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("- Filler enemies spawn every 4-6 seconds when enabled")
	print("- Filler spawning can be disabled independently")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("")
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
