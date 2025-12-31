extends Node2D
## Integration test: Boss Solar Flare attack (attack index 3)
## Verifies the radial burst pattern fires projectiles in all directions with faster speed.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 15.0
var _timer: float = 0.0

var _boss: Node = null
var _projectiles_spawned: Array = []
var _attack_fired_count: int = 0


func _ready() -> void:
	print("=== Test: Boss Solar Flare Attack (Index 3) ===")

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

	# Configure boss with ONLY attack 3 (Solar Flare)
	var config = {
		"attacks": [3],
		"attack_cooldown": 0.5,
		"wind_up_duration": 0.3
	}
	_boss.configure(config)
	print("Boss configured with attack index 3 (Solar Flare)")

	# Connect to attack signal
	if _boss.has_signal("attack_fired"):
		_boss.attack_fired.connect(_on_attack_fired)

	# Start attack cycle
	_boss.start_attack_cycle()
	print("Attack cycle started, waiting for Solar Flare...")

	# Wait for attack to fire
	await get_tree().create_timer(1.5).timeout
	_verify_solar_flare()


func _on_attack_fired() -> void:
	_attack_fired_count += 1
	print("Attack fired signal received (count: %d)" % _attack_fired_count)


func _verify_solar_flare() -> void:
	if _test_passed or _test_failed:
		return

	# Find all boss projectiles in scene
	_projectiles_spawned = _find_boss_projectiles()
	print("Projectiles found: %d" % _projectiles_spawned.size())

	if _projectiles_spawned.is_empty():
		_fail("No projectiles spawned - Solar Flare attack not implemented")
		return

	# Verify radial pattern: projectiles should have varied directions
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

	# Check for radial spread (should have directions in multiple quadrants)
	var has_left = false
	var has_right = false
	var has_up = false
	var has_down = false

	for dir in directions:
		if dir.x < -0.3:
			has_left = true
		if dir.x > 0.3:
			has_right = true
		if dir.y < -0.3:
			has_up = true
		if dir.y > 0.3:
			has_down = true

	print("Direction coverage - Left: %s, Right: %s, Up: %s, Down: %s" % [has_left, has_right, has_up, has_down])

	# Radial burst should cover all directions (360 degrees)
	var quadrants_covered = 0
	if has_left:
		quadrants_covered += 1
	if has_right:
		quadrants_covered += 1
	if has_up:
		quadrants_covered += 1
	if has_down:
		quadrants_covered += 1

	if quadrants_covered < 3:
		_fail("Solar Flare should fire in all directions (360 degrees). Only %d quadrants covered." % quadrants_covered)
		return

	print("Radial pattern verified - projectiles spread in multiple directions")

	# Verify faster speed (should be 900-1000, not default 750)
	var avg_speed = 0.0
	for s in speeds:
		avg_speed += s
	avg_speed /= speeds.size()

	print("Average projectile speed: %f" % avg_speed)

	if avg_speed < 850:
		_fail("Solar Flare projectiles should be faster (900-1000). Got average speed: %f" % avg_speed)
		return

	if avg_speed > 1100:
		_fail("Solar Flare projectiles too fast (expected 900-1000). Got average speed: %f" % avg_speed)
		return

	print("Speed verified: %f (expected 900-1000)" % avg_speed)

	# Verify attack signal was emitted
	if _attack_fired_count == 0:
		_fail("attack_fired signal was not emitted")
		return

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
		_fail("Test timed out waiting for Solar Flare attack")
		return


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("Solar Flare attack (index 3) works correctly:")
	print("- Fires projectiles in radial pattern (360 degrees)")
	print("- Projectiles use faster speed (900-1000)")
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
