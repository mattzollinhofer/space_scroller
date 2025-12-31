extends Node2D
## Integration test: Boss Ice Shards attack (attack index 5)
## Verifies the wide spread pattern fires many slow projectiles.
## Level 3 "cold/expansive" theme - numerous but slower.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 15.0
var _timer: float = 0.0

var _boss: Node = null
var _projectiles_spawned: Array = []
var _attack_fired_count: int = 0


func _ready() -> void:
	print("=== Test: Boss Ice Shards Attack (Index 5) ===")

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

	# Configure boss with ONLY attack 5 (Ice Shards)
	var config = {
		"attacks": [5],
		"attack_cooldown": 0.5,
		"wind_up_duration": 0.3
	}
	_boss.configure(config)
	print("Boss configured with attack index 5 (Ice Shards)")

	# Connect to attack signal
	if _boss.has_signal("attack_fired"):
		_boss.attack_fired.connect(_on_attack_fired)

	# Start attack cycle
	_boss.start_attack_cycle()
	print("Attack cycle started, waiting for Ice Shards...")

	# Wait for attack to fire
	await get_tree().create_timer(1.5).timeout
	_verify_ice_shards()


func _on_attack_fired() -> void:
	_attack_fired_count += 1
	print("Attack fired signal received (count: %d)" % _attack_fired_count)


func _verify_ice_shards() -> void:
	if _test_passed or _test_failed:
		return

	# Find all boss projectiles in scene
	_projectiles_spawned = _find_boss_projectiles()
	print("Projectiles found: %d" % _projectiles_spawned.size())

	if _projectiles_spawned.is_empty():
		_fail("No projectiles spawned - Ice Shards attack not implemented")
		return

	# Ice Shards should have MORE projectiles than standard barrage (5-7)
	# Expect at least 10 projectiles for "numerous" feel
	if _projectiles_spawned.size() < 10:
		_fail("Ice Shards should fire many projectiles (10+). Only %d found." % _projectiles_spawned.size())
		return

	print("Numerous projectiles verified: %d (expected 10+)" % _projectiles_spawned.size())

	# Verify wide spread pattern: should have directions spread across a wide arc
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

	# Check spread pattern - should primarily go left but with wide vertical spread
	var has_straight_left = false
	var has_up_left = false
	var has_down_left = false

	for dir in directions:
		# Primarily leftward projectiles
		if dir.x < -0.5:
			if dir.y < -0.3:
				has_up_left = true
			elif dir.y > 0.3:
				has_down_left = true
			else:
				has_straight_left = true

	print("Spread coverage - Straight left: %s, Up-left: %s, Down-left: %s" % [has_straight_left, has_up_left, has_down_left])

	# Wide spread should cover multiple angles
	var spread_count = 0
	if has_straight_left:
		spread_count += 1
	if has_up_left:
		spread_count += 1
	if has_down_left:
		spread_count += 1

	if spread_count < 2:
		_fail("Ice Shards should have wide spread. Only %d spread directions covered." % spread_count)
		return

	print("Wide spread pattern verified")

	# Verify SLOWER speed (400-500, not default 750)
	var avg_speed = 0.0
	for s in speeds:
		avg_speed += s
	avg_speed /= speeds.size()

	print("Average projectile speed: %f" % avg_speed)

	if avg_speed > 550:
		_fail("Ice Shards projectiles should be SLOWER (400-500). Got average speed: %f" % avg_speed)
		return

	if avg_speed < 350:
		_fail("Ice Shards projectiles too slow (expected 400-500). Got average speed: %f" % avg_speed)
		return

	print("Slow speed verified: %f (expected 400-500)" % avg_speed)

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
		_fail("Test timed out waiting for Ice Shards attack")
		return


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("Ice Shards attack (index 5) works correctly:")
	print("- Fires many projectiles (10+) for 'numerous' feel")
	print("- Wide spread pattern toward player")
	print("- Projectiles use slower speed (400-500)")
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
