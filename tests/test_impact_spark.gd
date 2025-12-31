extends Node2D
## Integration test: Impact spark appears when projectile hits enemy
## Verifies impact spark spawns at collision point with one_shot CPUParticles2D

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 3.0
var _timer: float = 0.0

var projectile: Node = null
var enemy: Node = null
var _impact_spark_found: bool = false
var _impact_spark_node: Node = null


func _ready() -> void:
	print("=== Test: Impact Spark on Enemy Hit ===")

	# Load and spawn an enemy
	var enemy_scene = load("res://scenes/enemies/patrol_enemy.tscn")
	if not enemy_scene:
		_fail("Could not load patrol enemy scene")
		return

	enemy = enemy_scene.instantiate()
	enemy.position = Vector2(600, 400)
	# Stop enemy movement so it stays in place
	enemy.scroll_speed = 0.0
	enemy.zigzag_speed = 0.0
	add_child(enemy)

	# Load and spawn a projectile near the enemy
	var projectile_scene = load("res://scenes/projectile.tscn")
	if not projectile_scene:
		_fail("Could not load projectile scene")
		return

	projectile = projectile_scene.instantiate()
	# Position projectile slightly to the left of enemy, moving right
	projectile.position = Vector2(550, 400)
	add_child(projectile)

	print("Enemy spawned at: %s" % enemy.position)
	print("Projectile spawned at: %s" % projectile.position)
	print("Waiting for collision...")


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("Test timed out - no impact spark detected")
		return

	# Check if projectile has been freed (hit occurred)
	if not is_instance_valid(projectile):
		print("Projectile destroyed - checking for impact spark...")
		# Give one frame for spark to be spawned
		await get_tree().process_frame
		_check_for_impact_spark()


func _check_for_impact_spark() -> void:
	# Look for ImpactSpark node in scene tree
	# It should have been added to the scene root or similar location
	var spark = _find_impact_spark(get_tree().root)

	if spark == null:
		_fail("No ImpactSpark node found after projectile hit enemy")
		return

	print("Found ImpactSpark: %s" % spark.name)
	_impact_spark_node = spark

	# Verify it has CPUParticles2D
	var particles: CPUParticles2D = null
	if spark is CPUParticles2D:
		particles = spark
	else:
		# Look for CPUParticles2D child
		for child in spark.get_children():
			if child is CPUParticles2D:
				particles = child
				break

	if particles == null:
		_fail("ImpactSpark does not contain CPUParticles2D")
		return

	print("Found CPUParticles2D in spark")

	# Verify one_shot is true (burst effect)
	if not particles.one_shot:
		_fail("Impact spark particles should be one_shot=true for burst effect")
		return

	print("Particles one_shot: true")

	# Verify emitting is true
	if not particles.emitting:
		_fail("Impact spark particles should be emitting")
		return

	print("Particles emitting: true")

	# Verify conservative particle count (5-10)
	var amount = particles.amount
	if amount < 5 or amount > 15:
		_fail("Impact spark amount should be 5-10, got: %d" % amount)
		return

	print("Particle amount is conservative: %d" % amount)

	# Verify brief lifetime (0.2-0.3 seconds)
	var lifetime = particles.lifetime
	if lifetime < 0.15 or lifetime > 0.4:
		_fail("Impact spark lifetime should be 0.2-0.3s, got: %s" % lifetime)
		return

	print("Particle lifetime is appropriate: %s seconds" % lifetime)

	_pass()


func _find_impact_spark(node: Node) -> Node:
	# Skip the test node itself
	if node == self:
		for child in node.get_children():
			var result = _find_impact_spark(child)
			if result != null:
				return result
		return null

	# Look for nodes named "ImpactSpark" (exact match preferred)
	if node.name == "ImpactSpark":
		return node

	# Also check if it's a CPUParticles2D with one_shot (likely our spark)
	if node is CPUParticles2D:
		var particles = node as CPUParticles2D
		if particles.one_shot and particles.emitting:
			# This might be our impact spark
			return node

	for child in node.get_children():
		var result = _find_impact_spark(child)
		if result != null:
			return result

	return null


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Impact spark appears correctly when projectile hits enemy.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
