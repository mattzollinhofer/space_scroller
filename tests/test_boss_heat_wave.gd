extends Node2D
## Integration test: Boss Heat Wave attack (attack index 4)
## Verifies the sweeping arc pattern fires continuous stream of fast projectiles.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 15.0
var _timer: float = 0.0

var _boss: Node = null
var _attack_fired_count: int = 0
var _projectile_spawn_times: Array[float] = []
var _initial_boss_y: float = 0.0
var _boss_moved: bool = false


func _ready() -> void:
	print("=== Test: Boss Heat Wave Attack (Index 4) ===")

	# Load boss scene directly for isolated testing
	var boss_scene = load("res://scenes/enemies/boss.tscn")
	if not boss_scene:
		_fail("Could not load boss scene")
		return

	_boss = boss_scene.instantiate()
	add_child(_boss)

	# Position boss for testing (in middle to allow sweep movement)
	_boss.position = Vector2(800, 700)
	_boss._battle_position = _boss.position
	_boss._entrance_complete = true
	_initial_boss_y = _boss.position.y

	# Configure boss with ONLY attack 4 (Heat Wave)
	var config = {
		"attacks": [4],
		"attack_cooldown": 0.5,
		"wind_up_duration": 0.3
	}
	_boss.configure(config)
	print("Boss configured with attack index 4 (Heat Wave)")

	# Connect to attack signal
	if _boss.has_signal("attack_fired"):
		_boss.attack_fired.connect(_on_attack_fired)

	# Start attack cycle
	_boss.start_attack_cycle()
	print("Attack cycle started, waiting for Heat Wave...")

	# Wait for attack to complete (sweep takes ~2 seconds)
	await get_tree().create_timer(3.0).timeout
	_verify_heat_wave()


func _on_attack_fired() -> void:
	_attack_fired_count += 1
	_projectile_spawn_times.append(_timer)
	print("Attack fired signal received (count: %d at time %.2f)" % [_attack_fired_count, _timer])


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Track if boss has moved significantly during attack
	if _boss and is_instance_valid(_boss):
		var y_diff = abs(_boss.position.y - _initial_boss_y)
		if y_diff > 100:
			_boss_moved = true

	if _timer >= _test_timeout:
		_fail("Test timed out waiting for Heat Wave attack")
		return


func _verify_heat_wave() -> void:
	if _test_passed or _test_failed:
		return

	# Find all boss projectiles in scene
	var projectiles = _find_boss_projectiles()
	print("Projectiles found: %d" % projectiles.size())

	if projectiles.is_empty():
		_fail("No projectiles spawned - Heat Wave attack not implemented")
		return

	# Verify continuous fire: multiple attack_fired signals should have been emitted
	if _attack_fired_count < 3:
		_fail("Heat Wave should fire continuously. Only %d attacks fired (expected 3+)" % _attack_fired_count)
		return

	print("Continuous fire verified: %d projectiles fired" % _attack_fired_count)

	# Verify sweeping movement: boss should have moved during attack
	if not _boss_moved:
		_fail("Heat Wave should involve boss movement (sweeping arc). Boss did not move.")
		return

	print("Sweeping arc verified: boss moved during attack")

	# Verify projectile speed (should be 900-1000, faster than default 750)
	var speeds: Array[float] = []
	for p in projectiles:
		if is_instance_valid(p):
			speeds.append(p.speed)

	if speeds.is_empty():
		_fail("Could not read projectile speeds")
		return

	var avg_speed = 0.0
	for s in speeds:
		avg_speed += s
	avg_speed /= speeds.size()

	print("Average projectile speed: %f" % avg_speed)

	if avg_speed < 850:
		_fail("Heat Wave projectiles should be faster (900-1000). Got average speed: %f" % avg_speed)
		return

	if avg_speed > 1100:
		_fail("Heat Wave projectiles too fast (expected 900-1000). Got average speed: %f" % avg_speed)
		return

	print("Speed verified: %f (expected 900-1000)" % avg_speed)

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


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("Heat Wave attack (index 4) works correctly:")
	print("- Boss moves in sweeping arc during attack")
	print("- Fires continuous stream of projectiles")
	print("- Projectiles use faster speed (900-1000)")
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
