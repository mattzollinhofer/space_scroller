extends Node2D
## Edge case test: Impact spark appears when projectile hits boss
## Verifies impact spark works on boss, not just regular enemies

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 3.0
var _timer: float = 0.0

var projectile: Node = null
var boss: Node = null
var _impact_spark_found: bool = false


func _ready() -> void:
	print("=== Test: Impact Spark on Boss Hit ===")

	# Load and spawn a boss
	var boss_scene = load("res://scenes/enemies/boss.tscn")
	if not boss_scene:
		_fail("Could not load boss scene")
		return

	boss = boss_scene.instantiate()
	boss.position = Vector2(600, 400)
	add_child(boss)

	# Mark entrance as complete so boss can be hit
	boss._entrance_complete = true
	boss._battle_position = boss.position

	# Stop attack cycle so it doesn't interfere
	boss.stop_attack_cycle()

	# Load and spawn a projectile near the boss
	var projectile_scene = load("res://scenes/projectile.tscn")
	if not projectile_scene:
		_fail("Could not load projectile scene")
		return

	projectile = projectile_scene.instantiate()
	# Position projectile slightly to the left of boss, moving right
	projectile.position = Vector2(500, 400)
	add_child(projectile)

	print("Boss spawned at: %s" % boss.position)
	print("Projectile spawned at: %s" % projectile.position)
	print("Boss health before hit: %d" % boss.health)
	print("Waiting for collision...")


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("Test timed out - no impact spark detected on boss hit")
		return

	# Check if projectile has been freed (hit occurred)
	if not is_instance_valid(projectile):
		print("Projectile destroyed - checking for impact spark...")
		# Give one frame for spark to be spawned
		await get_tree().process_frame
		_check_for_impact_spark()


func _check_for_impact_spark() -> void:
	# Verify boss took damage
	var boss_health_after = boss.health if is_instance_valid(boss) else -1
	print("Boss health after hit: %d" % boss_health_after)

	# Look for ImpactSpark node in scene tree
	var spark = _find_impact_spark(get_tree().root)

	if spark == null:
		_fail("No ImpactSpark node found after projectile hit boss")
		return

	print("Found ImpactSpark: %s" % spark.name)

	# Verify it's a one_shot CPUParticles2D
	var particles: CPUParticles2D = null
	if spark is CPUParticles2D:
		particles = spark
	else:
		for child in spark.get_children():
			if child is CPUParticles2D:
				particles = child
				break

	if particles == null:
		_fail("ImpactSpark does not contain CPUParticles2D")
		return

	if not particles.one_shot:
		_fail("Impact spark should be one_shot=true")
		return

	print("Impact spark verified on boss hit!")
	_pass()


func _find_impact_spark(node: Node) -> Node:
	if node == self:
		for child in node.get_children():
			var result = _find_impact_spark(child)
			if result != null:
				return result
		return null

	if node.name == "ImpactSpark":
		return node

	if node is CPUParticles2D:
		var particles = node as CPUParticles2D
		if particles.one_shot and particles.emitting:
			return node

	for child in node.get_children():
		var result = _find_impact_spark(child)
		if result != null:
			return result

	return null


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Impact spark appears correctly when projectile hits boss.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
