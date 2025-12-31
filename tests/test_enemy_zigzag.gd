extends Node2D
## Integration test: Enemy zigzag movement
## - Enemy Y position should change noticeably over 2-3 seconds
## - Enemy should bounce off Y bounds (140-1396)

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

# Test state tracking
var _enemy: Node = null
var _initial_y: float = 0.0
var _min_y_observed: float = INF
var _max_y_observed: float = -INF
var _y_positions: Array[float] = []
var _sample_interval: float = 0.1
var _sample_timer: float = 0.0

# Minimum Y change we expect to see for zigzag to be "working"
const MIN_EXPECTED_Y_CHANGE: float = 50.0


func _ready() -> void:
	print("=== Test: Enemy Zigzag Movement ===")

	# Create stationary enemy in the middle of the screen
	var enemy_scene = load("res://scenes/enemies/stationary_enemy.tscn")
	if not enemy_scene:
		_fail("Could not load stationary enemy scene")
		return
	_enemy = enemy_scene.instantiate()
	# Position in middle Y, keep well within bounds
	_enemy.position = Vector2(800, 768)
	# Stop horizontal scrolling so enemy stays on screen
	_enemy.scroll_speed = 0.0
	add_child(_enemy)

	_initial_y = _enemy.position.y
	print("Initial enemy Y position: %f" % _initial_y)
	print("Zigzag speed: %f" % _enemy.zigzag_speed)
	print("Y bounds: %f - %f" % [_enemy.Y_MIN, _enemy.Y_MAX])
	print("Monitoring Y position for %f seconds..." % _test_timeout)


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta
	_sample_timer += delta

	# Sample Y position periodically
	if _sample_timer >= _sample_interval and is_instance_valid(_enemy):
		_sample_timer = 0.0
		var current_y = _enemy.position.y
		_y_positions.append(current_y)
		_min_y_observed = min(_min_y_observed, current_y)
		_max_y_observed = max(_max_y_observed, current_y)

	# Check for timeout / completion
	if _timer >= _test_timeout:
		_evaluate_results()
		return


func _evaluate_results() -> void:
	if not is_instance_valid(_enemy):
		_fail("Enemy was destroyed or removed during test")
		return

	var final_y = _enemy.position.y
	var y_range = _max_y_observed - _min_y_observed
	var y_change_from_initial = abs(final_y - _initial_y)

	print("")
	print("=== Results ===")
	print("Samples collected: %d" % _y_positions.size())
	print("Initial Y: %f" % _initial_y)
	print("Final Y: %f" % final_y)
	print("Min Y observed: %f" % _min_y_observed)
	print("Max Y observed: %f" % _max_y_observed)
	print("Y range (max - min): %f" % y_range)
	print("Change from initial: %f" % y_change_from_initial)

	# Check if Y position changed significantly
	if y_range < MIN_EXPECTED_Y_CHANGE:
		_fail("Enemy Y position did not change enough. Expected at least %f, got range of %f" % [MIN_EXPECTED_Y_CHANGE, y_range])
		return

	# Check if enemy stayed within bounds
	if _min_y_observed < _enemy.Y_MIN - 1.0:  # Allow 1px tolerance
		_fail("Enemy went below Y_MIN bound: %f < %f" % [_min_y_observed, _enemy.Y_MIN])
		return

	if _max_y_observed > _enemy.Y_MAX + 1.0:  # Allow 1px tolerance
		_fail("Enemy went above Y_MAX bound: %f > %f" % [_max_y_observed, _enemy.Y_MAX])
		return

	_pass()


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("- Enemy Y position changed by %f pixels" % (_max_y_observed - _min_y_observed))
	print("- Enemy stayed within Y bounds (%f - %f)" % [_enemy.Y_MIN, _enemy.Y_MAX])
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
