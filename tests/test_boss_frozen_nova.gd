extends Node2D
## Integration test: Boss Frozen Nova attack (attack index 6)
## Verifies the delayed expanding burst fires slow projectiles in all directions.
## Level 3 "cold/expansive" theme - delayed telegraph then radial burst.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 15.0
var _timer: float = 0.0

var _boss: Node = null
var _projectiles_spawned: Array = []
var _attack_fired_count: int = 0
var _wind_up_start_time: float = 0.0
var _attack_fired_time: float = 0.0
var _wind_up_duration: float = 0.8  # Frozen Nova has longer wind-up for kid-friendly warning


func _ready() -> void:
	print("=== Test: Boss Frozen Nova Attack (Index 6) ===")

	# Load boss scene directly for isolated testing
	var boss_scene = load("res://scenes/enemies/boss.tscn")
	if not boss_scene:
		_fail("Could not load boss scene")
		return

	_boss = boss_scene.instantiate()
	add_child(_boss)

	# Position boss for testing
	_boss.position = Vector2(800, 500)
	_boss._battle_position = _boss.position
	_boss._entrance_complete = true

	# Configure boss with ONLY attack 6 (Frozen Nova)
	# Use longer wind-up to test the delay/telegraph
	var config = {
		"attacks": [6],
		"attack_cooldown": 0.5,
		"wind_up_duration": _wind_up_duration
	}
	_boss.configure(config)
	print("Boss configured with attack index 6 (Frozen Nova)")

	# Connect to attack signal
	if _boss.has_signal("attack_fired"):
		_boss.attack_fired.connect(_on_attack_fired)

	# Start attack cycle and track wind-up start
	_wind_up_start_time = Time.get_ticks_msec() / 1000.0
	_boss.start_attack_cycle()
	print("Attack cycle started, waiting for Frozen Nova...")

	# Wait for attack to fire (longer wait due to delay)
	await get_tree().create_timer(2.0).timeout
	_verify_frozen_nova()


func _on_attack_fired() -> void:
	_attack_fired_count += 1
	_attack_fired_time = Time.get_ticks_msec() / 1000.0
	print("Attack fired signal received (count: %d)" % _attack_fired_count)


func _verify_frozen_nova() -> void:
	if _test_passed or _test_failed:
		return

	# Find all boss projectiles in scene
	_projectiles_spawned = _find_boss_projectiles()
	print("Projectiles found: %d" % _projectiles_spawned.size())

	if _projectiles_spawned.is_empty():
		_fail("No projectiles spawned - Frozen Nova attack not implemented")
		return

	# Frozen Nova should fire projectiles in all directions (like Solar Flare but slower)
	# Expect at least 8 projectiles for radial burst
	if _projectiles_spawned.size() < 8:
		_fail("Frozen Nova should fire radial burst (8+ projectiles). Only %d found." % _projectiles_spawned.size())
		return

	print("Radial projectiles verified: %d (expected 8+)" % _projectiles_spawned.size())

	# Verify radial pattern: should have directions covering multiple quadrants
	var directions: Array[Vector2] = []
	var speeds: Array[float] = []

	for p in _projectiles_spawned:
		if is_instance_valid(p):
			directions.append(p.direction)
			speeds.append(p.speed)

	if directions.is_empty():
		_fail("Could not read projectile directions")
		return

	print("Directions found: %d" % directions.size())

	# Check radial pattern - should cover multiple quadrants (left, right, up, down)
	var has_left = false
	var has_right = false
	var has_up = false
	var has_down = false

	for dir in directions:
		if dir.x < -0.5:
			has_left = true
		if dir.x > 0.5:
			has_right = true
		if dir.y < -0.5:
			has_up = true
		if dir.y > 0.5:
			has_down = true

	print("Radial coverage - Left: %s, Right: %s, Up: %s, Down: %s" % [has_left, has_right, has_up, has_down])

	# Radial burst should cover at least 3 quadrants (preferably all 4)
	var quadrant_count = 0
	if has_left:
		quadrant_count += 1
	if has_right:
		quadrant_count += 1
	if has_up:
		quadrant_count += 1
	if has_down:
		quadrant_count += 1

	if quadrant_count < 3:
		_fail("Frozen Nova should expand in all directions. Only %d quadrants covered." % quadrant_count)
		return

	print("Radial expanding pattern verified")

	# Verify SLOW speed (400-500, not default 750)
	var avg_speed = 0.0
	for s in speeds:
		avg_speed += s
	avg_speed /= speeds.size()

	print("Average projectile speed: %f" % avg_speed)

	if avg_speed > 550:
		_fail("Frozen Nova projectiles should be SLOW (400-500). Got average speed: %f" % avg_speed)
		return

	if avg_speed < 350:
		_fail("Frozen Nova projectiles too slow (expected 400-500). Got average speed: %f" % avg_speed)
		return

	print("Slow speed verified: %f (expected 400-500)" % avg_speed)

	# Verify attack signal was emitted
	if _attack_fired_count == 0:
		_fail("attack_fired signal was not emitted")
		return

	# Verify delay/telegraph existed (wind-up duration was respected)
	# The attack should have taken at least wind_up_duration to fire
	var time_to_fire = _attack_fired_time - _wind_up_start_time
	print("Time from start to attack: %f seconds" % time_to_fire)

	# Should have taken at least 0.5 seconds (with some margin for test timing)
	if time_to_fire < 0.3:
		_fail("Frozen Nova should have delay/telegraph before firing. Fired too quickly: %f seconds" % time_to_fire)
		return

	print("Delay/telegraph verified: %f seconds before firing" % time_to_fire)

	_pass()


func _find_boss_projectiles() -> Array:
	var projectiles: Array = []
	_find_projectiles_recursive(self, projectiles)
	return projectiles


func _find_projectiles_recursive(node: Node, projectiles: Array) -> void:
	if node.get_script():
		var script_path = node.get_script().resource_path
		if "boss_projectile.gd" in script_path:
			projectiles.append(node)

	for child in node.get_children():
		_find_projectiles_recursive(child, projectiles)


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out waiting for Frozen Nova attack")
		return


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("Frozen Nova attack (index 6) works correctly:")
	print("- Fires radial burst (8+ projectiles) in all directions")
	print("- Projectiles use slow speed (400-500)")
	print("- Clear delay/telegraph before firing (kid-friendly)")
	print("- attack_fired signal emitted")
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
