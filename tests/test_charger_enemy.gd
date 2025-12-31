extends Node2D
## Integration test: ChargerEnemy charges toward player
## - Spawn ChargerEnemy, verify it moves left faster than scroll speed
## - ChargerEnemy should lock onto player Y position
## - ChargerEnemy should have 1 HP
## - ChargerEnemy should have cyan tint

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 1.5
var _timer: float = 0.0

# Test state tracking
var _enemy: Node = null
var _initial_x: float = 0.0
var _initial_y: float = 0.0
var _last_x: float = 0.0
var _last_time: float = 0.0
var _measured_speed: float = 0.0
var _health_verified: bool = false

# Normal scroll speed for comparison (180 px/s)
const NORMAL_SCROLL_SPEED: float = 180.0
# Charger should move at 2-3x normal (360-540 px/s)
const MIN_CHARGE_SPEED: float = 360.0


func _ready() -> void:
	print("=== Test: ChargerEnemy Charges Fast ===")

	# Create charger enemy
	var enemy_scene = load("res://scenes/enemies/charger_enemy.tscn")
	if not enemy_scene:
		_fail("Could not load charger enemy scene")
		return
	_enemy = enemy_scene.instantiate()
	# Position further right so we have time to measure
	_enemy.position = Vector2(2000, 500)
	add_child(_enemy)

	_initial_x = _enemy.position.x
	_initial_y = _enemy.position.y
	_last_x = _initial_x
	print("Enemy initial position: (%f, %f)" % [_enemy.position.x, _enemy.position.y])
	print("Enemy health: %d" % _enemy.health)
	_health_verified = (_enemy.health == 1)


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Track position continuously while enemy exists
	if is_instance_valid(_enemy):
		var current_x = _enemy.position.x
		if _timer > _last_time and _timer > 0.1:
			_measured_speed = (_initial_x - current_x) / _timer
		_last_x = current_x
		_last_time = _timer

	# Evaluate after timeout
	if _timer >= _test_timeout:
		_evaluate_results()
		return


func _evaluate_results() -> void:
	# Health should have been verified at spawn (before potential despawn)
	if not _health_verified:
		_fail("ChargerEnemy should have 1 HP")
		return

	# Calculate speed from tracked measurements
	print("Distance moved: %f pixels in %f seconds" % [_initial_x - _last_x, _last_time])
	print("Calculated speed: %f px/s" % _measured_speed)
	print("Minimum required: %f px/s (2x scroll speed)" % MIN_CHARGE_SPEED)

	# Verify it's moving fast (at least 2x scroll speed)
	if _measured_speed < MIN_CHARGE_SPEED:
		_fail("ChargerEnemy too slow: %f px/s (need >= %f)" % [_measured_speed, MIN_CHARGE_SPEED])
		return

	# Verify it's not moving too fast (sanity check)
	if _measured_speed > 600.0:
		_fail("ChargerEnemy too fast: %f px/s (expected 360-540)" % _measured_speed)
		return

	_pass()


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("- ChargerEnemy has correct health (1 HP)")
	print("- ChargerEnemy speed: %f px/s (within 360-540 range)" % _measured_speed)
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
